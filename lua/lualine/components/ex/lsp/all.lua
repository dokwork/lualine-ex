local log = require('plenary.log').new({ plugin = 'ex.lsp.all' })
local ex = require('lualine.ex')
local SingleLsp = require('lualine.components.ex.lsp.single')

local function str_escape(str)
    str = str:gsub('-', '_')
    return str
end

---@class AllLspOptions: SingleLspOptions
---@field only_attached boolean
---@field icons_only boolean

---@class AllLspComponent: ExComponent
---@field options AllLspOptions
---@field components table
local AllLsp = require('lualine.ex.component'):extend(
    vim.tbl_extend('force', SingleLsp.default_options, {
        is_enabled = function(component)
            return not ex.is_empty(component:__clients())
        end,
    })
)

---@protected
function AllLsp:pre_init()
    self.options.component_name = 'ex_lsp_all'
    self.components = {}
    -- will be used to avoid duplicate highlights:
    self.__hls_cache = {}
end

---@private
function AllLsp:__clients()
    if self.options.only_attached == true then
        return vim.lsp.get_active_clients({ bufnr = 0 })
    else
        return vim.lsp.get_active_clients()
    end
end

local function key(client)
    return client.name .. '_' .. client.id
end

---@protected
function AllLsp:update_status(is_focused)
    local status = ''
    if self:is_enabled() then
        self.options.icon = nil
        local clients = self:__clients()
        self:__actualize_components(clients)
        for _, client in pairs(clients) do
            local key = key(client)
            local lsp = self.components[key]
            if not lsp then
                lsp = SingleLsp:new({
                    client = client,
                    component_name = str_escape('inner_lsp_' .. client.name),
                    hls_cache = self.__hls_cache,
                    self = self.options.self,
                    icons = self.options.icons,
                    icons_enabled = self.options.icons_enabled,
                    always_show_icon = self.options.always_show_icon,
                    icons_only = self.options.icons_only,
                    disabled_color = self.options.disabled_color,
                    disabled_icon_color = self.options.disabled_icon_color,
                })
                self.components[key] = lsp
            end
            status = status .. lsp:draw(self.default_hl, is_focused)
        end
    else
        self.options.icon = self.options.icons.lsp_is_off
    end
    return status
end

---@private
function AllLsp:__actualize_components(clients)
    local actual_components = {}
    for _, client in ipairs(clients) do
        local key = key(client)
        local component = self.components[key]
        if component then
            actual_components[key] = component
        end
    end
    self.components = actual_components
end

return AllLsp
