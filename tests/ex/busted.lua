---@diagnostic disable: lowercase-global
local M = {}

function M.ignore_it(desc, fun, reason)
    print('!!!IGNORED!!!', desc, '\nReason: ', reason or '')
end

function M.except_it(desc, fun)
    require('plenary.busted').it(desc, fun)
end

M.ignore_all_tests = function(self)
    it = function() end
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

return M
