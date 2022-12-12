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

function M.get_color(group, attr)
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(group)), attr)
end

function M.eq_colors(expected_name, actual_cterm, msg)
    local expected = tonumber(uc.rgb2cterm(uc.color_name2rgb(expected_name)))
    local actual = tonumber(actual_cterm)
    assert.are.equal(expected, actual, msg)
end

---@class ComponentTable
---@field icon_hl string
---@field icon_color Color
---@field icon string
---@field hl string
---@field color Color
---@field value string

---@return ComponentTable
function M.match_rendered_component(rendered_component)
    local ptrn_hl = '%%#([%w_]+)#'
    local ptrn_value = '(.*)'
    local t = {}
    -- try to match component with icon
    _, t.icon_hl, t.icon, t.hl, t.value = string.match(
        rendered_component,
        ptrn_hl .. ptrn_hl .. ptrn_value .. ptrn_hl .. ptrn_value
    )
    if t.icon_hl then
        t.icon_color = { fg = M.get_color(t.icon_hl, 'fg#'), bg = M.get_color(t.icon_hl, 'bg#') }
    end
    -- or try to match without icon
    if not t.icon_hl then
        t.hl, t.value = string.match(rendered_component, ptrn_hl .. ptrn_value)
    end
    assert(t.hl, string.format('String [%s] was not matched', rendered_component))
    t.color = { fg = M.get_color(t.hl, 'fg#'), bg = M.get_color(t.hl, 'bg#') }
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
function M.extract_component(component, opts)
    local rendered_component = M.render_component(component, opts)
    return M.match_rendered_component(rendered_component)
end

return M
