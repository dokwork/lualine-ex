.DEFAULT_GOAL = help

ifndef TMPDIR
	TMPDIR=/tmp
endif

ROOT = $(TMPDIR)/lualine-ex

export XDG_CONFIG_HOME=$(ROOT)/config

START=$(XDG_CONFIG_HOME)/nvim/pack/dokwork/start

# === Dependencies ===
# Common for the plugin
PLENARY=$(START)/plenary.nvim
DEVICONS=$(START)/nvim-web-devicons
LUALINE=$(START)/nvim-lspconfig

# Specific for components:
LSPCONFIG=$(START)/lualine.nvim
NONE_LS=$(START)/none-ls.nvim
# ====================

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

To turn on debug logs use 'DEBUG_PLENARY' with minimal log level or `true`:
> make test DEBUG_PLENARY=true

To try the specific component in demo you can specify its name:
> make demo component=ex.cwd

You can pass a path to file which should be opened in demo:
> make demo component=ex.cwd path=<path to file>

Also, you can pass custom options to the demo component as a json:
> make demo component=ex.cwd component_opts='{ "depth": 1 }'

If a component needs additional plugin, you can install it if specify
'plugin' name as <github user>/<github repo>:
> make install plugin nvimtools/none-ls.nvim

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
	@[ -d $(DEVICONS) ] || git clone --depth 1 https://github.com/nvim-tree/nvim-web-devicons $(DEVICONS)
	@[ -d $(LSPCONFIG) ] || git clone --depth 1 https://github.com/neovim/nvim-lspconfig $(LSPCONFIG)
	@[ -d $(LUALINE) ] || git clone --depth 1 https://github.com/nvim-lualine/lualine.nvim $(LUALINE)
	@[ -d $(NONE_LS) ] || git clone --depth 1 https://github.com/nvimtools/none-ls.nvim $(NONE_LS)
ifdef plugin
	@[ -d $(START)/$(notdir $(plugin)) ] || git clone --depth 1 https://github.com/$(plugin) $(START)/$(notdir $(plugin))
endif

test: install
	nvim --headless -u tests/init.lua -c "PlenaryBustedDirectory  tests/$(only) {minimal_init='tests/init.lua',sequential=true}"

demo: install
	nvim -u tests/init.lua $(path)

build: fmt test
