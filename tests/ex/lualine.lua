local uc = require('lualine.utils.color_utils')

-- choose a default theme
require('lualine.highlight').create_highlight_groups(require('lualine.themes.gruvbox'))
-- mark the current window as actual to make all components active
vim.g.actual_curwin = vim.api.nvim_get_current_win()

local M = {}

function M.opts(opts)
    opts = opts or {}
    opts.hl = opts.hl or ''
    opts.padding = opts.padding or 0
    -- turn on icons by default:
    opts.icons_enabled = opts.icons_enabled == nil or opts.icons_enabled
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

--- Compares two colors. The first color can be presented as a name or #rrggbb,
--- or a table with `fg` and `bg` properties with same format.
--- The second color must be in #rrggbb format, or a table with `fg` and `bg` properties
--- strictly in #rrggbb format.
function M.eq_colors(expected, actual, msg)
    if type(expected) ~= type(actual) then
        error(
            string.format(
                'Expected and actual colors have different types: %s, %s',
                vim.inspect(expected),
                vim.inspect(actual)
            )
        )
    end
    if type(expected) == 'string' then
        local expected_rgb = expected:find('#') and expected or uc.color_name2rgb(expected)
        assert.are.equal(expected_rgb, actual, msg)
    end
    if type(expected) == 'table' then
        M.eq_colors(expected.fg, actual.fg)
        M.eq_colors(expected.bg, actual.bg)
    end
end

---@class ComponentTable
---@field icon_hl? string
---@field icon_color? Color
---@field icon? string
---@field hl? string
---@field color? Color
---@field value string

---Gets a string with rendered component and match its properties.
---@param rendered_component string
---@param opts table inside information about component's options.
---@return ComponentTable # matched component.
function M.match_rendered_component(rendered_component, opts)
    local is_right_icon = opts and opts.icon and opts.icon.align == 'right'
    local p_hl = '%%#([%w_]+)#'
    local p_icon = '(%S+)'
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
            value, icon = string.match(t.value, p_value .. p_padding .. p_icon)
        else
            icon, value = string.match(t.value, p_icon .. p_padding .. p_value)
        end
        t.icon = icon
        t.value = value or t.value
    end
    return t
end

--- Builds and draws the component.
---@param component string|table string should contain the name of the component;
---         the table should be result of the `init_component` method.
---@param opts table custom options for the drawn component.
---@return string
function M.render_component(component, opts)
    if type(component) == 'string' then
        component = M.init_component(component, opts)
    end
    local hl = opts and opts.hl or M.opts(opts).hl
    return component:draw(hl, true)
end

---Draws and matches the component. See {render_component} and {match_rendered_component}.
---@param component string | table
---@return ComponentTable
function M.match_component(component, opts)
    local rendered_component = M.render_component(component, opts)
    return M.match_rendered_component(rendered_component)
end

return M
