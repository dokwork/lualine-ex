local log = require('plenary.log').new({ plugin = 'ex.lsp.all' })
local ex = require('lualine.ex')
local SingleLsp = require('lualine.components.ex.lsp.single')

---@class AllLspOptions: SingleLspOptions
---@field only_attached boolean
---@field icons_only boolean

---@class AllLspComponent: ExComponent
---@field options AllLspOptions
---@field components table
local AllLsp = require('lualine.ex.component'):extend(SingleLsp.default_options)

function AllLsp:pre_init()
    self.options.component_name = 'ex_lsp_all'
    self.components = {}
    -- will be used to avoid duplicate highlights:
    self.__hls_cache = {}
end

function AllLsp:is_enabled()
    return not ex.is_empty(self:__clients())
end

---@private
function AllLsp:__clients()
    if self.options.only_attached == true then
        return vim.lsp.get_active_clients({ bufnum = 0 })
    else
        return vim.lsp.get_active_clients()
    end
end

function AllLsp:update_status(is_focused)
    local status = ''
    if self:is_enabled() then
        self.options.icon = nil
        local clients = self:__clients()
        log.fmt_debug('%d lsp clients have been found', #clients)
        for _, client in pairs(clients) do
            local lsp = self.components[client.name .. client.id]
            if not lsp then
                lsp = SingleLsp:new({
                    client = client,
                    hls_cache = self.__hls_cache,
                    self = self.options.self,
                    icons = self.options.icons,
                    icons_enabled = self.options.icons_enabled,
                    always_show_icon = self.options.always_show_icon,
                    icons_only = self.options.icons_only,
                    disabled_color = self.options.disabled_color,
                    disabled_icon_color = self.options.disabled_icon_color,
                })
                self.components[client.name .. client.id] = lsp
            end
            status = status .. lsp:draw(self.default_hl, is_focused)
        end
    else
        self.options.icon = self.options.icons.lsp_is_off
    end
    return status
end

return AllLsp
