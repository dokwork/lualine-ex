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

define HELP
make [command]\nCommands:
  help     shows this help.
  install  downloads needed plugins.
  test     runs tests.
  fmt      formats lua files.
  build    prepares for pushing changes. It sequentially runs 'fmt' and 'test' tasks.
  demo     runs neovim with test configuration of the statusline.
  clean    cleans up all downloaded files

Hints:
--------------------
You can run separate test file or tests from a subdirectory passing 'only' parameter:
> make test only=components/git_branch_spec.lua
or
> make test only=components
\nTo turn on debug logs use 'DEBUG_PLENARY' with minimal log level or `true`:
> make test DEBUG_PLENARY=true
\nTo try the specific component in demo you can specify its name:
> make demo component=ex.lsp.all
\nYou can pass any argument to the demo task. For example,it can be a path to file which should be opened:
> make demo path=<path to file>

endef

help: export HELP:=$(HELP)
help:
	@echo "$$HELP"

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
