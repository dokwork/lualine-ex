local log = require('plenary.log').new({ plugin = 'ex.lsp.null-ls' })

-- This is a component mock to notify about not back compatibly renaming
-- of the component `ex.lsp.null_ls` to the `ex.lsp.none_ls`
local NullLS = require('lualine.components.ex.lsp.none_ls'):extend({
    component_name = 'ex_lsp_null_ls',
})

function NullLS:post_init()
    log.warn(
        'The `ex.lsp.null_ls` component was renamed to `ex.lsp.none_ls`. Please, use the actual component.'
    )
end

return NullLS
