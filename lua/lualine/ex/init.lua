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
M.merge = function(dest, source, already_visited)
    vim.validate({ dest = { dest, 'table' }, source = { source, 'table' } })
    for key, value in pairs(dest) do
        if type(value) == 'table' and type(source[key]) == 'table' then
            already_visited = already_visited or {}
            if not already_visited[value] then
                already_visited[value] = true
                M.merge(value, source[key], already_visited)
            end
        end
    end
    for key, value in pairs(source) do
        if dest[key] == nil then
            dest[key] = value
        end
    end
    return dest
end

---Resolves a {max_length} option of a component.
--- - if {opt} is a function, it invokes that function with the {value} parameter;
--- - if {opt} is number > 0 and < 1, and {laststatus} == 3 then this function
---   calculates a fraction of the {vim.o.columns};
--- - if {opt} is number > 0 and < 1, and {laststatus} ~= 3 then this function
---   calculates a fraction of the {vim.api.nvim_win_get_width(0)};
--- - all other numbers will be returned as is;
--- - in case of all other types the nill will be returned.
---
---@param opt number|fun(value: string) an initial setting for the max_length.
---@param value? string an actual component status which will be passed to the {opt}
---              if it's a function.
---@return number | nil
M.max_length = function(opt, value)
    opt = (type(opt) == 'function') and opt(value) or opt
    if type(opt) ~= 'number' then
        return nil
    end
    if opt > 0 and opt < 1 then
        return opt * (vim.o.laststatus == 3 and vim.o.columns or vim.api.nvim_win_get_width(0))
    else
        return opt
    end
end

return M
