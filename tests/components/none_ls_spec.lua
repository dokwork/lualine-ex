local none_ls = require('null-ls')
local l = require('tests.ex.lualine')
local t = require('tests.ex.busted') --:ignore_all_tests()

local eq = assert.are.equal

local component_name = 'ex.lsp.none_ls'
describe(component_name, function()
    none_ls.setup({
        sources = {
            none_ls.builtins.completion.spell,
            none_ls.builtins.formatting.stylua,
            none_ls.builtins.hover.dictionary,
            none_ls.builtins.diagnostics.clang_check,
        },
    })
    describe('draw method', function()
        it('should show the name of any source only once', function()
            l.test_matched_component(component_name, function(ctbl)
                local expected = {
                    clang_check = true,
                    spell = true,
                    dictionary = true,
                    stylua = true,
                }
                for name in string.gmatch(ctbl.value, '%w+') do
                    assert(expected[name], 'Unexpected name ' .. name)
                    expected[name] = nil
                end
            end)
        end)
        it('by default should return only sources for the current filetypes or for all', function()
            vim.bo.filetype = 'lua'
            l.test_matched_component(component_name, opts, function(ctbl)
                for name in string.gmatch(ctbl.value, '%w+') do
                    assert(name ~= 'clang_check', 'Unexpected name ' .. name)
                end
            end)
        end)
        it('should show names only of sources sutisfied to the query', function()
            local opts = { query = { method = none_ls.methods.HOVER } }
            l.test_matched_component(component_name, opts, function(ctbl)
                eq('dictionary', ctbl.value)
            end)
        end)
    end)
end)
