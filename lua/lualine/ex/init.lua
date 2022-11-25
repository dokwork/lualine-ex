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
---The same as `vim.tbl_extend('keep', t1 or {}, t2 or {})`
M.merge = function(t1, t2)
    return vim.tbl_extend('keep', t1 or {}, t2 or {})
end

---@type fun(t1: table, t2: table): table
---The same as `vim.tbl_deep_extend('keep', t1 or {}, t2 or {})`
M.deep_merge = function(t1, t2)
    return vim.tbl_deep_extend('keep', t1 or {}, t2 or {})
end

return M
