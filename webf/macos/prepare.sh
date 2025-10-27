read_version() {
  VERSION_STR=$(cat webf.podspec | grep s.version | awk '{print $3}')
  END_POS=$(echo ${#VERSION_STR} - 2 | bc)
  export VERSION=${VERSION_STR:1:$END_POS}
}

ROOT=$(pwd)
BRIDGE_BUILD_DIR="$ROOT/../../bridge/build/macos/lib"

# Function to copy library with fallback to architecture-specific versions
copy_library() {
  local lib_name=$1
  local target_file="$ROOT/$lib_name"
  
  # Resolve a valid source path first; only then remove/copy
  local src_file=""
  # Prefer universal binary if available
  if [ -f "$BRIDGE_BUILD_DIR/universal/$lib_name" ]; then
    src_file="$BRIDGE_BUILD_DIR/universal/$lib_name"
    echo "Copying universal $lib_name"
  # Fallback to architecture-specific library based on current architecture
  elif [ "$(uname -m)" = "arm64" ] && [ -f "$BRIDGE_BUILD_DIR/arm64/$lib_name" ]; then
    src_file="$BRIDGE_BUILD_DIR/arm64/$lib_name"
    echo "Copying arm64 $lib_name"
  elif [ "$(uname -m)" = "x86_64" ] && [ -f "$BRIDGE_BUILD_DIR/x86_64/$lib_name" ]; then
    src_file="$BRIDGE_BUILD_DIR/x86_64/$lib_name"
    echo "Copying x86_64 $lib_name"
  fi

  if [ -n "$src_file" ]; then
    # Only remove existing file or symlink if a valid source exists
    if [ -e "$target_file" ] || [ -L "$target_file" ]; then
      rm -f "$target_file"
    fi
    cp "$src_file" "$target_file"
  else
    echo "Warning: Could not find source for $lib_name in $BRIDGE_BUILD_DIR"
    echo "Available architectures:"
    ls -la "$BRIDGE_BUILD_DIR/" 2>/dev/null || echo "Bridge build directory not found"
  fi
}

# Copy libraries
copy_library "libwebf.dylib"
copy_library "libquickjs.dylib"
