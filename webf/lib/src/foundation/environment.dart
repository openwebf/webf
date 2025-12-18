/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Directory? _webfTemporaryDirectory;
Future<String> getWebFTemporaryPath() async {
  if (_webfTemporaryDirectory == null) {
    Directory temporaryDirectory = await getTemporaryDirectory();
    _webfTemporaryDirectory = temporaryDirectory;
  }
  return _webfTemporaryDirectory!.path;
}

MethodChannel _methodChannel = const MethodChannel('webf');
MethodChannel getWebFMethodChannel() {
  return _methodChannel;
}
