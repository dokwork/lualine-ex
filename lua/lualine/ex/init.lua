local M = {}

---@type fun(x: any): boolean
---Checks is an argument {x} is empty.
---
---@return boolean #true when the argument is empty.
---The argument is empty when:
---* it is the nil;
---* it has a type 'table' and doesn't have any pair;
---* it has a type 'string' and doesn't have any char;
---otherwise result is false.
M.is_empty = function(x)
    if x == nil then
        return true
    end
    if type(x) == 'table' and next(x) == nil then
        return true
    end
    if type(x) == 'string' and string.len(x) < 1 then
        return true
    end
    return false
end

---@type fun(t1: table, t2: table): table
---The same as `vim.tbl_extend('keep', t1 or {}, t2 or {})`,
M.extend = function(t1, t2)
    return vim.tbl_extend('keep', t1 or {}, t2 or {})
end

---@type fun(dest: table, source: table): table
--- Puts all absent key-value pairs from the {source} to the {dest}.
---@return table dest with added pairs.
M.merge = function (dest, source)
    vim.validate({ dest = { dest, 'table' }, source = { source, 'table' } })
    for key, value in pairs(dest) do
        if type(value) == 'table' and type(source[key]) == 'table' then
            M.merge(value, source[key])
        end
    end
    for key, value in pairs(source) do
        if dest[key] == nil then
            dest[key] = value
        end
    end
    return dest
end

return M
