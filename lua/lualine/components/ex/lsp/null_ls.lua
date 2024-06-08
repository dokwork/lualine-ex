local log = require('plenary.log').new({ plugin = 'ex.lsp.null-ls' })

-- we should be ready to three possible cases:
-- * when null-ls is not loaded we should load it only on demand;
-- * when null-ls is not installed we should mock it to avoid errors;
-- * when it is installed and loaded we should use it.
local null_ls = setmetatable({}, {
    __index = function(self, key)
        -- attempt to lazy load null-ls plugin
        if rawget(self, 'is_installed') == nil then
            local is_installed, null_ls = pcall(require, 'null-ls')
            rawset(self, 'is_installed', is_installed)
            rawset(self, 'null_ls', null_ls)
            if is_installed then
                log.debug('none-ls is installed')
            else
                log.warn('none-ls is not installed.')
            end
        end
        -- return original plugin if it's installed
        if rawget(self, 'is_installed') then
            return rawget(self, 'null_ls')[key]
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

local NullLS = require('lualine.ex.component'):extend({
    icon = '',
    query = function()
        return { filetype = vim.bo.filetype }
    end,
    component_name = 'ex_lsp_null_ls',
    source_names_separator = ',',
    is_enabled = function(component)
        return null_ls.is_registered(component:get_query())
    end,
})

function NullLS:get_query()
    if type(self.options.query) == 'function' then
        return self.options.query()
    else
        return self.options.query
    end
end

-- get sources by query, and concatenate their unique names with {source_names_separator}
function NullLS:update_status()
    local sources = null_ls.get_source(self:get_query())
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

return NullLS
