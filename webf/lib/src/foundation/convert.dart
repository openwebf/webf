/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

bool isValidUTF8String(Uint8List data) {
  int count = 0;
  for (int byte in data) {
    if (count == 0) {
      if ((byte >> 7) == 0) {
        continue;
      } else if ((byte >> 5) == 0x6) { // 0b110 in hex
        count = 1;
      } else if ((byte >> 4) == 0xE) { // 0b1110 in hex
        count = 2;
      } else if ((byte >> 3) == 0x1E) { // 0b11110 in hex
        count = 3;
      } else {
        return false; // Invalid starting byte
      }
    } else {
      if ((byte >> 6) != 0x2) { // 0b10 in hex
        return false; // Not a valid continuation byte
      }
      count--;
    }
  }
  return count == 0;
}

FutureOr<String> resolveStringFromData(final List<int> data, {Codec codec = utf8, bool preferSync = false}) async {
  if (codec == utf8) {
    return _resolveUtf8StringFromData(data, preferSync);
  } else {
    return codec.decode(data);
  }
}

Future<String> _resolveUtf8StringFromData(final List<int> data, [bool preferSync = false]) async {
  // reference: https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/services/asset_bundle.dart#L71
  // 50 KB of data should take 2-3 ms to parse on a Moto G4, and about 400 μs
  // on a Pixel 4.
  if (preferSync || data.length < 50 * 1024) {
    return utf8.decode(data);
  }
  // For strings larger than 50 KB, run the computation in an isolate to
  // avoid causing main thread jank.
  return compute(_utf8decode, data);
}

String _utf8decode(List<int> data) => utf8.decode(data);
