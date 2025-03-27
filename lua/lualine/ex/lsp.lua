local M = {}

---Iterates over active lsp clients and stops every client without attached buffers.
---@param opts? table
---@field notify_enabled? boolean true enables echo about every stopped client.
---@field notify_hl? HighlightGroup a name of the highlight which should be used in echo.
M.stop_unused_clients = function(opts)
    opts = opts or {}
    local hl = opts.notify_hl or 'Comment'
    local function notify(msg, ...)
        if opts.notify_enabled == true then
            local arg = { ... }
            msg = string.format('[lualine.ex.lsp] ' .. msg, unpack(arg))
            vim.api.nvim_echo({ { msg, hl } }, true, {})
        end
    end
    local were_stopped = 0
    for _, client in pairs(vim.lsp.get_clients()) do
        if not next(client.attached_buffers) then
            notify('Stop the client %d %s', client.id, client.name or 'UNKNOWN')
            vim.lsp.stop_client(client.id)
            were_stopped = were_stopped + 1
        end
    end
    if were_stopped == 0 then
        notify('No one unused client')
    else
        notify('%d client%s stopped', were_stopped, (were_stopped > 1) and 's were' or ' was')
    end
end

return M
