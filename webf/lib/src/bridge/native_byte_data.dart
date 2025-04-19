/*
* Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
* Licensed under GNU AGPL with Enterprise exception.
*/

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

// Private class that maps to the C++ struct memory layout
class _NativeByteDataStruct extends Struct {
  /// Pointer to the byte array
  external Pointer<Uint8> bytes;

  /// Length of the byte array
  @Int32()
  external int length;

  /// Pointer to the free function
  external Pointer<NativeFunction<Void Function(Pointer<Void>)>> free_native_byte_data_;

  /// Optional context pointer for the free function
  external Pointer<Void> ptr;
}

/// NativeByteData is a Dart representation of the C++ NativeByteData class.
/// It wraps a Uint8List (byte array) for efficient binary data transfer between Dart and C++.
class NativeByteData implements Finalizable {
  // Pointer to the native struct
  final Pointer<_NativeByteDataStruct> _pointer;

  // Finalizer to clean up native resources when this object is garbage collected
  static final _finalizer = Finalizer(_finalize);

  // Cached Uint8List to avoid repeated conversion
  Uint8List? _cachedBytes;

  /// Constructor that takes a pointer to an existing NativeByteData from C++
  NativeByteData(this._pointer) {
    // Register with finalizer to clean up when garbage collected
    _finalizer.attach(this, _pointer.cast());
  }

  /// Get the bytes as a Uint8List
  Uint8List get bytes {
    if (_cachedBytes != null) return _cachedBytes!;

    final bytesPtr = _pointer.ref.bytes;
    final length = _pointer.ref.length;

    if (bytesPtr == nullptr || length <= 0) {
      _cachedBytes = Uint8List(0);
    } else {
      _cachedBytes = bytesPtr.asTypedList(length);
    }

    return _cachedBytes!;
  }

  /// Get the length of the byte array
  int get length => _pointer.ref.length;

  /// Get the pointer to the underlying struct
  Pointer<_NativeByteDataStruct> get pointer => _pointer;

  /// Native finalizer callback
  static void _finalize(Pointer<Void> pointer) {
    final nativeData = pointer.cast<_NativeByteDataStruct>();

    // Call the free function if provided
    if (nativeData.ref.free_native_byte_data_ != nullptr && nativeData.ref.ptr != nullptr) {
      final freeFunction = nativeData.ref.free_native_byte_data_
          .asFunction<void Function(Pointer<Void>)>();
      freeFunction(nativeData.ref.ptr);
    }

    // Free the bytes if allocated by Dart
    if (nativeData.ref.bytes != nullptr &&
        nativeData.ref.free_native_byte_data_ == nullptr) {
      malloc.free(nativeData.ref.bytes);
    }

    // Free the struct itself
    malloc.free(nativeData);
  }
}
