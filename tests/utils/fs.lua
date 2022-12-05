local M = {}

function M.debug(msg)
    if vim.env.DEBUG then
        print('> ' .. msg)
    end
end

function M.path(...)
    local args = { ... }
    return vim.fn.join(args, '/')
end

function M.remove(path)
    M.debug('Removing ' .. path)
    os.execute('rm -rf ' .. path)
end

function M.mkdir(path)
    M.debug('Making a new directory: ' .. path)
    os.execute('mkdir ' .. path)
    local p, err = vim.loop.fs_realpath(path)
    assert(not err, err)
    return p
end

function M.mktmpdir(dir_name)
    dir_name = dir_name or ('dir_' .. math.random(999))
    local cwd = '/tmp/' .. dir_name
    M.remove(cwd)
    cwd = M.mkdir(cwd)
    M.debug('Working directory for tests is ' .. cwd)
    return cwd
end

function M.touch(path)
    M.debug('Touch file ' .. path)
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
