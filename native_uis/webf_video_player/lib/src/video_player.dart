/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:webf/css.dart';
import 'package:webf/webf.dart';

import 'video_player_bindings_generated.dart';

/// WebF custom element that wraps Flutter's VideoPlayer.
///
/// Exposed as `<webf-video-player>` in the DOM.
/// Provides an HTML5-compatible video player API.
class WebFVideoPlayer extends WebFVideoPlayerBindings {
  WebFVideoPlayer(super.context);

  // Property backing fields
  String? _src;
  String? _poster;
  bool _autoplay = false;
  bool _controls = true;
  bool _loop = false;
  bool _muted = false;
  double _volume = 1.0;
  double _playbackRate = 1.0;
  String _objectFit = 'contain';
  String _preload = 'metadata';
  bool _playsInline = true;

  // Read-only state (managed by controller)
  double _duration = double.nan;
  bool _paused = true;
  bool _ended = false;
  bool _seeking = false;
  int _readyState = 0;
  int _networkState = 0;
  int _videoWidth = 0;
  int _videoHeight = 0;
  bool _buffering = false;

  // ============ Property Getters & Setters ============

  @override
  String? get src => _src;

  @override
  set src(value) {
    final String? next = value?.toString();
    if (next != _src) {
      _src = next;
      state?._initializeController();
    }
  }

  @override
  String? get poster => _poster;

  @override
  set poster(value) {
    final String? next = value?.toString();
    if (next != _poster) {
      _poster = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get autoplay => _autoplay;

  @override
  set autoplay(value) {
    _autoplay = value == true;
  }

  @override
  bool get controls => _controls;

  @override
  set controls(value) {
    final bool next = value == true;
    if (next != _controls) {
      _controls = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  bool get loop => _loop;

  @override
  set loop(value) {
    final bool next = value == true;
    if (next != _loop) {
      _loop = next;
      state?._controller?.setLooping(next);
    }
  }

  @override
  bool get muted => _muted;

  @override
  set muted(value) {
    final bool next = value == true;
    if (next != _muted) {
      _muted = next;
      state?._controller?.setVolume(next ? 0.0 : _volume);
      _dispatchVolumeChange();
    }
  }

  @override
  double get volume => _volume;

  @override
  set volume(value) {
    final double next = _parseDouble(value, _volume).clamp(0.0, 1.0);
    if (next != _volume) {
      _volume = next;
      if (!_muted) {
        state?._controller?.setVolume(next);
      }
      _dispatchVolumeChange();
    }
  }

  @override
  double get playbackRate => _playbackRate;

  @override
  set playbackRate(value) {
    final double next = _parseDouble(value, _playbackRate);
    if (next != _playbackRate && next > 0) {
      _playbackRate = next;
      state?._controller?.setPlaybackSpeed(next);
      dispatchEvent(CustomEvent('ratechange', detail: {'playbackRate': next}));
    }
  }

  @override
  double get currentTime {
    final controller = state?._controller;
    if (controller != null && controller.value.isInitialized) {
      return controller.value.position.inMilliseconds / 1000.0;
    }
    return 0.0;
  }

  @override
  set currentTime(value) {
    final double seconds = _parseDouble(value, 0.0);
    state?._seekTo(seconds);
  }

  @override
  String get objectFit => _objectFit;

  @override
  set objectFit(value) {
    final String next = value?.toString() ?? 'contain';
    if (next != _objectFit) {
      _objectFit = next;
      state?.requestUpdateState(() {});
    }
  }

  @override
  String get preload => _preload;

  @override
  set preload(value) {
    _preload = value?.toString() ?? 'metadata';
  }

  @override
  bool get playsInline => _playsInline;

  @override
  set playsInline(value) {
    _playsInline = value == true;
  }

  // ============ Read-only Properties ============
  // These properties are read-only in the HTML5 API, but setters are required
  // by the generated bindings. The setters are no-ops.

  @override
  double get duration => _duration;

  @override
  set duration(value) {
    // Read-only property, setter is a no-op
  }

  @override
  bool get paused => _paused;

  @override
  set paused(value) {
    // Read-only property, setter is a no-op
  }

  @override
  bool get ended => _ended;

  @override
  set ended(value) {
    // Read-only property, setter is a no-op
  }

  @override
  bool get seeking => _seeking;

  @override
  set seeking(value) {
    // Read-only property, setter is a no-op
  }

  @override
  int get readyState => _readyState;

  @override
  set readyState(value) {
    // Read-only property, setter is a no-op
  }

  @override
  int get networkState => _networkState;

  @override
  set networkState(value) {
    // Read-only property, setter is a no-op
  }

  @override
  int get videoWidth => _videoWidth;

  @override
  set videoWidth(value) {
    // Read-only property, setter is a no-op
  }

  @override
  int get videoHeight => _videoHeight;

  @override
  set videoHeight(value) {
    // Read-only property, setter is a no-op
  }

  @override
  bool get buffering => _buffering;

  @override
  set buffering(value) {
    // Read-only property, setter is a no-op
  }

  // ============ Internal Methods ============

  double _parseDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  void _dispatchVolumeChange() {
    dispatchEvent(CustomEvent('volumechange', detail: {
      'volume': _volume,
      'muted': _muted,
    }));
  }

  void _updateReadOnlyState(VideoPlayerValue value) {
    _duration = value.duration.inMilliseconds / 1000.0;
    _paused = !value.isPlaying;
    _ended = value.isCompleted;
    _buffering = value.isBuffering;
    _videoWidth = value.size.width.toInt();
    _videoHeight = value.size.height.toInt();

    if (value.hasError) {
      _readyState = 0;
      _networkState = 3;
    } else if (value.isInitialized) {
      _readyState = value.isBuffering ? 2 : 4;
      _networkState = 1;
    }
  }

  // ============ Synchronous Methods ============

  void _playSync(List<dynamic> args) {
    state?._play();
  }

  void _pauseSync(List<dynamic> args) {
    state?._pause();
  }

  void _loadSync(List<dynamic> args) {
    state?._initializeController();
  }

  String _canPlayTypeSync(List<dynamic> args) {
    final mimeType = args.isNotEmpty ? args[0]?.toString() : '';
    if (mimeType == null || mimeType.isEmpty) return '';
    if (mimeType.contains('video/mp4')) return 'probably';
    if (mimeType.contains('video/webm')) return 'maybe';
    if (mimeType.contains('video/ogg')) return 'maybe';
    if (mimeType.contains('application/x-mpegURL')) return 'maybe';
    if (mimeType.contains('application/vnd.apple.mpegurl')) return 'maybe';
    return '';
  }

  static StaticDefinedSyncBindingObjectMethodMap videoPlayerMethods = {
    'play': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<WebFVideoPlayer>(element)._playSync(args);
        return null;
      },
    ),
    'pause': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<WebFVideoPlayer>(element)._pauseSync(args);
        return null;
      },
    ),
    'load': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        castToType<WebFVideoPlayer>(element)._loadSync(args);
        return null;
      },
    ),
    'canPlayType': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        return castToType<WebFVideoPlayer>(element)._canPlayTypeSync(args);
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        videoPlayerMethods,
      ];

  @override
  WebFVideoPlayerState? get state => super.state as WebFVideoPlayerState?;

  @override
  WebFWidgetElementState createState() {
    return WebFVideoPlayerState(this);
  }
}

class WebFVideoPlayerState extends WebFWidgetElementState {
  WebFVideoPlayerState(super.widgetElement);

  @override
  WebFVideoPlayer get widgetElement => super.widgetElement as WebFVideoPlayer;

  VideoPlayerController? _controller;
  Timer? _timeUpdateTimer;
  bool _isInitializing = false;
  bool _showPoster = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widgetElement.src != null && widgetElement.src!.isNotEmpty) {
      _initializeController();
    }
  }

  @override
  void dispose() {
    _timeUpdateTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeController() async {
    if (_isInitializing) return;
    _isInitializing = true;
    _hasError = false;
    _errorMessage = null;

    // Dispose existing controller
    _timeUpdateTimer?.cancel();
    _controller?.removeListener(_onControllerUpdate);
    await _controller?.dispose();
    _controller = null;

    final src = widgetElement.src;
    if (src == null || src.isEmpty) {
      _isInitializing = false;
      return;
    }

    widgetElement._networkState = 2; // NETWORK_LOADING
    widgetElement.dispatchEvent(Event('loadstart'));

    try {
      VideoPlayerController controller;

      if (src.startsWith('asset://')) {
        controller = VideoPlayerController.asset(src.substring(8));
      } else if (src.startsWith('file://')) {
        controller = VideoPlayerController.file(File(src.substring(7)));
      } else {
        controller = VideoPlayerController.networkUrl(Uri.parse(src));
      }

      await controller.initialize();

      _controller = controller;
      _controller!.addListener(_onControllerUpdate);

      // Apply initial settings
      if (widgetElement.loop) {
        await _controller!.setLooping(true);
      }
      if (widgetElement.muted) {
        await _controller!.setVolume(0.0);
      } else {
        await _controller!.setVolume(widgetElement.volume);
      }
      if (widgetElement.playbackRate != 1.0) {
        await _controller!.setPlaybackSpeed(widgetElement.playbackRate);
      }

      // Update read-only state
      widgetElement._updateReadOnlyState(_controller!.value);
      widgetElement._readyState = 4; // HAVE_ENOUGH_DATA
      widgetElement._networkState = 1; // NETWORK_IDLE

      // Dispatch loaded events
      widgetElement.dispatchEvent(CustomEvent('loadedmetadata', detail: {
        'duration': widgetElement.duration,
        'videoWidth': widgetElement.videoWidth,
        'videoHeight': widgetElement.videoHeight,
      }));
      widgetElement.dispatchEvent(Event('loadeddata'));
      widgetElement.dispatchEvent(Event('canplay'));
      widgetElement.dispatchEvent(Event('canplaythrough'));
      widgetElement.dispatchEvent(CustomEvent('durationchange', detail: {
        'duration': widgetElement.duration,
      }));

      // Start time update timer
      _startTimeUpdateTimer();

      // Auto-play if requested
      if (widgetElement.autoplay) {
        await _play();
      }

      _showPoster = false;
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString();
      widgetElement._readyState = 0;
      widgetElement._networkState = 3; // NETWORK_NO_SOURCE
      widgetElement.dispatchEvent(CustomEvent('error', detail: {
        'code': 4,
        'message': e.toString(),
      }));
      if (mounted) {
        setState(() {});
      }
    } finally {
      _isInitializing = false;
    }
  }

  void _onControllerUpdate() {
    final controller = _controller;
    if (controller == null) return;

    final value = controller.value;
    final wasBuffering = widgetElement._buffering;
    widgetElement._updateReadOnlyState(value);

    // Handle buffering state changes
    if (value.isBuffering && !wasBuffering) {
      widgetElement.dispatchEvent(Event('waiting'));
    } else if (!value.isBuffering && wasBuffering) {
      widgetElement.dispatchEvent(Event('playing'));
    }

    // Handle playback end
    if (value.isCompleted && !widgetElement._ended) {
      widgetElement._ended = true;
      widgetElement.dispatchEvent(Event('ended'));

      // Handle looping
      if (widgetElement.loop) {
        _seekTo(0);
        _play();
      }
    }

    // Handle errors
    if (value.hasError && !_hasError) {
      _hasError = true;
      _errorMessage = value.errorDescription ?? 'Unknown error';
      widgetElement.dispatchEvent(CustomEvent('error', detail: {
        'code': 4,
        'message': _errorMessage,
      }));
    }

    // Dispatch progress event for buffering
    widgetElement.dispatchEvent(Event('progress'));

    if (mounted) {
      setState(() {});
    }
  }

  void _startTimeUpdateTimer() {
    _timeUpdateTimer?.cancel();
    _timeUpdateTimer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (_controller != null && _controller!.value.isPlaying) {
        widgetElement.dispatchEvent(CustomEvent('timeupdate', detail: {
          'currentTime': widgetElement.currentTime,
          'duration': widgetElement.duration,
        }));
      }
    });
  }

  Future<void> _play() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    // Reset ended state if at end
    if (controller.value.isCompleted) {
      await controller.seekTo(Duration.zero);
      widgetElement._ended = false;
    }

    widgetElement.dispatchEvent(Event('play'));
    await controller.play();
    widgetElement._paused = false;
    widgetElement.dispatchEvent(Event('playing'));
  }

  Future<void> _pause() async {
    final controller = _controller;
    if (controller == null) return;

    await controller.pause();
    widgetElement._paused = true;
    widgetElement.dispatchEvent(Event('pause'));
  }

  Future<void> _seekTo(double seconds) async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    widgetElement._seeking = true;
    widgetElement.dispatchEvent(Event('seeking'));

    final duration = Duration(milliseconds: (seconds * 1000).toInt());
    await controller.seekTo(duration);

    widgetElement._seeking = false;
    widgetElement._ended = false;
    widgetElement.dispatchEvent(Event('seeked'));
  }

  BoxFit _getBoxFit() {
    switch (widgetElement.objectFit) {
      case 'cover':
        return BoxFit.cover;
      case 'fill':
        return BoxFit.fill;
      case 'none':
        return BoxFit.none;
      case 'contain':
      default:
        return BoxFit.contain;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final CSSRenderStyle renderStyle = widgetElement.renderStyle;

    // Determine dimensions
    double? width = renderStyle.width.computedValue;
    double? height = renderStyle.height.computedValue;
    if (width == 0) width = null;
    if (height == 0) height = null;

    Widget content;

    if (_hasError) {
      // Show error state
      content = Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.white54),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Error loading video',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    } else if (controller == null || !controller.value.isInitialized) {
      // Show poster or placeholder
      if (widgetElement.poster != null && _showPoster) {
        content = Image.network(
          widgetElement.poster!,
          fit: _getBoxFit(),
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        );
      } else {
        content = _buildPlaceholder();
      }
    } else {
      // Build video player
      Widget videoWidget = FittedBox(
        fit: _getBoxFit(),
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      );

      if (widgetElement.controls) {
        videoWidget = Stack(
          alignment: Alignment.bottomCenter,
          children: [
            videoWidget,
            _VideoControls(
              controller: controller,
              onPlay: _play,
              onPause: _pause,
              onSeek: _seekTo,
              onVolumeChange: (vol) {
                widgetElement.volume = vol;
              },
              onMuteToggle: () {
                widgetElement.muted = !widgetElement.muted;
              },
              muted: widgetElement.muted,
              volume: widgetElement.volume,
            ),
          ],
        );
      }

      content = videoWidget;
    }

    // Apply sizing
    if (width != null || height != null) {
      content = SizedBox(
        width: width,
        height: height,
        child: content,
      );
    }

    return ClipRect(child: content);
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: _isInitializing
            ? const CircularProgressIndicator(color: Colors.white54)
            : const Icon(Icons.play_circle_outline,
                size: 48, color: Colors.white54),
      ),
    );
  }
}

/// Simple video controls overlay widget.
class _VideoControls extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onPlay;
  final VoidCallback onPause;
  final ValueChanged<double> onSeek;
  final ValueChanged<double> onVolumeChange;
  final VoidCallback onMuteToggle;
  final bool muted;
  final double volume;

  const _VideoControls({
    required this.controller,
    required this.onPlay,
    required this.onPause,
    required this.onSeek,
    required this.onVolumeChange,
    required this.onMuteToggle,
    required this.muted,
    required this.volume,
  });

  @override
  State<_VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<_VideoControls> {
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _startHideTimer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && widget.controller.value.isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  void _onTap() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _startHideTimer();
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (d.inHours > 0) {
      final hours = d.inHours.toString();
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final value = widget.controller.value;
    final position = value.position.inMilliseconds.toDouble();
    final duration = value.duration.inMilliseconds.toDouble();

    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: IgnorePointer(
          ignoring: !_showControls,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  const Color.fromRGBO(0, 0, 0, 0.7),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Text(
                        _formatDuration(value.position),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 12),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                            overlayColor: Colors.white24,
                          ),
                          child: Slider(
                            value: position.clamp(0, duration),
                            min: 0,
                            max: duration > 0 ? duration : 1,
                            onChanged: (val) {
                              widget.onSeek(val / 1000);
                            },
                            onChangeEnd: (_) {
                              _startHideTimer();
                            },
                          ),
                        ),
                      ),
                      Text(
                        _formatDuration(value.duration),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                // Control buttons
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          value.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          if (value.isPlaying) {
                            widget.onPause();
                          } else {
                            widget.onPlay();
                          }
                          _startHideTimer();
                        },
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(
                          widget.muted ? Icons.volume_off : Icons.volume_up,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          widget.onMuteToggle();
                          _startHideTimer();
                        },
                      ),
                      SizedBox(
                        width: 100,
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 2,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 5),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 10),
                            activeTrackColor: Colors.white,
                            inactiveTrackColor: Colors.white30,
                            thumbColor: Colors.white,
                            overlayColor: Colors.white24,
                          ),
                          child: Slider(
                            value: widget.muted ? 0 : widget.volume,
                            onChanged: (val) {
                              widget.onVolumeChange(val);
                              _startHideTimer();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
