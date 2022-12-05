require('lualine.highlight').create_highlight_groups(require('lualine.themes.gruvbox'))

local M = {}

function M.opts(opts)
    opts = opts or {}
    opts.hl = opts.hl or ''
    opts.icons_enabled = opts.icons_enabled or true
    opts.theme = opts.theme or 'gruvbox'
    opts.self = opts.self or { section = 'c' }
    opts.component_separators = opts.component_separators or {
        left = '',
        right = ''
    }
    opts.section_separators = opts.section_separators or {
        left = '',
        right = ''
    }
    return opts
end

return M
