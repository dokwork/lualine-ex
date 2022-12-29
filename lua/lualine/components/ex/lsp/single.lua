local log = require('plenary.log').new({ plugin = 'ex.lsp.single' })

---@class LspClient object which is returned from the `vim.lsp.client()`.
---@field id number     The id allocated to the client.
---@field name string   If a name is specified on creation, that will be used.
---                     Otherwise it is just the client id. This is used for logs and messages.
---@field config { filetypes: string[] } Configuration with a list of file types, appropriate for
---  this client.

---@alias LspIcon string | LualineIcon | DevIcon

---@class LspIcons A table with icons for lsp clients. Keys are names of the lsp servers or
---  appropriate file types.
---@field unknown LspIcon  An icon for unknown lsp client.
---@field lsp_off string   A symbol to illustrate that no one client exists.

local __devicons

-- Returns icons from the 'nvim-web-devicons' module or empty table.
---@see require('nvim-web-devicons').get_icons
local function devicons()
    if not __devicons then
        local ok, devicons = pcall(require, 'nvim-web-devicons')
        __devicons = ok and devicons.get_icons() or {}
    end
    return __devicons
end

---Takes a type of the file from the {client} and tries to take a corresponding icon
---from the {icons} or 'nvim-web-devicons'.
---
---@param client LspClient               A client to a LSP server.
---@param icons table<string, LspIcon> # A table with icons for lsp clients.
---
---@return string | LualineIcon # An icon of the LspClient or `nil` when the {client} is absent or icon not found.
local function lsp_client_icon(client, icons)
    -- try to get an appropriated icon from the passed table
    local dev_icon = icons[client.name]
    if dev_icon then
        return dev_icon
    end
    -- or looking for it in the nvim-web-devicons
    icons = devicons()
    for _, ft in ipairs(client.config.filetypes) do
        if icons[ft] then
            dev_icon = icons[ft]
            local icon = { dev_icon.icon }
            icon.color = { fg = dev_icon.color }
            return icon
        end
    end
    return icons.unknown
end

local function is_lsp_client_ready(client)
    -- TODO: add support of the metals
    return true
end

local function is_lsp_client_active(client)
    if not client then
        return false
    end
    local buffers = vim.lsp.get_buffers_by_client_id(client.id) or {}
    local is_active = vim.tbl_contains(buffers, vim.fn.bufnr('%'))
    return is_active and is_lsp_client_ready(client)
end

local function str_escape(str)
    str = str:gsub('-', '_')
    return str
end

---@class SingleLspOptions: ExComponentOptions
---@field client? LspClient
---@field parent? string
---@field self { section: string }
---@field icon LualineIcon | string
---@field icons LspIcons
---@field icons_enabled boolean
---@field icon_only boolean

---@class SingleLsp: ExComponent
---@field super ExComponent
---@field options SingleLspOptions
---@field new fun(options: SingleLspOptions): SingleLsp
---@field client fun(): LspClient | nil
local Lsp = require('lualine.ex.component'):extend({
    icons = {
        unknown = '?',
        lsp_off = 'ﮤ',
    },
})

function Lsp:pre_init()
    local client_name = self.options.client and str_escape(self.options.client.name)
    self.options.component_name = 'ex_lsp_' .. (client_name or 'single')
    self.options.padding = self.options.padding or (self.options.icon_only and 0 or 1)
    self.options.color = function()
        return type(self.options.icon) == 'table' and self.options.icon.color or nil
    end
    log.fmt_debug(
        'A new ex.lsp.single component has been created with a name: %s',
        self.options.component_name
    )
    self:__update_icon(self.options.client)
end

function Lsp:is_enabled()
    return is_lsp_client_active(self.options.client)
end

function Lsp:update_status()
    self:__update_client()
    if self.options.icon_only then
        return ''
    end
    return self:is_enabled() and self.options.client.name or ''
end

---@private
function Lsp:__update_client()
    if self.options.parent then
        return
    end

    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    local _, client = next(clients or {})
    if (client and self.options.client) and (client.id == self.options.client.id) then
        return
    end

    self.options.client = client
    if client then
        log.fmt_debug(
            'The client was changed. The new client is %s with id %d',
            client.name,
            client.id
        )
        self:__update_icon(self.options.client)
    end
end

---@private
function Lsp:__update_icon(client)
    if client then
        self.options.icon = lsp_client_icon(client, self.options.icons)
        log.fmt_debug(
            'An icon for the component %s has been created: %s',
            self.options.component_name,
            self.options.icon
        )
    else
        self.options.icon = self.options.icons.lsp_off
        log.debug('No one client was found. Lsp is off.')
    end
end

return Lsp
