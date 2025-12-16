/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';

/// Lays the child out as if it was in the tree, but without painting anything,
/// without making the child available for hit testing, and without taking any
/// room in the parent.
mixin RenderContentVisibilityMixin on RenderBoxModelBase {
  bool contentVisibilityHitTest(BoxHitTestResult result, {Offset? position}) {
    ContentVisibility? contentVisibility = renderStyle.contentVisibility;
    return contentVisibility != ContentVisibility.hidden;
  }

  void paintContentVisibility(PaintingContext context, Offset offset, PaintingContextCallback callback) {
    ContentVisibility? contentVisibility = renderStyle.contentVisibility;
    if (contentVisibility == ContentVisibility.hidden) {
      return;
    }
    callback(context, offset);
  }
}
