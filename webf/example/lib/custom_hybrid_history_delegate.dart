/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:webf/webf.dart';

class CustomHybridHistoryDelegate extends HybridHistoryDelegate {
  @override
  void pop(BuildContext context) {
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
      return;
    }
    Navigator.pop(context);
  }

  @override
  String path(BuildContext? context, String? initialRoute) {
    if (context == null) return initialRoute ?? '/';
    try {
      return GoRouterState.of(context).uri.toString();
    } catch (_) {
      String? currentPath = ModalRoute.of(context)?.settings.name;
      return currentPath ?? initialRoute ?? '/';
    }
  }

  @override
  void pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    GoRouter.of(context).push(routeName, extra: arguments);
  }

  @override
  void replaceState(BuildContext context, Object? state, String name) {
    GoRouter.of(context).pushReplacement(name, extra: state);
  }

  @override
  dynamic state(BuildContext? context, Map<String, dynamic>? initialState) {
    if (context == null) return initialState != null ? jsonEncode(initialState) : '{}';
    var route = ModalRoute.of(context);
    if (route?.settings.arguments != null) {
      return jsonEncode(route!.settings.arguments);
    }
    return '{}';
  }

  @override
  String restorablePopAndPushNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    // go_router doesn't support restorable navigation APIs; fall back to a non-restorable equivalent.
    if (GoRouter.of(context).canPop()) {
      GoRouter.of(context).pop();
    }
    GoRouter.of(context).push(routeName, extra: arguments);
    return routeName;
  }

  @override
  void popUntil(BuildContext context, RoutePredicate predicate) {
    final router = GoRouter.of(context);
    final navigator = router.routerDelegate.navigatorKey.currentState;
    if (navigator != null) {
      navigator.popUntil(predicate);
      return;
    }
    Navigator.popUntil(context, predicate);
  }

  @override
  bool canPop(BuildContext context) {
    return GoRouter.of(context).canPop() || Navigator.canPop(context);
  }

  @override
  Future<bool> maybePop<T extends Object?>(BuildContext context, [T? result]) {
    return Navigator.maybePop(context, result);
  }

  @override
  void popAndPushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    final router = GoRouter.of(context);
    if (router.canPop()) {
      router.pop();
    }
    router.push(routeName, extra: arguments);
  }

  @override
  void pushNamedAndRemoveUntil(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    final router = GoRouter.of(context);
    final navigator = router.routerDelegate.navigatorKey.currentState;
    if (navigator != null) {
      navigator.popUntil(predicate);
      router.push(newRouteName, extra: arguments);
      return;
    }
    router.go(newRouteName, extra: arguments);
  }
}
