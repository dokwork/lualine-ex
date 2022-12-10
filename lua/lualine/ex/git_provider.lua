local fs = vim.fs
local fn = vim.fn
local uv = vim.loop

local Job = require('plenary.job')
local log = require('plenary.log').new({
    plugin = 'ex.git_provider',
    use_file = false,
    use_console = 'sync',
})

local function path(...)
    local args = { ... }
    return vim.fn.join(args, '/')
end

---Reads the whole file and returns its content.
local function read(file_path)
    local f = io.open(file_path, 'r')
    if not f then
        return nil
    end
    local content = f:read('*a')
    f:close()
    return content
end

---@class GitProvider: Object
---@field new fun(git_root_path: string): GitProvider
--- Creates a new {Git} provider instance around {git_root_path}.
local Git = require('lualine.utils.class'):extend()

---This static method looks for the path with `.git/` directory outside the {path}.
---@param path string The path to the directory or file, from which the search of
---   the `.git/` directory should begun.
---@return string # The path to the root of the git workspace, or nil.
function Git.find_git_root(path)
    local function is_git_dir(path)
        local dir = path .. '/.git'
        return fn.isdirectory(dir) == 1
    end

    local git_root = is_git_dir(path) and path or nil
    if not git_root then
        for dir in fs.parents(path) do
            if is_git_dir(dir) then
                git_root = dir
                break
            end
        end
    end
    return git_root
end

---@type fun(git_root_path: string)
---@param git_root_path string Path to the root of the git worktree.
function Git:init(git_root_path)
    local p, err = uv.fs_realpath(git_root_path)
    if p then
        local _, err = uv.fs_realpath(path(p, '.git'))
        p = (not err and p) or nil
    end
    self.__git_root = p
    self.__git_root_err = err
end

---Reads '{git_root}/.git/HEAD' file and gets the name of the current git branch, or the first 7
---symbols of the commit sha.
---@return string # The name of the current branch or first 7 symbols of the commit's hash.
function Git:__read_git_branch()
    local head = read(path(self:git_root(), '.git', 'HEAD'))
    local branch = head
        and (
            string.match(head, 'ref: refs/heads/(%w+)')
            or string.match(head, 'ref: refs/tags/(%w+)')
            or string.match(head, 'ref: refs/remotes/(%w+)')
        )
    return branch or (head and head:sub(1, #head - 7))
end

---Returns a path to the root git directory, or nil with error message if path is not exists.
function Git:git_root()
    return self.__git_root, self.__git_root_err
end

function Git:get_branch()
    -- git branch already known
    if self.__git_branch then
        return self.__git_branch
    end

    -- git root was not found
    if not self.__git_root then
        return nil
    end

    -- read current branch
    self.__git_branch = self:__read_git_branch()

    -- run poll of HEAD's changes
    self.__poll_head = uv.new_fs_event()
    uv.fs_event_start(self.__poll_head, path(self:git_root(), '.git', 'HEAD'), {}, function()
        self.__git_branch = self.__read_git_branch()
    end)

    return self.__git_branch
end

---Runs `git status` to ckeck the current status of the worktree.
---@param is_sync boolean If true, `git status` will be run in background and this method could return
---     not actual result, which eventially become correct.
---@return boolean | nil # The status of the worktree. In async mode can return nil at first time.
---   If `git_root` is absent, then nil will be returned.
function Git:is_worktree_changed(is_sync)
    -- git root was not found
    if not self.__git_root then
        return nil
    end

    -- `git status` is not run yet
    if not self.__git_status_job then
        local args = { 'status', '--porcelain', '--untracked-files=no' }

        self.__git_status_job = Job:new({
            command = 'git',
            args = args,
            cwd = self:git_root(),
            on_exit = function(_, exit_code)
                -- if list of changes was empty, but git status completed successfully,
                -- it means that worktree is not changed
                if exit_code == 0 and self.__git_status_job.stdout_was_empty then
                    self.__is_workspace_changed = false
                end
                self.__git_status_job = nil
            end,
            on_stdout = function(err, data)
                assert(not err, err)
                self.__git_status_job.stdout_was_empty = false
                self.__is_workspace_changed = #data > 0
            end,
        })
        self.__git_status_job.stdout_was_empty = true

        if is_sync then
            self.__git_status_job:sync()
        else
            self.__git_status_job:start()
        end
    end

    return self.__is_workspace_changed
end

return Git
