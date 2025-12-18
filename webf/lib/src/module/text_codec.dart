/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:convert';

import 'package:webf/src/module/module_manager.dart';

class TextCodecModule extends WebFBaseModule {
  @override
  String get name => 'TextCodec';
  TextCodecModule(super.moduleManager);

  static String textDecoder(List<int> bytes, String encoding, bool fatal, bool ignoreBOM) {
    String lower = encoding.toLowerCase();
    Encoding? codec;
    switch (lower) {
      case 'utf-8':
      case 'utf8':
        codec = utf8;
        break;
      case 'ascii':
      case 'us-ascii':
        codec = ascii;
        break;
      case 'latin1':
      case 'iso-8859-1':
        codec = latin1;
        break;
      default:
        if (fatal) {
          throw RangeError('The encoding "$encoding" is not supported.');
        }
        // Fallback to utf-8 when not fatal.
        codec = utf8;
    }

    // Handle BOM for UTF-8 (remove leading EF BB BF when ignoreBOM is false)
    if (!ignoreBOM && (lower == 'utf-8' || lower == 'utf8') && bytes.length >= 3) {
      if (bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
        bytes = bytes.sublist(3);
      }
    }

    try {
      if ((lower == 'utf-8' || lower == 'utf8') && !fatal) {
        // Use lenient UTF-8 decoder to replace malformed sequences with U+FFFD.
        return const Utf8Decoder(allowMalformed: true).convert(bytes);
      }
      // For ascii/latin1 or fatal utf-8 decoding rely on strict decoder.
      return codec.decode(bytes);
    } catch (e) {
      if (fatal) {
        throw FormatException('Failed to decode text: $e');
      }
      // As a final safety net, perform a manual lenient UTF-8 decode.
      return _lenientUtf8(bytes);
    }
  }

  // Fallback lenient UTF-8 decoding that substitutes invalid sequences with U+FFFD.
  static String _lenientUtf8(List<int> bytes) {
    // Simple state machine; for brevity and safety only covers replacing invalid sequences.
    StringBuffer sb = StringBuffer();
    int i = 0;
    while (i < bytes.length) {
      int b = bytes[i];
      if (b < 0x80) {
        sb.writeCharCode(b);
        i++;
      } else if ((b & 0xE0) == 0xC0) {
        if (i + 1 < bytes.length) {
          int b2 = bytes[i + 1];
          if ((b2 & 0xC0) == 0x80) {
            int codePoint = ((b & 0x1F) << 6) | (b2 & 0x3F);
            if (codePoint >= 0x80) {
              sb.writeCharCode(codePoint);
              i += 2;
              continue;
            }
          }
        }
        sb.writeCharCode(0xFFFD);
        i++;
      } else if ((b & 0xF0) == 0xE0) {
        if (i + 2 < bytes.length) {
          int b2 = bytes[i + 1];
          int b3 = bytes[i + 2];
          if ((b2 & 0xC0) == 0x80 && (b3 & 0xC0) == 0x80) {
            int codePoint = ((b & 0x0F) << 12) | ((b2 & 0x3F) << 6) | (b3 & 0x3F);
            if (codePoint >= 0x800 && !(codePoint >= 0xD800 && codePoint <= 0xDFFF)) {
              sb.writeCharCode(codePoint);
              i += 3;
              continue;
            }
          }
        }
        sb.writeCharCode(0xFFFD);
        i++;
      } else if ((b & 0xF8) == 0xF0) {
        if (i + 3 < bytes.length) {
          int b2 = bytes[i + 1];
          int b3 = bytes[i + 2];
          int b4 = bytes[i + 3];
          if ((b2 & 0xC0) == 0x80 && (b3 & 0xC0) == 0x80 && (b4 & 0xC0) == 0x80) {
            int codePoint = ((b & 0x07) << 18) | ((b2 & 0x3F) << 12) | ((b3 & 0x3F) << 6) | (b4 & 0x3F);
            if (codePoint >= 0x10000 && codePoint <= 0x10FFFF) {
              int high = 0xD800 + ((codePoint - 0x10000) >> 10);
              int low = 0xDC00 + ((codePoint - 0x10000) & 0x3FF);
              sb.writeCharCode(high);
              sb.writeCharCode(low);
              i += 4;
              continue;
            }
          }
        }
        sb.writeCharCode(0xFFFD);
        i++;
      } else {
        sb.writeCharCode(0xFFFD);
        i++;
      }
    }
    return sb.toString();
  }

  static List<int> textEncoder(String text) {
    // TextEncoder always uses UTF-8 encoding
    return utf8.encode(text);
  }

  @override
  void dispose() {}

  @override
  dynamic invoke(String method, List<dynamic> params) {
    try {
      if (method == 'textDecoder') {
        // params: [bytes, encoding, fatal, ignoreBOM]
        List<int> bytes = List<int>.from(params[0]);
        String encoding = params[1] as String;
        bool fatal = params[2] as bool;
        bool ignoreBOM = params[3] as bool;
        return TextCodecModule.textDecoder(bytes, encoding, fatal, ignoreBOM);
      } else if (method == 'textEncoder') {
        // params: [text]; tolerant to non-string inputs.
        var raw = params.isNotEmpty ? params[0] : '';
        String text;
        if (raw is String) {
          text = raw;
        } else if (raw == null) {
          text = 'null';
        } else {
          text = raw.toString();
        }
        return TextCodecModule.textEncoder(text);
      } else {
        throw Exception('Unknown method: $method');
      }
    } catch (e) {
      rethrow;
    }
  }
}
