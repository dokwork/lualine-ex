local l = require('tests.ex.lualine')

local mock = { o = {}, api = {} }
local eq = assert.are.equal

local component_name = 'ex.cwd'

describe('cwd component', function()
    local cwd

    before_each(function()
        mock.getcwd = vim.fn.getcwd
        vim.fn.getcwd = function(string, nosuf)
            return cwd
        end
        mock.o.laststatus = vim.o.laststatus
        mock.o.columns = vim.o.columns
        mock.api.nvim_win_get_width = vim.api.nvim_win_get_width
    end)

    after_each(function()
        vim.fn.getcwd = mock.getcwd
        vim.o.laststatus = mock.o.laststatus
        vim.o.columns = mock.o.columns
        vim.api.nvim_win_get_width = mock.api.nvim_win_get_width
    end)

    it('should do nothing when path less or equal to {depth}', function()
        cwd = '/a/b/c/'
        local opts = { depth = 3 }
        l.test_matched_component(component_name, opts, function(ct)
            eq(cwd, ct.value)
        end)
    end)

    it('should add the path separator to the end of the cwd', function()
        cwd = '/a/b/c'
        local opts = { depth = 3 }
        l.test_matched_component(component_name, opts, function(ct)
            eq(cwd .. '/', ct.value)
        end)
    end)

    it('should contain only {depth} parts of the cwd from the end', function()
        cwd = '/a/b/c/d/'
        local opts = { depth = 3 }
        l.test_matched_component(component_name, opts, function(ct)
            eq('…/b/c/d/', ct.value)
        end)
    end)

    it('should add the path separator to the end of the cropped cwd', function()
        cwd = '/a/b/c/d'
        local opts = { depth = 3 }
        l.test_matched_component(component_name, opts, function(ct)
            eq('…/b/c/d/', ct.value)
        end)
    end)

    it(
        'should contain only {depth} parts of the cwd from the start and do not use prefix',
        function()
            cwd = '/a/b/c/d/'
            local opts = { depth = -3 }
            l.test_matched_component(component_name, opts, function(ct)
                eq('/a/b/c/', ct.value)
            end)
        end
    )

    describe('shorten algorithm', function()
        it('should decrease the {depth} until the cwd less than {max_length}', function()
            cwd = '/abcd/efghi/jklmn/opqr/'
            local expected_value = '…/jklmn/opqr/'
            local opts = { max_length = #expected_value, depth = 3 }
            l.test_matched_component(component_name, opts, function(ct)
                eq(expected_value, ct.value)
            end)
        end)

        it('should be empty if the {max_length} is 0', function()
            cwd = '/abcd/efghi/jklmn/opqr/'
            local opts = { max_length = 1 }
            l.test_matched_component(component_name, opts, function(ct)
                eq('', ct.value)
            end)
        end)

        it('should count symbols, not bytes, to compare with max_length', function()
            -- this path has less symbols than bytes:
            cwd = '/абв/гд/'
            local opts = { max_length = 9 }
            l.test_matched_component(component_name, opts, function(ct)
                eq(cwd, ct.value)
            end)
        end)
    end)
end)
