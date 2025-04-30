/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:webf/foundation.dart';

/// A special WebFBundle implementation for testing that can simulate
/// network delays and other timing-related behaviors
class MockTimedBundle extends WebFBundle {
  MockTimedBundle(
    String url, {
    this.delayInMilliseconds = 0,
    this.content,
    this.bytecode,
    this.completer,
    this.autoResolve = true,
    ContentType? contentType,
  }) : super(url, contentType: contentType) {
    // If automatic resolution is enabled, prepare the data
    if (autoResolve && content != null) {
      data = Uint8List.fromList(utf8.encode(content!));
    } else if (autoResolve && bytecode != null) {
      data = bytecode;
    }
  }

  /// The delay in milliseconds before this bundle will resolve
  final int delayInMilliseconds;

  /// Optional text content for the bundle
  final String? content;

  /// Optional bytecode for the bundle
  final Uint8List? bytecode;

  /// A completer that can be used to manually control when the bundle resolves
  final Completer? completer;

  /// Whether the bundle should automatically resolve after the delay
  final bool autoResolve;

  /// Flag to track if this bundle has been canceled during loading
  bool _isCanceled = false;

  /// Method to allow cancellation of this bundle during loading
  void cancel() {
    _isCanceled = true;
  }

  /// Check if this bundle has been canceled
  bool get isCanceled => _isCanceled;

  @override
  Future<void> resolve({String? baseUrl, UriParser? uriParser}) async {
    await super.resolve(baseUrl: baseUrl, uriParser: uriParser);

    // If a delay is specified, wait for that duration
    if (delayInMilliseconds > 0) {
      await Future.delayed(Duration(milliseconds: delayInMilliseconds));
    }

    // Check if canceled after delay/completer
    if (_isCanceled) {
      throw FlutterError('Bundle loading was canceled');
    }
  }

  @override
  String toStringShort() {
    return 'MockTimedBundle($content)';
  }

  @override
  Future<void> obtainData([double contextId = 0]) async {
    // If data is already set or the bundle is canceled, return immediately
    if (data != null || _isCanceled) return;

    // If we have a delay, wait for it
    if (delayInMilliseconds > 0) {
      await Future.delayed(Duration(milliseconds: delayInMilliseconds));
    }

    // If we have a completer, wait for it
    if (completer != null) {
      await completer!.future;
    }

    // Check if canceled after delay/completer
    if (_isCanceled) {
      throw FlutterError('Bundle loading was canceled');
    }

    // Set the content based on what was provided
    if (content != null) {
      data = Uint8List.fromList(utf8.encode(content!));
    } else if (bytecode != null) {
      data = bytecode;
    } else {
      data = Uint8List.fromList(utf8.encode('console.log("Default mock content")'));
    }
  }

  /// Creates a MockTimedBundle that will resolve quickly (10ms delay)
  static MockTimedBundle fast({
    String? content,
    Uint8List? bytecode,
    ContentType? contentType,
    String url = 'mock://fast.js',
  }) {
    return MockTimedBundle(
      url,
      delayInMilliseconds: 10,
      content: content,
      bytecode: bytecode,
      contentType: contentType ?? javascriptContentType,
    );
  }

  /// Creates a MockTimedBundle that will resolve quickly (10ms delay)
  static MockTimedBundle medium({
    String? content,
    Uint8List? bytecode,
    ContentType? contentType,
    String url = 'mock://medium.js',
  }) {
    return MockTimedBundle(
      url,
      delayInMilliseconds: 100,
      content: content,
      bytecode: bytecode,
      contentType: contentType ?? javascriptContentType,
    );
  }

  /// Creates a MockTimedBundle that will resolve slowly (500ms delay)
  static MockTimedBundle slow({
    String? content,
    Uint8List? bytecode,
    ContentType? contentType,
    String url = 'mock://slow.js',
  }) {
    return MockTimedBundle(
      url,
      delayInMilliseconds: 500,
      content: content,
      bytecode: bytecode,
      contentType: contentType ?? javascriptContentType,
    );
  }

  /// Creates a MockTimedBundle that will only resolve when the provided completer completes
  static MockTimedBundle controlled({
    required Completer completer,
    String? content,
    Uint8List? bytecode,
    ContentType? contentType,
    String url = 'mock://controlled.js',
  }) {
    return MockTimedBundle(
      url,
      completer: completer,
      content: content,
      bytecode: bytecode,
      contentType: contentType ?? javascriptContentType,
    );
  }
}
