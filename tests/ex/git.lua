local log = require('plenary.log').new({
    plugin = 'tests.ex.git',
    use_file = false,
    use_console = 'sync',
})

local Git = {}

local dev_null = (vim.env.DEBUG or vim.env.DEBUG_PLENARY) and '' or ' &> /dev/null'

local function git(git_root, ...)
    local cmd = table.concat({ ... }, ' ')
    cmd = string.format('git -C %s %s %s', git_root, cmd, dev_null)
    log.debug('Execute: ' .. cmd)
    os.execute(cmd)
end

function Git.init(git_root, branch)
    branch = branch or 'main'
    git(git_root, 'init', '-b', branch)
end

function Git.add(git_root, file)
    git(git_root, 'add', file)
end

function Git.commit(git_root, message)
    git(git_root, 'commit', '-m', '"' .. message .. '"')
end

return Git
