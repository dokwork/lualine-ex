---@alias RGB string # RGB hex color description

---@alias HighlightGroup string # a name of the highlight group

---@alias StatuslineHighlight string # `%#<HighlightGroup>#`

---@class Color # Highlight definition map. See :help nvim_set_hl
---@field fg RGB
---@field bg RGB

---@class HighlightToken # any table identifier received from create_hl or create_component_highlight_group
---@field name HighlightGroup
---@field no_mode boolean
---@field section string
---@field options LualineComponentOptions
---@field no_default boolean

---@class DevIcon # An object which returns from the 'nvim-web-devicons' module.
---@field icon string
---@field color RGB
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
---@field super Object
---@field new fun(...)
---@field init fun(...)

---@alias Aligns
---| '"left"'
---| '"right"'

---@class LualineIcon
---@field align Aligns
---@field color Color

---@alias Icon string | LualineIcon

---@class LualineComponentPublicOptions
---@field icon Icon
---@field cond fun(): boolean
---@field fmt fun(status: string): string
---@field icons_enabled boolean
---@field color Color | fun(mode: string): Color

---@class LualineComponentPrivateOptions
---@field self table
---@field component_name string
---@field color_highlight HighlightToken
---@field icon_color_highlight HighlightToken
---@field __enabled_hl HighlightToken
---@field __enabled_icon_hl HighlightToken
---@field __disabled_hl HighlightToken

---@class LualineComponentOptions: LualineComponentPrivateOptions | LualineComponentPublicOptions

---@class LualineComponent: Object
---@field super Object
---@field self LualineComponent
---@field status string
---@field options LualineComponentOptions
---@field default_hl HighlightToken
---@field init fun(self: LualineComponent, options: LualineComponentOptions)
---@field create_option_highlights fun(self: LualineComponent)
---@field create_hl fun(self: LualineComponent, color: table|string|function, hint?: string): HighlightToken
---@field update_status fun(self: LualineComponent, is_focused: boolean?)
---@field draw fun(self: LualineComponent, default_highlight: string, is_focused: boolean): string
---@field apply_icon fun()
---@field apply_padding fun()
---@field apply_on_click fun()
---@field apply_highlights fun(default_highlight: HighlightToken)
---@field apply_section_separators fun()
---@field apply_separator fun()
