local ex = require('lualine.ex')

---@class ExComponentOptions: LualineComponentOptions
---@field is_enabled fun(): boolean
---@field always_show_icon boolean
---@field disabled_color Color
---@field disabled_color_highlight LualineHighlight

---@class ExComponent: LualineComponent The extension of the {LualineComponent}
--- which provide ability to mark the component as disabled and use custom icon and color
--- for disabled  state.
---
---@field super LualineComponent
---@field self ExComponent
---@field default_options table
---@field options ExComponentOptions
---@field setup fun()
local Ex = require('lualine.component'):extend()

function Ex:init(options)
    options = ex.deep_merge(options, self.default_options)
    Ex.super.init(self, options)
    self:setup(options)
end

function Ex:setup(options) end

---creates hl group from color option
function Ex:create_option_highlights()
    Ex.super.create_option_highlights(self)
    -- set disabled higlight
    if self.options.disabled_color then
        self.options.disabled_color_highlight = self:create_hl(self.options.disabled_color)
    end
end

function Ex:is_enabled()
    local is_disabled = self.options.is_enabled and not self.options.is_enabled()
    return not is_disabled
end

function Ex:update_colors_if_disabled(is_focused)
    if not self:is_enabled() or not is_focused then
        self.options.color_highlight = self.options.disabled_color_highlight
        self.options.icon_color_highlight = self.options.disabled_color_highlight
    end
end

function Ex:draw(default_highlight, is_focused)
    self.status = ''
    self.applied_separator = ''

    if self.options.cond ~= nil and self.options.cond() ~= true then
        return self.status
    end

    self.default_hl = default_highlight
    local status = self:update_status()
    if self.options.fmt then
        status = self.options.fmt(status or '')
    end
    local show_icons = self.options.icons_enabled and self.options.always_show_icon
    if type(status) == 'string' and (#status > 0 or show_icons) then
        self.status = status
        self:update_colors_if_disabled(is_focused)
        self:apply_icon()
        self:apply_padding()
        self:apply_on_click()
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
        self:apply_separator()
    end
    return self.status
end
