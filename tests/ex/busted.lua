---@diagnostic disable: lowercase-global
local M = {}

assert.is_blank = function(str, msg)
    if type(str) == 'string' then
        if string.gmatch(str, '^%s*$') then
            return
        else
            error(string.format('The string "%s" is not blank.%s', str, msg or ''))
        end
    end
    error(string.format('The {str} has wrong type %s instead of "string".%s', type(str), msg or ''))
end

function M.ignore_it(desc, fun, reason)
    print('!!!IGNORED!!!', desc, '\nReason: ', reason or '')
end

function M.it(desc, fun)
    require('plenary.busted').it(desc, fun)
end

M.ignore_all_tests = function(self)
    it = function(desc)
        M.ignore_it(desc, nil, 'ignore all')
    end
    return self
end

function M.eventually(test, timeout_sec)
    timeout_sec = timeout_sec or 3
    local start = os.time()
    local attempt = 1
    local ok, err = pcall(test)
    local time = os.difftime(os.time(), start)
    while not ok and time < timeout_sec do
        vim.loop.sleep(100)
        attempt = attempt + 1
        ok, err = pcall(test)
        time = os.difftime(os.time(), start)
    end

    if not ok then
        error(
            string.format(
                'After %d seconds and %d attempts function was failed. The last error is:\n%s',
                time,
                attempt,
                err
            )
        )
    end
end

function M.with_clue(clue, test)
    local ok, err = pcall(test)
    if not ok then
        error(string.format('Clue: [%s] Error: %s', clue, err))
    end
end

return M
