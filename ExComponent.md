# ExComponent

**Note:** _this plugin is under develop, and API of the `lualine.ex.component`
can be changed._

The `lualine.ex.component` is an abstract class, which extends the
`lualine.component` and adds few additional features.

Implementation of OOP ideas is taken from the
[classic](https://github.com/rxi/classic/blob/master/classic.lua) project.

### Create your own component

To create your own ex component you should extends the `lualine.ex.component`:

```lua
local Spell = require('lualine.ex.component'):extend()
```

The `lualine.ex.component` class inherits all options from the original lualine class such as `icon`,
`fmt`, `color`, `cond`, etc, plus adds few new. You can define default values for options on extending 
`lualine.ex.component`:

```lua
local Spell = require('lualine.ex.component'):extend({
    -- An icon for the component
    icon = '⅍',
})
```

All specified options will be available at the `<Your class>.default_options`
(`Spell.default_options` in the example above).

### Disabled state

The `ExComponent` has the 'disabled' state. This state means that a component
is not active, but an icon still should be shown with 'disabled' color. The
difference between cases when the component property `cond = false` and the
`is_enabled = false` is that in the first case a component will not be rendered
at all, but in the second case only the icon with `disabled_color` will be
shown:

```lua
local Spell = require('lualine.ex.component'):extend({
    -- An icon for the component
    icon = '⅍',

    -- The function to check is component enabled or not:
    is_enabled = function(component)
        return vim.wo.spell
    end
})
```

The `disabled_color` can be specified in the same manner as the `color` for the
component. The disabled color for whole component and for icon may be specified
separately.

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

    -- The `true` means that the icon must be shown
    -- even if the component is empty:
    always_show_icon = true
})
```

By default, `lualine` doesn't show an icon if a component is empty, but it
may be not very useful for disabled components. To show the icon in any cases
set the property `always_show_icon` to `true`.

### Render circle

TODO: Describe the sequence of methods invocation during render a component

#### Initialization hooks

TODO


