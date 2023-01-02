local l = require('tests.ex.lualine')
local t = require('tests.ex.busted') -- :ignore_all_tests()
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
            same(opts.disabled_color.fg, ctbl.color.fg)
        end)

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
            ctbl = l.match_component(lsp)

            --then:
            eq(vim_lsp.name, ctbl.value, 'Wrong name in the rendered component: ' .. rc)
            eq(vim_icon.icon, ctbl.icon, 'Wrong icon in the rendered component: ' .. rc)
            eq(vim_icon.color, ctbl.color.fg, 'Wrong color in the rendered component: ' .. rc)
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

    it('should have `lsp_off` icon when disabled', function()
        vim.mock.lsp.get_active_clients.returns({})
        local opts = l.opts({ icons = { lsp_off = '-' } })
        local rc = l.render_component(component_name, opts)
        local ctbl = l.match_rendered_component(rc)
        eq(opts.icons.lsp_off, ctbl.icon, 'Wrong icon in the ' .. rc)
    end)

    it('should have the ex.lsp.single components for every client', function()
        -- given:
        local another_lua_lsp = vim.tbl_deep_extend('keep', { id = 3 }, lua_lsp)
        local clients = { lua_lsp, vim_lsp, another_lua_lsp }
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
end)
