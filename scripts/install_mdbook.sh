#!/bin/bash

set -e

# Check if mdbook is already installed
if command -v mdbook &> /dev/null; then
    echo "mdbook is already installed: $(mdbook --version)"
    exit 0
fi

# Create .local/bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Detect architecture
ARCH=$(uname -m)
case $ARCH in
    x86_64)
        ARCH="x86_64"
        ;;
    arm64|aarch64)
        ARCH="aarch64"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

# Detect OS
OS=$(uname -s)
case $OS in
    Linux)
        # Use musl for ARM64/aarch64 on Linux, gnu for x86_64
        if [ "$ARCH" = "aarch64" ]; then
            OS="unknown-linux-musl"
        else
            OS="unknown-linux-gnu"
        fi
        ;;
    Darwin)
        OS="apple-darwin"
        ;;
    *)
        echo "Unsupported OS: $OS"
        exit 1
        ;;
esac

# Download URL
BINARY_NAME="mdbook-v0.4.52-${ARCH}-${OS}.tar.gz"
DOWNLOAD_URL="https://github.com/rust-lang/mdBook/releases/download/v0.4.52/${BINARY_NAME}"

echo "Downloading mdbook from ${DOWNLOAD_URL}..."

# Download and extract
cd /tmp
curl -L -o "${BINARY_NAME}" "${DOWNLOAD_URL}"
tar -xzf "${BINARY_NAME}"

# Move to .local/bin
mv mdbook ~/.local/bin/

# Clean up
rm "${BINARY_NAME}"

# Add ~/.local/bin to PATH if not already there
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "Adding ~/.local/bin to PATH in your shell profile..."
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc 2>/dev/null || true
fi

echo "mdbook has been successfully installed in ~/.local/bin/"
echo "You may need to restart your terminal or run: export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "Verify installation by running: mdbook --version"