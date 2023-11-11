local ex = require('lualine.ex')

local eq = assert.are.equal
local same = assert.are.same

describe('extend', function()
    it('should put all absent keys from b to a', function()
        local a = { a = 'a' }
        local b = { b = 'b' }

        same({ a = 'a', b = 'b' }, ex.extend(a, b))
    end)

    it('should not change original table', function()
        local a = { a = 'a' }
        local b = { b = 'b' }

        ex.extend(a, b)

        same({ a = 'a' }, a)
    end)

    it('should not override existed keys', function()
        local a = { a = 'a' }
        local b = { a = 'b' }

        same({ a = 'a' }, ex.extend(a, b))
    end)

    it('should copy numbered keys too', function()
        local a = { a = 'a' }
        local b = { 'b' }

        same({ 'b', a = 'a' }, ex.extend(a, b))
    end)

    it('should ignore nil as argument', function()
        local a = { a = 'a' }
        same({ a = 'a' }, ex.extend(a, nil))
        same({ a = 'a' }, ex.extend(nil, a))
    end)
end)

describe('merge', function()
    it('should put all absent keys from b to a', function()
        local a = { a = false }
        local b = { b = true }

        same({ c = { a = false, b = true } }, ex.merge({ c = a }, { c = b }))
    end)

    it('should not override existed keys', function()
        local a = { a = false }
        local b = { a = true }

        same({ c = { a = false } }, ex.merge({ c = a }, { c = b }))
    end)

    it('should put numbered keys too', function()
        local a = { a = 'a' }
        local b = { 'b' }

        same({ c = { 'b', a = 'a' } }, ex.merge({ c = a }, { c = b }))
    end)
end)

describe('max_length', function()
    local mock = { o = {}, api = {} }

    before_each(function()
        mock.o.laststatus = vim.o.laststatus
        mock.o.columns = vim.o.columns
        mock.api.nvim_win_get_width = vim.api.nvim_win_get_width
    end)

    after_each(function()
        vim.o.laststatus = mock.o.laststatus
        vim.o.columns = mock.o.columns
        vim.api.nvim_win_get_width = mock.api.nvim_win_get_width
    end)

    it('should run opts with value', function()
        local value = 'abcdfg'
        local opt = function(arg)
            return #arg
        end
        eq(#value, ex.max_length(opt, value))
    end)

    describe('when vim.o.laststatus is 3', function()
        vim.o.laststatus = 3
        it('should be calculated as a fraction of the terminal window', function()
            vim.o.columns = 100
            eq(50, ex.max_length(0.5))
        end)
    end)

    describe('when vim.o.laststatus is not 3', function()
        vim.o.laststatus = 2
        it('should be calculated as a fraction of the terminal window', function()
            vim.api.nvim_win_get_width = function(wn)
                return wn == 0 and 50 or nil
            end
            eq(25, ex.max_length(0.5))
        end)
    end)
end)
