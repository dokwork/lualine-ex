-- Add the path to this plugin to the runtimepath
vim.cmd('set rtp+=' .. vim.fn.expand('<sfile>:p:h:h'))

-- Turn on termguicolors for feline
vim.opt.termguicolors = true

-- Download the packer
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system({
        'git',
        'clone',
        '--depth',
        '1',
        'https://github.com/wbthomason/packer.nvim',
        install_path,
    })
end

-- Turn on and setup packer
vim.cmd([[packadd packer.nvim]])
require('packer').startup(function(use)
    use('wbthomason/packer.nvim')
    use({
        'nvim-lualine/lualine.nvim',
        requires = {
            { 'kyazdani42/nvim-web-devicons' },
            { 'nvim-lua/plenary.nvim' },
        },
    })
    -- used for testing ex.lsp components
    use({ 'neovim/nvim-lspconfig' })
end)

if packer_bootstrap then
    require('packer').sync()
    print('Please, restart nvim to use installed plugins.')
else
    -- Configuration for tests: --
    vim.cmd('colorscheme habamax')

    -- used for testing ex.spellcheck component:
    vim.o.spell = true

    -- used for testing ex.lsp component:
    local lspconfig = require('lspconfig')
    lspconfig.sumneko_lua.setup({
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
end
