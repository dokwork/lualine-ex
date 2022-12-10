# lualine-ex

[![lualine-ex ci](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml/badge.svg)](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml)

This is a [plugin](https://github.com/nvim-lualine/lualine.nvim/wiki/Plugins) 
for the [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) 
with additional [components](#Components), and an extended class of the `lualine.component` with additional functionality.

## Installation

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'nvim-lualine/lualine.nvim',
    requires = { 
      { 'nvim-lua/plenary.nvim' },
      { 'dokwork/lualine-ex' },
      { 'kyazdani42/nvim-web-devicons', opt = true  },
    }
}
```

## Components

### ex.git.branch

This component provides a name of the git branch for the current working directory.
The color of this component depends on the state of the git worktree. The component
can show three different states:
  - `disabled` means that the current working directory is not under git control
  - `changed` means that at least one uncommitted change exists
  - `commited` means that everything is committed, and no one tracked file is changed.

```lua
sections = {
  lualine_a = {
    {
      'ex.git.branch',
      icon = ' ',
      -- `git status` command is used to check the status of the worktree.
      -- By default, it's run in background for performance purpose, but it could lead to
      -- wrong 'unknow' status at first time.
      async = true, 
      -- colors for possible states
      colors = {
          changed = { fg = 'orange' },
          commited = { fg = 'green' },
          disabled = { fg = 'grey' }
      },
      -- `true` means that icon must be shown even in case when no git repository
      always_show_icon = true
    }
  }
}
```

## ExComponent

`ExComponent` is an abstract class, which extends the `lualine.component` to provide additional
functionality:

 1. Use custom color for a component
 1. Show 'disabled' state of a component instead to completely hide it
