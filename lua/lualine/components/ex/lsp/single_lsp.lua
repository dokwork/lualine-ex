---@class LspClient object which returns from the `vim.lsp.client()`.
---@field id number The id allocated to the client.
---@field name string If a name is specified on creation, that will be used. Otherwise it is just the client id. This is used for logs and messages.

---Takes a type of the file from the {client} and tries to take a corresponding icon
---from the {icons} or 'nvim-web-devicons'.
---DevIcon example:
---```lua
---{
---   icon = "",
---   color = "#51a0cf",
---   cterm_color = "74",
---   name = "Lua",
---}
---```
---@see require('nvim-web-devicons').get_icons
---
---@param client LspClient the client to the LSP server.
---@param icons table<string, LspIcon> # a table with icons for the lsp clients.
---
---@return LualineIcon # an icon of the LspClient or `nil` when the `client` is absent or icon not found.
local function lsp_client_icon(client, icons)
    -- get an appropriated icon
    local dev_icon = icons[client.name]
    if not dev_icon then
        for _, ft in ipairs(client.config.filetypes) do
            if icons[ft] then
                dev_icon = icons[ft]
                break
            end
        end
    end
    if type(dev_icon) == 'table' then
        local icon = { dev_icon.icon or dev_icon[1] }
        icon.color = dev_icon.color
        return icon
    elseif type(dev_icon) == 'string' then
        return { dev_icon }
    else
        return icons.unknown or { '?' }
    end
end

local function is_lsp_client_ready(client)
    -- TODO: add support of the metals
    return true
end

local function is_lsp_client_active(client)
    if not client then
        return false
    end
    local buffers = vim.lsp.get_buffers_by_client_id(client.id)
    local is_active = (vim.tbl_contains(buffers, vim.fn.bufnr('%')))
    return is_active and is_lsp_client_ready(client)
end

---@class SingleLsp: LualineComponent
---@field super LualineComponent
---@field new fun(options: LspInitOptions): SingleLsp
---@field init fun(options: LspInitOptions)
---@field update_status fun(is_focused: boolean): string
local Lsp = require('lualine.component'):extend()

---@class LspInitOptions: LualineComponentOptions
---@field client LspClient
---@field self { section: string }
---@field icon LualineIcon
---@field icons LspIcons
---@field icons_enabled boolean
---@field icons_only boolean
---@field inactive_color_highlight HighlightGroup
---@field default_highlight_group HighlightGroup

---@param options LspInitOptions
function Lsp:init(options)
    self.options = options
    if not self.options.client then
        self.options.client = next(vim.lsp.get_active_clients({ bufnr = 0 }))
    end
    self.options.component_name = 'lsp_' .. options.client.name .. options.client.id
    self.options.icon = lsp_client_icon(options.client, options.icons)
    self:create_option_highlights()
end

function Lsp:create_option_highlights()
    local hl_name = table.concat({
        'lualine',
        self.options.self.section,
        self.options.component_name,
    }, '_')
    if self.options.color then
        self.options.color_highlight = self:create_hl(
            hl_name,
            self.options.default_highlight_group,
            self.options.icon.color
        )
    end
    -- setup icon highlight
    if type(self.options.icon) == 'table' and self.options.icon.color then
        self.options.icon_color_highlight = self:create_hl(
            hl_name .. '_icon',
            self.options.default_highlight_group,
            self.options.icon.color
        )
    end
end

---Creates a new highlight group from the `template_hl_name` group, replacing
---properties by values from the `hl_props`.
---
---@param hl_name HighlightGroup a name of the new highlight group.
---@param template_hl_name HighlightGroup the name of the highlight, which should be used as
---prototype.
---@param hl_props_or_fg_color Highlight | Color a fg color or table with highlight's properties,
---                           which should be replaced.
---
---@return LualineHighlight # a new created highlight table.
function Lsp:create_hl(hl_name, template_hl_name, hl_props_or_fg_color)
    local hl_props = type(hl_props_or_fg_color) == 'string' and { fg = hl_props_or_fg_color }
        or hl_props_or_fg_color
    local orig = template_hl_name and vim.api.nvim_get_hl_by_name(template_hl_name, true) or {}
    vim.api.nvim_set_hl(0, hl_name, vim.tbl_extend('force', orig, hl_props))
    return {
        name = hl_name,
        no_mode = true,
        section = self.options.self.section,
        options = self.options,
        no_default = false,
    }
end

function Lsp:is_active()
    return is_lsp_client_active(self.options.client)
end

function Lsp:update_colors(is_focused)
    if not self:is_active() or not is_focused then
        self.options.color_highlight = self.options.inactive_color_highlight
        self.options.icon_color_highlight = self.options.inactive_color_highlight
    end
end

function Lsp:update_status()
    if self.options.icons_only then
        return ''
    else
        return self.options.client.name
    end
end

function Lsp:draw(default_highlight, is_focused)
    self.status = ''
    self.applied_separator = ''

    self.default_hl = default_highlight
    local status = self:update_status()
    if self.options.fmt then
        status = self.options.fmt(status or '')
    end
    if type(status) == 'string' then
        self.status = status
        self:update_colors(is_focused)
        self:apply_icon()
        self:apply_padding()
        self:apply_highlights(default_highlight)
        self:apply_section_separators()
    end
    return self.status
end

return Lsp
