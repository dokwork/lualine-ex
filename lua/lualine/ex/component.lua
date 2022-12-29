local ex = require('lualine.ex')

---@class ExComponentOptions: LualineComponentOptions
---@field always_show_icon boolean True means that icon should be shown even for inactive component.
---@field disabled_color Color
---@field disabled_icon_color Color
---@field is_enabled boolean | fun(): boolean
---@field __enabled_hl HighlightToken
---@field __enabled_icon_hl HighlightToken
---@field __disabled_hl HighlightToken
---@field __disabled_icon_hl HighlightToken

---@class ExComponent: LualineComponent The extension of the {LualineComponent}
--- which provide ability to mark the component as disabled and use a custom icon
--- and a color for disabled state.
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
        is_enabled = true,
    })
    return cls
end

function Ex:init(options)
    options = ex.deep_merge(options, self.default_options)
    self.options = options
    self:pre_init()
    Ex.super.init(self, options)
    self:post_init()
end

---Initialization hook. Runs before {Ex.super.init}.
---@param options table The {ExComponentOptions} merged with {default_options}.
---@return table # Optionally patched options.
function Ex:pre_init() end

---Initialization hook. Runs right after {Ex.super.init}.
---@param options table The {ExComponentOptions} merged with {default_options}.
function Ex:post_init() end

---creates hl group from color option
function Ex:create_option_highlights()
    Ex.super.create_option_highlights(self)
    -- remember enabled highlights
    self.options.__enabled_hl = self.options.color_highlight
    self.options.__enabled_icon_hl = self.options.icon_color_highlight
    -- set disabled highlights
    self.options.__disabled_hl = self:create_hl(self.options.disabled_color, 'disabled')
    self.options.__disabled_icon_hl = self.options.disabled_icon_color
            and self:create_hl(self.options.disabled_icon_color, 'disabled_icon')
        or self.options.__disabled_hl
end

---`true` means component enabled and must be shown. Disabled component has only icon with
--- {options.disabled_color}.
function Ex:is_enabled()
    if self.options.is_enabled and type(self.options.is_enabled) == 'function' then
        return self.options.is_enabled()
    end
    return self.options.is_enabled ~= nil and self.options.is_enabled
end

--- Disable component should have disabled color
function Ex:__update_colors_if_disabled()
    if self:is_enabled() then
        self.options.color_highlight = self.options.__enabled_hl
        self.options.icon_color_highlight = self.options.__enabled_icon_hl
    else
        self.options.color_highlight = self.options.__disabled_hl
        self.options.icon_color_highlight = self.options.__disabled_hl
    end
end

---Overridden method to draw this component.
function Ex:draw(default_highlight, is_focused)
    self.status = ''
    self.applied_separator = ''

    -- if options.cond is not true, component should not be rendered at all.
    if self.options.cond ~= nil and self.options.cond() ~= true then
        return self.status
    end

    self.default_hl = default_highlight
    local status = self:update_status(is_focused)
    if self.options.fmt then
        status = self.options.fmt(status or '')
    end
    -- we have two option to turn icon off:
    -- 1. turn off all icons for components
    -- 2. turn off icon for disabled component only
    local show_icon = self.options.icons_enabled
        and (self:is_enabled() or self.options.always_show_icon)

    if type(status) == 'string' and (#status > 0 or show_icon) then
        self.status = status
        self:__update_colors_if_disabled()
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
