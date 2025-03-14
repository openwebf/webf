/*
 * Copyright (C) 2024 The OpenWebF(Cayman) Company . All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/gesture.dart';
import 'package:webf/rendering.dart' hide RenderBoxContainerDefaultsMixin;
import 'package:webf/dom.dart' as dom;

class StickyBoxWrapper extends MultiChildRenderObjectWidget {
  final dom.Element ownerElement;

  StickyBoxWrapper({required List<Widget> children, required this.ownerElement}) : super(children: children);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlowLayout(renderStyle: ownerElement.renderStyle);
  }
}
