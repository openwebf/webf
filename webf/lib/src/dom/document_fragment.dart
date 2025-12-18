/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';

class DocumentFragment extends ContainerNode {
  DocumentFragment([context]) : super(NodeType.DOCUMENT_FRAGMENT_NODE, context);

  @override
  String get nodeName => '#documentfragment';

  // No additional methods or properties for DocumentFragment.

  @override
  RenderBox? get attachedRenderer => null;

  @override
  bool get isRendererAttached => false;

  bool get isRendererAttachedToSegmentTree => false;

  // DocumentFragment has no hash key representation.
}
