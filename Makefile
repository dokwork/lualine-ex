.DEFAULT_GOAL = help

help:
	@echo "make [command]\nCommands:"
	@echo "  'help' to show this help."
	@echo "  'test' to run tests."
	@echo "  'fmt' to format lua files."
	@echo "  'nvim' to run neovim with test configuration of the statusline."
	@echo "  'check' to prepare for pushing changes. It sequentially run 'fmt' and 'test'."
	@echo "\nHints:\n"
	@echo "You can run separate test file or tests from a subdirectory passing 'only' parameter:"
	@echo "> make test only=components/git_branch_spec.lua"
	@echo "or"
	@echo "> make test only=components"
	@echo "\nTo turn on debug logs use 'DEBUG_PLENARY':"
	@echo "> make test DEBUG_PLENARY=true"

fmt:
	stylua .

test:
	nvim --headless -u tests/init.vim -c "lua require('plenary.test_harness').test_directory('tests/$(only)', {minimal_init='tests/init.vim',sequential=true})"

nvim:
	tests/try.sh $(path)

check: fmt test
