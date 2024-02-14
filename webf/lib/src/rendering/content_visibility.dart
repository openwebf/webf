/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

/// Lays the child out as if it was in the tree, but without painting anything,
/// without making the child available for hit testing, and without taking any
/// room in the parent.
mixin RenderContentVisibilityMixin on RenderBoxModelBase {
  bool contentVisibilityHitTest(BoxHitTestResult result, {Offset? position}) {
    ContentVisibility? _contentVisibility = renderStyle.contentVisibility;
    return _contentVisibility != ContentVisibility.hidden;
  }

  static void paintContentVisibility(WebFPaintingPipeline pipeline, Offset offset, [WebFPaintingContextCallback? callback]) {
    if (!kReleaseMode) {
      WebFProfiler.instance.startTrackPaintStep('paintContentVisibility');
    }
    ContentVisibility? _contentVisibility = pipeline.renderBoxModel.renderStyle.contentVisibility;
    if (_contentVisibility == ContentVisibility.hidden) {
      if (!kReleaseMode) {
        WebFProfiler.instance.finishTrackPaintStep();
      }
      return;
    }
    if (!kReleaseMode) {
      WebFProfiler.instance.finishTrackPaintStep();
    }
    pipeline.paintOverlay(pipeline, offset);
  }

  void debugVisibilityProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty<ContentVisibility>('contentVisibility', renderStyle.contentVisibility));
  }
}
