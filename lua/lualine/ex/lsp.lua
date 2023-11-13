local M = {}

M.stop_inactive_clients = function(opts)
    opts = opts or {}
    local hl = opts.debug_hl or 'Comment'
    local function notify(msg, ...)
        if opts.notify_enabled then
            local arg = { ... }
            msg = string.format('[lualine.ex.lsp] ' .. msg, unpack(arg))
            vim.api.nvim_echo({ { msg, hl } }, true, {})
        end
    end
    local were_stopped = 0
    for _, client in pairs(vim.lsp.get_active_clients()) do
        if not next(client.attached_buffers) then
            notify('Stop the client %d %s', client.id, client.name or 'UNKNOWN')
            vim.lsp.stop_client(client.id)
            were_stopped = were_stopped + 1
        end
    end
    if were_stopped == 0 then
        notify('No one inactive client')
    else
        notify('%d clients were stop', were_stopped)
    end
end

return M
