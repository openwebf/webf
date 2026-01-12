/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:webf/webf.dart';

import 'camera_bindings_generated.dart';
import 'logger.dart';

/// Mixin for exposing camera methods to JavaScript
mixin FlutterCameraMixin on WidgetElement {
  /// Sync methods that return immediately
  static StaticDefinedSyncBindingObjectMethodMap cameraSyncMethods = {
    'getMinZoomLevel': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final camera = castToType<FlutterCamera>(element);
        return camera._minZoom;
      },
    ),
    'getMaxZoomLevel': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final camera = castToType<FlutterCamera>(element);
        return camera._maxZoom;
      },
    ),
    'getMinExposureOffset': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final camera = castToType<FlutterCamera>(element);
        return camera._minExposureOffset;
      },
    ),
    'getMaxExposureOffset': StaticDefinedSyncBindingObjectMethod(
      call: (element, args) {
        final camera = castToType<FlutterCamera>(element);
        return camera._maxExposureOffset;
      },
    ),
  };

  /// Async methods that return Futures
  static StaticDefinedAsyncBindingObjectMethodMap cameraAsyncMethods = {
    'initialize': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        await camera._initializeCamera();
      },
    ),
    'dispose': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        await camera._disposeCamera();
      },
    ),
    'takePicture': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        return await camera._takePicture();
      },
    ),
    'startVideoRecording': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        await camera._startVideoRecording();
      },
    ),
    'stopVideoRecording': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        return await camera._stopVideoRecording();
      },
    ),
    'pauseVideoRecording': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        await camera._pauseVideoRecording();
      },
    ),
    'resumeVideoRecording': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        await camera._resumeVideoRecording();
      },
    ),
    'switchCamera': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        await camera._switchCamera();
      },
    ),
    'setFlashMode': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        final mode = args.isNotEmpty ? args[0].toString() : 'auto';
        await camera._setFlashMode(mode);
      },
    ),
    'setZoomLevel': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        final zoom = (args.isNotEmpty && args[0] is num)
            ? (args[0] as num).toDouble()
            : 1.0;
        await camera._setZoomLevel(zoom);
      },
    ),
    'setExposureOffset': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        final offset = (args.isNotEmpty && args[0] is num)
            ? (args[0] as num).toDouble()
            : 0.0;
        return await camera._setExposureOffset(offset);
      },
    ),
    'setFocusPoint': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        final x = (args.isNotEmpty && args[0] is num)
            ? (args[0] as num).toDouble()
            : 0.5;
        final y = (args.length > 1 && args[1] is num)
            ? (args[1] as num).toDouble()
            : 0.5;
        await camera._setFocusPoint(x, y);
      },
    ),
    'setExposurePoint': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        final x = (args.isNotEmpty && args[0] is num)
            ? (args[0] as num).toDouble()
            : 0.5;
        final y = (args.length > 1 && args[1] is num)
            ? (args[1] as num).toDouble()
            : 0.5;
        await camera._setExposurePoint(x, y);
      },
    ),
    'lockCaptureOrientation': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        final orientation = args.isNotEmpty ? args[0]?.toString() : null;
        await camera._lockCaptureOrientation(orientation);
      },
    ),
    'unlockCaptureOrientation': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        await camera._unlockCaptureOrientation();
      },
    ),
    'getAvailableCameras': StaticDefinedAsyncBindingObjectMethod(
      call: (element, args) async {
        final camera = castToType<FlutterCamera>(element);
        return camera._getAvailableCamerasInfo();
      },
    ),
  };

  @override
  List<StaticDefinedSyncBindingObjectMethodMap> get methods => [
        ...super.methods,
        cameraSyncMethods,
      ];

  @override
  List<StaticDefinedAsyncBindingObjectMethodMap> get asyncMethods => [
        ...super.asyncMethods,
        cameraAsyncMethods,
      ];
}

/// WebF custom element that wraps Flutter's Camera package.
///
/// Exposed as `<flutter-camera>` in the DOM.
class FlutterCamera extends FlutterCameraBindings with FlutterCameraMixin {
  FlutterCamera(super.context);

  // Internal state
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  int _currentCameraIndex = 0;
  bool _isInitialized = false;
  bool _isRecording = false;

  // Cached zoom/exposure limits
  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _minExposureOffset = 0.0;
  double _maxExposureOffset = 0.0;

  // Property backing fields
  String _facing = 'back';
  String _resolution = 'high';
  String _flashMode = 'auto';
  bool _enableAudio = true;
  bool _autoInit = true;
  double _zoom = 1.0;
  double _exposureOffset = 0.0;
  String _focusMode = 'auto';
  String _exposureMode = 'auto';

  // Helper to parse double from various types
  double _parseDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  // Property getters/setters

  @override
  String? get facing => _facing;

  @override
  set facing(value) {
    final next = value?.toString() ?? 'back';
    if (next != _facing) {
      _facing = next;
      if (_isInitialized) {
        _switchToFacing(next);
      }
    }
  }

  @override
  String? get resolution => _resolution;

  @override
  set resolution(value) {
    _resolution = value?.toString() ?? 'high';
  }

  @override
  String? get flashMode => _flashMode;

  @override
  set flashMode(value) {
    final next = value?.toString() ?? 'auto';
    if (next != _flashMode) {
      _flashMode = next;
      if (_isInitialized) {
        _applyFlashMode();
      }
    }
  }

  @override
  bool get enableAudio => _enableAudio;

  @override
  set enableAudio(value) {
    _enableAudio = value == true;
  }

  @override
  bool get autoInit => _autoInit;

  @override
  set autoInit(value) {
    _autoInit = value == true;
  }

  @override
  double? get zoom => _zoom;

  @override
  set zoom(value) {
    final next = _parseDouble(value, _zoom);
    if (next != _zoom) {
      _zoom = next.clamp(_minZoom, _maxZoom);
      if (_isInitialized && _cameraController != null) {
        _cameraController!.setZoomLevel(_zoom);
      }
    }
  }

  @override
  double? get exposureOffset => _exposureOffset;

  @override
  set exposureOffset(value) {
    final next = _parseDouble(value, _exposureOffset);
    if (next != _exposureOffset) {
      _exposureOffset = next.clamp(_minExposureOffset, _maxExposureOffset);
      if (_isInitialized && _cameraController != null) {
        _cameraController!.setExposureOffset(_exposureOffset);
      }
    }
  }

  @override
  String? get focusMode => _focusMode;

  @override
  set focusMode(value) {
    final next = value?.toString() ?? 'auto';
    if (next != _focusMode) {
      _focusMode = next;
      if (_isInitialized) {
        _applyFocusMode();
      }
    }
  }

  @override
  String? get exposureMode => _exposureMode;

  @override
  set exposureMode(value) {
    final next = value?.toString() ?? 'auto';
    if (next != _exposureMode) {
      _exposureMode = next;
      if (_isInitialized) {
        _applyExposureMode();
      }
    }
  }

  // Convert string resolution to ResolutionPreset
  ResolutionPreset _getResolutionPreset() {
    switch (_resolution) {
      case 'low':
        return ResolutionPreset.low;
      case 'medium':
        return ResolutionPreset.medium;
      case 'high':
        return ResolutionPreset.high;
      case 'veryHigh':
        return ResolutionPreset.veryHigh;
      case 'ultraHigh':
        return ResolutionPreset.ultraHigh;
      case 'max':
        return ResolutionPreset.max;
      default:
        return ResolutionPreset.high;
    }
  }

  // Convert string flash mode to FlashMode
  FlashMode _getFlashMode() {
    switch (_flashMode) {
      case 'off':
        return FlashMode.off;
      case 'auto':
        return FlashMode.auto;
      case 'always':
        return FlashMode.always;
      case 'torch':
        return FlashMode.torch;
      default:
        return FlashMode.auto;
    }
  }

  // Check if a camera matches the facing preference
  bool _matchesFacing(CameraLensDirection direction) {
    switch (_facing) {
      case 'front':
        return direction == CameraLensDirection.front;
      case 'back':
        return direction == CameraLensDirection.back;
      case 'external':
        return direction == CameraLensDirection.external;
      default:
        return direction == CameraLensDirection.back;
    }
  }

  // Convert CameraLensDirection to string
  String _lensDirectionToString(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.front:
        return 'front';
      case CameraLensDirection.back:
        return 'back';
      case CameraLensDirection.external:
        return 'external';
    }
  }

  // Get camera info as a map
  Map<String, dynamic> _getCameraInfo(CameraDescription camera) {
    return {
      'name': camera.name,
      'lensDirection': _lensDirectionToString(camera.lensDirection),
      'sensorOrientation': camera.sensorOrientation,
    };
  }

  // Get all available cameras info
  List<Map<String, dynamic>> _getAvailableCamerasInfo() {
    return _cameras.map(_getCameraInfo).toList();
  }

  // Dispatch error event
  void _dispatchError(String eventName, String error, [String? code]) {
    dispatchEvent(CustomEvent(eventName, detail: {
      'error': error,
      if (code != null) 'code': code,
    }));
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        _dispatchError('camerafailed', 'No cameras available', 'NO_CAMERAS');
        return;
      }

      // Find camera matching facing preference
      _currentCameraIndex =
          _cameras.indexWhere((camera) => _matchesFacing(camera.lensDirection));
      if (_currentCameraIndex < 0) _currentCameraIndex = 0;

      await _createController(_cameras[_currentCameraIndex]);
    } catch (e) {
      logger.e('Camera initialization error: $e');
      _dispatchError('camerafailed', e.toString(), 'INIT_ERROR');
    }
  }

  // Create camera controller
  Future<void> _createController(CameraDescription camera) async {
    _cameraController?.dispose();

    _cameraController = CameraController(
      camera,
      _getResolutionPreset(),
      enableAudio: _enableAudio,
    );

    try {
      await _cameraController!.initialize();

      // Cache zoom/exposure limits
      _minZoom = await _cameraController!.getMinZoomLevel();
      _maxZoom = await _cameraController!.getMaxZoomLevel();
      _minExposureOffset = await _cameraController!.getMinExposureOffset();
      _maxExposureOffset = await _cameraController!.getMaxExposureOffset();

      // Apply initial settings
      await _applyFlashMode();
      if (_zoom > 1.0) {
        await _cameraController!.setZoomLevel(_zoom.clamp(_minZoom, _maxZoom));
      }

      _isInitialized = true;
      state?.requestUpdateState(() {});

      // Dispatch ready event
      dispatchEvent(CustomEvent('cameraready', detail: {
        'cameras': _getAvailableCamerasInfo(),
        'currentCamera': _getCameraInfo(_cameras[_currentCameraIndex]),
        'minZoom': _minZoom,
        'maxZoom': _maxZoom,
        'minExposureOffset': _minExposureOffset,
        'maxExposureOffset': _maxExposureOffset,
      }));
    } catch (e) {
      logger.e('Camera controller initialization error: $e');
      _dispatchError('camerafailed', e.toString(), 'CONTROLLER_ERROR');
    }
  }

  // Apply flash mode
  Future<void> _applyFlashMode() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      await _cameraController!.setFlashMode(_getFlashMode());
    } catch (e) {
      logger.e('Error setting flash mode: $e');
    }
  }

  // Apply focus mode
  Future<void> _applyFocusMode() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final mode = _focusMode == 'locked' ? FocusMode.locked : FocusMode.auto;
      await _cameraController!.setFocusMode(mode);
    } catch (e) {
      logger.e('Error setting focus mode: $e');
    }
  }

  // Apply exposure mode
  Future<void> _applyExposureMode() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      final mode =
          _exposureMode == 'locked' ? ExposureMode.locked : ExposureMode.auto;
      await _cameraController!.setExposureMode(mode);
    } catch (e) {
      logger.e('Error setting exposure mode: $e');
    }
  }

  // Take picture
  Future<Map<String, dynamic>> _takePicture() async {
    if (!_isInitialized || _cameraController == null) {
      throw Exception('Camera not initialized');
    }

    try {
      final XFile file = await _cameraController!.takePicture();
      final fileSize = await file.length();
      final result = {
        'path': file.path,
        'width': _cameraController!.value.previewSize?.width.toInt() ?? 0,
        'height': _cameraController!.value.previewSize?.height.toInt() ?? 0,
        'size': fileSize,
      };

      dispatchEvent(CustomEvent('photocaptured', detail: result));
      return result;
    } catch (e) {
      _dispatchError('capturefailed', e.toString());
      rethrow;
    }
  }

  // Start video recording
  Future<void> _startVideoRecording() async {
    if (!_isInitialized || _isRecording || _cameraController == null) return;

    try {
      await _cameraController!.startVideoRecording();
      _isRecording = true;
      dispatchEvent(CustomEvent('recordingstarted'));
    } catch (e) {
      _dispatchError('recordingfailed', e.toString());
      rethrow;
    }
  }

  // Stop video recording
  Future<Map<String, dynamic>> _stopVideoRecording() async {
    if (!_isRecording || _cameraController == null) {
      throw Exception('Not recording');
    }

    try {
      final XFile file = await _cameraController!.stopVideoRecording();
      _isRecording = false;

      final result = {
        'path': file.path,
        'duration': 0.0, // Duration not directly available from camera package
      };

      dispatchEvent(CustomEvent('recordingstopped', detail: result));
      return result;
    } catch (e) {
      _isRecording = false;
      _dispatchError('recordingfailed', e.toString());
      rethrow;
    }
  }

  // Pause video recording (iOS only)
  Future<void> _pauseVideoRecording() async {
    if (!_isRecording || _cameraController == null) return;
    try {
      await _cameraController!.pauseVideoRecording();
    } catch (e) {
      logger.e('Error pausing video recording: $e');
      rethrow;
    }
  }

  // Resume video recording (iOS only)
  Future<void> _resumeVideoRecording() async {
    if (!_isRecording || _cameraController == null) return;
    try {
      await _cameraController!.resumeVideoRecording();
    } catch (e) {
      logger.e('Error resuming video recording: $e');
      rethrow;
    }
  }

  // Switch camera
  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    await _createController(_cameras[_currentCameraIndex]);

    dispatchEvent(CustomEvent('cameraswitched', detail: {
      'facing':
          _lensDirectionToString(_cameras[_currentCameraIndex].lensDirection),
      'camera': _getCameraInfo(_cameras[_currentCameraIndex]),
    }));
  }

  // Switch to specific facing
  Future<void> _switchToFacing(String facing) async {
    final index =
        _cameras.indexWhere((c) => _lensDirectionToString(c.lensDirection) == facing);
    if (index >= 0 && index != _currentCameraIndex) {
      _currentCameraIndex = index;
      await _createController(_cameras[index]);
    }
  }

  // Set flash mode
  Future<void> _setFlashMode(String mode) async {
    _flashMode = mode;
    await _applyFlashMode();
  }

  // Set zoom level
  Future<void> _setZoomLevel(double zoom) async {
    if (_cameraController == null) return;
    _zoom = zoom.clamp(_minZoom, _maxZoom);
    await _cameraController!.setZoomLevel(_zoom);
    dispatchEvent(CustomEvent('zoomchanged', detail: {'zoom': _zoom}));
  }

  // Set exposure offset
  Future<double> _setExposureOffset(double offset) async {
    if (_cameraController == null) return _exposureOffset;
    _exposureOffset = offset.clamp(_minExposureOffset, _maxExposureOffset);
    final actual = await _cameraController!.setExposureOffset(_exposureOffset);
    return actual;
  }

  // Set focus point
  Future<void> _setFocusPoint(double x, double y) async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setFocusPoint(Offset(x, y));
      dispatchEvent(CustomEvent('focusset', detail: {'x': x, 'y': y}));
    } catch (e) {
      logger.e('Error setting focus point: $e');
      rethrow;
    }
  }

  // Set exposure point
  Future<void> _setExposurePoint(double x, double y) async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.setExposurePoint(Offset(x, y));
    } catch (e) {
      logger.e('Error setting exposure point: $e');
      rethrow;
    }
  }

  // Lock capture orientation
  Future<void> _lockCaptureOrientation(String? orientation) async {
    if (_cameraController == null) return;
    try {
      DeviceOrientation? deviceOrientation;
      if (orientation != null) {
        switch (orientation) {
          case 'portraitUp':
            deviceOrientation = DeviceOrientation.portraitUp;
            break;
          case 'portraitDown':
            deviceOrientation = DeviceOrientation.portraitDown;
            break;
          case 'landscapeLeft':
            deviceOrientation = DeviceOrientation.landscapeLeft;
            break;
          case 'landscapeRight':
            deviceOrientation = DeviceOrientation.landscapeRight;
            break;
        }
      }
      await _cameraController!.lockCaptureOrientation(deviceOrientation);
    } catch (e) {
      logger.e('Error locking capture orientation: $e');
      rethrow;
    }
  }

  // Unlock capture orientation
  Future<void> _unlockCaptureOrientation() async {
    if (_cameraController == null) return;
    try {
      await _cameraController!.unlockCaptureOrientation();
    } catch (e) {
      logger.e('Error unlocking capture orientation: $e');
      rethrow;
    }
  }

  // Dispose camera
  Future<void> _disposeCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;
    _isInitialized = false;
    _isRecording = false;
    dispatchEvent(CustomEvent('cameradisposed'));
  }

  @override
  FlutterCameraState? get state => super.state as FlutterCameraState?;

  @override
  WebFWidgetElementState createState() {
    return FlutterCameraState(this);
  }
}

/// State class for FlutterCamera
class FlutterCameraState extends WebFWidgetElementState {
  FlutterCameraState(super.widgetElement);

  @override
  FlutterCamera get widgetElement => super.widgetElement as FlutterCamera;

  @override
  void initState() {
    super.initState();

    // Auto-initialize if enabled
    if (widgetElement._autoInit) {
      widgetElement._initializeCamera();
    }
  }

  @override
  void dispose() {
    widgetElement._disposeCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator if not initialized
    if (!widgetElement._isInitialized ||
        widgetElement._cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Check if controller is initialized
    if (!widgetElement._cameraController!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Build camera preview with proper aspect ratio handling
    return ClipRect(
      child: OverflowBox(
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: widgetElement._cameraController!.value.previewSize!.height,
            height: widgetElement._cameraController!.value.previewSize!.width,
            child: CameraPreview(widgetElement._cameraController!),
          ),
        ),
      ),
    );
  }
}
