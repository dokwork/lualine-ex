local log = require('plenary.log').new({
    plugin = 'git_branch_spec',
    use_file = false,
    use_console = 'sync',
})
local b = require('tests.ex.busted') --:ignore_all_tests()
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
            log.debug('Working directory for test is: ' .. vim.fn.getcwd())
        end)

        after_each(function()
            fs.remove(cwd)
        end)

        it('should be disabled', function()
            local c = l.init_component(component_name)
            eq(false, c:is_enabled())
        end)

        it('should have only icon with disabled color', function()
            local disabled_color = { fg = 'grey' }
            local opts = l.opts({ colors = { disabled = disabled_color } })
            local ctbl = l.extract_component(component_name, opts)
            eq(' ', ctbl.icon)
            l.eq_colors(disabled_color.fg, ctbl.icon_color.fg)
        end)
    end)

    describe('inside the git worktree', function()
        local git_root

        before_each(function()
            git_root = fs.mktmpdir()
            git.init(git_root)
            vim.cmd('cd ' .. git_root)
            log.debug('Working directory for test is: ' .. vim.fn.getcwd())
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
            local rendered_component = l.render_component(component_name)
            local ctbl = l.match_rendered_component(rendered_component)
            eq('  main', ctbl.value, 'Wrong value from: ' .. rendered_component)
        end)

        it('rendered component should have "commited" color', function()
            local commited_color = { fg = 'green' }
            local opts = l.opts({ colors = { commited = commited_color }, async = false })
            local rendered_component = l.render_component(component_name, opts)
            local ctbl = l.match_rendered_component(rendered_component)
            l.eq_colors(
                commited_color.fg,
                ctbl.color.fg,
                'Wrong color for component in ' .. rendered_component
            )
        end)
    end)
end)
