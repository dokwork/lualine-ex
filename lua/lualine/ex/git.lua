local fs = vim.fs
local fn = vim.fn
local uv = vim.loop

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

---@class Git: Object
---@field new fun(git_root_path: string): Git
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
    local branch = string.match(head, 'ref: refs/heads/(%w+)')
        or string.match(head, 'ref: refs/tags/(%w+)')
        or string.match(head, 'ref: refs/remotes/(%w+)')
    return branch or head:sub(1, #head - 7)
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

function Git:is_workspace_changed()
    -- is_staged is already known
    if self.__staged then
        return true
    end

    -- git root was not found
    if not self.__git_root then
        return nil
    end

    return
end

return Git
