local l = require('tests.ex.lualine')
local t = require('tests.ex.busted') --:ignore_all_tests()

local eq = assert.are.equal

local orig = {
    line = vim.fn.line,
}
local mock = {
    line = {},
}

local component_name = 'ex.progress'

describe(component_name, function()
    before_each(function()
        vim.fn.line = function(arg)
            return mock.line[arg]
        end
    end)

    after_each(function()
        vim.fn.line = orig.line
    end)

    describe('in "percent" (default) mode', function()
        it('should show "Top" when the cursor is on bottom of the buffer', function()
            -- { line, total, expected percent }
            local cases = {
                { 1, 100, 'Top' },
                { 1, 1000, 'Top' },
                { 2, 1000, '  1%%' },
            }
            for _, case in ipairs(cases) do
                mock.line['.'] = case[1]
                mock.line['$'] = case[2]
                local c = l.render_component(component_name)
                eq(case[3], c, vim.inspect(case))
            end
        end)
        it('should show "Bot" when the cursor is on bottom of the buffer', function()
            -- { line, total, expected percent }
            local cases = {
                { 100, 100, 'Bot' },
                { 1000, 1000, 'Bot' },
                { 999, 1000, ' 99%%' },
            }
            for _, case in ipairs(cases) do
                mock.line['.'] = case[1]
                mock.line['$'] = case[2]
                local c = l.render_component(component_name)
                eq(case[3], c, vim.inspect(case))
            end
        end)
        it('should show expected persentage of the buffer', function()
            -- { line, total, expected percent }
            local cases = {
                { 1, 100, 1 },
                { 100, 100, 100 },
                { 17, 111, 16 },
            }
            for _, case in ipairs(cases) do
                mock.line['.'] = case[1]
                mock.line['$'] = case[2]
                local c = l.render_component(component_name, { top = false, bottom = false })
                eq(string.format('%3d%%%%', case[3]), c, vim.inspect(case))
            end
        end)
    end)

    describe('in "bar" mode, or "tabe" mode', function()
        it('should show appropriate symbol', function()
            -- { line, total, expected percent }
            local cases = {
                { 1, 100, '█' },
                { 100, 100, ' ' },
                { 99, 100, '▁' },
                { 7, 9, '▂' },
                { 19, 31, '▄' },
            }
            for _, case in ipairs(cases) do
                mock.line['.'] = case[1]
                mock.line['$'] = case[2]
                local c = l.render_component(
                    component_name,
                    { top = false, bottom = false, mode = 'bar' }
                )
                eq(case[3], c, vim.inspect(case))
            end
        end)
    end)
end)
