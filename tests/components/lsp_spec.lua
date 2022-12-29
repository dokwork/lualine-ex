local l = require('tests.ex.lualine')
local t = require('tests.ex.busted') --:ignore_all_tests()
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

        it('should not be changed if a parent was specified', function()
            -- given:
            local lsp = l.init_component(
                component_name,
                l.opts({ parent = 'some_component', client = vim_lsp })
            )
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
