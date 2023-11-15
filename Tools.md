# 🛠️ Tools

## Contents

 - [ExComponent](#excomponent)
 - [Helpful functions](#helpful-functions)
 - [Make a demo](#make-a-demo)

## ExComponent

**Note:** _this plugin is under develop, and API of the `lualine.ex.component`
can be changed._

The `lualine.ex.component` is an abstract class, which extends the
`lualine.component` and adds a few additional features.

Implementation of OOP ideas is taken from the
[classic](https://github.com/rxi/classic/blob/master/classic.lua) project.

 The best way to become familiar with `ex.component` is create your own
 component using it. As example, we will create a simple component to show the
 `vim.bo.spelllang` value.

### Creating a new component

To create your own `ex.component` you should extends the `lualine.ex.component`
inside `lua/components` directory of your plugin:

```lua
-- lua/components/spellcheck.lua
local Spell = require('lualine.ex.component'):extend()
```

The `lualine.ex.component` class inherits all options from the original lualine
class such as `icon`, `fmt`, `color`, `cond`, etc, plus adds a few new. You can
define default values for options on extending `lualine.ex.component`:

```lua
local Spell = require('lualine.ex.component'):extend({
    -- The icon of the component
    icon = '⅍',
})
```

All specified options will be available at the `<Your class>.default_options`
(`Spell.default_options` in the example above).

### Disabled state

The `ExComponent` has a new `disabled` state. This state means that a component
is not active, but the icon still should be shown with `disabled` color. The
difference between cases when the component property `cond = false` and the
`is_enabled = false` is that in the first case a component will not be rendered
at all, but in the second case only the icon with `disabled_color` will be
shown:

```lua
local Spell = require('lualine.ex.component'):extend({
    -- An icon for the component
    icon = '⅍',

    -- A function or boolean to check is the component enabled or not:
    is_enabled = function(component)
        return vim.wo.spell
    end
})
```

The `disabled_color` can be specified in the same manner as the `color` for the
component. The disabled color for the whole component and for the icon may be
specified separately.

```lua
local Spell = require('lualine.ex.component'):extend({
    -- An icon for the component
    icon = '⅍',

    -- The function to check is component enabled or not:
    is_enabled = function(component)
        return vim.wo.spell
    end

    -- The color for the disabled component:
    disabled_color = { fg = 'grey' }

    -- The color for the icon of the disabled component:
    disabled_icon_color = { fg = 'grey' }
})
```

### Provide component's value

To provide the value (or status in terms of the lualine) of the component, you
should override the `update_status` method:

```lua
local Spell = require('lualine.ex.component'):extend({
...
}
function Spell:update_status()
    return vim.o.spell and vim.bo.spelllang or ''
end
```

After that, you may use your component as all other default components from the
lualine:

```lua
sections = {
    lualine_a = {
        'spellcheck'
    }
}
```

### Render circle

TODO: Describe the sequence of methods invocation during render a component

#### Initialization hooks

TODO


## Helpful functions

The `lualine.ex` plugin provides a few functions, which can help you to define
your own components.

### `lsp.stop_unused_clients()`

```lua
require('lualine.ex.lsp').stop_unused_clients({opts})
```

Iterates over active lsp clients and stops every client without attached
buffers. This function is used as default `on_click` handler for the
`ex.lsp.all` component.

**Parameters:**

    * {opts} (table) optional additional options:
        * notify_enabled    (boolean) turns on notifications. The notifications 
                            are implemented as call the {echohl} function.
                            Default to `false`.
        * notify_hl         (string) the name of the highlight group which will 
                            be used to show notification. Default to 'Comment'.
                    

### `crop()`

```lua
require('lualine.ex').crop({str}, {cmp})
```

Crops the component when its length longer than {max_length} option (if it's
specified).

**Parameters:**

    * {str}           (string) the current value of the component.
    * {cmp}           (table) the component object with follow options:
        * max_length  (number) the maximum count of symbols in the component, 
                      after which the component will be cropped. If it's absent
                      or less or equal zero, the function returns `nil`. Default
                      to `nil`.
        * crop        (table) crop options:
            * stub    (string) a string which will be used instead of cropped
                      part. Default to '…'.
            * side    ('left' | 'right') a side from which a value will be
                      cropped. If absent, it will be calculated from the
                      component's section: for sections a,b,c a component value
                      will be cropped from the left; for sections x,y,z from the
                      right.

**Return:**

Original or cropped string.

### `max_length()`

```lua
require('lualine.ex').max_length({ln}, {str})
```

Resolves a {max_length} option of a component. The result depends on {ln}.

**Parameters:**

    * {ln}    (number) a count of symbols or fraction of the statusline width.
                 * if {ln} is a function, it will be invoked with {str} parameter,
                   and result will be used as describet below;
                 * if {ln} is a number > 0 and < 1, and {laststatus} == 3 then
                   this function calculates a fraction of the {vim.o.columns}:
                   `math.floor(ln * vim.o.columns)`;
                 * if {lng} is number > 0 and < 1, and {laststatus} ~= 3 then
                   this function calculates a fraction of the
                   {vim.api.nvim_win_get_width(0)}: 
                   `math.floor(ln * vim.api.nvim_win_get_width(0))`;
                 * all other numbers will be returned as is;
                 * if {ln} is not number then nil will be returned.
    * {str}   (string) an optional parameter which  will be passed to the {ln},
              if it's a function.

**Return:**

An integer number.

## Make a demo

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

![demo]()
