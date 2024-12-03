/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/dom.dart';
import 'package:webf/src/foundation/binding.dart';

const String DOCUMENT_FRAGMENT = 'DOCUMENTFRAGMENT';

class DocumentFragment extends ContainerNode {
  DocumentFragment([context]) : super(NodeType.COMMENT_NODE, context);

  @override
  String get nodeName => '#documentfragment';

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
  }

  @override
  RenderBox? get domRenderer => null;

  @override
  bool get isRendererAttached => false;

  @override
  bool get isRendererAttachedToSegmentTree => false;
}
