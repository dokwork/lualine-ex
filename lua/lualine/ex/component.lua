local ex = require('lualine.ex')

---@class ExComponentOptions: LualineComponentOptions
---@field always_show_icon boolean True means that icon should be shown even for inactive component.
---@field disabled_color Color
---@field colors table<string, Color>
---@field __hls table<string, LualineHighlight>
---@field __disabled_color_highlight LualineHighlight

---@class ExComponent: LualineComponent The extension of the {LualineComponent}
--- which provide ability to mark the component as disabled and use a custom icon
--- and color for disabled state.
---@field super LualineComponent
---@field self ExComponent
---@field default_options table
---@field options ExComponentOptions
local Ex = require('lualine.component'):extend()

function Ex:extend(default_options)
    local cls = self.super.extend(self)
    cls.default_options = ex.deep_merge(default_options, {
        always_show_icon = true,
        disabled_color = { fg = 'grey' },
    })
    return cls
end

function Ex:init(options)
    options = ex.deep_merge(options, self.default_options)
    options = self:pre_init(options)
    Ex.super.init(self, options)
    self:post_init(options)
end

---Initialization hook. Runs before {Ex.super.init}.
---@param options table The {ExComponentOptions} merged with {default_options}.
---@return table # Optionally patched options.
function Ex:pre_init(options)
    return options
end

---Initialization hook. Runs right after {Ex.super.init}.
---@param options table The {ExComponentOptions} merged with {default_options}.
function Ex:post_init(options) end

---creates hl group from color option
function Ex:create_option_highlights()
    Ex.super.create_option_highlights(self)
    -- set disabled higlight
    if self.options.disabled_color then
        self.options.__disabled_color_highlight = self:create_hl(
            self.options.disabled_color,
            'disabled'
        )
    end
    -- set custom highlights
    self.options.__hls = {}
    for name, color in pairs(self.options.colors or {}) do
        self.options.__hls[name] = self:create_hl(color, name)
        -- self.options.__hls[name].no_mode = true
    end
end

---@return string # The name of color from the {options.colors} which should be used for component.
function Ex:custom_color() end

---@return string # The name of color from the {options.colors} which should be used for icon.
function Ex:custom_icon_color() end

function Ex:__custom_hl()
    local custom_color = self:custom_color()
    return custom_color and self.options.__hls[custom_color]
end

function Ex:__custom_icon_hl()
    local custom_color = self:custom_icon_color() or self:custom_color()
    return custom_color and self.options.__hls[custom_color]
end

---`true` means component enabled and must be shown. Disabled component has only icon with
--- {options.disabled_color}. This method must be overrided.
function Ex:is_enabled()
    return false
end

--- Disable component should have disabled color
function Ex:__update_colors(is_focused)
    if not is_focused then
        return
    end
    if self:is_enabled() then
        self.options.color_highlight = self:__custom_hl()
        self.options.icon_color_highlight = self:__custom_icon_hl()
    else
        self.options.color_highlight = self.options.__disabled_color_highlight
        self.options.icon_color_highlight = self.options.__disabled_color_highlight
    end
end

---Overrided method to draw this component.
function Ex:draw(default_highlight, is_focused)
    self.status = ''
    self.applied_separator = ''

    -- if options.cond is not true, component should not be rendered at all.
    if self.options.cond ~= nil and self.options.cond() ~= true then
        return self.status
    end

    -- FIXME: maybe it would better to use "disabled" color here?
    self.default_hl = default_highlight
    local status = self:update_status()
    if self.options.fmt then
        status = self.options.fmt(status or '')
    end
    -- we have two option to turn icon off:
    -- 1. turn off all icons for components
    -- 2. turn off icon for disabled component only
    local show_icon = self.options.icons_enabled and self.options.always_show_icon

    if type(status) == 'string' and (#status > 0 or show_icon) then
        self.status = status
        self:__update_colors(is_focused)
        self:apply_icon()
        self:apply_padding()
        self:apply_on_click()
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
        self:apply_separator()
    end
    return self.status
end

return Ex
