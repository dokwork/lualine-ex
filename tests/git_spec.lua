local eq = assert.are.equal
local same = assert.are.same

local Git = require('lualine.ex.git')

local function debug(msg)
    if vim.env.DEBUG then
        print('> ' .. msg)
    end
end

local function path(...)
    local args = { ... }
    return vim.fn.join(args, '/')
end

local function remove(path)
    debug('Removing ' .. path)
    os.execute('rm -rf ' .. path)
end

local function mkdir(path)
    debug('Making a new directory: ' .. path)
    os.execute('mkdir ' .. path)
    local p, err = vim.loop.fs_realpath(path)
    assert(not err, err)
    return p
end

local function mktmpdir()
    local cwd = '/tmp/__git_spec_cwd__'
    remove(cwd)
    cwd = mkdir(cwd)
    debug('Working directory for tests is ' .. cwd)
    return cwd
end

local function touch(path)
    debug('Touch file ' .. path)
    os.execute('touch ' .. path)
end

describe('outside a git worktree', function()
    local tmp_dir

    before_each(function()
        tmp_dir = mktmpdir()
    end)

    after_each(function()
        remove(tmp_dir)
    end)

    it('find_git_root should return nil for directory outside a git worktree', function()
        eq(nil, Git.find_git_root(tmp_dir))
    end)

    it('git_root should return nil', function()
        local git = Git:new(tmp_dir)
        eq(nil, git:git_root())
    end)
end)

describe('inside the git worktree', function()
    local git_root

    before_each(function()
        git_root = mktmpdir()
        os.execute('git init -b main ' .. git_root)
    end)

    after_each(function()
        remove(git_root)
    end)

    it('find_git_root should return git_root path when git_root passed', function()
        eq(git_root, Git.find_git_root(git_root))
    end)

    it('find_git_root should return git_root path when directory inside the git worktree passed', function()
        eq(git_root, Git.find_git_root(mkdir(path(git_root, 'test'))))
    end)

    it('git_root should return path passed to the constructor', function()
        local git = Git:new(git_root)
        eq(git_root, git:git_root())
    end)

    it('get_branch should return the name of the current git branch', function()
        local git = Git:new(git_root)
        eq('main', git:get_branch())
    end)

    it('is_workspace_changed should return false for a new git workspace', function()
        local git = Git:new(git_root)
        eq(false, git:is_workspace_changed())
    end)

    it('is_workspace_changed should return true when a file was added', function()
        local file = path(git_root, 'test.txt')
        touch(file)
        os.execute('git -C ' .. git_root .. ' add ' .. file)

        local git = Git:new(git_root)
        eq(true, git:is_workspace_changed())
    end)
end)
