local Spell = require('lualine.ex.component'):extend({
    icon = '⅍',
    is_enabled = function()
        return vim.o.spell
    end,
})

function Spell:update_status()
    if vim.o.spell then
        return vim.bo.spelllang
    else
        return ''
    end
end

return Spell
