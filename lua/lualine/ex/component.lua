local ex = require('lualine.ex')

local log = require('plenary.log').new({ plugin = 'ex.component' })

---@class ExComponentOptions: LualineComponentOptions
---@field disabled_color Color
---@field disabled_icon_color Color
---@field is_enabled fun(component: ExComponent): boolean `true` means component enabled and must be shown. Disabled component has only icon with
---@field hls_cache? table

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
    cls.default_options = ex.merge(vim.deepcopy(default_options or {}), {
        disabled_color = { fg = 'grey' },
        disabled_icon_color = { fg = 'grey' },
        draw_empty = true,
    })
    return cls
end

---@private
function Ex:init(options)
    options = ex.merge(options, self.default_options)
    self.options = options
    self:pre_init()
    Ex.super.init(self, options)
    self:post_init()
end

---Initialization hook. It's run before {Ex.super.init}.
---@protected
function Ex:pre_init() end

---Initialization hook. It's run right after {Ex.super.init}.
---@protected
function Ex:post_init() end

---creates hl group from color option
---@private
function Ex:create_option_highlights()
    local function copy(t, options)
        if not t then
            return nil
        end
        local res = vim.tbl_extend('keep', t, {})
        res.options = options
        return res
    end
    local function get_higlights_from_cache()
        local cache = self.options.hls_cache
        if not cache then
            return false
        end
        local key = self.options.component_name
        log.fmt_debug('Getting highlights from the cache for the %s component', key)
        self.options.__enabled_hl = copy(cache[key], self.options)
        self.options.__enabled_icon_hl = copy(cache[key .. 'icon'], self.options)
        self.options.__disabled_hl = copy(cache[key .. 'disabled'], self.options)
        self.options.__disabled_icon_hl = copy(cache[key .. 'disabled_icon'], self.options)
        return self.options.__enabled_hl
            or self.options.__enabled_icon_hl
            or self.options.__disabled_hl
            or self.options.__disabled_icon_hl
    end
    local function put_higlights_to_cache()
        if not self.options.hls_cache then
            return
        end
        local key = self.options.component_name
        log.fmt_debug('Putting highlights to the cache for the %s component', key)
        self.options.hls_cache[key] = copy(self.options.__enabled_hl)
        self.options.hls_cache[key .. 'icon'] = copy(self.options.__enabled_icon_hl)
        self.options.hls_cache[key .. 'disabled'] = copy(self.options.__disabled_hl)
        self.options.hls_cache[key .. 'disabled_icon'] = copy(self.options.__disabled_icon_hl)
    end

    -- HACK: to avoid creating a new highlight for a similar component inside a parent,
    -- we should try to use the cache:
    if not get_higlights_from_cache() then
        Ex.super.create_option_highlights(self)
        self:create_option_disabled_highlights()
        put_higlights_to_cache()
    end
end

---@protected
function Ex:create_option_disabled_highlights()
    -- remember enabled highlights
    self.options.__enabled_hl = self.options.color_highlight
    self.options.__enabled_icon_hl = self.options.icon_color_highlight
    -- set disabled highlights
    self.options.__disabled_hl = self:create_hl(self.options.disabled_color, 'disabled')
    self.options.__disabled_icon_hl = self.options.disabled_icon_color
            and self:create_hl(self.options.disabled_icon_color, 'disabled_icon')
        or self.options.__disabled_hl
end

---@protected
---@final
function Ex:is_enabled()
    if type(self.options.is_enabled) == 'function' then
        return self.options.is_enabled(self)
    elseif type(self.options.is_enabled) == 'boolean' then
        return self.options.is_enabled
    else
        return true
    end
end

--- Disable component should have disabled color
---@private
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
---@final
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
    local show_icon = self.options.icons_enabled and (self:is_enabled() or self.options.draw_empty)

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
