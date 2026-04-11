# [book.kanishkk.xyz](https://book.kanishkk.xyz)
An online fingerprint of my knowledge base

<p align="center">
    <img src="logo/logo.png">
</p>

## Setup
- Clone the Repo
```
git clone https://tangled.org/mr-sunglasses.tngl.sh/book.kanishkk.xyz/ 

cd book.kanishkk.xyz
```
- Install mdbook into your system ( using script )
```
cd scripts/

chmod +x install_mdbook.sh

./install_mdbook.sh
```

- Install mdbook into your system ( using make )
```
make install
```

- Install pre-commit to run spell checks (using [uv](https://docs.astral.sh/uv/getting-started/installation/))
```
uv install pre-commit
```

- Run pre-commit on all files
```
make pre-commit
```

- Run the book
```
make serve
```

- Build for the production
```
make build
```

- Clean the build
```
make clean
```
