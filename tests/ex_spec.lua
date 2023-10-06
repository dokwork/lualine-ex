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
