
default:
	@echo "Usage: make <target>"
	@echo ""
	@echo "Targets:"
	@echo "  build    Build the book"
	@echo "  serve    Serve the book locally at http://localhost:3000"
	@echo "  install  Install mdBook and required plugins"
	@echo "  clean    Remove build artifacts"
	@echo "  pre-commit-run  Run pre-commit hooks"
	@echo "  pre-commit-install  Install pre-commit hooks"

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

pre-commit-run: .pre-commit-config.yaml
	@echo "Running pre-commit hooks"
	pre-commit run --files src/

pre-commit-install: .pre-commit-config.yaml
	@echo "Installing pre-commit hooks"
	pre-commit install

.PHONY: default serve build install clean pre-commit
