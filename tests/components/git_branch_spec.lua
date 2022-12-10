local log = require('plenary.log').new({
    plugin = 'git_branch_spec',
    use_file = false,
    use_console = 'sync',
})
local t = require('tests.ex.busted')--:ignore_all_tests()
local l = require('tests.ex.lualine')
local fs = require('tests.ex.fs')
local git = require('tests.ex.git')

local eq = assert.are.equal
local function trim(str)
    return string.match(str, '%s*(%S+)%s*')
end

local component_name = 'ex.git.branch'

describe('ex.git.branch component', function()
    describe('outside the git worktree', function()
        local cwd

        before_each(function()
            cwd = fs.mktmpdir()
            vim.cmd('cd ' .. cwd)
            log.info('Working directory for test is: ' .. vim.fn.getcwd())
        end)

        after_each(function()
            fs.remove(cwd)
        end)

        it('should be enabled', function()
            local c = l.init_component(component_name)
            eq(false, c:is_enabled())
        end)

        it('should have only icon with disabled hl', function()
            local c_tbl = l.extract_component(component_name)
            eq(' ', c_tbl.icon)
            eq('lualine_c_2_inactive', c_tbl.icon_hl)
        end)
    end)

    describe('inside the git worktree', function()
        local git_root

        before_each(function()
            git_root = fs.mktmpdir()
            git.init(git_root)
            vim.cmd('cd ' .. git_root)
            log.info('Working directory for test is: ' .. vim.fn.getcwd())
        end)

        after_each(function()
            fs.remove(git_root)
        end)

        it('should be enabled', function()
            local c = l.init_component(component_name)
            eq(true, c:is_enabled())
        end)

        it('should has status with a name of the current branch', function()
            local c = l.init_component(component_name)
            eq('main', c:update_status())
        end)

        it('rendered component should have a branch name and icon', function()
            local c_tbl = l.extract_component(component_name)
            eq('main', trim(c_tbl.value))
            eq(' ', c_tbl.icon)
        end)

        it('rendered component should have "commited" color', function()
            local c_tbl = l.extract_component(component_name)
            eq('lualine_c_2_inactive', c_tbl.icon_hl)
        end)
    end)
end)
