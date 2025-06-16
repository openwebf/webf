# Running WebF Cupertino UI Example on macOS

This guide explains how to run the WebF Cupertino UI example application on macOS.

## Prerequisites

1. **Flutter SDK**: Make sure you have Flutter installed and configured for macOS development
   ```bash
   flutter doctor
   ```

2. **Xcode**: Install Xcode from the Mac App Store

3. **CocoaPods**: Install CocoaPods if not already installed
   ```bash
   sudo gem install cocoapods
   ```

## Running the Example

1. **Install dependencies**:
   ```bash
   cd webf_cupertino_ui/example
   flutter pub get
   ```

2. **Install CocoaPods dependencies**:
   ```bash
   cd macos
   pod install
   cd ..
   ```

3. **Run the application**:
   ```bash
   flutter run -d macos
   ```

## macOS Configuration

The example app is configured with the following macOS-specific settings:

### Entitlements
- **JIT Compilation**: Enabled for WebF's JavaScript engine
- **Network Access**: Client and server network access enabled
- **File Access**: User-selected file read/write access
- **App Sandbox**: Disabled for development (required for WebF)

### Window Configuration
- Default size: 1200x800 pixels
- Minimum size: 800x600 pixels
- Window is resizable and centered on startup

### Platform Requirements
- macOS 12.4 or later
- Flutter 3.0 or later

## Troubleshooting

1. **Build errors**: If you encounter build errors, try:
   ```bash
   flutter clean
   cd macos
   pod deintegrate
   pod install
   cd ..
   flutter pub get
   flutter run -d macos
   ```

2. **WebF loading issues**: Ensure your local WebF package is properly built:
   ```bash
   cd ../../webf
   npm run build:bridge:macos
   ```

3. **Permission issues**: The app requires network access and JIT compilation. These are configured in the entitlements files.

## Building for Release

To build a release version:
```bash
flutter build macos --release
```

The built app will be located at `build/macos/Build/Products/Release/WebF Cupertino UI Example.app`

## Notes

- The example uses a local path dependency for WebF during development
- For production, update the pubspec.yaml to use the hosted WebF package
- The Vue.js Cupertino Gallery example requires building the Vue app first (see main README)