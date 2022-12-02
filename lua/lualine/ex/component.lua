local ex = require('lualine.ex')

---@class ExComponentOptions: LualineComponentOptions
---@field always_show_icon boolean
---@field disabled_color Color
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
    cls.default_options = vim.tbl_deep_extend('force', {
        always_show_icon = true,
        disabled_color = { fg = 'grey' },
    }, default_options)
    return cls
end

function Ex:init(options)
    options = ex.deep_merge(options, self.default_options)
    Ex.super.init(self, options)
    self:setup(options)
end

---Initialization hook. Runs right after {Ex.super.init}.
---@param options table The {ExComponentOptions} merged with {default_options}.
function Ex:setup(options) end

---creates hl group from color option
function Ex:create_option_highlights()
    Ex.super.create_option_highlights(self)
    -- set disabled higlight
    if self.options.disabled_color then
        self.options.__disabled_color_highlight = self:create_hl(self.options.disabled_color)
    end
end

---`true` means component enabled and must be shown. Disabled component has only icon with
--- {options.disabled_color}. This method must be overrided.
function Ex:is_enabled()
    return false
end

function Ex:is_disabled()
    return not self:is_enabled()
end

--- Disable component should have disabled color
function Ex:__update_colors_if_disabled(is_focused)
    if self:is_disabled() or not is_focused then
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

    self.default_hl = default_highlight
    local status = self:update_status()
    if self.options.fmt then
        status = self.options.fmt(status or '')
    end
    -- we have two option to turn icon off:
    -- 1. turn all icons for components
    -- 2. turn off icon for disabled component only
    local show_icons = self.options.icons_enabled and self.options.always_show_icon

    if type(status) == 'string' and (#status > 0 or show_icons) then
        self.status = status
        self:__update_colors_if_disabled(is_focused)
        self:apply_icon()
        self:apply_padding()
        self:apply_on_click()
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
        self:apply_separator()
    end
    return self.status
end
