local ex = require('lualine.ex')

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

    -- calculate parameters for shorten algorithm
    local max_length = ex.max_length(self.options.max_length, filepath) or 0
    local exclude = self.options.shorten.exclude or {}
    if exclude[-1] == nil then
        table.insert(exclude, -1)
    end
    local shorten_length = self.options.shorten.length or 1

    -- do not short the filename
    if max_length < 0 then
        return prefix .. filepath
    end

    -- just apply user setting and short the filepath
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
