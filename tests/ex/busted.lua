---@diagnostic disable: lowercase-global
local M = {}

function M.except_it(desc, fun)
    require('plenary.busted').it(desc, fun)
end

M.ignore_all_tests = function(self)
    it = function() end
    return self
end

return M
