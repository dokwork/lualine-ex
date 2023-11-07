local l = require('tests.ex.lualine')

local mock = { o = {}, api = {} }
local eq = assert.are.equal

local component_name = 'ex.relative_filename'

describe('relative_filename component', function()
    local current_file
    local cwd

    before_each(function()
        mock.expand = vim.fn.expand
        vim.fn.expand = function(string, nosuf)
            if string == '%:p' then
                return current_file
            else
                return nil
            end
        end
        mock.getcwd = vim.fn.getcwd
        vim.fn.getcwd = function()
            return cwd
        end
        mock.o.laststatus = vim.o.laststatus
        mock.o.columns = vim.o.columns
        mock.api.nvim_win_get_width = vim.api.nvim_win_get_width
    end)

    after_each(function()
        vim.fn.expand = mock.expand
        vim.fn.getcwd = mock.getcwd
        vim.o.laststatus = mock.o.laststatus
        vim.o.columns = mock.o.columns
        vim.api.nvim_win_get_width = mock.api.nvim_win_get_width
    end)

    it('should contain only part after the cwd', function()
        current_file = '/a/b/c.txt'
        cwd = '/a/'
        l.test_matched_component(component_name, function(ct)
            eq('b/c.txt', ct.value)
        end)
    end)

    it('should contain absolute path with prefix', function()
        current_file = '/a/b/c.txt'
        cwd = '/d/'
        local opts = { external_prefix = '/...' }
        l.test_matched_component(component_name, opts, function(ct)
            eq(opts.external_prefix .. current_file, ct.value)
        end)
    end)

    it('external prefix is empty by default', function()
        current_file = '/a/b/c.txt'
        cwd = '/d/'
        l.test_matched_component(component_name, function(ct)
            eq(current_file, ct.value)
        end)
    end)

    it('should contain relate to the home path with ~ as a prefix', function()
        current_file = vim.loop.os_homedir() .. '/a/b/c.txt'
        cwd = '/d/'
        l.test_matched_component(component_name, opts, function(ct)
            eq('~/a/b/c.txt', ct.value)
        end)
    end)

    describe('shorten algorithm', function()
        cwd = '/'
        current_file = cwd .. 'abcde/xyz/test.txt'

        it("should shortify the path if it's longer than max_length", function()
            local expected_value = 'a/x/test.txt'
            local opts = { max_length = #expected_value }
            l.test_matched_component(component_name, opts, function(ct)
                eq(expected_value, ct.value)
            end)
        end)

        it('should always shorten the path when {max_length} is 0', function()
            local opts = { max_length = 0 }
            l.test_matched_component(component_name, opts, function(ct)
                eq('a/x/test.txt', ct.value)
            end)
        end)

        it('should never shorten the path when {max_length} less 0', function()
            local opts = { max_length = -1 }
            l.test_matched_component(component_name, opts, function(ct)
                eq('abcde/xyz/test.txt', ct.value)
            end)
        end)

        it(
            'if the {max_length} is a function then it should be invoked with the current path',
            function()
                local passed_arg
                local opts = {
                    max_length = function(path)
                        passed_arg = path
                        return 0
                    end,
                }
                l.test_matched_component(component_name, opts, function(ct)
                    eq('a/x/test.txt', ct.value)
                    eq('abcde/xyz/test.txt', passed_arg)
                end)
            end
        )

        it(
            'should contain only specified count of symbols in every directory of the path',
            function()
                local opts = { shorten = { length = 2 }, max_length = 0 }
                l.test_matched_component(component_name, opts, function(ct)
                    eq('ab/xy/test.txt', ct.value)
                end)
            end
        )

        it('should never shortify the file name', function()
            local opts = { shorten = { length = 1, exclude = { 1 } }, max_length = 0 }
            l.test_matched_component(component_name, opts, function(ct)
                eq('abcde/x/test.txt', ct.value)
            end)
        end)

        it('should decrease the {shorten.length} until it become enough', function()
            local opts = { shorten = { length = 3 }, max_length = #current_file - 5 }
            l.test_matched_component(component_name, opts, function(ct)
                eq('ab/xy/test.txt', ct.value)
            end)
        end)

        it('should ignore the {shorten.exclude} the {shorten.length} == 1 is not enough', function()
            local opts = { shorten = { exclude = { 1 } }, max_length = #current_file - 5 }
            l.test_matched_component(component_name, opts, function(ct)
                eq('a/x/test.txt', ct.value)
            end)
        end)

        it(
            "should return only file name with prefix if all other options didn't help achive the {max_length}",
            function()
                local opts = { filename_only_prefix = '.../', max_length = 1 }
                l.test_matched_component(component_name, opts, function(ct)
                    eq(opts.filename_only_prefix .. 'test.txt', ct.value)
                end)
            end
        )

        describe('when vim.o.laststatus == 3', function()
            vim.o.laststatus = 3
            vim.o.columns = #current_file * 10
            it(
                'should not shortify component if the full name less than max_length * vim.o.columns',
                function()
                    local opts = { max_length = 0.5 }
                    l.test_matched_component(component_name, opts, function(ct)
                        eq('abcde/xyz/test.txt', ct.value)
                    end)
                end
            )
            it(
                'should shortify component if the full name longer than max_length * vim.o.columns',
                function()
                    local expected_value = 'a/x/test.txt'
                    local opts = { max_length = #expected_value / vim.o.columns }
                    l.test_matched_component(component_name, opts, function(ct)
                        eq('a/x/test.txt', ct.value)
                    end)
                end
            )
        end)

        describe('when vim.o.laststatus is not 3', function()
            vim.o.laststatus = 2
            vim.o.columns = #current_file * 10
            it(
                'should shortify component if the full name longer than max_length * nvim_win_get_width(0)',
                function()
                    vim.api.nvim_win_get_width = function()
                        return #current_file * 2
                    end
                    local expected_value = 'a/x/test.txt'
                    local opts = { max_length = #expected_value / vim.api.nvim_win_get_width(0) }
                    l.test_matched_component(component_name, opts, function(ct)
                        eq(expected_value, ct.value)
                    end)
                end
            )
        end)
    end)
end)
