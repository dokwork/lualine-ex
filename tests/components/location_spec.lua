local l = require('tests.ex.lualine')
local t = require('tests.ex.busted') --:ignore_all_tests()

local eq = assert.are.equal

local orig = {
    line = vim.fn.line,
    virtcol = vim.fn.virtcol,
}
local mock = {
    line = {},
    virtcol = {},
}

local component_name = 'ex.location'
describe(component_name, function()
    before_each(function()
        vim.fn.line = function(arg)
            return mock.line[arg]
        end
        vim.fn.virtcol = function(arg)
            return mock.virtcol[arg]
        end
    end)

    after_each(function()
        vim.fn.line = orig.line
        vim.fn.virtcol = orig.virtcol
    end)

    describe('default patter', function()
        it('should show {line}:{column}/{total}', function()
            mock.virtcol['.'] = 11
            mock.line['.'] = 222
            mock.line['$'] = 3333
            local component = l.render_component(component_name)
            eq('11:222/3333', component)
        end)
        it('should fill numbers by space', function()
            mock.virtcol['.'] = 1
            mock.line['.'] = 2
            mock.line['$'] = 3
            local component = l.render_component(component_name)
            eq(' 1:2  /3', component)
        end)
    end)
end)
