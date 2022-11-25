local uv = vim.loop
local Git = require('lualine.ex.git')

local function debug(msg)
    if vim.env.DEBUG then
        print('> ' .. msg)
    end
end

local function remove(path)
    debug('Removing ' .. path)
    os.execute('rm -rf ' .. path)
end

local function mktmpdir()
    local cwd = vim.fs.normalize('$TMPDIR/__git_spec_cwd__'):gsub('//', '/')
    remove(cwd)
    local result, err_msg = uv.fs_mkdtemp(cwd)
    assert(result, err_msg)
    cwd = result
    debug('Working directory for tests is ' .. cwd)
    return cwd
end

describe('when cwd is the git root', function()
    local cwd
    local git_root

    before_each(function()
        cwd = mktmpdir()
        git_root = cwd
        os.execute('git init ' .. git_root)
    end)

    after_each(function()
        remove(git_root .. '/.git')
    end)

    it('git_root should return cwd', function()
        local git = Git:new(cwd)
        assert.are.equal(cwd, git:git_root())
    end)

    it('is_git_workspace should return true', function()
        local git = Git:new(cwd)
        assert.True(git:is_workspace())
    end)

    it('get_branch should return the name of the current git branch', function()
        local git = Git:new(cwd)
        assert.are.equal('main', git:get_branch())
    end)
end)

describe('when cwd is outside of the git root', function()
    local cwd

    before_each(function()
        cwd = mktmpdir()
    end)

    after_each(function()
        remove(cwd)
    end)

    it('git_root should return nil', function()
        local git = Git:new(cwd)
        assert.are.equal(nil, git:git_root())
    end)

    it('is_git_workspace should return false', function()
        local git = Git:new(cwd)
        assert.is_false(git:is_workspace())
    end)

    it('get_branch should return nil', function()
        local git = Git:new(cwd)
        assert.are.equal(nil, git:get_branch())
    end)
end)
