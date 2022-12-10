local fs = require('tests.ex.fs')
local git = require('tests.ex.git')

local eq = assert.are.equal

local GitProvider = require('lualine.ex.git_provider')

describe('outside a git worktree', function()
    local tmp_dir

    before_each(function()
        tmp_dir = fs.mktmpdir()
    end)

    after_each(function()
        fs.remove(tmp_dir)
    end)

    it('find_git_root should return nil for directory outside a git worktree', function()
        eq(nil, GitProvider.find_git_root(tmp_dir))
    end)

    it('git_root should return nil', function()
        local p = GitProvider:new(tmp_dir)
        eq(nil, p:git_root())
    end)

    it('is_worktree_changed should return nil', function()
        local p = GitProvider:new(tmp_dir)
        eq(nil, p:is_worktree_changed(true))
    end)
end)

describe('inside the git worktree', function()
    local git_root

    before_each(function()
        git_root = fs.mktmpdir()
        git.init(git_root)
    end)

    after_each(function()
        fs.remove(git_root)
    end)

    it('find_git_root should return git_root path when git_root passed', function()
        eq(git_root, GitProvider.find_git_root(git_root))
    end)

    it(
        'find_git_root should return git_root path when directory inside the git worktree passed',
        function()
            eq(git_root, GitProvider.find_git_root(fs.mkdir(fs.path(git_root, 'test'))))
        end
    )

    it('git_root should return path passed to the constructor', function()
        local p = GitProvider:new(git_root)
        eq(git_root, p:git_root())
    end)

    it('get_branch should return the name of the current git branch', function()
        local p = GitProvider:new(git_root)
        eq('main', p:get_branch())
    end)

    describe('is_worktree_changed', function()
        it('should return false for a new git workspace', function()
            local p = GitProvider:new(git_root)
            eq(false, p:is_worktree_changed(true))
        end)

        it('should return false when a new file was created, but not tracked', function()
            local file = fs.path(git_root, 'test.txt')
            fs.touch(file)

            local p = GitProvider:new(git_root)
            eq(false, p:is_worktree_changed(true))
        end)

        it('should return true when a new file was created and add to the index', function()
            local file = fs.path(git_root, 'test.txt')
            fs.touch(file)
            git.add(git_root, file)

            local p = GitProvider:new(git_root)
            eq(true, p:is_worktree_changed(true))
        end)

        it('should return false right after commit all changes', function()
            local file = fs.path(git_root, 'test.txt')
            fs.touch(file)
            git.add(git_root, file)
            git.commit(git_root, 'add file')

            local p = GitProvider:new(git_root)
            eq(false, p:is_worktree_changed(true))
        end)

        it('should return true when an indexed file was changed', function()
            local file = fs.path(git_root, 'test.txt')
            fs.touch(file)
            git.add(git_root, file)
            git.commit(git_root, 'add file')
            fs.write(file, 'test')

            local p = GitProvider:new(git_root)
            eq(true, p:is_worktree_changed(true))
        end)

        it('should return true when a file was removed', function()
            local file = fs.path(git_root, 'test.txt')
            fs.touch(file)
            git.add(git_root, file)
            git.commit(git_root, 'add file')
            fs.remove(file)

            local p = GitProvider:new(git_root)
            eq(true, p:is_worktree_changed(true))
        end)
    end)
end)
