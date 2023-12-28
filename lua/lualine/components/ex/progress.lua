-- stylua: ignore start
local progress_bar = { '█', '▇', '▆', '▅', '▄', '▃', '▂', '▁', ' ' }
-- stylua: ignore end

local Progress = require('lualine.ex.component'):extend({
    mode = 'percent',
    top = 'Top',
    bottom = 'Bot',
})

local function mode_percent(self, line, total)
    if (line == total) and self.options.bottom then
        return self.options.bottom
    end
    if (line == 1) and self.options.top then
        return self.options.top
    end
    return string.format('%3d%%%%', 99 * line / total + 1)
end

local function mode_table(t)
    return function(self, line, total)
        if (line == total) and self.options.bottom then
            return self.options.bottom
        end
        if (line == 1) and self.options.top then
            return self.options.top
        end
        local idx = math.floor(line * (#t - 1) / total) + 1
        return t[idx]
    end
end

function Progress:post_init()
    if type(self.options.mode) == 'string' then
        self.options.mode = (self.options.mode == 'bar') and mode_table(progress_bar)
            or mode_percent
    end
    if type(self.options.mode) == 'table' then
        self.options.mode = mode_table(self.options.mode)
    end
end

function Progress:update_status()
    return self.options.mode(self, vim.fn.line('.'), vim.fn.line('$'))
end

return Progress
