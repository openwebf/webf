# WebF Video Player

HTML5-compatible video player for WebF applications. Wraps Flutter's `video_player` package with a familiar HTML5 video element API.

## Installation

Add this package to your `pubspec.yaml`:

```yaml
dependencies:
  webf_video_player: ^1.0.0
```

## Setup

Register the custom element in your Flutter app's main function:

```dart
import 'package:webf_video_player/webf_video_player.dart';

void main() {
  installWebFVideoPlayer();
  runApp(MyApp());
}
```

## Usage

### Basic Example

```html
<webf-video-player
  src="https://example.com/video.mp4"
  controls
></webf-video-player>
```

### With All Options

```html
<webf-video-player
  src="https://example.com/video.mp4"
  poster="https://example.com/poster.jpg"
  controls
  autoplay
  muted
  loop
  volume="0.8"
  playback-rate="1.0"
  object-fit="contain"
></webf-video-player>
```

### JavaScript Control

```javascript
const video = document.querySelector('webf-video-player');

// Play/Pause
video.play();
video.pause();

// Seek to 30 seconds
video.currentTime = 30;

// Adjust volume
video.volume = 0.5;
video.muted = true;

// Change playback speed
video.playbackRate = 1.5;

// Listen to events
video.addEventListener('play', () => console.log('Playing'));
video.addEventListener('pause', () => console.log('Paused'));
video.addEventListener('ended', () => console.log('Ended'));
video.addEventListener('timeupdate', (e) => {
  console.log('Current time:', e.detail.currentTime);
});
video.addEventListener('error', (e) => {
  console.error('Error:', e.detail.message);
});
```

## Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `src` | string | - | Video source URL. Supports `http://`, `https://`, `asset://`, `file://` |
| `poster` | string | - | Poster image URL displayed before playback |
| `autoplay` | boolean | false | Auto-start playback when loaded |
| `controls` | boolean | true | Show playback controls |
| `loop` | boolean | false | Loop video continuously |
| `muted` | boolean | false | Mute audio |
| `volume` | number | 1.0 | Volume level (0.0 to 1.0) |
| `playbackRate` | number | 1.0 | Playback speed (0.25 to 2.0) |
| `currentTime` | number | 0 | Current position in seconds (read/write) |
| `objectFit` | string | 'contain' | Video sizing: 'contain', 'cover', 'fill', 'none' |
| `preload` | string | 'metadata' | Preload hint: 'none', 'metadata', 'auto' |
| `playsInline` | boolean | true | Play inline on iOS (vs fullscreen) |

### Read-only Properties

| Property | Type | Description |
|----------|------|-------------|
| `duration` | number | Total duration in seconds |
| `paused` | boolean | Whether playback is paused |
| `ended` | boolean | Whether playback has ended |
| `seeking` | boolean | Whether currently seeking |
| `readyState` | number | Loading ready state (0-4) |
| `networkState` | number | Network state (0-3) |
| `videoWidth` | number | Natural video width in pixels |
| `videoHeight` | number | Natural video height in pixels |
| `buffering` | boolean | Whether currently buffering |

## Events

| Event | Detail | Description |
|-------|--------|-------------|
| `loadstart` | - | Browser starts loading |
| `loadedmetadata` | `{duration, videoWidth, videoHeight}` | Metadata loaded |
| `loadeddata` | - | First frame loaded |
| `canplay` | - | Ready to play |
| `canplaythrough` | - | Can play without buffering |
| `play` | - | Playback started |
| `playing` | - | Playback ready after pause/buffer |
| `pause` | - | Playback paused |
| `ended` | - | Playback ended |
| `waiting` | - | Buffering/stalled |
| `seeking` | - | Seek operation started |
| `seeked` | - | Seek operation completed |
| `timeupdate` | `{currentTime, duration}` | Position update (~4x/sec) |
| `durationchange` | `{duration}` | Duration changed |
| `volumechange` | `{volume, muted}` | Volume/mute changed |
| `ratechange` | `{playbackRate}` | Playback rate changed |
| `progress` | - | Download progress |
| `error` | `{code, message}` | Error occurred |

## Methods

| Method | Returns | Description |
|--------|---------|-------------|
| `play()` | void | Start playback |
| `pause()` | void | Pause playback |
| `load()` | void | Reload video source |
| `canPlayType(mimeType)` | string | Check MIME support ('', 'maybe', 'probably') |

## Source URL Protocols

| Protocol | Example | Description |
|----------|---------|-------------|
| `http://` | `http://example.com/video.mp4` | HTTP URL |
| `https://` | `https://example.com/video.mp4` | HTTPS URL |
| `asset://` | `asset://videos/intro.mp4` | Flutter asset |
| `file://` | `file:///path/to/video.mp4` | Local file |

## Supported Formats

The supported video formats depend on the platform:

| Format | iOS | Android | Description |
|--------|-----|---------|-------------|
| MP4 (H.264) | Yes | Yes | Most compatible |
| WebM | No | Yes | Android only |
| HLS | Yes | Yes | Streaming format |

## Platform Configuration

### iOS

Add to `ios/Runner/Info.plist` for network video playback:

```xml
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## License

Apache License 2.0
