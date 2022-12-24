local ex = require('lualine.ex')
local log = require('plenary.log').new({ plugin = 'ex.lsp' })
local SingleLsp = require('lualine.components.ex.lsp.single_lsp')

-- tries to get icons from the 'nvim-web-devicons' module
local function dev_icons()
    local ok, devicons = pcall(require, 'nvim-web-devicons')
    return ok and devicons.get_icons() or {}
end

---@alias LspIcon string | LualineIcon | DevIcon

---@class LspIcons A table with icons for lsp clients. Keys are names of the lsp servers.
---@field unknown LspIcon  An icon for unknown lsp client.
---@field lsp_off string   A symbol to illustrate that all clients are off.

---@class LspOptions: ExComponentOptions
---@field icons LspIcons
---@field icons_only boolean
---@field only_attached boolean

---@alias LspComponentOptions ExComponentOptions | LspOptions

---@class LspComponent: LualineComponent
---@field options LspComponentOptions
local LspComponent = require('lualine.ex.component'):extend({
    component_name = 'ex_lsp',
    icons = ex.merge({
        unknown = '?',
        lsp_off = 'ﮤ',
    }, dev_icons()),
})

function LspComponent:post_init()
    self.__components = {}
end

function LspComponent:is_enabled()
    return not ex.is_empty(self:__clients())
end

function LspComponent:__clients()
    if self.options.only_attached == true then
        return vim.lsp.get_active_clients({ bufnum = 0 })
    else
        return vim.lsp.get_active_clients()
    end
end

function LspComponent:update_status(is_focused)
    local status = ''
    if self:is_enabled() then
        self.options.icon = nil
        for _, client in pairs(self:__clients()) do
            local lsp = self.__components[client.id]
            if not lsp then
                lsp = SingleLsp:new({
                    client = client,
                    self = self.options.self,
                    icons = self.options.icons,
                    icons_enabled = self.options.icons_enabled,
                    always_show_icon = self.options.always_show_icon,
                    icons_only = self.options.icons_only,
                    disabled_color = self.options.disabled_color,
                    disabled_icon_color = self.options.disabled_icon_color,
                    padding = self.options.icons_only and 0 or 1,
                })
                self.__components[client.id] = lsp
            end
            status = status .. lsp:draw(self.default_hl, is_focused)
        end
    else
        self.options.icon = self.options.icons.lsp_off
    end
    return status
end

return LspComponent
