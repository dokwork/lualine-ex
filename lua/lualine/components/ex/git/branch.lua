local Git = require('lualine.ex.git_provider')
local ex = require('lualine.ex')

---@class GitBranchColors
---@field changed Color
---@field commited Color

---@class CropOptions
---@field side? string 'left' | 'right'
---@field stub? string

---@class GitBranchOptions: ExComponentOptions
---@field icon Icon
---@field sync boolean
---@field colors GitBranchColors
---@field max_length? number|fun(): number
local default_options = {
    icon = { ' ' },
    colors = {
        changed = { fg = 'orange' },
        commited = { fg = 'green' },
    },
    max_length = nil,
    crop = {
        stub = '…',
        side = nil,
    },
    is_enabled = function(component)
        return component.git():git_root() ~= nil
    end,
    fmt = ex.crop,
}

---Singleton instance for any non git paths
local empty_provider = {
    git_root = function() end,
    get_branch = function() end,
    is_worktree_changed = function() end,
}

-- global cache of git providers for {git_root}s.
-- It helps to reduce count of active providers.
local git_providers = {}

---@class GitBranch: ExComponent
---@field options GitBranchOptions
---@field git fun(): GitProvider
local GitBranch = require('lualine.ex.component'):extend(default_options)

function GitBranch:pre_init()
    if self.options.color then
        return
    end
    self.options.color = function()
        local is_worktree_changed = self.git and self.git():is_worktree_changed(self.options.sync)
        -- do not change color for unknown state
        if is_worktree_changed == nil then
            return self.options.disabled_color
        end
        return is_worktree_changed and self.options.colors.changed or self.options.colors.commited
    end
end

function GitBranch:post_init()
    self.git = function()
        -- the shortest way to get actual provider:
        if vim.b.ex_git_root and git_providers[vim.b.ex_git_root] then
            return git_providers[vim.b.ex_git_root]
        end
        local path = vim.fs.normalize(vim.fn.getcwd())
        local git_root = Git.find_git_root(path)
        if not git_root then
            return empty_provider
        end
        -- put git root to buffer local for optimization
        local buf_path = vim.fs.normalize(vim.fn.expand('%:p'))
        if #buf_path > 0 and string.find(path, buf_path) then
            -- we can't put provider to buf local, because metatable will be lost.
            vim.b.ex_git_root = git_root
        end
        -- looking for provider in the cache, or put a new
        if not git_providers[git_root] then
            git_providers[git_root] = Git:new(git_root)
        end
        return git_providers[git_root]
    end
end

function GitBranch:update_status()
    local branch_name = self.git():get_branch()
    return branch_name and branch_name:gsub('%%', '%%%%') or ''
end

return GitBranch
