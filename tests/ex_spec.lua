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

describe('crop', function()
    it('should return passed string if max_length is not specified', function()
        local component = { options = {} }
        local str = 'example'
        eq(str, ex.crop(str, component))
    end)

    it('should crop the string from the right side', function()
        local component = { options = { crop = { side = 'right' }, max_length = 5 } }
        local str = 'example'
        eq('exam…', ex.crop(str, component))
    end)

    it('should crop the string from the left side', function()
        local component = { options = { crop = { side = 'left' }, max_length = 5 } }
        local str = 'example'
        eq('…mple', ex.crop(str, component))
    end)

    it(
        'should crop the string from the left side when the component s in sections a,b,c',
        function()
            for _, section in ipairs({ 'a', 'b', 'c' }) do
                local component = { options = { max_length = 5, self = { section = section } } }
                local str = 'example'
                eq('…mple', ex.crop(str, component))
            end
        end
    )

    it(
        'should crop the string from the right side when the component is in sections x,y,z',
        function()
            for _, section in ipairs({ 'x', 'y', 'z' }) do
                local component = { options = { max_length = 5, self = { section = section } } }
                local str = 'example'
                eq('exam…', ex.crop(str, component))
            end
        end
    )

    it('should replace an extra part by the stub', function()
        local component = { options = { crop = { side = 'left', stub = '---' }, max_length = 5 } }
        local str = 'example'
        eq('---le', ex.crop(str, component))
    end)

    it('should ignore side in case of wrong value', function()
        local component = {
            options = {
                crop = { side = 'wrong value', stub = '!' },
                max_length = 5,
                self = { section = 'a' },
            },
        }
        local str = 'example'
        eq('!mple', ex.crop(str, component))
    end)
end)
