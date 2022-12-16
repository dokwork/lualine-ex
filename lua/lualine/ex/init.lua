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
M.merge = function(t1, t2)
    return vim.tbl_extend('keep', t1 or {}, t2 or {})
end

---@type fun(t1: table, t2: table): table
---The same as `vim.tbl_deep_extend('keep', t1 or {}, t2 or {})`
---but can work with mixed tables (with numbered and string keys).
---If passed only the first argument, this method works as deep copy,
---and returns copy of the argument.
---If one of the arguments is not a table, the first argument will be returned.
M.deep_merge = function(t1, t2)
    t1 = t1 or {}
    t2 = t2 or {}

    if type(t1) ~= 'table' then
        return t1
    end
    local res = {}
    for key, value in pairs(t1) do
        res[key] = type(value) == 'table' and M.deep_merge(value) or value
    end

    if type(t2) ~= 'table' then
        return t1
    end

    for key, value in pairs(t2) do
        if type(value) == 'table' then
            res[key] = t1[key] ~= nil and M.deep_merge(t1[key], value) or M.deep_merge(value)
        elseif t1[key] == nil then
            res[key] = value
        end
    end
    return res
end

return M
