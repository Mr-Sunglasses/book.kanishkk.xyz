
default:
	@echo "Call a specific subcommand:"
	@echo
	@$(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null\
	| awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}'\
	| sort\
	| egrep -v -e '^[^[:alnum:]]' -e '^$@$$'
	@echo
	@exit 1

serve: book.toml src/
	@echo "Serving the book at http://localhost:3000"
	mdbook serve --open

build: book.toml src/
	@echo "Building the book"
	mdbook build

install: scripts/install_mdbook.sh
	@echo "Installing mdBook and required plugins"
	bash scripts/install_mdbook.sh

clean:
	@echo "Cleaning the book"
	mdbook clean
	@rm -rf book

.PHONY: default serve build install clean
