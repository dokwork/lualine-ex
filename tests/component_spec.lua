local u = require('tests.ex.lualine')
local uc = require('lualine.utils.color_utils')
local ex = require('lualine.ex')
local eq = assert.are.equal
local neq = assert.are.not_equal

describe('A child of the ex.component', function()
    it('should have the passed default options as a property', function()
        -- given:
        local def_opts = { test = 'test' }
        -- when:
        local Ex = require('lualine.ex.component'):extend(def_opts)
        -- then:
        for key, orig in pairs(def_opts) do
            eq(orig, Ex.default_options[key])
        end
    end)

    it('should has a color for disabled state in the default options', function()
        -- when:
        local Ex = require('lualine.ex.component'):extend({})
        -- then:
        neq(nil, Ex.default_options.colors.disabled)
    end)

    describe('on initialization', function()
        it('should invoke `post_init` hook with init and default options', function()
            -- given:
            local def_opts = {}
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

    describe('on draw', function()
        it('should use `disabled` color if the component is not enabled', function()
            -- given:
            local Child = require('lualine.ex.component'):extend({})
            function Child:update_status()
                return 'status'
            end
            function Child:is_enabled()
                return false
            end
            local cmp = Child(u.opts())

            -- when:
            local rendered_component = u.render_component(cmp)
            local ctbl = u.match_rendered_component(rendered_component)

            -- then:
            local expected_fg = tonumber(
                uc.rgb2cterm(uc.color_name2rgb(Child.default_options.colors.disabled.fg))
            )
            eq(expected_fg, tonumber(ctbl.color.fg))
        end)

        it('should use custom color if the component is enabled', function()
            -- given:
            local colors = { test = { fg = 'red' } }
            local Child = require('lualine.ex.component'):extend({ colors = colors })
            function Child:custom_color()
                return 'test'
            end
            function Child:update_status()
                return 'status'
            end
            function Child:is_enabled()
                return true
            end
            local cmp = Child(u.opts())

            -- when:
            local rendered_component = u.render_component(cmp)
            local ctbl = u.match_rendered_component(rendered_component)

            -- then:
            local expected_fg = tonumber(uc.rgb2cterm(uc.color_name2rgb(colors.test.fg)))
            eq(expected_fg, tonumber(ctbl.color.fg))
        end)
    end)
end)
