#!/bin/bash

echo "Starting WebF Bridge Environment Setup..."

# 1. Update the package database and core system
pacman -Syu --noconfirm

# 2. Install the Toolchain & Dependencies
# These match the 'Setup MSYS2' step in your YAML exactly.
pacman -S --needed --noconfirm \
  mingw-w64-ucrt-x86_64-toolchain \
  mingw-w64-ucrt-x86_64-clang \
  mingw-w64-ucrt-x86_64-clang-tools-extra \
  mingw-w64-ucrt-x86_64-libc++ \
  mingw-w64-ucrt-x86_64-cmake \
  mingw-w64-ucrt-x86_64-ninja \
  mingw-w64-ucrt-x86_64-pkgconf \
  mingw-w64-ucrt-x86_64-gperf \
  mingw-w64-ucrt-x86_64-icu \
  mingw-w64-ucrt-x86_64-libiconv \
  mingw-w64-ucrt-x86_64-winpthreads \
  git make curl unzip

# 3. Configure Environment Variables
# Your CI sets CC=clang and CXX=clang++. We add this to .bashrc so it persists.
if ! grep -q "export CC=clang" ~/.bashrc; then
    echo "" >> ~/.bashrc
    echo "# WebF Bridge Env Vars" >> ~/.bashrc
    echo "export CC=clang" >> ~/.bashrc
    echo "export CXX=clang++" >> ~/.bashrc
    echo "export WEBF_JS_ENGINE=quickjs" >> ~/.bashrc
    echo "Environment variables added to ~/.bashrc"
fi

# Reload bashrc to apply changes immediately for this session
source ~/.bashrc

# 4. Install NVM and Node.js (Version 22)
# This replicates the CI 'Install NVM and Node.js' step.
# Note: This installs NVM *inside* MSYS2. It is separate from any Windows NVM you might have.

if [ ! -d "$HOME/.nvm" ]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
else
    echo "NVM already installed."
fi

# Load NVM for this script execution
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node 22
echo "Installing Node.js 22..."
nvm install 22
nvm use 22
nvm alias default 22

echo "--------------------------------------------------"
echo "Setup Complete!"
echo "Node Version: $(node --version)"
echo "Clang Version: $(clang --version | head -n 1)"
echo "Ninja Version: $(ninja --version)"
echo "--------------------------------------------------"
echo "Please restart your terminal or run 'source ~/.bashrc' before building."