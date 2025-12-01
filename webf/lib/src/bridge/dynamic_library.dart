/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:ffi';
import 'dart:io' show Platform;

import 'package:path/path.dart';

abstract class WebFDynamicLibrary {
  static final String _defaultLibraryPath = '';

  /// The search path that dynamic library be load, if null using default.
  static String dynamicLibraryPath = _defaultLibraryPath;

  // The kraken library name.
  static String libName = 'webf';

  static String get _nativeDynamicLibraryName {
    if (Platform.isMacOS) {
      return 'lib$libName.dylib';
    } else if (Platform.isWindows) {
      return 'lib$libName.dll';
    } else if (Platform.isAndroid || Platform.isLinux) {
      return 'lib$libName.so';
    } else {
      throw UnimplementedError('Not supported platform.');
    }
  }

  static DynamicLibrary? _ref;
  static DynamicLibrary get ref {
    DynamicLibrary? nativeDynamicLibrary = _ref;
    if (Platform.isIOS) {
      _ref = nativeDynamicLibrary ??= DynamicLibrary.executable();
    } else {
      _ref = nativeDynamicLibrary ??= DynamicLibrary.open(
          join(dynamicLibraryPath, _nativeDynamicLibraryName));
    }

    return nativeDynamicLibrary;
  }
}
