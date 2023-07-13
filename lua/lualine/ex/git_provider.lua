---Provides utils to find the current working directory and the name of git branch.
---@class GitProvider: Object
---@field new fun(git_root_path: string): GitProvider Creates a new {Git} provider instance around {git_root_path}.
local Git = require('lualine.utils.class'):extend()

local fs = vim.fs
local fn = vim.fn
local uv = vim.loop

local Job = require('plenary.job')
local log = require('plenary.log').new({
    plugin = 'ex.git_provider',
    use_console = vim.env.PLENARY_USE_CONSOLE or 'async',
})

local sep = package.config:sub(1, 1)
local function make_path(...)
    local args = { ... }
    return vim.fn.join(args, sep)
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

---This static method looks for the path with `.git/` directory outside the {path}.
---@param path string The path to the directory or file, from which the search of
---   the `.git/` directory should begun.
---@return string # The path to the root of the git workspace, or nil.
function Git.find_git_root(path)
    local function is_git_dir(path)
        local dir = make_path(path, '.git')
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
    -- the path must be real
    local p, err = uv.fs_realpath(git_root_path)
    if p then
        -- the path must be the git root
        local _, err = uv.fs_realpath(make_path(p, '.git'))
        p = (not err and p) or nil
    end
    self.__git_root = p
    self.__git_root_err = err
    if p then
        log.fmt_debug('Provider for %s has been created.', p)
    elseif err then
        log.fmt_error('Error on creating provider: %s', err)
    end
end

---Reads '{git_root}/.git/HEAD' file and gets the name of the current git branch, or the first 7
---symbols of the commit sha.
---@return string # The name of the current branch or first 7 symbols of the commit's hash.
function Git:read_git_branch()
    local path = make_path(self:git_root(), '.git', 'HEAD')
    local head = read(path)
    log.fmt_debug('Read a name of the git branch. Content of the %s:\n%s', path, head)
    local name_pattern = '(%S+)'
    local branch = head
        and (
            string.match(head, 'ref: refs/heads/' .. name_pattern)
            or string.match(head, 'ref: refs/tags/' .. name_pattern)
            or string.match(head, 'ref: refs/remotes/' .. name_pattern)
        )
    return branch or (head and head:sub(1, #head - 7))
end

---Returns a path to the root git directory, or nil with error message if path is not exists.
function Git:git_root()
    return self.__git_root, self.__git_root_err
end

---Returns a name of the current git branch. The result of this function changes only when
---HEAD file was changed.
function Git:get_branch()
    -- git root was not found
    if not self.__git_root then
        return nil
    end

    -- git branch already known
    if self.__git_branch then
        return self.__git_branch
    end

    -- read the name of the current branch
    self.__git_branch = self:read_git_branch()

    -- run poll of HEAD's changes
    self:__poll_head(make_path(self:git_root(), '.git', 'HEAD'))

    return self.__git_branch
end

function Git:__poll_head(path)
    local is_os_windows = sep == [[\]]
    self.__poll_event = self.__poll_event
        or (is_os_windows and uv.new_fs_poll() or uv.new_fs_event())
    log.fmt_debug('Start %s for %s', is_os_windows and 'fs_poll' or 'fs_event', path)
    self.__poll_event:start(
        path,
        is_os_windows and 1000 or {},
        vim.schedule_wrap(function(err, filename, event)
            if err then
                log.fmt_warn('Error happened on polling %s: %s', filename, err)
            else
                log.fmt_debug('New update for %s: %s', filename, event)
                self.__git_branch = self:read_git_branch()
            end
            self.__poll_event:stop()
            self:__poll_head(path)
        end)
    )
end

---Runs `git status` to check the current status of the worktree.
---@param is_sync boolean If true, `git status` will be run in background and this method could return
---     not actual result, which eventually become correct.
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
