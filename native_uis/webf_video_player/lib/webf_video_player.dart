/// WebF Video Player - HTML5-compatible video playback for WebF applications.
///
/// This package provides a `<webf-video-player>` custom element that wraps
/// Flutter's video_player package with an HTML5-compatible API.
///
/// ## Quick Start
///
/// 1. Install the package in your WebF application
/// 2. Call `installWebFVideoPlayer()` in your main() function
/// 3. Use `<webf-video-player>` in your HTML/JavaScript code
///
/// ## Dart Setup
///
/// ```dart
/// import 'package:webf_video_player/webf_video_player.dart';
///
/// void main() {
///   installWebFVideoPlayer();
///   runApp(MyApp());
/// }
/// ```
///
/// ## JavaScript Usage
///
/// ```html
/// <webf-video-player
///   src="https://example.com/video.mp4"
///   controls
///   autoplay
///   muted
///   loop
/// ></webf-video-player>
/// ```
///
/// ## Supported Properties
///
/// - `src` - Video source URL (http://, https://, asset://, file://)
/// - `poster` - Poster image URL
/// - `autoplay` - Auto-start playback
/// - `controls` - Show playback controls
/// - `loop` - Loop video continuously
/// - `muted` - Mute audio
/// - `volume` - Volume level (0.0 to 1.0)
/// - `playbackRate` - Playback speed (0.5 to 2.0)
/// - `currentTime` - Current position in seconds
/// - `objectFit` - Video sizing (contain, cover, fill, none)
///
/// ## Supported Events
///
/// - `play`, `pause`, `ended` - Playback state changes
/// - `timeupdate` - Periodic position updates
/// - `loadstart`, `loadedmetadata`, `canplay` - Loading events
/// - `error` - Error events
/// - `volumechange`, `ratechange` - Settings changes
///
/// ## Supported Methods
///
/// - `play()` - Start playback
/// - `pause()` - Pause playback
/// - `load()` - Reload video source
/// - `canPlayType(mimeType)` - Check MIME type support
// ignore_for_file: unnecessary_library_name
library webf_video_player;

import 'package:webf/webf.dart';

import 'src/video_player.dart';

export 'src/video_player.dart';

/// Installs the WebF Video Player custom element.
///
/// Call this function in your main() before running your WebF application
/// to register the `<webf-video-player>` custom element.
///
/// Example:
/// ```dart
/// void main() {
///   installWebFVideoPlayer();
///   runApp(MyApp());
/// }
/// ```
void installWebFVideoPlayer() {
  WebF.defineCustomElement(
      'webf-video-player', (context) => WebFVideoPlayer(context));
}
