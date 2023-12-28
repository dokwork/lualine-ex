local log = require('plenary.log').new({ plugin = 'ex.location' })

local Location = require('lualine.ex.component'):extend({
    pattern = '%2C:%-3L/%T',
})

function Location:post_init()
    self.__substitutions = {}
    self.__pattern = string.gsub(self.options.pattern, '(%%%-?%d*[LCT]+)', function(template)
        return string.gsub(template, '([LCT])', function(value)
            table.insert(self.__substitutions, value)
            return 'd'
        end)
    end)
    log.debug(self.__substitutions)
    log.debug(self.__pattern)
end

function Location:update_status()
    local values = {
        L = vim.fn.line('.'),
        C = vim.fn.virtcol('.'),
        T = vim.fn.line('$'),
    }
    local substitutions = vim.tbl_map(function(key)
        return values[key]
    end, self.__substitutions)
    return string.format(self.__pattern, unpack(substitutions))
end

return Location
