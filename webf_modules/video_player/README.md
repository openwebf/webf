# WebF Video Player

WebF Video Player module for handling video playback with Flutter video_player in WebF applications.

## Features

- Video playback with network URLs
- Play/pause controls
- Seek to specific position
- Volume control
- Playback speed adjustment
- Progress tracking
- Custom HTML elements for WebF

## Usage

### Installation

Add this package to your WebF application's dependencies:

```yaml
dependencies:
  webf_video_player: ^0.1.0-beta
```

### Initialize

```dart
import 'package:webf_video_player/webf_video_player.dart';

void main() {
  installWebFVideoPlayer();
  runApp(MyApp());
}
```

### HTML Elements

#### Video Player

```html
<flutter-video
  src="https://example.com/video.mp4"
  autoplay="true"
  muted="false"
  loop="false"
  volume="1.0"
  playback-rate="1.0"
></flutter-video>
```

#### Video Progress Bar

```html
<flutter-video-progress player-id="video-1"></flutter-video-progress>
```

## API

### Attributes

- `src`: Video source URL (required)
- `autoplay`: Auto-play video when loaded (default: false)
- `muted`: Mute video audio (default: false) 
- `loop`: Loop video playback (default: false)
- `volume`: Volume level (0.0 - 1.0, default: 1.0)
- `playback-rate`: Playback speed (default: 1.0)

### Methods

- `play()`: Start video playback
- `pause()`: Pause video playback
- `seekTo(position)`: Seek to specific position in seconds
- `setVolume(volume)`: Set volume (0.0 - 1.0)
- `setPlaybackSpeed(speed)`: Set playback speed

### Events

- `play`: Fired when video starts playing
- `pause`: Fired when video is paused
- `ended`: Fired when video playback ends
- `timeupdate`: Fired during playback with current time
- `loadedmetadata`: Fired when video metadata is loaded
- `error`: Fired when an error occurs

## License

GNU GPL v3 with OpenWebF Enterprise Exception