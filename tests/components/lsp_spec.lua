local l = require('tests.ex.lualine')
local t = require('tests.ex.busted') --ignore_all_tests()
local mock = require('luassert.mock')
local devicons = require('nvim-web-devicons').get_icons()

local eq = assert.are.equal
local same = assert.are.same

local lua_lsp = {
    id = 1,
    name = 'sumneko_lua',
    config = {
        filetypes = { 'lua' },
    },
}

local vim_lsp = {
    id = 2,
    name = 'viml',
    config = {
        filetypes = { 'vim' },
    },
}

local lua_icon = devicons['lua']
local vim_icon = devicons['vim']

-- here we will have all mocked vim libs:
vim.mock = {}

local function get_all_highlights(rendered_component)
    local acc = {}
    for hl in string.gmatch(rendered_component, '%%#([%w_]+)#') do
        table.insert(acc, hl)
    end
    return acc
end

local function count(list, x)
    local i = 0
    for _, k in ipairs(list) do
        i = k == x and i + 1 or i
    end
    return i
end

describe('ex.lsp.single component', function()
    local component_name = 'ex.lsp.single'

    before_each(function()
        vim.mock.lsp = mock(vim.lsp, true)
    end)

    after_each(function()
        mock.revert(vim.mock.lsp)
    end)

    describe('on draw', function()
        it('should have a name, icon and a color of the client from the dev-icons', function()
            vim.mock.lsp.get_active_clients.returns({ lua_lsp })
            -- make the component enabled:
            vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })
            -- when:
            local rc = l.render_component(component_name)
            local ctbl = l.match_rendered_component(rc)
            -- then:
            eq(lua_lsp.name, ctbl.value, 'Wrong name in the rendered component: ' .. rc)
            eq(lua_icon.icon, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
            eq(lua_icon.color, ctbl.color.fg, 'Wrong color in the rendered component: ' .. rc)
        end)

        it('should have the disabled color when the client is not active', function()
            local opts = l.opts({ disabled_color = { fg = '#223421' } })
            vim.mock.lsp.get_active_clients.returns({ lua_lsp })
            -- make the component inactive:
            vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') + 1 })
            -- when:
            local rc = l.render_component(component_name, opts)
            local ctbl = l.match_rendered_component(rc)
            -- then:
            eq(opts.disabled_color.fg, ctbl.color.fg)
            eq(lua_lsp.name, ctbl.value, 'Wrong name in the rendered component: ' .. rc)
            eq(lua_icon.icon, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
        end)

        it(
            'should use `unknown` icon when nor `icon` nor devicons has appropriate icon for the current client',
            function()
                -- given:
                local unknown_lsp = {
                    id = 1,
                    name = 'unknown',
                }
                vim.mock.lsp.get_active_clients.returns({ unknown_lsp })
                vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })
                local opts = l.opts()
                -- when:
                local rc = l.render_component(component_name, opts)
                local ctbl = l.match_rendered_component(rc)
                -- then:
                eq(opts.icons.unknown, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
            end
        )

        it(
            'should use the `lsp_is_off` icon and the `disabled` color when no one lsp client is active',
            function()
                local opts = l.opts({
                    disabled_color = { fg = '#223421' },
                    icons = { lsp_is_off = '!' },
                })
                vim.mock.lsp.get_active_clients.returns({})
                vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })
                -- when:
                local rc = l.render_component(component_name, opts)
                local ctbl = l.match_rendered_component(rc)
                -- then:
                eq(opts.disabled_color.fg, ctbl.color.fg)
                eq('', ctbl.value, 'Wrong name in the rendered component: ' .. rc)
                eq(opts.icons.lsp_is_off, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
            end
        )

        it('should change the value, icon and color when the client was changed', function()
            -- given:
            local lsp = l.init_component(component_name)
            vim.mock.lsp.get_active_clients.returns({ lua_lsp })
            vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })

            local rc = l.render_component(lsp)
            local ctbl = l.match_component(lsp)
            eq(lua_lsp.name, ctbl.value, 'Wrong name in the rendered component: ' .. rc)
            eq(lua_icon.icon, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
            eq(lua_icon.color, ctbl.color.fg, 'Wrong color in the rendered component: ' .. rc)

            -- when:
            vim.mock.lsp.get_active_clients.returns({ vim_lsp })
            rc = l.render_component(lsp)
            ctbl = l.match_rendered_component(rc)

            --then:
            eq(vim_lsp.name, ctbl.value, 'Wrong name in the rendered component: ' .. rc)
            eq(vim_icon.icon, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
            eq(vim_icon.color, ctbl.color.fg, 'Wrong color in the rendered component: ' .. rc)
        end)

        it('should not create highlight for the different client with the same name', function()
            -- given:
            local another_lua_lsp = vim.tbl_deep_extend('keep', { id = 2 }, lua_lsp)
            vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })
            vim.mock.lsp.get_active_clients.returns({ lua_lsp })
            local lsp = l.init_component(component_name)
            local rc = l.render_component(lsp)
            local ctbl = l.match_rendered_component(rc)
            local hl = ctbl.hl
            -- when:
            vim.mock.lsp.get_active_clients.returns({ another_lua_lsp })
            rc = l.render_component(lsp)
            ctbl = l.match_rendered_component(rc)
            -- then:
            same(hl, ctbl.hl, 'Wrong highlight in ' .. rc)
        end)

        it('should not be changed if the client was specified in options', function()
            -- given:
            local lsp = l.init_component(component_name, l.opts({ client = vim_lsp }))
            vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })

            -- when:
            vim.mock.lsp.get_active_clients.returns({ lua_lsp })
            local rc = l.render_component(lsp)
            local ctbl = l.match_component(lsp)

            --then:
            eq(vim_lsp.name, ctbl.value, 'Wrong name in the rendered component: ' .. rc)
            eq(vim_icon.icon, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
            eq(vim_icon.color, ctbl.color.fg, 'Wrong color in the rendered component: ' .. rc)
        end)
    end)
end)

describe('ex.lsp.all component', function()
    local component_name = 'ex.lsp.all'

    before_each(function()
        vim.mock.lsp = mock(vim.lsp, true)
    end)

    after_each(function()
        mock.revert(vim.mock.lsp)
    end)

    it('should be disabled when no one client was found', function()
        vim.mock.lsp.get_active_clients.returns({})
        local all_lsp = l.init_component(component_name)
        eq(false, all_lsp:is_enabled())
    end)

    it('should be enabled when at least one client was found', function()
        vim.mock.lsp.get_active_clients.returns({ lua_lsp })
        local all_lsp = l.init_component(component_name)
        eq(true, all_lsp:is_enabled())
    end)

    it('should have `lsp_is_off` icon when disabled', function()
        vim.mock.lsp.get_active_clients.returns({})
        local opts = l.opts({ icons = { lsp_is_off = '-' } })
        local rc = l.render_component(component_name, opts)
        local ctbl = l.match_rendered_component(rc)
        eq(opts.icons.lsp_is_off, ctbl.icon, 'Wrong icon in the ' .. rc)
    end)

    it('should have the ex.lsp.single components for every client', function()
        -- given:
        local clients = { lua_lsp, vim_lsp }
        vim.mock.lsp.get_active_clients.returns(clients)
        -- when:
        local all_lsp = l.init_component(component_name)
        l.render_component(all_lsp)
        -- then:
        local clients_from_component = vim.tbl_values(vim.tbl_map(function(x)
            return x.client
        end, all_lsp.components))
        table.sort(clients_from_component, function(x, y)
            return x.id < y.id
        end)
        same(clients, clients_from_component)
    end)

    it('should remove components for stopped clients', function()
        -- given:
        local all_lsp = l.init_component(component_name)
        vim.mock.lsp.get_active_clients.returns({ lua_lsp, vim_lsp })
        l.render_component(all_lsp)
        eq(2, vim.tbl_count(all_lsp.components), 'Wrong init count of the components')
        -- when:
        vim.mock.lsp.get_active_clients.returns({ vim_lsp })
        l.render_component(all_lsp)
        -- then:
        eq(1, vim.tbl_count(all_lsp.components), 'Wrong components count after update')
        local _, component = next(all_lsp.components)
        same(vim_lsp, component.client)
    end)

    it('should use colors from the `icons` or devicons', function()
        -- given:
        local lua_color = lua_icon.color
        local vim_color = '#7cfc00'
        local all_lsp = l.init_component(
            component_name,
            { icons = { viml = { 'V', color = { fg = vim_color } } } }
        )
        vim.mock.lsp.get_active_clients.returns({ lua_lsp, vim_lsp })
        -- make all components enabled:
        vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })
        -- when:
        local rc = l.render_component(all_lsp)
        -- then:
        local hls = get_all_highlights(rc)
        assert(#hls > 2, 'Colors not enough in ' .. rc)
        for _, hl in ipairs(hls) do
            local fg = l.get_gui_color(hl, 'fg')
            assert(
                vim_color == fg or lua_color == fg,
                string.format('Unexpected fg color %s in %s of the component %s', fg, hl, rc)
            )
        end
    end)

    it('should reuse already existed highlight group', function()
        -- given:
        vim.mock.lsp.get_active_clients.returns({
            lua_lsp,
            vim.tbl_deep_extend('keep', { id = 3 }, lua_lsp),
        })
        vim.mock.lsp.get_buffers_by_client_id.returns({ vim.fn.bufnr('%') })
        -- when:
        local rc = l.render_component(component_name, { icons_enabled = false })
        -- then:
        local hls = get_all_highlights(rc)
        eq(#hls, count(hls, hls[1]), 'Not all highlights are equal in ' .. rc)
    end)
end)
