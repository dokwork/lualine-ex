---@alias RGB string # RGB hex color description

---@alias Color string | RGB # a name of the color or RGB

---@alias HighlightGroup string # a name of the highlight group

---@alias StatuslineHighlight string # `%#<HighlightGroup>#`

---@class Highlight # highlight definition map. See :help nvim_set_hl
---@field fg Color
---@field bg Color

---@class LualineHighlight # any table identifier received from create_hl or create_component_highlight_group
---@field name HighlightGroup
---@field no_mode boolean
---@field section string
---@field options LualineComponentOptions
---@field no_default boolean

---@class DevIcon # An object which returns from the 'nvim-web-devicons' module.
---@field icon string
---@field color Color
---@field name string
---@field cterm_color string
---
---DevIcon example:
---```lua
---{
---   icon = "",
---   color = "#51a0cf",
---   cterm_color = "74",
---   name = "Lua",
---}
---```

---@class Object
---@field new fun(...)
---@field init fun(...)

---@alias Aligns
---| '"left"'
---| '"right"'

---@class LualineIcon
---@field align Aligns
---@field color { fg: Color }

---@alias Icon string | LualineIcon

---@class LualineComponentOptions
---@field self table
---@field component_name string
---@field color Color
---@field icon Icon
---@field cond fun(): boolean
---@field fmt fun(status: string): string
---@field icons_enabled boolean
---@field icon_color_highlight LualineHighlight table identifier received from create_hl or create_component_highlight_group

---@class LualineComponent: Object
---@field super Object
---@field self LualineComponent
---@field status string
---@field options LualineComponentOptions
---@field init fun(options: LualineComponentOptions)
---@field create_option_highlights fun()
---@field create_hl fun(color: table|string|function, hint?: string): table
---@field update_status fun(is_focused: boolean)
---@field apply_icon fun()
---@field apply_padding fun()
---@field apply_on_click fun()
---@field apply_higlights fun(default_highlight: LualineHighlight)
---@field apply_section_separators fun()
---@field apply_separator fun()
