local M = require('lualine.ex.component'):extend({
    external_prefix = nil,
    filename_only_prefix = '…/',
    shorten = { lenght = 5, exclude = nil },
    -- -1 - never shorten; 0 - always shorten; >0 - shorten when longer then N symbols
    max_length = 0.3,
})

local Path = require('plenary.path')

---Resolves the name of the current file relative to the current working directory.
---If the file is not in the one of subdirectories of the working directory, then its
---path will be returned with:
--- * prefix {external_prefix} in case when the file is not in the one of home
---          subdirectories;
--- * prefix "~" in case when the file is in one of home subdirectories.
---Also it may shorten the file path according to {max_length}.
function M:update_status()
    local current_file = vim.fn.expand('%:p')
    if current_file == '' then
        return ''
    end

    local filepath = Path:new(current_file):normalize(vim.fn.getcwd())
    local prefix = (filepath == current_file) and self.options.external_prefix or ''

    local max_length = self.options.max_length
    max_length = (type(max_length) == 'function') and max_length(filepath) or max_length
    max_length = (type(max_length) == 'number') and max_length or 0

    if max_length < 0 then
        return prefix .. filepath
    end

    -- calculate parameters for shorten algorithm
    if max_length > 0 and max_length < 1 then
        local width = (vim.o.laststatus == 3) and vim.o.columns or vim.api.nvim_win_get_width(0)
        max_length = max_length * width
    end
    local exclude = self.options.shorten.exclude or {}
    if exclude[-1] == nil then
        table.insert(exclude, -1)
    end
    local shorten_length = self.options.shorten.length or 1

    -- just apply user setting and shorten the filepath
    if max_length == 0 then
        return prefix .. Path:new(filepath):shorten(shorten_length, exclude)
    end

    -- calculate optimal filepath
    while #filepath > max_length do
        if shorten_length > 0 then
            filepath = Path:new(filepath):shorten(shorten_length, exclude)
            shorten_length = shorten_length - 1
        else
            filepath = Path:new(filepath):shorten(1, { -1 })
            break
        end
    end

    if #filepath > max_length then
        prefix = self.options.filename_only_prefix or ''
        filepath = vim.fn.fnamemodify(filepath, ':t')
    end

    return prefix .. filepath
end

return M
