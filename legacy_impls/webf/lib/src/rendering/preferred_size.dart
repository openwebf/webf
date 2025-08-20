/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

/// [RenderPreferredSize] Render a box with preferred size,
/// if no child provided, size is exactly what preferred size
/// is, but it also obey parent constraints.
class RenderPreferredSize extends RenderProxyBox {
  RenderPreferredSize({
    required Size preferredSize,
    RenderBox? child,
  })  : _preferredSize = preferredSize,
        super(child);

  Size _preferredSize;

  Size get preferredSize => _preferredSize;

  set preferredSize(Size value) {
    if (_preferredSize == value) return;

    _preferredSize = value;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      markNeedsLayout();
    });
  }

  @override
  void performResize() {
    size = constraints.constrain(preferredSize);
    markNeedsSemanticsUpdate();
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Size>('preferredSize', _preferredSize, missingIfNull: true));
  }
}
