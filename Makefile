.DEFAULT_GOAL = help

help:
	@echo "make [command]\nCommands:"
	@echo "'help' to show this help"
	@echo "'test' to run tests"
	@echo "'fmt' to format lua files"
	@echo "\nHints:\nYou can run separate test file or tests from asubdirectory passing 'only' parameter:\n> make test only=components\n"
	@echo "To turn on debug logs use 'DEBUG_PLENARY':\n> make test DEBUG_PLENARY=true"

fmt:
	stylua .

test:
	nvim --headless -u tests/init.vim -c "lua require('plenary.test_harness').test_directory('tests/$(only)', {minimal_init='tests/init.vim',sequential=true})"
