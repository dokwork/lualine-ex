local M = require('lualine.component'):extend()

---Resolves the name of the current file relative to the current working directory.
---If the file is not in the one of subdirectories of the working directory, then its
---path will be returned with:
--- * prefix "/.../" in case when the file is not in the one of home subdirectories;
--- * prefix "~/" in case when the file is in one of home subdirectories.
function M:update_status()
    local full_name = vim.fn.expand('%:p')
    local name = vim.fn.expand('%:.')
    if name == full_name then
        name = vim.fn.expand('%:~')
    end
    if name == full_name then
        name = vim.fn.expand('%:t')
        if #name > 0 then
            name = '/.../' .. name
        end
    end
    return name
end

return M
