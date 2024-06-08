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
---@field fn_number number

---Gets a string with rendered component and match its properties.
---@param rendered_component string
---@param opts table inside information about component's options.
---@return ComponentTable # matched component.
function M.match_rendered_component(rendered_component, opts)
    local default_hl = opts and opts.hl or M.opts(opts).hl
    local is_right_icon = opts and opts.icon and opts.icon.align == 'right'
    local p_hl = '%%#([%w_]+)#'
    local p_icon = '(%S+)'
    local p_value = (opts and opts.draw_empty) and '(.*)' or '(.+)'
    local p_padding = '%s*'
    local p_fn = "%%%d+@v:lua.require'lualine.utils.fn_store'.call_fn@"
    local t = {}

    -- Extract 'on_click' part
    local from, to = rendered_component:find(p_fn)
    if from then
        t.fn_number = tonumber(string.match(rendered_component, '%%(%d+)@'))
        rendered_component = rendered_component:sub(1, from - 1)
            .. rendered_component:sub(to + 1, #rendered_component)
    end

    -- Try match the full pattern with both colors
    local _, hl1, value1, hl2, value2 = string.match(
        rendered_component,
        p_hl .. p_hl .. p_value .. p_hl .. p_padding .. p_value .. '$'
    )
    -- if the full pattern was matched
    if value2 then
        if is_right_icon then
            t.hl = hl1
            t.value = value1
            t.icon_hl = hl2
            t.icon = value2
        else
            t.icon_hl = hl1
            t.icon = value1
            t.hl = hl2
            t.value = value2
        end
        t.color = { fg = M.get_gui_color(t.hl, 'fg#'), bg = M.get_gui_color(t.hl, 'bg#') }
        t.icon_color = {
            fg = M.get_gui_color(t.icon_hl, 'fg#'),
            bg = M.get_gui_color(t.icon_hl, 'bg#'),
        }
        return t
    end

    -- Try to match the short pattern with icon color only
    if is_right_icon then
        t.value, t.icon_hl, t.icon =
            string.match(rendered_component, p_value .. p_padding .. p_hl .. p_icon .. '$')
        t.hl = default_hl
        t.icon_color = {
            fg = M.get_gui_color(t.icon_hl, 'fg#'),
            bg = M.get_gui_color(t.icon_hl, 'bg#'),
        }
    else
        t.icon_hl, t.icon, t.value =
            string.match(rendered_component, p_hl .. p_icon .. p_padding .. p_value)
        t.icon_color = {
            fg = M.get_gui_color(t.icon_hl, 'fg#'),
            bg = M.get_gui_color(t.icon_hl, 'bg#'),
        }
        t.hl = t.icon_hl
        t.color = t.icon_color
    end
    if t.icon_hl then
        return t
    end

    -- Try to match the pattern without colors
    if is_right_icon then
        t.value, t.icon = string.match(rendered_component, p_value .. p_icon)
    else
        t.icon, t.value = string.match(rendered_component, p_icon .. p_padding .. p_value .. '$')
    end

    if t.value and #t.value > 1 then
        return t
    end

    -- It looks like the whole component is a value
    t.value = rendered_component
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

--- Runs test with matched component.
function M.test_matched_component(component_name, optsOrTest, test)
    local opts = (type(optsOrTest) == 'table') and optsOrTest
    local test = (type(optsOrTest) == 'function') and optsOrTest or test
    local rc = M.render_component(component_name, opts)
    local ct = M.match_rendered_component(rc, opts)
    local ok, err = pcall(test, ct)
    if not ok then
        local msg = string.format(
            'Error with component [%s]: %s\n\nMatched component:\n%s',
            rc,
            err,
            vim.inspect(ct)
        )
        msg = opts and msg .. '\n\nComponent options:\n' .. vim.inspect(opts) or msg
        error(msg)
    end
end

return M
