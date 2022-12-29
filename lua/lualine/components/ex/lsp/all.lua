local ex = require('lualine.ex')
local SingleLsp = require('lualine.components.ex.lsp.single')

---@class AllLspOptions: SingleLspOptions
---@field only_attached boolean
---@field icons_only boolean

---@class AllLspComponent: ExComponent
---@field options AllLspOptions
local AllLsp = require('lualine.ex.component'):extend(SingleLsp.default_options)

function AllLsp:pre_init()
    self.options.component_name = 'ex_lsp_all'
    self.__components = {}
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
        for _, client in pairs(self:__clients()) do
            local lsp = self.__components[client.name .. client.id]
            if not lsp then
                lsp = SingleLsp:new({
                    client = client,
                    parent = self.options.component_name,
                    self = self.options.self,
                    icons = self.options.icons,
                    icons_enabled = self.options.icons_enabled,
                    always_show_icon = self.options.always_show_icon,
                    icon_only = self.options.icons_only,
                    disabled_color = self.options.disabled_color,
                    disabled_icon_color = self.options.disabled_icon_color,
                })
                self.__components[client.name .. client.id] = lsp
            end
            status = status .. lsp:draw(self.default_hl, is_focused)
        end
    else
        self.options.icon = self.options.icons.lsp_off
    end
    return status
end

return AllLsp
