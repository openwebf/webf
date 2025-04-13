/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webf/webf.dart';

class CustomHybridHistoryDelegate extends HybridHistoryDelegate {
  @override
  void pop(BuildContext context) {
    Navigator.pop(context);
  }

  @override
  String path(BuildContext context, String? initialRoute) {
    String? currentPath = ModalRoute.of(context)?.settings.name;
    return currentPath ?? initialRoute ?? '';
  }

  @override
  void pushNamed(BuildContext context, String routeName, {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  @override
  void replaceState(BuildContext context, Object? state, String name) {
    Navigator.pushReplacementNamed(context, name, arguments: state);
  }

  @override
  dynamic state(BuildContext context, Map<String, dynamic>? initialState) {
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
    return Navigator.restorablePopAndPushNamed(context, routeName, arguments: arguments);
  }

  @override
  void popUntil(BuildContext context, RoutePredicate predicate) {
    Navigator.popUntil(context, predicate);
  }

  @override
  bool canPop(BuildContext context) {
    return Navigator.canPop(context);
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
    Navigator.popAndPushNamed(context, routeName, arguments: arguments);
  }

  @override
  void pushNamedAndRemoveUntil(
    BuildContext context,
    String newRouteName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    Navigator.pushNamedAndRemoveUntil(context, newRouteName, predicate, arguments: arguments);
  }
}
