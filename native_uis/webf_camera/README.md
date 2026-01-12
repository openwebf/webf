# WebF Camera

Camera component for WebF applications. Wraps Flutter's `camera` package as an HTML custom element for capturing photos and videos.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  webf_camera: ^0.1.0
```

## Setup

Register the custom element in your Flutter app's main function:

```dart
import 'package:webf_camera/webf_camera.dart';

void main() {
  installWebFCamera();
  runApp(MyApp());
}
```

## Usage

### React

Install the React package:

```bash
npm install @openwebf/react-camera
```

Basic usage:

```tsx
import { useRef } from 'react';
import { FlutterCamera, FlutterCameraElement } from '@openwebf/react-camera';

function CameraApp() {
  const cameraRef = useRef<FlutterCameraElement>(null);

  const handleCameraReady = (e: CustomEvent) => {
    console.log('Camera ready:', e.detail);
    console.log('Zoom range:', e.detail.minZoom, '-', e.detail.maxZoom);
  };

  const takePicture = () => {
    cameraRef.current?.takePicture();
  };

  return (
    <div>
      <FlutterCamera
        ref={cameraRef}
        facing="back"
        resolution="high"
        flashMode="auto"
        autoInit={true}
        enableAudio={true}
        style={{ width: '100%', height: '400px' }}
        onCameraready={handleCameraReady}
        onPhotocaptured={(e) => console.log('Photo:', e.detail.path)}
        onCapturefailed={(e) => console.error('Failed:', e.detail.error)}
      />
      <button onClick={takePicture}>Take Photo</button>
    </div>
  );
}
```

### Vue

Install the Vue package:

```bash
npm install @openwebf/vue-camera
```

Basic usage:

```vue
<template>
  <div>
    <FlutterCamera
      ref="cameraRef"
      facing="back"
      resolution="high"
      flash-mode="auto"
      :auto-init="true"
      :enable-audio="true"
      :style="{ width: '100%', height: '400px' }"
      @cameraready="handleCameraReady"
      @photocaptured="handlePhotoCaptured"
      @camerafailed="handleCameraFailed"
    />
    <button @click="takePicture">Take Photo</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue';
import { FlutterCamera } from '@openwebf/vue-camera';

const cameraRef = ref<InstanceType<typeof FlutterCamera> | null>(null);

const handleCameraReady = (e: CustomEvent) => {
  console.log('Camera ready:', e.detail);
  console.log('Zoom range:', e.detail.minZoom, '-', e.detail.maxZoom);
};

const handlePhotoCaptured = (e: CustomEvent) => {
  console.log('Photo saved to:', e.detail.path);
};

const handleCameraFailed = (e: CustomEvent) => {
  console.error('Camera error:', e.detail.error);
};

const takePicture = () => {
  cameraRef.value?.$el.takePicture();
};
</script>
```

### HTML Custom Element

Basic example:

```html
<flutter-camera></flutter-camera>
```

With options:

```html
<flutter-camera
  facing="back"
  resolution="high"
  flash-mode="auto"
  enable-audio="true"
  auto-init="true"
></flutter-camera>
```

### JavaScript Control

```javascript
const camera = document.querySelector('flutter-camera');

// Listen for camera ready
camera.addEventListener('cameraready', (e) => {
  console.log('Available cameras:', e.detail.cameras);
  console.log('Zoom range:', e.detail.minZoom, '-', e.detail.maxZoom);
});

// Take a photo
camera.takePicture();

// Listen for photo captured
camera.addEventListener('photocaptured', (e) => {
  console.log('Photo saved to:', e.detail.path);
});

// Record video
camera.startVideoRecording();
// ... recording ...
camera.stopVideoRecording();

// Listen for recording stopped
camera.addEventListener('recordingstopped', (e) => {
  console.log('Video saved to:', e.detail.path);
});

// Switch between front/back cameras
camera.switchCamera();

// Control zoom
camera.setZoomLevel(2.0);

// Set flash mode
camera.setFlashMode('torch');

// Set focus point (normalized 0-1 coordinates)
camera.setFocusPoint(0.5, 0.5);

// Handle errors
camera.addEventListener('camerafailed', (e) => {
  console.error('Camera error:', e.detail.error, e.detail.code);
});
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `facing` | string | 'back' | Camera facing: 'front', 'back', 'external' |
| `resolution` | string | 'high' | Resolution: 'low', 'medium', 'high', 'veryHigh', 'ultraHigh', 'max' |
| `flash-mode` | string | 'auto' | Flash mode: 'off', 'auto', 'always', 'torch' |
| `enable-audio` | boolean | true | Enable audio for video recording |
| `auto-init` | boolean | true | Auto-initialize camera on mount |
| `zoom` | number | 1.0 | Current zoom level |
| `exposure-offset` | number | 0.0 | Current exposure offset |
| `focus-mode` | string | 'auto' | Focus mode: 'auto', 'locked' |
| `exposure-mode` | string | 'auto' | Exposure mode: 'auto', 'locked' |

## Methods

### Async Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `initialize()` | Promise<void> | Initialize the camera |
| `dispose()` | Promise<void> | Dispose camera resources |
| `takePicture()` | Promise<CaptureResult> | Take a photo |
| `startVideoRecording()` | Promise<void> | Start video recording |
| `stopVideoRecording()` | Promise<VideoResult> | Stop video recording |
| `pauseVideoRecording()` | Promise<void> | Pause video recording (iOS only) |
| `resumeVideoRecording()` | Promise<void> | Resume video recording (iOS only) |
| `switchCamera()` | Promise<void> | Switch between cameras |
| `setFlashMode(mode)` | Promise<void> | Set flash mode |
| `setZoomLevel(zoom)` | Promise<void> | Set zoom level (1.0 to maxZoom) |
| `setExposureOffset(offset)` | Promise<number> | Set exposure offset |
| `setFocusPoint(x, y)` | Promise<void> | Set focus point (normalized 0-1) |
| `setExposurePoint(x, y)` | Promise<void> | Set exposure point (normalized 0-1) |
| `lockCaptureOrientation(orientation)` | Promise<void> | Lock capture orientation |
| `unlockCaptureOrientation()` | Promise<void> | Unlock capture orientation |
| `getAvailableCameras()` | Promise<CameraInfo[]> | Get available cameras |

### Sync Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `getMinZoomLevel()` | number | Get minimum zoom level |
| `getMaxZoomLevel()` | number | Get maximum zoom level |
| `getMinExposureOffset()` | number | Get minimum exposure offset |
| `getMaxExposureOffset()` | number | Get maximum exposure offset |

## Events

| Event | Detail | Description |
|-------|--------|-------------|
| `cameraready` | `{cameras, currentCamera, minZoom, maxZoom, minExposureOffset, maxExposureOffset}` | Camera initialized |
| `camerafailed` | `{error, code}` | Camera initialization failed |
| `photocaptured` | `{path, width, height, size}` | Photo captured successfully |
| `capturefailed` | `{error}` | Photo capture failed |
| `recordingstarted` | - | Video recording started |
| `recordingstopped` | `{path, duration}` | Video recording stopped |
| `recordingfailed` | `{error}` | Video recording failed |
| `cameraswitched` | `{facing, camera}` | Camera switched |
| `zoomchanged` | `{zoom}` | Zoom level changed |
| `focusset` | `{x, y}` | Focus point set |
| `cameradisposed` | - | Camera disposed |

## Error Codes

| Code | Description |
|------|-------------|
| `NO_CAMERAS` | No cameras available on device |
| `INIT_ERROR` | Failed to initialize cameras |
| `CONTROLLER_ERROR` | Failed to create camera controller |

## Platform Configuration

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for taking photos and videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for recording video with audio.</string>
```

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

Set minimum SDK version in `android/app/build.gradle`:

```gradle
minSdkVersion 21
```

### macOS

Add to `macos/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for taking photos and videos.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for recording video with audio.</string>
```

Add to `macos/Runner/DebugProfile.entitlements` and `macos/Runner/Release.entitlements`:

```xml
<key>com.apple.security.device.camera</key>
<true/>
<key>com.apple.security.device.audio-input</key>
<true/>
```

## License

Apache License 2.0
