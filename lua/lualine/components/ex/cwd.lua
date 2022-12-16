---@class CwdComponentOptions: ExComponentOptions
---@field depth number A count of the last directories in the working path. Default is 2.
---@field prefix string

---@class CwdComponent: ExComponent
---@field options CwdComponentOptions
local Cwd = require('lualine.ex.component'):extend({
    depth = 2,
    prefix = '…',
})

---Cuts the current working path and gets the `options.depth` directories from the end
---with prefix ".../". For example: inside the path `/3/2/1` this provider will return
---the string ".../2/1" for depth 2. If `options.depth` is more then directories in
---the path, then path will be returned as is.
function Cwd:update_status()
    local full_path = vim.fn.getcwd()
    local count = self.options.depth
    local sep = '/' -- FIXME: use system separator
    local dirs = vim.split(full_path, sep, { plain = true, trimempty = true })
    local result = self.options.prefix .. sep
    if count > #dirs then
        return full_path
    end
    if count <= 0 then
        return result
    end
    local tail = vim.list_slice(dirs, #dirs - count + 1, #dirs)
    for _, dir in ipairs(tail) do
        result = result .. dir .. sep
    end
    return result
end

return Cwd
