-- Prepare runtimepath
vim.cmd([[set rtp=$VIMRUNTIME,$XDG_CONFIG_HOME]])
-- Add the path to this plugin to the runtimepath
vim.cmd('set rtp+=' .. vim.fn.expand('<sfile>:p:h:h'))

-- Turn on termguicolors for lualine
vim.opt.termguicolors = true

-- Configuration for tests: --
vim.cmd('colorscheme habamax')

-- used for testing ex.spellcheck component:
vim.o.spell = true

-- used for testing ex.lsp component:
local lspconfig = require('lspconfig')
lspconfig.lua_ls.setup({
    cmd = { 'lua-language-server' },
})
lspconfig.vimls.setup({
    cmd = { 'vim-language-server', '--stdio' },
})

-- choose ex component for demo:
local demo_component = vim.env.component or 'ex.cwd'

local function demo_component_name()
    return string.format("This is a demo of the '%s' component:", demo_component)
end

-- setup statusline with ex component:
require('lualine').setup({
    options = {
        theme = 'papercolor_dark',
    },
    sections = {
        lualine_z = { demo_component },
        lualine_b = {},
        lualine_c = { demo_component_name },
        lualine_x = {},
        lualine_y = {},
        lualine_a = { 'buffers' },
    },
})
