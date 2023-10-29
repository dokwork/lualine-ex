# lualine-ex

[![lualine-ex ci](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml/badge.svg)](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml)

This is a [plugin](https://github.com/nvim-lualine/lualine.nvim/wiki/Plugins) 
for [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) 
with additional [components](#provided-components), and an extended class of the `lualine.component` with
[additional functionality](ExComponent.md).

## Installation

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
{
    'nvim-lualine/lualine.nvim',
    dependencies = { 
      { 'dokwork/lualine-ex' },
      { 'nvim-lua/plenary.nvim' },
      { 'kyazdani42/nvim-web-devicons', opt = true  },
    }
}
```

### [Packer](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'nvim-lualine/lualine.nvim',
    requires = { 
      { 'dokwork/lualine-ex' },
      { 'nvim-lua/plenary.nvim' },
      { 'kyazdani42/nvim-web-devicons', opt = true  },
    }
}
```

## Provided components

_Most of the components use icons from a [patched nerd font](https://www.nerdfonts.com/)._

### ex.spellcheck

`vim.o.spell=true`: &nbsp; <img src="https://github.com/dokwork/lualine-ex/assets/6939832/4064c0c6-42eb-41da-a471-0e4d8a7fc2a8" height=18>
`vim.o.spell=false`: &nbsp;  <img src="https://github.com/dokwork/lualine-ex/assets/6939832/0943ce1b-c5d9-4982-89f4-2ba26bf90e85" height=18>

The simple component shows an actual status of the `vim.wo.spell` option.

```lua
sections = {
  lualine_a = {
    {
      'ex.spellcheck',

      -- The color for the disabled component:
      disabled_color = { fg = 'grey' }

      -- The color for the icon of the disabled component:
      disabled_icon_color = { fg = 'grey' }

      -- The `true` means that the icon must be shown even in case when component is empty:
      always_show_icon = true
    }
  }
}
```

### ex.cwd

`pwd` = `/Users/dokwork/.local/share/nvim/lazy/lualine-ex`:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<img src="https://github.com/dokwork/lualine-ex/assets/6939832/3673df9d-b405-4a10-ad11-e9c46973120a" height=18 />


This component shows the last `depth` directories from the working path:

```lua
sections = {
  lualine_a = {
    {
      'ex.cwd',
      
      -- count of directories from the current working path:
      depth = 2,

      -- the prefix which should be used when {depth} less than directories at all:
      prefix = '…'
    }
  }
}
```

### ex.git.branch

| No git worktree | Worktree is commited | Worktree is changed |
| :---: | :---: | :---: |
| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/23b34d15-c711-49dc-a94b-0a27aab0d436" height=18 />| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/6e66a6f5-84ed-45a1-a03f-f5592c670ec1" height=18 />| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/0d3a41b1-6538-4d34-b890-c3b978f35c6d" height=18 />|

This component shows a name of the git branch for the current working directory. The color of this
component depends on the state of the git worktree. The component can show different states of the
git worktree:

  - `changed` means that at least one uncommitted change exists;
  - `commited` means that everything is committed, and no one tracked file is changed;
  - `disabled` means that the `cwd` is not under git control. 

```lua
sections = {
  lualine_a = {
    {
      'ex.git.branch',

      icon = ' ',

      -- The `git status` command is used to check the status of the worktree.
      -- By default, it's run in background for performance purpose, but it could lead to
      -- the wrong 'unknow' status at the first time. The `sync = true` can prevent it, 
      -- but it degrades startup time: 
      sync = false, 

      -- The colors for possible states:
      colors = {
          changed = { fg = 'orange' },
          commited = { fg = 'green' },
      },

      -- The color for the disabled component:
      disabled_color = { fg = 'grey' }

      -- The color for the icon of the disabled component:
      disabled_icon_color = { fg = 'grey' }

      -- The `true` means that the icon must be shown even in case when component is empty:
      always_show_icon = true
    }
  }
}
```


### ex.lsp.single

No one lsp client:&nbsp;<img src="https://github.com/dokwork/lualine-ex/assets/6939832/c1390d0e-29bc-4fba-be1d-15fd0954494d" height=18 />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`lua_ls` is active:&nbsp;<img src="https://github.com/dokwork/lualine-ex/assets/6939832/4c893fb5-6ac7-4145-9a3d-933cc4f00154" height=18 />

This component shows a name and appropriate icon of the first active lsp client for the current
buffer. 

An icon and a color are taken from the `icons` table or `nvim-wev-devicons` plugin (if it's installed). 
If no one icon was found for the lsp client neither in `icons`, nor in `nvim-wev-devicons`, the `unknown` icon 
will be used. For the case, when no one server is run, the component is in disabled state and has
the `lsp_is_off` icon.

An icon should be either string, or a table with following format: the `[1]` element must be a string with
icon's symbol; the optional element `color` should be one of: a name of a color, or a color in #RGB format, 
or a table with `fg` color. 

**NOTE:** the icon's property `color` with type of string for any of an icon from the `icons` has
different meaning comparing to usual `lualine` colors. It should be a name of a *color* **not** a
*highlight group*.

```lua
sections = {
  lualine_a = {
    {
      'ex.lsp.single',

      icons = {
        -- Default icon for any unknow server:
        unknown = '?', 

        -- Default icon for a case, when no one server is run:
        lsp_is_off = 'ﮤ',

        -- Example of the icon for a client, which doesn't have an icon in `nvim-web-devicons`:
        ['null-ls'] = { 'N', color = 'magenta' }
      }

      -- If true then the name of the client will be ommited, and only an icon used:
      icons_only = false,

      -- The color for the disabled component:
      disabled_color = { fg = 'grey' }

      -- The color for the icon of the disabled component:
      disabled_icon_color = { fg = 'grey' }
    }
  }
}
```

### ex.lsp.all

| No one lsp client | Only `lua_ls` is run and active | Both `lua_ls` and `vimls` are run, but only `vimls` is active |
| :---: | :---: | :---: |
| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/c1390d0e-29bc-4fba-be1d-15fd0954494d" height=18 />| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/4c893fb5-6ac7-4145-9a3d-933cc4f00154" height=18 />| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/02696971-bca1-4b7b-9d84-3898a693eeff" height=18 />|

[demo](https://asciinema.org/a/550273)

This component provides information about status of all run LSP servers. Every server has its own
color and icon, which can be taken from the option `icons` or plugin `nvim-wev-devicons` (if it's
installed). 

When some of already run servers is not active for the current buffer, it is in _disabled_ state.
The component in _disabled_ state has a color specified in the option `disabled_color`.

If no on lsp client is run, the component shows only `lsp_is_off` icon.

The `ex.lsp.all` component has the same options as the [ex.lsp.single](#exlspsingle) component, 
with additional option `only_attached`, which can be used to show only attached to the current buffer 
clients:

```lua
sections = {
  lualine_a = {
    {
      'ex.lsp.all',

      -- Extends options from the `ex.lsp.single`

      -- If true then only clients attached to the current buffer will be shown:
      only_attached = false,
    }
  }
}
```



