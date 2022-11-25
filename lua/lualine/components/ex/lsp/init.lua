local h = require('lualine.highlight')
local ex = require('lualine.ex')
local SingleLsp = require('lualine.components.ex.lsp.single_lsp')

-- try to get icons from the 'nvim-web-devicons' module
local function dev_icons()
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    return ok and devicons.get_icons() or {}
end

---@alias LspIcon string | LualineIcon | DevIcon

---@class LspIcons A table with icons for lsp clients. Keys are names of the lsp servers.
---@field unknown string LspIcon an icon for unknown lsp client.
---@field lsp_off string a symbol to illustrate that all clients are off.

---@alias LspComponentOptions LualineComponentOptions | LspOptions

---@class LspComponent: LualineComponent
---@field options LspComponentOptions
local LspComponent = require('lualine.component'):extend()

---@class LspOptions
---@field icons LspIcons
---@field inactive_color Color
---@field inactive_color_highlight LualineHighlight
---@field icons_only boolean
---@field only_attached boolean
LspComponent.default_options = {
    icons = ex.merge({ unknown = '?', lsp_off = 'ﮤ' }, dev_icons()),
    inactive_color = 'grey',
    inner_padding = 0,
}

function LspComponent:init(options)
    LspComponent.super.init(self, options)
    self.options = ex.deep_merge(self.options, self.default_options)
    self:setup()
end

function LspComponent:setup()
    self.components = {}
    local inactive_hl = h.get_lualine_hl('lualine_' .. self.options.self.section .. '_inactive') or {}
    if self.options.inactive_color then
        inactive_hl.fg = self.options.inactive_color
    end
    self.options.inactive_color_highlight = self:create_hl(inactive_hl, 'inactive_component')
end

function LspComponent:render(default_highlight, is_focused)
    -- by default, if no one lsp client exists, this component must be inactive
    local status = '%#' .. self.options.inactive_color_highlight.name .. '#'

    local clients
    if self.options.only_attached then
        clients = vim.lsp.get_active_clients({ bufnum = 0 })
    else
        clients = vim.lsp.get_active_clients()
    end

    if ex.is_empty(clients) then
        status = status .. self.options.icons.lsp_off
    else
        for _, client in pairs(clients) do
            local component_id = { id = client.id, name = client.name }
            local lsp = self.components[component_id]
            if not lsp then
                lsp = SingleLsp:new({
                    client = client,
                    self = self.options.self,
                    icons = self.options.icons,
                    icons_enabled = self.options.icons_enabled,
                    color = self.options.color,
                    inactive_color_highlight = self.options.inactive_color_highlight,
                    default_highlight_group = string.sub(default_highlight, 3, #default_highlight - 1),
                    icons_only = self.options.icons_only,
                    padding = self.options.inner_padding,
                })
                self.components[component_id] = lsp
            end
            status = status .. lsp:draw(default_highlight, is_focused)
        end
    end
    return status
end

function LspComponent:draw(default_highlight, is_focused)
    if self.options.cond ~= nil and self.options.cond() ~= true then
        return ''
    end
    self.applied_separator = ''
    self.status = self:render(default_highlight, is_focused)
    self:apply_padding()
    self:apply_on_click()
    self:apply_highlights(default_highlight)
    self:apply_section_separators()
    self:apply_separator()
    return self.status
end

return LspComponent
