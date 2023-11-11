local ex = require('lualine.ex')

---@class CwdComponentOptions: ExComponentOptions
---@field depth number A count of the last directories in the working path. Default is 2.
---@field prefix string

---@class CwdComponent: ExComponent
---@field options CwdComponentOptions
local Cwd = require('lualine.ex.component'):extend({
    depth = 2,
    prefix = '…',
    max_length = 0.2,
})

---Cuts the current working path and gets the `options.depth` directories from the end
---with prefix ".../". For example: inside the path `/3/2/1` this function will return
---the string ".../2/1" for depth 2. If `options.depth` is more then directories in
---the path, then path will be returned as is.
function Cwd:update_status()
    local cwd = vim.fn.getcwd()
    local depth = self.options.depth
    local sep = package.config:sub(1, 1)
    local dirs = vim.split(cwd, sep, { plain = true, trimempty = true })
    local prefix = (self.options.prefix and depth > 0) and self.options.prefix .. sep or ''
    local max_length = ex.max_length(self.options.max_length, cwd) or 0

    repeat
        cwd = ''
        if depth > 0 then
            local tail = vim.list_slice(dirs, #dirs - depth + 1, #dirs)
            cwd = table.concat(tail, sep)
            depth = depth - 1
        elseif depth < 0 then
            for i = 1, math.abs(depth), 1 do
                cwd = cwd .. sep .. dirs[i]
            end
            depth = depth + 1
        else
            return ''
        end
    until #cwd < max_length
    return prefix .. cwd .. sep
end

return Cwd
