/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:meta/meta.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/dom.dart';
import 'package:webf/launcher.dart';
import 'package:webf/devtools.dart';

String enumKey(String key) {
  return key.split('.').last;
}

class PageScreenCastFrameEvent extends InspectorEvent {
  @override
  String get method => 'Page.screencastFrame';

  @override
  JSONEncodable get params => _screenCastFrame;

  final ScreenCastFrame _screenCastFrame;

  PageScreenCastFrameEvent(this._screenCastFrame);
}

// Information about the Frame on the page.
class Frame extends JSONEncodable {
  // Frame unique identifier.
  final String id;

  // Parent frame identifier.
  String? parentId;

  // Identifier of the loader associated with this frame.
  final String loaderId;

  // Frame's name as specified in the tag.
  String? name;

  // Frame document's URL without fragment.
  final String url;

  // Frame document's URL fragment including the '#'.
  String? urlFragment;

  // Frame document's registered domain, taking the public suffixes list into account. Extracted from the Frame's url. Example URLs: http://www.google.com/file.html -> "google.com" http://a.b.co.uk/file.html -> "b.co.uk"
  final String domainAndRegistry;

  // Frame document's security origin.
  final String securityOrigin;

  // Frame document's mimeType as determined by the browser.
  final String mimeType;

  // If the frame failed to load, this contains the URL that could not be loaded. Note that unlike url above, this URL may contain a fragment.
  String? unreachableUrl;

  // Indicates whether this frame was tagged as an ad.
  String? AdFrameType;

  // Indicates whether the main document is a secure context and explains why that is the case.
  final String secureContextType;

  // Indicates whether this is a cross origin isolated context.
  final String crossOriginIsolatedContextType;

  // Indicated which gated APIs / features are available.
  final List<String> gatedAPIFeatures;

  Frame(this.id, this.loaderId, this.url, this.domainAndRegistry, this.securityOrigin, this.mimeType,
      this.secureContextType, this.crossOriginIsolatedContextType, this.gatedAPIFeatures,
      {this.parentId, this.name, this.urlFragment, this.unreachableUrl, this.AdFrameType});

  @override
  Map toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'loaderId': loaderId,
      'url': url,
      'domainAndRegistry': domainAndRegistry,
      'securityOrigin': securityOrigin,
      'mimeType': mimeType,
      'secureContextType': secureContextType,
      'crossOriginIsolatedContextType': crossOriginIsolatedContextType,
      'gatedAPIFeatures': gatedAPIFeatures
    };

    if (parentId != null) map['parentId'] = parentId;
    if (name != null) map['name'] = name;
    if (urlFragment != null) map['urlFragment'] = urlFragment;
    if (unreachableUrl != null) map['unreachableUrl'] = unreachableUrl;
    if (AdFrameType != null) map['AdFrameType'] = AdFrameType;
    return map;
  }
}

class FrameResource extends JSONEncodable {
  // Resource URL.
  final String url;

  // Type of this resource.
  final String type;

  // Resource mimeType as determined by the browser.
  final String mimeType;

  // last-modified timestamp as reported by server.
  int? lastModified;

  // Resource content size.
  int? contentSize;

  // True if the resource failed to load.
  bool? failed;

  // True if the resource was canceled during loading.
  bool? canceled;

  FrameResource(this.url, this.type, this.mimeType, {this.lastModified, this.contentSize, this.failed, this.canceled});

  @override
  Map toJson() {
    Map<String, dynamic> map = {'url': url, 'type': type, 'mimeType': mimeType};
    if (lastModified != null) map['lastModified'] = lastModified;
    if (contentSize != null) map['contentSize'] = contentSize;
    if (failed != null) map['failed'] = failed;
    if (canceled != null) map['canceled'] = canceled;
    return map;
  }
}

// Information about the Frame hierarchy along with their cached resources.
class FrameResourceTree extends JSONEncodable {
  // Frame information for this tree item.
  final Frame frame;

  // Child frames.
  List<FrameResourceTree>? childFrames;

  // Information about frame resources.
  final List<FrameResource> resources;

  FrameResourceTree(this.frame, this.resources, {this.childFrames});

  @override
  Map toJson() {
    Map<String, dynamic> map = {'frame': frame, 'resources': resources};
    if (childFrames != null) map['childFrames'] = childFrames;
    return map;
  }
}

enum ResourceType {
  Document,
  Stylesheet,
  Image,
  Media,
  Font,
  Script,
  TextTrack,
  XHR,
  Fetch,
  EventSource,
  WebSocket,
  Manifest,
  SignedExchange,
  Ping,
  CSPViolationReport,
  Preflight,
  Other
}

class InspectPageModule extends UIInspectorModule {
  Document get document => (devtoolsService is ChromeDevToolsService)
      ? ChromeDevToolsService.unifiedService.currentController!.view.document
      : devtoolsService.controller!.view.document;

  InspectPageModule(DevToolsService devtoolsService) : super(devtoolsService);

  @override
  String get name => 'Page';

  @override
  void receiveFromFrontend(int? id, String method, Map<String, dynamic>? params) async {
    switch (method) {
      case 'getResourceTree':
        handleGetFrameResourceTree(id, params!);
        break;
      case 'startScreencast':
        sendToFrontend(id, null);
        _devToolsMaxWidth = params?['maxWidth'] ?? 0;
        _devToolsMaxHeight = params?['maxHeight'] ?? 0;
        startScreenCast();
        break;
      case 'stopScreencast':
        sendToFrontend(id, null);
        stopScreenCast();
        break;
      case 'screencastFrameAck':
        sendToFrontend(id, null);
        handleScreencastFrameAck(params!);
        break;
      case 'getResourceContent':
        String? url = params!['url'];
        sendToFrontend(id,
            JSONEncodableMap({'content': devtoolsService.controller?.getResourceContent(url), 'base64Encoded': false}));
        break;
      case 'reload':
        sendToFrontend(id, null);
        handleReloadPage();
        break;
      default:
        sendToFrontend(id, null);
    }
  }

  void handleReloadPage() async {
    try {
      await document.controller.reload();
    } catch (e, stack) {
      print('Dart Error: $e\n$stack');
    }
  }

  int? _lastSentSessionID;
  bool _isFramingScreenCast = false;
  int _devToolsMaxWidth = 0;
  int _devToolsMaxHeight = 0;

  double _cachedViewportWidth = 300;
  double _cachedViewportHeight = 640;

  void _frameScreenCast(Duration timeStamp) {
    final controller = (devtoolsService is ChromeDevToolsService)
        ? ChromeDevToolsService.unifiedService.currentController
        : devtoolsService.controller;
    if (controller == null || !controller.isComplete) {
      return;
    }
    Element root = document.documentElement!;
    // the devtools of some pc do not automatically scale. so modify devicePixelRatio for it
    double? devicePixelRatio;
    double? viewportWidth = document.viewport?.viewportSize.width;
    double? viewportHeight = document.viewport?.viewportSize.height;

  // Send a screencast frame to the frontend.
  void _sendFrame(Uint8List bytes, Duration timeStamp, Element root, double deviceWidth, double deviceHeight) {
    final String encodedImage = base64Encode(bytes);
    _lastSentSessionID = timeStamp.inMilliseconds;
    final InspectorEvent event = PageScreenCastFrameEvent(
      ScreenCastFrame(
        encodedImage,
        ScreencastFrameMetadata(
          0,
          1,
          deviceWidth,
          deviceHeight,
          root.offsetLeft,
          root.offsetTop,
          timestamp: timeStamp.inMilliseconds,
        ),
        _lastSentSessionID!,
      ),
    );
    sendEventToFrontend(event);
  }

  // Generate and send a white PNG frame of the given viewport size.
  Future<void> _sendWhiteFrame(Duration timeStamp, Element root, double deviceWidth, double deviceHeight) async {
    final double dpr = document.controller.ownerFlutterView?.devicePixelRatio ?? 1.0;
    final int imgW = (deviceWidth * dpr).round().clamp(1, 1000000);
    final int imgH = (deviceHeight * dpr).round().clamp(1, 1000000);
    final Uint8List blank = await _makeWhitePng(imgW, imgH);
    _sendFrame(blank, timeStamp, root, deviceWidth, deviceHeight);
  }

  void _frameScreenCast(Duration timeStamp) {
    Element root = document.documentElement!;
    // the devtools of some pc do not automatically scale. so modify devicePixelRatio for it
    double? devicePixelRatio;
    double? viewportWidth = document.viewport?.viewportSize.width;
    double? viewportHeight = document.viewport?.viewportSize.height;

    _cachedViewportWidth = viewportWidth ?? _cachedViewportWidth;
    _cachedViewportHeight = viewportHeight ?? _cachedViewportHeight;
    final double deviceWidth = _cachedViewportWidth;
    final double deviceHeight = _cachedViewportHeight;

    // When flutter is detached, stream a white blank frame until it reattaches.
    if (!devtoolsService.controller!.isFlutterAttached ||
        !devtoolsService.controller!.viewportLayoutCompleter.isCompleted) {
      _sendWhiteFrame(timeStamp, root, deviceWidth, deviceHeight);
      return;
    }

    if (_devToolsMaxWidth > 0 && _devToolsMaxHeight > 0 && deviceWidth > 0 && deviceHeight > 0) {
      // Scale down according to devtools constraints, capped by device DPR.
      final double sx = _devToolsMaxWidth / deviceWidth;
      final double sy = _devToolsMaxHeight / deviceHeight;
      devicePixelRatio = math.min(sx, sy);
      devicePixelRatio = math.min(devicePixelRatio, document.controller.ownerFlutterView!.devicePixelRatio);
    }
    root
        .toBlob(devicePixelRatio: devicePixelRatio)
        .then((Uint8List screenShot) {
          if (!devtoolsService.controller!.isFlutterAttached) {
            // Detached after capture started; send white frame instead.
            return _sendWhiteFrame(timeStamp, root, deviceWidth, deviceHeight);
          }
          _sendFrame(screenShot, timeStamp, root, deviceWidth, deviceHeight);
        })
        .catchError((error, stack) {
          // If capturing failed, send a white frame to keep stream consistent.
          return _sendWhiteFrame(timeStamp, root, deviceWidth, deviceHeight);
        });
  }

  Future<Uint8List> _makeWhitePng(int width, int height) async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);
    final picture = recorder.endRecording();
    final ui.Image image = await picture.toImage(width, height);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void startScreenCast() {
    _isFramingScreenCast = true;
    SchedulerBinding.instance.addPostFrameCallback(_frameScreenCast);
    SchedulerBinding.instance.scheduleFrame();
  }

  void stopScreenCast() {
    _isFramingScreenCast = false;
  }

  /// Gets whether screencast is currently active
  bool get isScreencastActive => _isFramingScreenCast;

  /// Transfers screencast state from another Page module (used during controller switch)
  void transferScreencastState(InspectPageModule fromModule) {
    if (fromModule._isFramingScreenCast) {
      _isFramingScreenCast = true;
      _devToolsMaxWidth = fromModule._devToolsMaxWidth;
      _devToolsMaxHeight = fromModule._devToolsMaxHeight;
      _lastSentSessionID = fromModule._lastSentSessionID;

      // Start screencast on the new controller
      SchedulerBinding.instance.addPostFrameCallback(_frameScreenCast);
      SchedulerBinding.instance.scheduleFrame();
    }
  }

  /// Avoiding frame blocking, confirm frontend has ack last frame,
  /// and then send next frame.
  void handleScreencastFrameAck(Map<String, dynamic> params) {
    int? ackSessionID = params['sessionId'];
    if (ackSessionID == _lastSentSessionID && _isFramingScreenCast) {
      SchedulerBinding.instance.addPostFrameCallback(_frameScreenCast);
    }
  }

  void handleGetFrameResourceTree(int? id, Map<String, dynamic> params) {
    Frame frame = Frame('Frame Name', 'frame-id', '', '', '', '', '', '', []);
    FrameResourceTree frameResourceTree = FrameResourceTree(frame, []);
    sendToFrontend(id, JSONEncodableMap({'frameTree': frameResourceTree}));
  }
}

@immutable
class ScreenCastFrame implements JSONEncodable {
  final String data;
  final ScreencastFrameMetadata metadata;
  final int sessionId;

  ScreenCastFrame(this.data, this.metadata, this.sessionId);

  @override
  Map toJson() {
    return {
      'data': data,
      'metadata': metadata.toJson(),
      'sessionId': sessionId,
    };
  }
}

@immutable
class ScreencastFrameMetadata implements JSONEncodable {
  final num offsetTop;
  final num pageScaleFactor;
  final num deviceWidth;
  final num deviceHeight;
  final num scrollOffsetX;
  final num scrollOffsetY;
  final num? timestamp;

  ScreencastFrameMetadata(
      this.offsetTop, this.pageScaleFactor, this.deviceWidth, this.deviceHeight, this.scrollOffsetX, this.scrollOffsetY,
      {this.timestamp});

  @override
  Map toJson() {
    return {
      'offsetTop': offsetTop,
      'pageScaleFactor': pageScaleFactor,
      'deviceWidth': deviceWidth,
      'deviceHeight': deviceHeight,
      'scrollOffsetX': scrollOffsetX,
      'scrollOffsetY': scrollOffsetY,
      'timestamp': timestamp
    };
  }
}
