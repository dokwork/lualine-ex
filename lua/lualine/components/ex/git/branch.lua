local Git = require('lualine.ex.git')

---@class GitBranchColors
---@field changed Color
---@field commited Color

---@class GitBranchOptions: ExComponentOptions
---@field icon Icon
---@field colors GitBranchColors
local default_options = {
    icon = ' ',
    colors = {
        changed = { fg = 'orange' },
        commited = { fg = 'green' },
    },
}

local git_providers = {}

---@class GitBranch: ExComponent
---@field options GitBranchOptions
---@field git fun(): GitProvider
local GitBranch = require('lualine.ex.component'):extend(default_options)

function GitBranch:setup()
    self.git = function()
        if vim.b.ex_git_provider then
            return vim.b.ex_git_provider
        end
        local path = vim.fn.expand('%:p')
        local git_root = Git.find_git_root(path)
        if not git_root then
            vim.b.ex_git_provider = Git(path)
        end
        if git_root and not git_providers[git_root] then
            git_providers[git_root] = Git(git_root)
        end
        if git_root and git_providers[git_root] then
            vim.b.ex_git_provider = git_providers[git_root]
        end
        return vim.b.ex_git_provider
    end
end

function GitBranch:is_enabled()
    return self.git():git_root() ~= nil
end

function GitBranch:update_status()
    local colors = self.options.colors
    local is_worktree_changed = self.git():is_worktree_changed({ only_index = true, is_async = true })
    self.options.color = is_worktree_changed and colors.changed or colors.commited
    return self.git():get_branch() or ''
end

return GitBranch
