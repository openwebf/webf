/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:webf/webf.dart';

class HybridHistoryItem {
  HybridHistoryItem(this.bundle, this.state, this.needJump);

  final WebFBundle bundle;
  final dynamic state;
  final bool needJump;
}

abstract class HybridHistoryDelegate {
  /// Pop the top-most route off the navigator that most tightly encloses the
  /// given context.
  void pop(BuildContext context);

  /// Push a named route onto the navigator that most tightly encloses the given
  /// context.
  void pushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  });

  String restorablePopAndPushNamed<T extends Object?, TO extends Object?>(
      BuildContext context,
      String routeName, {
        TO? result,
        Object? arguments,
      });

  void replaceState(BuildContext context, Object? state, String name);

  String path(BuildContext context, String? initialRoute);

  dynamic state(BuildContext context, Map<String, dynamic>? initialState);

  /// Pops until a route with the given name.
  void popUntil(BuildContext context, RoutePredicate predicate);

  /// Whether the navigator can be popped.
  bool canPop(BuildContext context);

  /// Pop the top-most route off, only if it's not the last route.
  Future<bool> maybePop<T extends Object?>(BuildContext context, [T? result]);

  /// Pop the current route off and push a named route in its place.
  void popAndPushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  });

  /// Push the route with the given name and remove routes until the predicate returns true.
  void pushNamedAndRemoveUntil(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  });
}

class HybridHistoryModule extends BaseModule {
  @override
  String get name => 'HybridHistory';

  HybridHistoryDelegate? _delegate;

  set delegate(HybridHistoryDelegate value) {
    _delegate = value;
  }

  HybridHistoryModule(ModuleManager? moduleManager) : super(moduleManager);

  BuildContext? get _context => moduleManager?.controller.currentBuildContext?.context;

  void back() async {
    pop();
  }

  /// Pop the current route - matches Flutter's Navigator.pop
  void pop([Object? result]) {
    if (_delegate != null) {
      _delegate!.pop(_context!);
      return;
    }
    Navigator.pop(_context!, result);
  }

  /// Push a named route onto the navigator that most tightly encloses the given
  /// context.
  /// Original API - kept for backward compatibility
  void pushState(Object? state, String name) {
    pushNamed(name, arguments: state);
  }

  /// Push a named route onto the navigator - matches Flutter's Navigator.pushNamed
  void pushNamed(String routeName, {Object? arguments}) {
    if (_delegate != null) {
      _delegate!.pushNamed(_context!, routeName, arguments: arguments);
      return;
    }
    Navigator.pushNamed(_context!, routeName, arguments: arguments);
  }

  /// Pop the current route off the navigator that most tightly encloses the
  /// given context and push a named route in its place.
  /// Original API - kept for backward compatibility
  String restorablePopAndPushState(Object? state, String name) {
    return restorablePopAndPushNamed(name, arguments: state);
  }

  /// Restorably pop the current route and push a named route - matches Flutter's Navigator
  String restorablePopAndPushNamed(String routeName, {Object? arguments}) {
    if (_delegate != null) {
      return _delegate!.restorablePopAndPushNamed(_context!, routeName, arguments: arguments);
    }
    return Navigator.restorablePopAndPushNamed(_context!, routeName, arguments: arguments);
  }

  /// Original API - kept for backward compatibility
  void replaceState(Object? state, String name) {
    if (moduleManager!.controller.buildContextStack.length == 1) {
      throw FlutterError('Can not replaceState at the top stack of hybrid router');
    }
    pushReplacementNamed(name, arguments: state);
  }

  /// Push a replacement named route - matches Flutter's Navigator.pushReplacementNamed
  void pushReplacementNamed(String routeName, {Object? arguments}) {
    if (_delegate != null) {
      _delegate!.replaceState(_context!, arguments, routeName);
      return;
    }
    Navigator.pushReplacementNamed(_context!, routeName, arguments: arguments);
  }

  String path() {
    String initialRoute = moduleManager!.controller.initialRoute;
    if (_delegate != null) {
      return _delegate!.path(_context!, initialRoute);
    }
    String? currentPath = ModalRoute.of(_context!)?.settings.name;
    return currentPath ?? initialRoute ?? '/';
  }

  /// Whether the navigator can be popped.
  bool canPop() {
    if (_delegate != null) {
      return _delegate!.canPop(_context!);
    }
    return Navigator.canPop(_context!);
  }

  /// Pop the top-most route off, only if it's not the last route.
  Future<bool> maybePop([Object? result]) async {
    if (_delegate != null) {
      return await _delegate!.maybePop(_context!, result);
    }
    return await Navigator.maybePop(_context!, result);
  }

  /// Pop the current route off and push a named route in its place.
  void popAndPushNamed(String routeName, {Object? arguments}) {
    if (_delegate != null) {
      _delegate!.popAndPushNamed(_context!, routeName, arguments: arguments);
      return;
    }
    Navigator.popAndPushNamed(_context!, routeName, arguments: arguments);
  }

  /// Pops until a route with the given name.
  void popUntil(String routeName) {
    bool predicateFunc(Route<dynamic> route) => route.settings.name == routeName;
    if (_delegate != null) {
      _delegate!.popUntil(_context!, predicateFunc);
      return;
    }
    Navigator.popUntil(_context!, predicateFunc);
  }

  /// Push the route with the given name and remove routes until the predicate returns true.
  /// Original API - kept for backward compatibility
  void pushNamedAndRemoveUntil(Object? state, String newRouteName, String untilRouteName) {
    pushNamedAndRemoveUntilRoute(newRouteName, untilRouteName, arguments: state);
  }

  /// Push the route with the given name and remove routes until named route is reached.
  /// This is a more Flutter-like API
  void pushNamedAndRemoveUntilRoute(String newRouteName, String untilRouteName, {Object? arguments}) {
    bool predicateFunc(Route<dynamic> route) => route.settings.name == untilRouteName;
    if (_delegate != null) {
      _delegate!.pushNamedAndRemoveUntil(
        _context!,
        newRouteName,
        predicateFunc,
        arguments: arguments
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      _context!,
      newRouteName,
      predicateFunc,
      arguments: arguments
    );
  }

  @override
  dynamic invoke(String method, Object? params, InvokeModuleCallback callback) {
    // Handle the case where params might be null
    List<dynamic> paramsList = [];
    if (params != null) {
      paramsList = params as List<dynamic>;
    }

    if (_context == null) {
      throw FlutterError('Could not invoke HybridHistory API when flutter context was not attached');
    }

    switch (method) {
      case 'state':
        Map<String, dynamic>? initialState = moduleManager!.controller.initialState;

        if (_delegate != null) {
          return _delegate!.state(_context!, initialState);
        }

        var route = ModalRoute.of(_context!);

        if (route?.settings.arguments != null) {
          return jsonEncode(route!.settings.arguments);
        } else if (route?.settings.name == null && initialState != null) {
          return jsonEncode(initialState);
        }
        return '{}';

      // Original API methods - for backward compatibility
      case 'back':
        back();
        break;
      case 'pushState':
        if (paramsList.length >= 2) {
          pushState(paramsList[0], paramsList[1]);
        }
        break;
      case 'replaceState':
        if (paramsList.length >= 2) {
          replaceState(paramsList[0], paramsList[1]);
        }
        break;
      case 'restorablePopAndPushState':
        if (paramsList.length >= 2) {
          return restorablePopAndPushState(paramsList[0], paramsList[1]);
        }
        break;

      // New Flutter-like API methods
      case 'pop':
        pop(paramsList.isNotEmpty ? paramsList[0] : null);
        break;
      case 'pushNamed':
        if (paramsList.length >= 2) {
          pushNamed(paramsList[0], arguments: paramsList[1]);
        } else if (paramsList.isNotEmpty) {
          pushNamed(paramsList[0]);
        }
        break;
      case 'pushReplacementNamed':
        if (paramsList.length >= 2) {
          pushReplacementNamed(paramsList[0], arguments: paramsList[1]);
        } else if (paramsList.isNotEmpty) {
          pushReplacementNamed(paramsList[0]);
        }
        break;
      case 'restorablePopAndPushNamed':
        if (paramsList.length >= 2) {
          return restorablePopAndPushNamed(paramsList[0], arguments: paramsList[1]);
        } else if (paramsList.isNotEmpty) {
          return restorablePopAndPushNamed(paramsList[0]);
        }
        break;

      // Other methods
      case 'path':
        return path();
      case 'canPop':
        return canPop().toString();
      case 'maybePop':
        // We need to handle this specially because it returns a Future
        maybePop(paramsList.isNotEmpty ? paramsList[0] : null).then((value) {
          callback(data: value.toString());
        });
        return EMPTY_STRING;
      case 'popAndPushNamed':
        if (paramsList.length >= 2) {
          popAndPushNamed(paramsList[0], arguments: paramsList[1]);
        } else if (paramsList.isNotEmpty) {
          popAndPushNamed(paramsList[0]);
        }
        break;
      case 'popUntil':
        if (paramsList.isNotEmpty) {
          popUntil(paramsList[0]);
        }
        break;
      case 'pushNamedAndRemoveUntil':
        if (paramsList.length == 3) {
          // Old style with 3 params
          pushNamedAndRemoveUntil(paramsList[0], paramsList[1], paramsList[2]);
        } else if (paramsList.length >= 2) {
          // New style with 2+ params
          pushNamedAndRemoveUntilRoute(paramsList[0], paramsList[1],
            arguments: paramsList.length > 2 ? paramsList[2] : null);
        }
        break;
    }
    return EMPTY_STRING;
  }

  @override
  void dispose() {}
}
