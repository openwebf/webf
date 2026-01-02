/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'binding_object.dart';

typedef BindingObjectCreator = BindingObject Function(BindingContext context, List<dynamic> args);

final class BindingObjectRegistry {
  static final Map<String, BindingObjectCreator> _creators = {};
  static int _version = 0;

  static int get version => _version;
  static Iterable<String> get names => _creators.keys;

  static BindingObjectCreator? getCreator(String name) => _creators[name];

  static void define(String name, BindingObjectCreator creator) {
    _creators[name] = creator;
    _version++;
  }
}

