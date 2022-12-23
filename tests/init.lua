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
            { 'kyazdani42/nvim-web-devicons', opt = true },
            { 'nvim-lua/plenary.nvim' },
        },
    })
    -- used for testing ex.lsp component
    use({ 'jose-elias-alvarez/null-ls.nvim' })
end)

if packer_bootstrap then
    require('packer').sync()
    print('Please, restart nvim to use installed plugins.')
else
    -- Configuration for tests: --

    -- used for testing ex.spellcheck component
    vim.o.spell = true

    -- used for testing ex.lsp component
    local null_ls = require('null-ls')
    null_ls.setup({
        sources = {
            null_ls.builtins.formatting.stylua,
        },
    })

    -- setup statusline with ex components
    require('lualine').setup({
        options = {
            theme = 'material',
        },
        sections = {
            lualine_a = {
                { 'ex.cwd', padding = 0, separator = '' },
            },
            lualine_b = {
                { 'ex.relative_filename', padding = 0 },
            },
            lualine_c = { 'ex.git.branch' },
            lualine_y = {
                { 'ex.lsp', interactive_color = { fg = 'red' } },
                'ex.spellcheck',
            },
        },
    })
end
