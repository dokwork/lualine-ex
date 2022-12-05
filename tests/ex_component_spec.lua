local u = require('tests.utils.lualine')
local ex = require('lualine.ex')
local eq = assert.are.equal

describe('Child of ex.component', function()
    it('should have passed default options as a property', function()
        -- given:
        local def_opts = { test = 'test' }
        -- when:
        local Ex = require('lualine.ex.component'):extend(def_opts)
        -- then:
        for key, orig in pairs(def_opts) do
            eq(orig, Ex.default_options[key])
        end
    end)

    describe('on initialization', function()
        it('should invoke `post_init` hook with init and default options', function()
            -- given:
            local def_opts = { test = 'test' }
            local Ex = require('lualine.ex.component'):extend(def_opts)
            local init_opts = u.opts()
            local passed_opts
            function Ex:post_init(opts)
                passed_opts = opts
            end
            -- when:
            Ex(init_opts)
            -- then:
            for key, orig in pairs(ex.merge(init_opts, def_opts)) do
                eq(orig, passed_opts[key])
            end
        end)
    end)
end)
