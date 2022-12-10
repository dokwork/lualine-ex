local log = require('plenary.log').new({
    plugin = 'tests.ex.fs',
    use_file = false,
    use_console = 'sync',
})

local M = {}

function M.path(...)
    local args = { ... }
    return vim.fn.join(args, '/')
end

function M.remove(path)
    log.debug('Removing ' .. path)
    os.execute('rm -rf ' .. path)
end

function M.mkdir(path)
    log.debug('Making a new directory: ' .. path)
    os.execute('mkdir ' .. path)
    local p, err = vim.loop.fs_realpath(path)
    assert(not err, err)
    return p
end

function M.mktmpdir(dir_name)
    dir_name = dir_name or ('dir_' .. math.random(999))
    local cwd = M.path(vim.env.TMPDIR or '/tmp', dir_name)
    M.remove(cwd)
    cwd = M.mkdir(cwd)
    return cwd
end

function M.touch(path)
    log.debug('Touch file ' .. path)
    os.execute('touch ' .. path)
end

function M.write(file, text)
    local f, err = io.open(file, 'w')
    if not f then
        return nil, err
    end
    f:write(text)
    f:close()
    return true
end

return M
