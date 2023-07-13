---This is util to work with git.
---@class Git
---@field apply fun(git_root: string) create a new instance of the {Git} to work with git
---  inside the {git_root}.
---@field git fun(...) execute git with passed arguments.
---@field init fun(branch: string) init a new git repo with branch named {branch}.
---@field checkout fun(branch_name: string) checkout {branch_name}.
---@field new_branch fun(branch_name) creates a new branch.
local Git = {}

local log = require('plenary.log').new({
    plugin = 'tests.ex.git',
    use_file = false,
    use_console = 'sync',
})

local dev_null = (vim.env.DEBUG or vim.env.DEBUG_PLENARY) and '' or ' &> /dev/null'

setmetatable(Git, {
    __call = function(_, git_root)
        local obj = {
            git_root = git_root,
        }
        setmetatable(obj, { __index = Git })
        return obj
    end,
})

function Git:git(...)
    local cmd = table.concat({ ... }, ' ')
    cmd = string.format('git -C %s %s %s', self.git_root, cmd, dev_null)
    log.debug('Execute: ' .. cmd)
    os.execute(cmd)
end

function Git:init(branch)
    branch = branch or 'main'
    self:git('init', '-b', branch)
end

function Git:checkout(branch_name)
    self:git('checkout', branch_name)
end

function Git:add(file)
    self:git('add', file)
end

function Git:commit(message)
    self:git('commit', '-m', '"' .. message .. '"')
end

function Git:new_branch(branch_name)
    self:git('checkout', '-b', branch_name)
end

return Git
