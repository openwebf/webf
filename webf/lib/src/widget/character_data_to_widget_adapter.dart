/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'character_data_to_flutter_element_adapter.dart';

class WebFCharacterDataToWidgetAdaptor extends RenderObjectWidget {
  final dom.CharacterData webFCharacterData;
  dom.CharacterData get webFCharacter => webFCharacterData;

  WebFCharacterDataToWidgetAdaptor(this.webFCharacterData, {Key? key}) : super(key: key) {
    webFCharacterData.flutterWidget = this;
    webFCharacterData.managedByFlutterWidget = true;
  }

  @override
  RenderObjectElement createElement() {
    return WebFCharacterDataToFlutterElementAdapter(this);
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return webFCharacterData.renderer!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(webFCharacterData.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(webFCharacterData.nodeName.toString())));
  }
}
