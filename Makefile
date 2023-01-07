.DEFAULT_GOAL = help

help:
	@echo "make [command]\nCommands:"
	@echo "  help     to show this help."
	@echo "  test     to run tests."
	@echo "  fmt      to format lua files."
	@echo "  build    to prepare for pushing changes. It sequentially runs 'fmt' and 'test' tasks."
	@echo "  demo     to run neovim with test configuration of the statusline." 
	@echo "           If someting is going wrong, try to use 'prepare' command."
	@echo "  prepare  to prepare neovim with test configuration of the statusline."
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

check:
	stylua --check .

fmt:
	stylua .

test:
	nvim --headless -u tests/test_init.vim -c "lua require('plenary.test_harness').test_directory('tests/$(only)', {minimal_init='tests/test_init.vim',sequential=true})"

demo:
	tests/try.sh $(path)

prepare:
	tests/try.sh --prepare

build: fmt test
