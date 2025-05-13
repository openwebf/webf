# WebF Package Preparation Script

## Overview
The `prepare_webf_package.js` script prepares the WebF package for publishing by handling the necessary file copying, patching, and git operations. This script replaces the legacy implementation in `scripts/pre_publish_webf.js`.

## Key Changes
The main difference from the legacy implementation is that iOS frameworks are now compiled from source rather than using symbol-to-file copying.

## Script Functions

### 1. Dynamic Library Handling
- macOS dynamic libraries (`libwebf.dylib` and `libquickjs.dylib`) are copied from `bridge/build/macos/lib/x86_64/` to `webf/macos` folder
- Existing destination files are deleted before copying to ensure clean replacement

### 2. C/C++ Source Files
- For platforms other than macOS, essential C/C++ sources from `bridge/` folder are copied into `webf/src` folder
- The script completely cleans the destination directory before copying to avoid leftover files
- Directory structure mirrors the reference links in the webf/ios platform

### 3. Windows Support
- The `webf/windows/CMakeLists.txt` is patched to use `src` instead of `win_src`

### 4. Version Information
- App revision and version are patched in both:
  - `webf/src/CMakeLists.txt`
  - `webf/ios/webf.podspec`
- Values are derived from git commit hash and app version information

### 5. Git Operations
- Files are added to git and committed with appropriate metadata
- If present, the win_src directory is removed

## Usage
Run the script from the project root:
```bash
node scripts/prepare_webf_package.js
```

## Implementation Details
- Handles platform-specific operations for both Windows and Unix-like systems
- Includes comprehensive error handling and logging
- Automatically removes existing files before copying to prevent conflicts
- Uses smart path resolution to ensure consistency across platforms

Created: May 5, 2025  
Last Updated: May 5, 2025