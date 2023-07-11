.DEFAULT_GOAL = help

ifndef TMPDIR
	TMPDIR=/tmp
endif

ROOT = $(TMPDIR)/lualine-ex

export XDG_CONFIG_HOME=$(ROOT)/config

START=$(XDG_CONFIG_HOME)/nvim/pack/dokwork/start

PLENARY=$(START)/plenary.nvim
DEVICONS=$(START)/nvim-web-devicons
LSPCONFIG=$(START)/lualine.nvim
LUALINE=$(START)/nvim-lspconfig

help:
	@echo "make [command]\nCommands:"
	@echo "  help     to show this help."
	@echo "  install  to download needed plugins."
	@echo "  test     to run tests."
	@echo "  fmt      to format lua files."
	@echo "  build    to prepare for pushing changes. It sequentially runs 'fmt' and 'test' tasks."
	@echo "  demo     to run neovim with test configuration of the statusline." 
	@echo "\nHints:\n"
	@echo "You can run separate test file or tests from a subdirectory passing 'only' parameter:"
	@echo "> make test only=components/git_branch_spec.lua"
	@echo "or"
	@echo "> make test only=components"
	@echo "\nTo turn on debug logs use 'DEBUG_PLENARY' with minimal log level or `true`:"
	@echo "> make test DEBUG_PLENARY=true"
	@echo "\nTo try the specific component in demo you can specify its name:"
	@echo "> make demo component=ex.lsp.all"
	@echo "\nYou can pass any argument to the demo task. For example,it can be a path to file which should be opened:"
	@echo "> make demo path=<path to file>"

clean:
	rm -rf $(XDG_CONFIG_HOME)

check:
	stylua --check .

fmt:
	stylua .

install:
	@[ -d $(PLENARY) ] || git clone --depth 1 https://github.com/nvim-lua/plenary.nvim $(PLENARY)
	@[ -d $(DEVICONS)/ ] || git clone --depth 1 https://github.com/nvim-tree/nvim-web-devicons $(DEVICONS)
	@[ -d $(LSPCONFIG)/ ] || git clone --depth 1 https://github.com/neovim/nvim-lspconfig $(LSPCONFIG)
	@[ -d $(LUALINE)/ ] || git clone --depth 1 https://github.com/nvim-lualine/lualine.nvim $(LUALINE)

test: install
	nvim --headless -u tests/init.lua -c "PlenaryBustedDirectory  tests/$(only) {minimal_init='tests/init.lua',sequential=true}"

demo: install
	nvim -u tests/init.lua $(path)

build: fmt test
