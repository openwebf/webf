/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */
import 'dart:ffi';

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';
import 'package:webf/foundation.dart';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE,
};

enum PseudoKind {
  kPseudoBefore,
  kPseudoAfter,
}

class PseudoElement extends Element {
  final PseudoKind kind;
  final Element parent;

  @override
  Pointer<NativeBindingObject>? get pointer => parent.pointer;

  PseudoElement(this.kind, this.parent, [BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}
