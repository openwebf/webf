/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class WebFRenderImage extends RenderImage {
  WebFRenderImage({
    super.image,
    super.fit,
    super.alignment,
  });

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
    return WebFRenderImage(image: image?.clone(), fit: fit, alignment: alignment);
  }
}
