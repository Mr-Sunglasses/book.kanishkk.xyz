serve: book.toml src/
	@echo "Serving the book at http://localhost:3000"
	mdbook serve --open

build: book.toml src/
	@echo "Building the book"
	mdbook build

clean:
	@echo "Cleaning the book"
	mdbook clean
	@rm -rf book
