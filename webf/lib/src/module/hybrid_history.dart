/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:collection';
import 'dart:convert';

import 'package:webf/webf.dart';

class HybridHistoryItem {
  HybridHistoryItem(this.bundle, this.state, this.needJump);
  final WebFBundle bundle;
  final dynamic state;
  final bool needJump;
}

class HybridHistoryModule extends BaseModule {
  @override
  String get name => 'HybridHistory';

  HybridHistoryModule(ModuleManager? moduleManager) : super(moduleManager);

  Queue<HybridHistoryItem> get _previousStack => moduleManager!.controller.previousHybridHistoryStack;
  Queue<HybridHistoryItem> get _nextStack => moduleManager!.controller.nextHybridHistoryStack;

  WebFBundle? get stackTop {
    if (_previousStack.isEmpty) {
      return null;
    } else {
      return _previousStack.first.bundle;
    }
  }

  void add(WebFBundle bundle) {
    HybridHistoryItem history = HybridHistoryItem(bundle, null, true);
    _addItem(history);
  }

  void _addItem(HybridHistoryItem historyItem) {
    _previousStack.addFirst(historyItem);

    // Clear.
    while (_nextStack.isNotEmpty) {
      _nextStack.removeFirst();
    }
  }

  void back() async {
    if (_previousStack.length > 1) {
      HybridHistoryItem currentItem = _previousStack.first;
      _previousStack.removeFirst();
      _nextStack.addFirst(currentItem);
      dynamic state = _previousStack.first.state;
      _dispatchPopStateEvent(state);
    }
  }

  void forward() {
    if (_nextStack.isNotEmpty) {
      HybridHistoryItem currentItem = _nextStack.first;
      _nextStack.removeFirst();
      _previousStack.addFirst(currentItem);
      _dispatchPopStateEvent(currentItem.state);
    }
  }

  void go(num? num) {
    num ??= 0;
    if (num >= 0) {
      if (_nextStack.length < num) {
        return;
      }

      for (int i = 0; i < num; i++) {
        HybridHistoryItem currentItem = _nextStack.first;
        _nextStack.removeFirst();
        _previousStack.addFirst(currentItem);
      }
    } else {
      if (_previousStack.length - 1 < num.abs()) {
        return;
      }

      for (int i = 0; i < num.abs(); i++) {
        HybridHistoryItem currentItem = _previousStack.first;
        _previousStack.removeFirst();
        _nextStack.addFirst(currentItem);
      }
    }

    _dispatchPopStateEvent(_previousStack.first.state);
  }

  void _dispatchPopStateEvent(state) {
    PopStateEvent popStateEvent = PopStateEvent(state: state);
    moduleManager!.controller.view.window.dispatchEvent(popStateEvent);
  }

  void pushState(state, {String? url, String? title}) {
    try {
      WebFController controller = moduleManager!.controller;
      String currentUrl = _previousStack.first.bundle.url;
      url = url ?? currentUrl;
      Uri uri = Uri.parse(url);
      Uri currentUri = Uri.parse(currentUrl);
      uri = controller.uriParser!.resolve(Uri.parse(controller.url), uri);

      if (uri.host.isNotEmpty && uri.host != currentUri.host) {
        print('Failed to execute \'pushState\' on \'HybridHistory\': '
            'A history state object with URL $url cannot be created in a document with origin ${uri.host} and URL ${currentUri.host}. "');
        return;
      }

      WebFBundle bundle = controller.getPreloadBundleFromUrl(uri.toString()) ?? WebFBundle.fromUrl(uri.toString());
      HybridHistoryItem history = HybridHistoryItem(bundle, state, false);
      _addItem(history);
    } catch (e) {
      print('$e');
    }
  }

  void replaceState(state, {String? url, String? title}) {
    WebFController controller = moduleManager!.controller;
    url = url ?? _previousStack.first.bundle.url;
    String currentUrl = _previousStack.first.bundle.url;
    Uri currentUri = Uri.parse(currentUrl);

    Uri uri = Uri.parse(url);
    uri = controller.uriParser!.resolve(Uri.parse(controller.url), uri);

    if (uri.host.isNotEmpty && uri.host != currentUri.host) {
      print('Failed to execute \'pushState\' on \'History\': '
          'A history state object with URL $url cannot be created in a document with origin ${uri.host} and URL ${currentUri.host}. "');
      return;
    }

    WebFBundle bundle = controller.getPreloadBundleFromUrl(uri.toString()) ?? WebFBundle.fromUrl(uri.toString());
    HybridHistoryItem history = HybridHistoryItem(bundle, state, false);

    _previousStack.removeFirst();
    _previousStack.addFirst(history);
  }

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'length':
        return (_previousStack.length + _nextStack.length).toString();
      case 'state':
        if (_previousStack.isEmpty) {
          return jsonEncode(null);
        }
        HybridHistoryItem history = _previousStack.first;
        return jsonEncode(history.state);
      case 'back':
        back();
        break;
      case 'forward':
        forward();
        break;
      case 'pushState':
        pushState(params[0], title: params[1], url: params[2]);
        break;
      case 'replaceState':
        replaceState(params[0], title: params[1], url: params[2]);
        break;
      case 'go':
        go(params);
        break;
    }
    return EMPTY_STRING;
  }

  @override
  void dispose() {}
}
