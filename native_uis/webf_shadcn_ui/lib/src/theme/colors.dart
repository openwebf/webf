/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under the Apache License, Version 2.0.
 */

import 'package:flutter/widgets.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Returns a ShadColorScheme for the given scheme name and brightness.
ShadColorScheme getColorScheme(String scheme, Brightness brightness) {
  return ShadColorScheme.fromName(scheme, brightness: brightness);
}

/// All available color scheme names.
const List<String> availableColorSchemes = [
  'blue',
  'gray',
  'green',
  'neutral',
  'orange',
  'red',
  'rose',
  'slate',
  'stone',
  'violet',
  'yellow',
  'zinc',
];
