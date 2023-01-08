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
      { 'dokwork/lualine-ex' },
      { 'nvim-lua/plenary.nvim' },
      { 'kyazdani42/nvim-web-devicons', opt = true  },
    }
}
```

## Components

### ex.lsp.single

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

### ex.git.branch

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

### ex.cwd

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

### ex.spellcheck

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


## ExComponent

**Note:** _this plugin is under develop, and API of the `lualine.ex.component` can be changed._

The `lualine.ex.component` is an abstract class, which extends the `lualine.component` to make it possible to
show an icon even for empty component in 'disabled' state. A state of the component depends on the result
of the `is_enabled` method:

```lua
-- You can specify default options for every child of your class
-- passing them to the method `extend`: 
local Spell = require('lualine.ex.component'):extend({
    icon = '暈'
})

function Spell:is_enabled()
    return vim.wo.spell
end

function Spell:update_status()
    if vim.wo.spell then
        return vim.bo.spelllang
    else
        return ''
    end
end

return Spell
```

The difference between cases when `cond = false` and `is_enabled = false` is that the first case
component will not be rendered at all, but in the second case only an icon with `disabled_color` 
will be shown. 

The `disabled_color` can be specified in the same manner as the `color` for the component.

### ExComponent options

Every child of the `lualine.ex.component` inherits the following options:

```lua
{
  -- The color for the disabled component:
  disabled_color = { fg = 'grey' }

  -- The color for the icon of the disabled component:
  disabled_icon_color = { fg = 'grey' }

  -- The `true` means that the icon must be shown even in case when component is empty:
  always_show_icon = true
}
```
