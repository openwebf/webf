/// WebF Video Player - Video playback components for WebF applications
/// 
/// This package provides video playback functionality using Flutter's video_player
/// package wrapped as custom HTML elements for WebF applications.
/// 
/// Example usage:
/// ```dart
/// import 'package:webf_video_player/webf_video_player.dart';
/// 
/// void main() {
///   // Register video player components
///   installWebFVideoPlayer();
///   
///   runApp(MyApp());
/// }
/// ```
library webf_video_player;

import 'package:webf/webf.dart';

// Export components
export 'src/video_player.dart';

// Import components for registration
import 'src/video_player.dart';

/// Installs all WebF Video Player components.
/// 
/// This function registers video player components as custom HTML elements
/// that can be used in WebF applications.
/// 
/// Call this function once during app initialization:
/// ```dart
/// void main() {
///   installWebFVideoPlayer();
///   runApp(MyApp());
/// }
/// ```
void installWebFVideoPlayer() {
  // Register video player component
  WebF.defineCustomElement('flutter-video-player', (context) => FlutterVideoPlayer(context));
  
  // Register video progress component
  WebF.defineCustomElement('flutter-video-progress', (context) => FlutterVideoProgress(context));
  
  print('WebF Video Player components installed successfully');
}