/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webf/webf.dart';

class GoRouterHybridHistoryDelegate extends HybridHistoryDelegate {
  @override
  void pop(BuildContext context) {
    // Use go_router's pop functionality
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    }
  }

  @override
  String path(BuildContext? context, String? initialRoute) {
    if (context == null) return initialRoute ?? '/';
    
    // CRITICAL FIX: For WebF internal navigation, we need to track the current WebF route path
    // not the go_router global path. WebF expects this to return the current route within the WebF app.
    
    // Try to get the current route from the nearest ModalRoute (which represents the current WebF route)
    final ModalRoute? route = ModalRoute.of(context);
    if (route?.settings.name != null) {
      final routeName = route!.settings.name!;
      return routeName;
    }
    
    // Fallback to go_router's current location
    final GoRouter router = GoRouter.of(context);
    final String currentLocation = router.routeInformationProvider.value.uri.path;
    return currentLocation.isNotEmpty ? currentLocation : (initialRoute ?? '/');
  }

  @override
  void pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    // Use go_router's push to maintain proper route stack
    if (arguments != null) {
      GoRouter.of(context).push(routeName, extra: arguments);
    } else {
      GoRouter.of(context).push(routeName);
    }
  }

  @override
  void replaceState(BuildContext context, Object? state, String name) {
    // Use go_router's pushReplacement functionality
    if (state != null) {
      GoRouter.of(context).pushReplacement(name, extra: state);
    } else {
      GoRouter.of(context).pushReplacement(name);
    }
  }

  @override
  dynamic state(BuildContext? context, Map<String, dynamic>? initialState) {
    if (context == null) return initialState != null ? jsonEncode(initialState) : '{}';
    
    // CRITICAL FIX: Get state from go_router's extra parameter
    // This is where the state from hybridHistory.pushState() is actually stored
    final route = ModalRoute.of(context);
    if (route?.settings.arguments != null) {
      final arguments = route!.settings.arguments;
      
      if (arguments is Map) {
        return jsonEncode(arguments);
      } else {
        return jsonEncode({'data': arguments});
      }
    }
    
    // Try to get from GoRouterState if available
    try {
      final goRouterState = GoRouterState.of(context);
      if (goRouterState.extra != null) {
        
        if (goRouterState.extra is Map) {
          return jsonEncode(goRouterState.extra);
        } else {
          return jsonEncode({'data': goRouterState.extra});
        }
      }
    } catch (e) {
      print('[GoRouterHybridHistoryDelegate.state] Could not get GoRouterState: $e');
    }
    
    // Fallback to initialState
    return initialState != null ? jsonEncode(initialState) : '{}';
  }

  @override
  String restorablePopAndPushNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    // go_router doesn't have direct equivalent, use pop + push
    pop(context);
    pushNamed(context, routeName, arguments: arguments);
    return routeName; // Return route name as restoration ID
  }

  @override
  void popUntil(BuildContext context, RoutePredicate predicate) {
    // go_router approach: keep popping while we can and predicate fails
    final GoRouter router = GoRouter.of(context);
    
    // This is a simplified implementation
    // For more complex scenarios, you might need to track route stack differently
    while (router.canPop()) {
      // Check current route against predicate
      final currentRoute = ModalRoute.of(context);
      if (currentRoute != null && predicate(currentRoute)) {
        break;
      }
      router.pop();
    }
  }

  @override
  bool canPop(BuildContext context) {
    return GoRouter.of(context).canPop();
  }

  @override
  Future<bool> maybePop<T extends Object?>(BuildContext context, [T? result]) async {
    final GoRouter router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop(result);
      return true;
    }
    return false;
  }

  @override
  void popAndPushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    // Use go_router's pushReplacement which is equivalent to pop + push
    if (arguments != null) {
      GoRouter.of(context).pushReplacement(routeName, extra: arguments);
    } else {
      GoRouter.of(context).pushReplacement(routeName);
    }
  }

  @override
  void pushNamedAndRemoveUntil(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    // For go_router, we'll use go() which replaces the entire route stack
    // This is a simplified approach - for complex scenarios you might need
    // to manage the route stack more carefully
    if (arguments != null) {
      GoRouter.of(context).go(newRouteName, extra: arguments);
    } else {
      GoRouter.of(context).go(newRouteName);
    }
  }
}