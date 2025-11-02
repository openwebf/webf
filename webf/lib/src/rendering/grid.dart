/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'package:webf/css.dart';

/// Temporary Grid render object scaffold.
///
/// For the initial step, RenderGridLayout subclasses RenderFlowLayout so that
/// display:grid containers behave like block/flow containers while we land the
/// full CSS Grid algorithm incrementally. This ensures display:grid does not
/// throw and can participate in layout/painting with predictable behavior.
class RenderGridLayout extends RenderFlowLayout {
  RenderGridLayout({
    List<RenderBox>? children,
    required CSSRenderStyle renderStyle,
  }) : super(children: children, renderStyle: renderStyle);
}

