/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2023-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/bridge.dart';

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

  PseudoElement(this.kind, this.parent, [BindingContext? context]) : super(context) {
    tagName = 'Pseudo';
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}
