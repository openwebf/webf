/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU AGPL with Enterprise exception.
 */
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';
import 'package:webf/dom.dart' as dom;
import 'package:video_player/video_player.dart';

class FlutterVideoPlayer extends WidgetElement {
  FlutterVideoPlayer(super.context);

  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;

  static StaticDefinedSyncBindingObjectMethodMap videoPlayerMethods = {
    // HTML5 standard methods only
    'play': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      castToType<FlutterVideoPlayer>(element).play();
    }),
    'pause': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      castToType<FlutterVideoPlayer>(element).pause();
    }),
    'load': StaticDefinedSyncBindingObjectMethod(call: (element, args) {
      castToType<FlutterVideoPlayer>(element).load();
    }),
  };

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    print('[FlutterVideoPlayer] 🔧 Initializing properties');
    
    properties['src'] = BindingObjectProperty(getter: () => getAttribute('src'), setter: (value) {
      print('[FlutterVideoPlayer] 📝 src property setter called with: $value');
      if (value is String && value.isNotEmpty) {
        setAttribute('src', value);
        _initializeVideo(value);
      } else {
        print('[FlutterVideoPlayer] ⚠️  Invalid src value: $value');
      }
    });
    
    properties['currentTime'] = BindingObjectProperty(
      getter: () {
        return (_controller?.value.position.inMilliseconds ?? 0) / 1000.0;
      },
      setter: (value) {
        // HTML5 standard: setting currentTime performs seek operation
        if (_controller != null && _isInitialized && value is num) {
          final seconds = value.toDouble();
          _controller!.seekTo(Duration(milliseconds: (seconds * 1000).round()));
        }
      }
    );
    
    properties['duration'] = BindingObjectProperty(getter: () {
      return (_controller?.value.duration.inMilliseconds ?? 0) / 1000.0;
    });
    
    properties['volume'] = BindingObjectProperty(
      getter: () => _controller?.value.volume ?? 1.0,
      setter: (value) {
        // HTML5 standard: direct property setter
        if (_controller != null && _isInitialized && value is num) {
          final volume = value.toDouble().clamp(0.0, 1.0);
          _controller!.setVolume(volume);
        }
      }
    );
    
    properties['playbackRate'] = BindingObjectProperty(
      getter: () => _controller?.value.playbackSpeed ?? 1.0,
      setter: (value) {
        // HTML5 standard: direct property setter
        if (_controller != null && _isInitialized && value is num) {
          final rate = value.toDouble();
          _controller!.setPlaybackSpeed(rate);
        }
      }
    );
    
    properties['paused'] = BindingObjectProperty(getter: () {
      return !(_controller?.value.isPlaying ?? false);
    });
    
    properties['ended'] = BindingObjectProperty(getter: () {
      if (_controller == null) return false;
      final position = _controller!.value.position;
      final duration = _controller!.value.duration;
      return position >= duration && duration > Duration.zero;
    });
  }

  @override
  void initializeAttributes(Map<String, ElementAttributeProperty> attributes) {
    super.initializeAttributes(attributes);
    print('[FlutterVideoPlayer] 🏷️  Initializing attributes');
    
    attributes['src'] = ElementAttributeProperty(setter: (value) {
      print('[FlutterVideoPlayer] 🏷️  src attribute setter called with: $value');
      _initializeVideo(value);
    });
    attributes['autoplay'] = ElementAttributeProperty(setter: (value) {
      // HTML5 boolean attribute: presence indicates true
      // Empty string or any value means true, null means false
    });
    attributes['muted'] = ElementAttributeProperty(setter: (value) {
      // HTML5 boolean attribute: presence indicates true
      if (value != null && _controller != null && _isInitialized) {
        _controller!.setVolume(0.0);
      }
    });
    attributes['loop'] = ElementAttributeProperty(setter: (value) {
      // HTML5 boolean attribute: presence indicates true
      _controller?.setLooping(value != null);
    });
    attributes['volume'] = ElementAttributeProperty(setter: (value) {
      if (_controller != null && _isInitialized) {
        double vol = double.tryParse(value) ?? 1.0;
        _controller!.setVolume(vol.clamp(0.0, 1.0));
      }
    });
    attributes['playbackRate'] = ElementAttributeProperty(setter: (value) {
      if (_controller != null && _isInitialized) {
        double rate = double.tryParse(value) ?? 1.0;
        _controller!.setPlaybackSpeed(rate);
      }
    });
  }

  void _initializeVideo(String src) async {
    print('[FlutterVideoPlayer] 🎬 _initializeVideo called with src: $src');
    
    if (src.isEmpty) {
      print('[FlutterVideoPlayer] ❌ Empty src provided, returning');
      return;
    }
    
    // Clean up previous controller
    print('[FlutterVideoPlayer] 🧹 Cleaning up previous controller');
    await _controller?.dispose();
    _controller = null;
    _isInitialized = false;
    _hasError = false;
    
    try {
      print('[FlutterVideoPlayer] 🌐 Creating VideoPlayerController with URL: $src');
      _controller = VideoPlayerController.networkUrl(Uri.parse(src));
      
      print('[FlutterVideoPlayer] ⏳ Initializing video controller...');
      await _controller!.initialize();
      _isInitialized = true;
      print('[FlutterVideoPlayer] ✅ Video controller initialized successfully!');
      print('[FlutterVideoPlayer] 📐 Video size: ${_controller!.value.size}');
      print('[FlutterVideoPlayer] ⏱️  Video duration: ${_controller!.value.duration}');
      
      // Set up listener for video events
      print('[FlutterVideoPlayer] 👂 Adding video state change listener');
      _controller!.addListener(_onVideoStateChanged);
      
      // Apply initial settings
      String? autoplayAttr = getAttribute('autoplay');
      print('[FlutterVideoPlayer] 🚀 Autoplay attribute: $autoplayAttr');
      if (autoplayAttr != null) { // HTML5 boolean attribute: presence = true
        print('[FlutterVideoPlayer] ▶️  Starting autoplay...');
        await _controller!.play();
      }
      
      String? mutedAttr = getAttribute('muted');
      print('[FlutterVideoPlayer] 🔇 Muted attribute: $mutedAttr');
      if (mutedAttr != null) { // HTML5 boolean attribute: presence = true
        print('[FlutterVideoPlayer] 🔇 Setting volume to 0 (muted)');
        await _controller!.setVolume(0.0);
      }
      
      String? loopAttr = getAttribute('loop');
      print('[FlutterVideoPlayer] 🔁 Loop attribute: $loopAttr');
      if (loopAttr != null) { // HTML5 boolean attribute: presence = true
        print('[FlutterVideoPlayer] 🔁 Enabling looping');
        await _controller!.setLooping(true);
      }
      
      String? volumeAttr = getAttribute('volume');
      print('[FlutterVideoPlayer] 🔊 Volume attribute: $volumeAttr');
      if (volumeAttr != null) {
        double volume = double.tryParse(volumeAttr) ?? 1.0;
        print('[FlutterVideoPlayer] 🔊 Setting volume to: $volume');
        await _controller!.setVolume(volume.clamp(0.0, 1.0));
      }
      
      String? rateAttr = getAttribute('playbackRate');
      print('[FlutterVideoPlayer] 🏃 Playback rate attribute: $rateAttr');
      if (rateAttr != null) {
        double rate = double.tryParse(rateAttr) ?? 1.0;
        print('[FlutterVideoPlayer] 🏃 Setting playback speed to: $rate');
        await _controller!.setPlaybackSpeed(rate);
      }
      
      // Dispatch loaded metadata event
      final eventDetail = {
        'duration': _controller!.value.duration.inMilliseconds,
        'videoWidth': _controller!.value.size.width,
        'videoHeight': _controller!.value.size.height,
      };
      print('[FlutterVideoPlayer] 📡 Dispatching loadedmetadata event: $eventDetail');
      dispatchEvent(CustomEvent('loadedmetadata', detail: eventDetail));
      
    } catch (e) {
      print('[FlutterVideoPlayer] ❌ ERROR during video initialization: $e');
      print('[FlutterVideoPlayer] 📍 Stack trace: ${StackTrace.current}');
      _hasError = true;
      dispatchEvent(CustomEvent('error', detail: e.toString()));
    }
    
    if (state != null) {
      (state as FlutterVideoPlayerState).updateWidget();
    }
  }
  
  void _onVideoStateChanged() {
    if (_controller == null) {
      return;
    }
    
    final value = _controller!.value;
    
    // Dispatch time update (no logging to avoid spam)
    final timeUpdateDetail = {
      'currentTime': value.position.inMilliseconds,
      'duration': value.duration.inMilliseconds,
    };
    dispatchEvent(CustomEvent('timeupdate', detail: timeUpdateDetail));
    
    // Check if video ended
    if (value.position >= value.duration && value.duration > Duration.zero) {
      print('[FlutterVideoPlayer] 🏁 Video ended');
      dispatchEvent(CustomEvent('ended'));
    }
    
    if (state != null) {
      (state as FlutterVideoPlayerState).updateWidget();
    }
  }

  void play() async {
    print('[FlutterVideoPlayer] ▶️  play() called');
    if (_controller != null && _isInitialized) {
      await _controller!.play();
      dispatchEvent(CustomEvent('play'));
    }
  }

  void pause() async {
    print('[FlutterVideoPlayer] ⏸️  pause() called');
    if (_controller != null && _isInitialized) {
      await _controller!.pause();
      dispatchEvent(CustomEvent('pause'));
    }
  }

  // HTML5 standard method - reload the video
  void load() async {
    print('[FlutterVideoPlayer] 🔄 load() called - reloading video');
    String? currentSrc = getAttribute('src');
    if (currentSrc != null && currentSrc.isNotEmpty) {
      _initializeVideo(currentSrc);
    }
  }


  @override
  Map<String, dynamic> get defaultStyle => {
    'width': '100%',
    'height': 'auto',
    'display': 'block',
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
    ...super.methods,
    videoPlayerMethods
  ];

  @override
  WebFWidgetElementState createState() {
    return FlutterVideoPlayerState(this);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoStateChanged);
    _controller?.dispose();
    super.dispose();
  }
}

class FlutterVideoPlayerState extends WebFWidgetElementState {
  FlutterVideoPlayerState(super.widgetElement);

  FlutterVideoPlayer get videoPlayer => widgetElement as FlutterVideoPlayer;

  void updateWidget() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = videoPlayer._controller;
    
    if (videoPlayer._hasError) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.black,
        child: const Center(
          child: Icon(
            Icons.error_outline,
            color: Colors.white,
            size: 48,
          ),
        ),
      );
    }
    
    if (controller == null || !videoPlayer._isInitialized) {
      return AspectRatio(
        aspectRatio: 2.0, // HTML5 video standard: 300x150 = 2:1
        child: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: VideoPlayer(controller),
    );
  }
}

// Progress bar component
class FlutterVideoProgress extends WidgetElement {
  FlutterVideoProgress(super.context);

  @override
  Map<String, dynamic> get defaultStyle => {
    'width': '100%',
    'height': '20px',
    'display': 'block',
  };

  @override
  WebFWidgetElementState createState() {
    return FlutterVideoProgressState(this);
  }
}

class FlutterVideoProgressState extends WebFWidgetElementState {
  FlutterVideoProgressState(super.widgetElement);

  FlutterVideoProgress get progressElement => widgetElement as FlutterVideoProgress;

  @override
  Widget build(BuildContext context) {
    // Find parent video player
    dom.Element? parent = progressElement.parentElement;
    FlutterVideoPlayer? videoPlayer;
    
    while (parent != null) {
      if (parent is FlutterVideoPlayer) {
        videoPlayer = parent;
        break;
      }
      parent = parent.parentElement;
    }
    
    if (videoPlayer?._controller == null || !videoPlayer!._isInitialized) {
      return Container(
        height: 20,
        color: Colors.grey[300],
      );
    }
    
    return VideoProgressIndicator(
      videoPlayer._controller!,
      allowScrubbing: true,
      colors: const VideoProgressColors(
        playedColor: Colors.blue,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.lightBlue,
      ),
    );
  }
}