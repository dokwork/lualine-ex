local log = require('plenary.log').new({ plugin = 'ex.lsp.none-ls' })

-- we should be ready to three possible cases:
-- * when none-ls is not loaded we should load it only on demand;
-- * when none-ls is not installed we should mock it to avoid errors;
-- * when it is installed and loaded we should use it.
local none_ls = setmetatable({}, {
    __index = function(self, key)
        -- attempt to lazy load none-ls plugin
        if rawget(self, 'is_installed') == nil then
            -- null-ls is old name of the none-ls plugin,
            -- which is still used for back compatibility
            local is_installed, none_ls = pcall(require, 'null-ls')
            rawset(self, 'is_installed', is_installed)
            rawset(self, 'none_ls', none_ls)
            if is_installed then
                log.debug('none-ls is installed')
            else
                log.warn('none-ls is not installed.')
            end
        end
        -- return original plugin if it's installed
        if rawget(self, 'is_installed') then
            return rawget(self, 'none_ls')[key]
        end
        -- return mock:
        if key == 'get_source' then
            return function()
                return {}
            end
        elseif key == 'is_registered' then
            return function()
                return false
            end
        else
            return nil
        end
    end,
})

local NoneLS = require('lualine.ex.component'):extend({
    icon = '',
    query = function()
        return { filetype = vim.bo.filetype }
    end,
    component_name = 'ex_lsp_none_ls',
    source_names_separator = ',',
    is_enabled = function(component)
        return none_ls.is_registered(component:get_query())
    end,
})

function NoneLS:get_query()
    if type(self.options.query) == 'function' then
        return self.options.query()
    else
        return self.options.query
    end
end

-- get sources by query, and concatenate their unique names with {source_names_separator}
function NoneLS:update_status()
    local sources = none_ls.get_source(self:get_query())
    log.fmt_debug(
        'For query %s was found sources: %s',
        vim.inspect(self.options.query),
        vim.inspect(sources)
    )
    local names_set = {}
    local names = {}
    for _, source in pairs(sources) do
        -- merge similar sources and escape special symbols
        if not names_set[source.name] then
            names_set[source.name] = true
            local escaped_name = string.gsub(source.name, '%%', '%%%%')
            table.insert(names, escaped_name)
        end
    end
    return table.concat(names, self.options.source_names_separator)
end

return NoneLS
