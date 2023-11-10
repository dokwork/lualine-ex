# lualine-ex

[![lualine-ex ci](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml/badge.svg)](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml)

This is a [plugin](https://github.com/nvim-lualine/lualine.nvim/wiki/Plugins) 
for [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) 
with additional [components](#provided-components), and an extended class of the `lualine.component` with
additional functionality (see [ExComponent.md](ExComponent.md)).

## Installation

This is not a plugin for vim. So, it's reasonable to install it as dependency for `lualine.nvim`.

### [Lazy](https://github.com/folke/lazy.nvim)

```lua
{
    'nvim-lualine/lualine.nvim',
    dependencies = { 
      { 'dokwork/lualine-ex' },
      { 'nvim-lua/plenary.nvim' },
      { 'kyazdani42/nvim-web-devicons' },
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
      { 'kyazdani42/nvim-web-devicons' },
    }
}
```

## Provided components

_Most of the components use icons from a [patched nerd font](https://www.nerdfonts.com/) by default._

### ex.spellcheck

`vim.o.spell=true`: &nbsp; <img src="https://github.com/dokwork/lualine-ex/assets/6939832/4064c0c6-42eb-41da-a471-0e4d8a7fc2a8" height=18>
`vim.o.spell=false`: &nbsp;  <img src="https://github.com/dokwork/lualine-ex/assets/6939832/0943ce1b-c5d9-4982-89f4-2ba26bf90e85" height=18>

This simplest component shows an actual status of the `vim.wo.spell` option.

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

### ex.relative_filename

This component shows a `filename`: a file name and a path to the current file relative to the
current working directory, and may be used effectively together with [ex.cwd](#ex.cwd). The
`filename` has a prefix, which shows a file's place in the file system relative to the `cwd`:

| File path relative to `cwd` | Options | Component example |
| :---: | :---: | ---: | 
| inside `cwd`                      | |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/af8ab32f-58f2-4f11-a2aa-6f519095c693" height=18 />|
| outside `cwd`                     | `external_prefix = "/..."` |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/7ada40a6-19c0-4811-ad59-ba3e08b40c44" height=18 />|
| outside `cwd`, but inside `$HOME` | |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/71a391aa-fb77-4f1a-88c8-76ed30b3907f" height=18 />|

Some path may be very long and takes significant part in the statusline. It's possible to specify the
{max_length} of the filename. To achieve that the follow algorithm is used:

- every part of the path is shorten till the {shorten.length} except parts from the {shorten.exclude}
  list;
- then the {shorten.length} will be repeatedly decreased until 1 or until the {max_length} will be 
  achieved;
- if it's not enough then the {exclude} setting will be ignored and all parts will be shorten;
- if the result is still longer than {max_length} than only the file name will be used with the prefix
  {filename_only_prefix}.

Example of the shorten filename with follow options `{ shorten: { length = 3, exclude = { 1 } } }`:

| Space for component enough to show ...| Component example |
| :--- | ---: |
| the whole path |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/af8ab32f-58f2-4f11-a2aa-6f519095c693" height=18 />|
| the path with specified options (`shorten.length` = 3) |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/378bf6e2-0a22-41d2-86de-62dd13292c11" height=18 />|
| the path with `shorten.length` = 2 |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/61d10458-9dfc-401f-a0a1-2b14111f0e14" height=18 />|
| the path with `shorten.length` = 1 |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/2553d511-d3bf-42eb-a86e-5b154513d517" height=18 />|
| the path ignoring `exclude` section |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/8520b046-299d-4668-a08b-cba6f13c1a87" height=18 />|
| only the file name |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/f26b9d9d-417e-4984-a1cb-077dce4cfdfd" height=18 />|

The {max_length} may be a number, or a function which receives the current component value and
returns a number:
 - Every value less than 0 means that the filename never should be shorten;
 - Zero means that filename should be always shorten;
 - A value more or equal to 1 represents a length, after which the filename should be shorten;
 - A value between 0 and 1 represents a fraction of the current window width if the {laststatus} == 2, 
   or a fraction of the terminal width.

**Default configuration:**
```lua
{
    -- The prefix which is used when the current file is outside cwd
    external_prefix = nil,

    -- The prefix which is used when the length of the filename after shorten
    -- is longer than {max_length}
    filename_only_prefix = '…/',

    -- The max length of the component value.
    -- < 0          - never shorten; 
    -- 0            - always shorten; 
    -- > 0 and  < 1 - shorten when longer than {max_length} * {vim.o.columns} 
    --                for {laststatus} == 3;
    --                and shorten when longer than 
    --                {max_length} * {vim.api.nvim_win_get_width(0)} overwise; 
    -- >= 1         - shorten when longer then N symbols;
    max_length = 0.3,

    -- The configuration of the shorten algorithm.
    shorten = { 
        -- The count of letters, which will be taken from every part of the path
        lenght = 5, 
        -- The list of indexes of filename parts, which should not be shorten at all
        -- (the file name { -1 } is always excluded)
        exclude = nil 
    },
}
```

_`ex.relative_filename` component doesn't provide options to show file states, because it easily
possible to do with standard approach:_

```lua
-- readonly mode indicator example:
{
    '%{""}',
    draw_empty = true,
    icon = { '' },
    cond = function()
        return not vim.bo.modifiable
    end,
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
