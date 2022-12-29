local uc = require('lualine.utils.color_utils')

-- choose default theme
require('lualine.highlight').create_highlight_groups(require('lualine.themes.gruvbox'))
-- mark current window as actual to make all components active
vim.g.actual_curwin = vim.api.nvim_get_current_win()

local M = {}

function M.opts(opts)
    opts = opts or {}
    opts.hl = opts.hl or ''
    opts.padding = opts.padding or 0
    opts.icons_enabled = opts.icons_enabled or true
    opts.theme = opts.theme or 'gruvbox'
    opts.self = opts.self or { section = 'c' }
    opts.component_separators = opts.component_separators
        or {
            left = '',
            right = '',
        }
    opts.section_separators = opts.section_separators
        or {
            left = '',
            right = '',
        }
    return opts
end

---@return LualineComponent
function M.init_component(component_name, opts)
    assert(component_name, 'Component must be specified. For example "ex.git.branch"')
    opts = M.opts(opts)
    return require('lualine.components.' .. component_name)(opts)
end

function M.get_gui_color(group, attr)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr, 'gui')
end

--- Compares two colors. The first color can be presented as a name or #rrggbb. The second
--- color must be in #rrggbb format.
function M.eq_colors(expected_color, actual_rgb, msg)
    local expected_rgb = expected_color:find('#') and expected_color
        or uc.color_name2rgb(expected_color)
    assert.are.equal(expected_rgb, actual_rgb, msg)
end

---@class ComponentTable
---@field icon_hl? string
---@field icon_color? Color
---@field icon? string
---@field hl? string
---@field color? Color
---@field value string

---@return ComponentTable
function M.match_rendered_component(rendered_component, opts)
    local is_right_icon = opts and opts.icon and opts.icon.align == 'right'
    local p_hl = '%%#([%w_]+)#'
    local p_value = '(.*)'
    local p_padding = '%s*'
    local t = {}
    -- try to match component with a special color for the icon
    if is_right_icon then
        t.hl, t.value, t.icon_hl, t.icon = string.match(
            rendered_component,
            p_hl .. p_hl .. p_value .. p_hl .. p_padding .. p_value .. p_padding
        )
    else
        _, t.icon_hl, t.icon, t.hl, t.value = string.match(
            rendered_component,
            p_hl .. p_hl .. p_value .. p_hl .. p_padding .. p_value .. p_padding
        )
    end
    if t.icon_hl then
        t.icon_color = {
            fg = M.get_gui_color(t.icon_hl, 'fg#'),
            bg = M.get_gui_color(t.icon_hl, 'bg#'),
        }
    end
    -- or try to match a component with one color
    if not t.icon_hl then
        t.hl, t.value = string.match(rendered_component, p_hl .. p_padding .. p_value)
    end
    if t.hl then
        t.color = { fg = M.get_gui_color(t.hl, 'fg#'), bg = M.get_gui_color(t.hl, 'bg#') }
    else
        -- the last option is a component without colors
        t.value = rendered_component
    end
    -- now, we can try to separate the icon and the value
    if not t.icon then
        local value, icon
        if is_right_icon then
            value, icon = string.match(t.value, '(.*) (.+)')
        else
            icon, value = string.match(t.value, '(.+) (.*)')
        end
        t.icon = icon
        t.value = value or t.value
    end
    return t
end

---@return string
function M.render_component(component, opts)
    if type(component) == 'string' then
        component = M.init_component(component, opts)
    end
    local hl = opts and opts.hl or M.opts(opts).hl
    return component:draw(hl, true)
end

---@return ComponentTable
function M.match_component(component, opts)
    local rendered_component = M.render_component(component, opts)
    return M.match_rendered_component(rendered_component)
end

return M
