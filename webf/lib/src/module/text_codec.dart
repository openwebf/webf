/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:webf/src/module/module_manager.dart';

class TextCodecModule extends BaseModule {
  @override
  String get name => 'TextCodec';
  TextCodecModule(ModuleManager? moduleManager) : super(moduleManager);

  static String textDecoder(List<int> bytes, String encoding, bool fatal, bool ignoreBOM) {
    try {
      Encoding codec;
      switch (encoding.toLowerCase()) {
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
          codec = utf8;
      }
      
      // Handle BOM for UTF-8
      if (!ignoreBOM && encoding.toLowerCase().startsWith('utf-8') && bytes.length >= 3) {
        if (bytes[0] == 0xEF && bytes[1] == 0xBB && bytes[2] == 0xBF) {
          bytes = bytes.sublist(3);
        }
      }
      
      return codec.decode(bytes);
    } catch (e) {
      if (fatal) {
        throw FormatException('Failed to decode text: $e');
      }
      return utf8.decode(bytes);
    }
  }

  static List<int> textEncoder(String text) {
    // TextEncoder always uses UTF-8 encoding
    return utf8.encode(text);
  }

  @override
  void dispose() {}

  @override
  Future<dynamic> invoke(String method, List<dynamic> params) {
    Completer<dynamic> completer = Completer();
    
    try {
      if (method == 'textDecoder') {
        // params: [bytes, encoding, fatal, ignoreBOM]
        List<int> bytes = List<int>.from(params[0]);
        String encoding = params[1] as String;
        bool fatal = params[2] as bool;
        bool ignoreBOM = params[3] as bool;
        
        String result = TextCodecModule.textDecoder(bytes, encoding, fatal, ignoreBOM);
        completer.complete(result);
      } else if (method == 'textEncoder') {
        // params: [text]
        String text = params[0] as String;
        
        List<int> result = TextCodecModule.textEncoder(text);
        completer.complete(result);
      } else {
        completer.completeError('Unknown method: $method');
      }
    } catch (e, stack) {
      completer.completeError(e, stack);
    }
    
    return completer.future;
  }
}