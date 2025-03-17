/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ui' as ui show Image;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class WebFRenderImage extends RenderImage {
  WebFRenderImage({
    ui.Image? image,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
  }) : super(
          image: image,
          fit: fit,
          alignment: alignment,
        );

  @override
  void performLayout() {
    super.performLayout();
    Size trySize = constraints.biggest;
    size = trySize.isInfinite ? size : trySize;
  }
}

class WebFRawImage extends RawImage {
  const WebFRawImage({
    super.key,
    super.image,
    super.debugImageLabel,
    super.width,
    super.height,
    super.scale = 1.0,
    super.color,
    super.opacity,
    super.colorBlendMode,
    super.fit,
    super.alignment
  });

  @override
  RenderImage createRenderObject(BuildContext context) {
    return WebFRenderImage(image: image?.clone(), fit: fit);
  }
}
