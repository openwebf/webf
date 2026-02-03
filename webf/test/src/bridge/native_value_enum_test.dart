import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webf/bridge.dart';

import '../../setup.dart';

enum _BridgeEnum {
  horizontal('horizontal'),
  vertical('vertical');

  final String value;
  const _BridgeEnum(this.value);

  @override
  String toString() => value;
}

enum _PlainEnum { foo, bar }

void main() {
  setUpAll(() {
    setupTest();
  });

  test('toNativeValue encodes Enum as JS string', () {
    final Pointer<NativeValue> out = malloc.allocate(sizeOf<NativeValue>());
    try {
      toNativeValue(out, _BridgeEnum.horizontal);
      expect(JSValueType.values[out.ref.tag], JSValueType.tagString);

      final nativeString = Pointer<NativeString>.fromAddress(out.ref.u);
      expect(nativeStringToString(nativeString), 'horizontal');
      freeNativeString(nativeString);
    } finally {
      malloc.free(out);
    }
  });

  test('toNativeValue encodes default Enum as JS string name', () {
    final Pointer<NativeValue> out = malloc.allocate(sizeOf<NativeValue>());
    try {
      toNativeValue(out, _PlainEnum.foo);
      expect(JSValueType.values[out.ref.tag], JSValueType.tagString);

      final nativeString = Pointer<NativeString>.fromAddress(out.ref.u);
      expect(nativeStringToString(nativeString), 'foo');
      freeNativeString(nativeString);
    } finally {
      malloc.free(out);
    }
  });

  test('toNativeValue encodes nested Enum values inside JSON', () {
    final Pointer<NativeValue> out = malloc.allocate(sizeOf<NativeValue>());
    try {
      toNativeValue(out, {'dir': _BridgeEnum.vertical, 'plain': _PlainEnum.bar});
      expect(JSValueType.values[out.ref.tag], JSValueType.tagJson);

      final Pointer<Utf8> jsonPtr = Pointer<Utf8>.fromAddress(out.ref.u);
      final String jsonStr = jsonPtr.toDartString();
      expect(jsonDecode(jsonStr), {'dir': 'vertical', 'plain': 'bar'});
      malloc.free(jsonPtr);
    } finally {
      malloc.free(out);
    }
  });
}
