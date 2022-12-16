local ex = require('lualine.ex')

local eq = assert.are.equal
local same = assert.are.same

describe('merge', function()
    it('should put all absent keys from b to a', function()
        local a = { a = 'a' }
        local b = { b = 'b' }

        same({ a = 'a', b = 'b' }, ex.merge(a, b))
    end)

    it('should not override existed keys', function()
        local a = { a = 'a' }
        local b = { a = 'b' }

        same({ a = 'a' }, ex.merge(a, b))
    end)

    it('should copy numbered keys too', function()
        local a = { a = 'a' }
        local b = { 'b' }

        same({ 'b', a = 'a' }, ex.merge(a, b))
    end)

    it('should ignore nil as argument', function()
        local a = { a = 'a' }
        same({ a = 'a' }, ex.merge(a, nil))
        same({ a = 'a' }, ex.merge(nil, a))
    end)
end)

describe('deep_merge', function()
    it('should put all absent keys from b to a', function()
        local a = { a = 'a' }
        local b = { b = 'b' }

        same({ c = { a = 'a', b = 'b' } }, ex.deep_merge({ c = a }, { c = b }))
    end)

    it('should not override existed keys', function()
        local a = { a = 'a' }
        local b = { a = 'b' }

        same({ c = { a = 'a' } }, ex.deep_merge({ c = a }, { c = b }))
    end)

    it('should copy numbered keys too', function()
        local a = { a = 'a' }
        local b = { 'b' }

        same({ c = { 'b', a = 'a' } }, ex.deep_merge({ c = a }, { c = b }))
    end)

    it('should replace nil by an empty table for any argument', function()
        local a = { a = 'a' }
        same({ a = 'a' }, ex.deep_merge(a, nil))
        same({ a = 'a' }, ex.deep_merge(nil, a))
    end)

    it('should work as deep copy when passed only the first argument', function()
        local t = { a = { b = { c = 1 } } }
        local r = ex.deep_merge(t)
        t.a.b.c = 2
        same({ a = { b = { c = 1 } } }, r)
    end)

    it('should return the first argument if the second is not a table', function()
        same({ a = 1 }, ex.deep_merge({ a = 1 }, 2))
    end)

    it('should return the first argument if it is not a table', function()
        eq(2, ex.deep_merge(2, { a = 1 }))
    end)
end)
