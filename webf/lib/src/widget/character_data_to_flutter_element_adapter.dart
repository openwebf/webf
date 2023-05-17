/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/widgets.dart';
import 'package:webf/src/widget/character_data_to_widget_adapter.dart';

class WebFCharacterDataToFlutterElementAdapter extends RenderObjectElement {
  WebFCharacterDataToFlutterElementAdapter(WebFCharacterDataToWidgetAdaptor widget) : super(widget);

  @override
  WebFCharacterDataToWidgetAdaptor get widget => super.widget as WebFCharacterDataToWidgetAdaptor;

  @override
  void mount(Element? parent, Object? newSlot) {
    widget.webFCharacter.createRenderer();
    super.mount(parent, newSlot);
    widget.webFCharacter.ensureChildAttached();
  }

  @override
  void unmount() {
    super.unmount();
  }

  // CharacterData have no children
  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {}
  @override
  void moveRenderObjectChild(covariant RenderObject child, covariant Object? oldSlot, covariant Object? newSlot) {}

  @override
  void removeRenderObjectChild(covariant RenderObject child, covariant Object? slot) {
  }
}
