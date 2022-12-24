---@class LspClient object which is returned from the `vim.lsp.client()`.
---@field id number     The id allocated to the client.
---@field name string   If a name is specified on creation, that will be used.
---                     Otherwise it is just the client id. This is used for logs and messages.

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
---@param client LspClient               A client to a LSP server.
---@param icons table<string, LspIcon> # A table with icons for lsp clients.
---
---@return LualineIcon # An icon of the LspClient or `nil` when the {client} is absent or icon not found.
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
        icon.color = { fg = dev_icon.color }
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
    local is_active = vim.tbl_contains(buffers, vim.fn.bufnr('%'))
    return is_active and is_lsp_client_ready(client)
end

local function str_escape(str)
    str = str:gsub('-', '_')
    return str
end

---@class SingleLsp: ExComponent
---@field super ExComponent
---@field new fun(options: LspInitOptions): SingleLsp
---@field init fun(options: LspInitOptions)
---@field update_status fun(is_focused: boolean): string
local Lsp = require('lualine.ex.component'):extend()

---@class LspInitOptions: ExComponentOptions
---@field client LspClient
---@field self { section: string }
---@field icon LualineIcon
---@field icons LspIcons
---@field icons_enabled boolean
---@field icons_only boolean

function Lsp:pre_init()
    self.options.component_name = table.concat(
        { 'lsp', str_escape(self.options.client.name), self.options.client.id },
        '_'
    )
    self.options.icon = lsp_client_icon(self.options.client, self.options.icons)
    self.options.color = self.options.icon.color
        and function()
            return self.options.icon.color
        end
end

function Lsp:post_init()
    vim.pretty_print(self.options.icon, self.options.component_name,
    self.options.color,
    self.options.color_highlight)
end

function Lsp:is_enabled()
    return is_lsp_client_active(self.options.client)
end

function Lsp:update_status()
    if self.options.icons_only then
        return ''
    else
        return self.options.client.name
    end
end

return Lsp
