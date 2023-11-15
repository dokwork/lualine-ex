local log = require('plenary.log').new({
    plugin = 'git_branch_spec',
    use_file = false,
    use_console = 'sync',
})
local t = require('tests.ex.busted') --:ignore_all_tests()
local l = require('tests.ex.lualine')
local fs = require('tests.ex.fs')
local Git = require('tests.ex.git')

local eq = assert.are.equal

local component_name = 'ex.git.branch'

describe('ex.git.branch component', function()
    describe('outside the git worktree', function()
        local cwd

        before_each(function()
            cwd = fs.mktmpdir()
            vim.cmd('cd ' .. cwd)
            log.debug('Working directory for test is: ' .. vim.fn.getcwd())
        end)

        after_each(function()
            fs.remove(cwd)
        end)

        it('should be disabled', function()
            local c = l.init_component(component_name)
            ---@cast c ExComponent
            eq(false, c:is_enabled())
        end)

        it('should have only icon with disabled color', function()
            local disabled_color = { fg = 'grey' }
            local opts = l.opts({ colors = { disabled = disabled_color } })
            local rc = l.render_component(component_name, opts)
            local ctbl = l.match_rendered_component(rc)
            eq(' ', ctbl.icon, 'Wrong icon in ' .. rc)
            l.eq_colors(disabled_color.fg, ctbl.icon_color.fg, 'Wrong color for icon in ' .. rc)
        end)
    end)

    describe('inside the git worktree', function()
        local git_root
        local git

        before_each(function()
            git_root = fs.mktmpdir()
            git = Git(git_root)
            git:init('main')
            vim.cmd('cd ' .. git_root)
            log.debug('Working directory for test is: ' .. vim.fn.getcwd())
        end)

        after_each(function()
            fs.remove(git_root)
        end)

        it('should be enabled', function()
            local c = l.init_component(component_name)
            ---@cast c ExComponent
            eq(true, c:is_enabled())
        end)

        it('should has status with a name of the current branch', function()
            git:checkout('main')
            local c = l.init_component(component_name)
            eq('main', c:update_status())
        end)

        it('should escape % symbols in a name of the current branch', function()
            local branch = '%branch'
            git:new_branch(branch)
            local c = l.init_component(component_name)
            eq('%' .. branch, c:update_status())
        end)

        it('should crop branch name', function()
            -- let's use symbols which are not equal to one byte,
            -- to bu sure that crop works correctly
            local branch = 'абвгд'
            git:new_branch(branch)
            local opts = { max_length = 4, crop = { side = 'right', stub = '!' } }
            l.test_matched_component(component_name, opts, function(ctbl)
                eq('абв!', ctbl.value)
            end)
        end)

        it('a rendered component should have the branch name and the icon', function()
            git:checkout('main')
            l.test_matched_component(component_name, opts, function(ctbl)
                eq('', ctbl.icon)
                eq('main', ctbl.value)
            end)
        end)

        it('rendered component should have "committed" color', function()
            local commited_color = { fg = 'blue' }
            local opts = l.opts({ colors = { commited = commited_color }, sync = true })
            l.test_matched_component(component_name, opts, function(ctbl)
                l.eq_colors(commited_color.fg, ctbl.color.fg)
            end)
        end)
    end)
end)
