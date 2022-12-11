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
        neq(nil, Ex.default_options.disabled_color)
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
        it('should show icon even for empty component in disabled state', function()
            -- given:
            local Child = require('lualine.ex.component'):extend({
                icon = '!',
                is_enabled = false,
            })
            function Child:update_status()
                return ''
            end
            local cmp = Child(u.opts())

            -- when:
            local rendered_component = u.render_component(cmp)
            local ctbl = u.match_rendered_component(rendered_component)

            -- then:
            eq('!', ctbl.icon, 'Unexpected icon from rendered component: ' .. rendered_component)
        end)

        it('should not show icon for empty component if always_show_icon = false', function()
            -- given:
            local Child = require('lualine.ex.component'):extend({
                icon = '!',
                is_enabled = false,
                always_show_icon = false,
            })
            function Child:update_status()
                return ''
            end
            local cmp = Child(u.opts())

            -- when:
            local rendered_component = u.render_component(cmp)

            -- then:
            eq('', rendered_component)
        end)

        it('should use `disabled_color` if the component is not enabled', function()
            -- given:
            local Child = require('lualine.ex.component'):extend({
                is_enabled = false,
            })
            function Child:update_status()
                return 'status'
            end
            local cmp = Child(u.opts())

            -- when:
            local rendered_component = u.render_component(cmp)
            local ctbl = u.match_rendered_component(rendered_component)

            -- then:
            local expected_fg = tonumber(
                uc.rgb2cterm(uc.color_name2rgb(Child.default_options.disabled_color.fg))
            )
            eq(expected_fg, tonumber(ctbl.color.fg))
        end)
    end)
end)
