/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';

class WebFWidgetElementChild extends SingleChildRenderObjectWidget {
  WebFWidgetElementChild({Widget? child, Key? key}): super(child: child, key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderWidgetElementChild();
  }
}

class RenderWidgetElementChild extends RenderProxyBox {}
