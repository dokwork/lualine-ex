# lualine-ex

[![lualine-ex ci](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml/badge.svg)](https://github.com/dokwork/lualine-ex/actions/workflows/ci.yml)

This is a [plugin](https://github.com/nvim-lualine/lualine.nvim/wiki/Plugins) 
for `lualine.nvim` with additional components.

## 📒 <a name="contents:">Contents:</a>
 - [📥 Installation](#installation)
 - [🔧 New common component options](#new-common-component-options)
 - [🎬 Make a demo](#make-a-demo)
 - [🧩 Provided components](#provided-components)
    - [ex.spellcheck](#exspellcheck)
    - [ex.cwd](#excwd)
    - [ex.location](#exlocation)
    - [ex.progress](#exprogress)
    - [ex.relative_filename](#exrelative_filename)
    - [ex.git.branch](#exgitbranch)
    - [ex.lsp.single](#exlspsingle)
    - [ex.lsp.all](#exlspall)
    - [ex.lsp.none_ls](#exlspnone_ls)
 - [🛠️ Tools](#tools)

## 📥 <a name="installation">Installation</a>

This is not a plugin for neovim. This is a plugin for _plugin_ for neovim ㋡. 
So, it's reasonable to install it as dependency for `lualine.nvim`:

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
 _It may be reasonable to use particular tag to avoid breaking changes._

## 🔧 <a name="new-common-component-options">New common component options</a>

Every provided component has additional options:

```lua
{
    -- The function or boolean to check is the component enabled or not:
    is_enabled = true

    -- The color for the disabled component:
    disabled_color = { fg = 'grey' }

    -- The color for the icon of the disabled component:
    disabled_icon_color = { fg = 'grey' }

    -- The different default for the option:
    draw_empty = true
}
```

This plugin introduces a new `disabled` state. This state means that a component is not active, but
an icon still should be shown with `disabled` color. The difference between  `cond = false` and the
`is_enabled = false` is that in the first case a component will not be rendered at all, but in the
second case only the icon with `disabled_color` will be shown.

## 🎬 <a name="make-a-demo">Make a demo</a>

You may try every component from this repo in the separate nvim instance. To do
this run in terminal:

```sh
make demo component=<component name>
```

Where the `<component name>` is the same string as should be used in the
lualine configuration. For example: `ex.cwd`.

Also, it's possible to pass a custom component options to the demo:

```sh
make demo component=<component name> component_opts='<json object>'
```

The `<json object>` should correspond to the lua table with component options.
For example: 

```sh
make demo component=ex.cwd component_opts='{ "depth": 1 }'
```

<img src="https://github.com/dokwork/lualine-ex/assets/1548114/66317d8e-6ecd-4329-bfbb-6f355c642ed6" height=100 />

## 🧩 <a name="provided-components">Provided components</a>

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
      
      -- The count of directories from the current working path, if > 0 then parts will be taken from
      -- the end of the path, or from the start if {depth} < 0:
      depth = 2,

      -- The prefix which should be used when {depth} great than 0 and less than directories in the
      -- path:
      prefix = '…'

      -- The count of symbols in the `cwd` after which the reduction algorith will be applied:
      -- if it > 0 and < 1 then it will be calculated as {max_length} * {vim.o.columns} for 
      -- {laststatus} == 3; and {max_length} * {vim.api.nvim_win_get_width(0)} for {laststatus} ~= 3; 
      max_length = 0.2
    }
  }
}
```

**Reduction algorithm**

The absolute value of the {depth} will be decreased until the length of the path becomes less then
{max_length}.

### ex.location

This component shows the current cursor position in configurable format. Comparing to the default
`location` component, this component can show total number of lines, and may be flexibly configured.

| pattern | example |
|:---:|:---:|
| `'%2C:%-3L/%T'` | <img height=18 alt="ex location" src="https://github.com/dokwork/lualine-ex/assets/6939832/743ffc33-a5f4-4f95-9204-e217fa9cdbf7"> |
| `'%3L:%-2C'` | <img  height=18  alt="ex location-2" src="https://github.com/dokwork/lualine-ex/assets/6939832/2e9dfa90-7363-4a99-a8d1-c1cc9033d5f7"> |


```lua
sections = {
  lualine_a = {
    {
      'ex.location',
      
      -- The pattern to show the cursor position. Here three possible specifiers:
      --  'L' means 'line' - the number of the line where is the cursor now;
      --  'C' means 'column' - the number of the virtual column where is the cursor now;
      --  'T' means 'total' - the total count of lines in the current buffer;
      -- Every specifier can be used in similar maner to %d in the {string.format} function.
      -- The pattern similar to the default 'location' component is '%3L:%-2C'
      pattern = '%2C:%-3L/%T'
    }
  }
}
```

### ex.progress

This component shows the progress in the file. It has two pre-build modes: 'percent' and 'bar'. The first
one is similar to the default `progress` component, but in the second 'bar' mode the progress is
shown as a progress bar.

| mode | example |
|:---:|:---:|
| `'percent'` | <img height=18 alt="ex progress-percent" src="https://github.com/dokwork/lualine-ex/assets/6939832/fa2413c7-dd03-474f-8152-d9b8f4d026ef"> |
| `'bar'` | <img height=18 alt="ex progress-bar" src="https://github.com/dokwork/lualine-ex/assets/6939832/df29650a-3fa9-422b-940f-956079f3a8bb"> |

```lua
sections = {
  lualine_a = {
    {
      'ex.progress',
      
      -- How to show the progress. It may be the one of two string constants:
      -- 'percent' or 'bar'. In the 'percent' mode the progress is shown as percent of the file.
      -- In the 'bar' mode it's shown as the vertical bar. Also, it can be a table with symbols
      -- which will be taken to show according to the progress, or a function, which receive three
      -- arguments: the component itself, the cursor line and total lines count in the file.
      mode = 'percent',

      -- This string will be shown when the cursor is on the first line of the file. Set `false`
      -- to turn this logic off.
      top = 'Top',

      -- This string will be shown when the cursor is on the last line of the file. Set `false`
      -- to turn this logic off.
      bottom = 'Bot'
    }
  }
}
```

### ex.relative_filename

This component shows a `filename`: a file name and a path to the current file relative to the
current working directory. The `filename` has a prefix, which shows a file's place in the file
system relative to the `cwd`:

| File path relative to `cwd` | Options | Component example |
| :---: | :---: | ---: | 
| inside `cwd`                      | |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/af8ab32f-58f2-4f11-a2aa-6f519095c693" height=18 />|
| outside `cwd`                     | `external_prefix = "/..."` |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/7ada40a6-19c0-4811-ad59-ba3e08b40c44" height=18 />|
| outside `cwd`, but inside `$HOME` | |<img src = "https://github.com/dokwork/lualine-ex/assets/6939832/71a391aa-fb77-4f1a-88c8-76ed30b3907f" height=18 />|

Some path may be very long and takes significant part in the statusline. It's possible to specify the
{max_length} of the filename. To achieve that the follow algorithm is used:

- every part of the path is shortened till the {shorten.length} except parts from the {shorten.exclude}
  list;
- then the {shorten.length} will be repeatedly decreased until 1 or until the {max_length} will be 
  achieved;
- if it's not enough then the {exclude} setting will be ignored and all parts will be shortened;
- if the result is still longer than {max_length} than only the file name will be used with the prefix
  {filename_only_prefix}.

Example of the shortened filename with follow options `{ shorten: { length = 3, exclude = { 1 } } }`:

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
 - Every value less than 0 means that the filename never should be shortened;
 - Zero means that filename should be always shortened;
 - A value more or equal to 1 represents a length, after which the filename should be shortened;
 - A value between 0 and 1 represents a fraction of the current window width if the {laststatus} == 2, 
   or a fraction of the terminal width.

**Default configuration:**
```lua
{
    -- The prefix which is used when the current file is outside cwd
    external_prefix = nil,

    -- The prefix which is used when the length of the filename after shortening
    -- is longer than {max_length}
    filename_only_prefix = '…/',

    -- The max length of the component value. It may be a number or a function.
    -- If it's function, then it will be invoked with actual value, and should 
    -- return a number:
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
        -- The list of indexes of filename parts, which should not be shortened
        -- at all (the file name { -1 } is always excluded)
        exclude = nil 
    },
}
```

_`ex.relative_filename` component doesn't provide options to show file states,
because it is easily possible to do with standard approach:_

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

| No git worktree | Worktree is committed | Worktree is changed |
| :---: | :---: | :---: |
| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/23b34d15-c711-49dc-a94b-0a27aab0d436" height=18 />| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/6e66a6f5-84ed-45a1-a03f-f5592c670ec1" height=18 />| <img src="https://github.com/dokwork/lualine-ex/assets/6939832/0d3a41b1-6538-4d34-b890-c3b978f35c6d" height=18 />|

This component shows a name of a git branch for a current working directory. The color of this
component depends on the state of the git worktree. The component can show different states of the
git worktree:

  - `changed` means that at least one uncommitted change exists;
  - `committed` means that everything is committed, and no one tracked file is changed;
  - `disabled` means that the `cwd` is not under git control. 

**Default configuration:**
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
          committed = { fg = 'green' },
      },

      -- The color for the disabled component:
      disabled_color = { fg = 'grey' },

      -- The color for the icon of the disabled component:
      disabled_icon_color = { fg = 'grey' },

      -- It can be a function which receive an actual component value, and should return a number;
      -- or it can be a number:
      -- * any number >= 1 is max count of symbols in the branch name
      -- * a number between 0 and 1 means fraction of the {vim.o.columns}
      --   for {laststatus} == 3, and fraction of the {vim.api.nvim_win_get_width(0)}
      --   in other cases.
      -- When this option is defined, a component value will be cropped if it's longer then
      -- a value of this property.
      max_length = nil,

      -- Follow options actual only if {max_length} is defined:
      crop = {
        -- The string which will be used instead of cropped part.
        stub =  '…',

         -- The side from which a value should be cropped. It may be 'left' or 'right'.
         -- If not specified, result depends on the component section:
         --   'right' for a|b|c
         --   'left' for x|y|z
        side = nil 
      }

      -- The {ex.crop} function is default {fmt} implementation.
      fmt = ex.crop
    }
  }
}
```


### ex.lsp.single

No one lsp client:&nbsp;<img src="https://github.com/dokwork/lualine-ex/assets/6939832/c1390d0e-29bc-4fba-be1d-15fd0954494d" height=18 />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
`lua_ls` is active:&nbsp;<img src="https://github.com/dokwork/lualine-ex/assets/6939832/4c893fb5-6ac7-4145-9a3d-933cc4f00154" height=18 />

This component shows a name and appropriate icon of the first active lsp client for the current
buffer. 

An icon and a color are taken from the `icons` table or `nvim-web-devicons` plugin (if it's installed). 
If no one icon was found for the lsp client neither in `icons`, nor in `nvim-web-devicons`, the `unknown` icon 
will be used. For the case, when no one server is run, the component is in disabled state and has
the `lsp_is_off` icon.

An icon should be either a string or a table with following format: the `[1]` element must be a string with
icon's symbol; the optional element `color` should be one of: a name of a color, or a color in #RGB format, 
or a table with `fg` color. 

**NOTE:** the icon's property `color` with the type of string for any icon from the `icons` has
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
        lsp_is_off = '󰚦',

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
color and icon, which can be taken from the option `icons` or plugin `nvim-web-devicons` (if it's
installed). 

When some of already run servers is not active for the current buffer, it is in _disabled_ state.
The component in _disabled_ state has a color specified in the option `disabled_color`.

If no one lsp client is run, the component shows only `lsp_is_off` icon.

The `ex.lsp.all` component has the same options as the [ex.lsp.single](#exlspsingle) component, 
with few additional:

```lua
sections = {
  lualine_a = {
    {
      'ex.lsp.all',

      -- Extends options from the `ex.lsp.single`

      -- If true then only clients attached to the current buffer will be shown:
      only_attached = false,

      -- If true then every closed client will be echoed:
      notify_enabled = true
      
      -- The name of highlight group which should be used in echo:
      notify_hl = 'Comment'
    }
  }
}
```

You may double click by this component to stop all not used lsp clients. 
Also, you can use the function to close not used clients outside the component
(see [Tools > stop_unused_clients](Tools.md/#stop_unused_clients)), or change the `on_click` handler:

```lua
-- close on Ctrl+single click
on_click = function(clicks, button, modified)
    if modified == 'c' and clicks == 1 then
        require('lualine.ex.lsp').stop_unused_clients()
    end
end
```

### ex.lsp.none_ls

This component shows names of the
[null-ls](https://github.com/nvimtools/none-ls.nvim) sources according to the specified
[`query`](https://github.com/nvimtools/none-ls.nvim/blob/main/doc/SOURCES.md#get_sourcequery).
By default, it shows names of all sources actual to the current buffer. All
duplicated names are merged.

```lua
sections = {
  lualine_a = {
    {
      'ex.lsp.none_ls',

      -- The table or function that returns the table with the source query.
      -- By default it shows only actual sorces. To show all registered sources
      -- you can use just empty table:
      -- query = {}
      query = function()
        return { filetype = vim.bo.filetype }
      end,

      -- The string separator between names
      source_names_separator = ',',

      -- The color for the disabled component:
      disabled_color = { fg = 'grey' }

      -- The color for the icon of the disabled component:
      disabled_icon_color = { fg = 'grey' }
    }
  }
}
```

No one source:&nbsp;<img height="18" alt="null-ls-disabled" src="https://github.com/dokwork/lualine-ex/assets/6939832/04ce4a14-a3f9-4d90-a229-d19b78fa7c11">
The `jq` and the `spell` sources are active for the current buffer:<img height="18" alt="nulll-ls-enabled" src="https://github.com/dokwork/lualine-ex/assets/6939832/dda7dbb4-8647-49a2-8c28-8d29a617c2b9">



## 🛠️ <a name="tools">Tools</a>
This plugin provide additional tools to help you create your own components. Read more details here:
[Tools.md](Tools.md).
