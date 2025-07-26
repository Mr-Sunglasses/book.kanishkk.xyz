# mdbook deploy CI with netlify

```
name: Build and Deploy mdbook with Netlify CLI

on:
  push:
    branches: [ master ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4
    
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: '18'
    
    - name: Setup Rust
      uses: dtolnay/rust-toolchain@stable
    
    - name: Install mdbook
      run: cargo install mdbook
    
    - name: Install Netlify CLI
      run: npm install -g netlify-cli
    
    - name: Build mdbook
      run: mdbook build
    
    - name: Deploy to Netlify
      run: netlify deploy --prod --dir=book
      env:
        NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
        NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
```

The following code will help you to setup a CI pipeline, in which when we push out code to the branch specifies, it automatically build the mdbook and deploy it to the netlify using netlify cli.

*[HowTo add secrets into your github repo](https://www.youtube.com/shorts/8H1HEi9atJA)*

*Note:* You need to add the following secrets into your github repo:
- NETLIFY_AUTH_TOKEN [Guide on HowTo get a netlify auth token](https://developers.netlify.com/videos/get-started-with-netlify-api/)
- NETLIFY_SITE_ID [Guide on HowTo get a netlify site id](https://docs.netlify.com/api-and-cli-guides/cli-guides/get-started-with-cli/#link-with-an-environment-variable)
