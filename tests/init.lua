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
        },
    })
end)

if packer_bootstrap then
    require('packer').sync()
    print('Please, restart nvim to use installed plugins.')
else
    -- Configuration for tests:
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
        },
    })
end
