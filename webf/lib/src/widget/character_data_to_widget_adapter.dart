/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:webf/dom.dart' as dom;
import 'character_data_to_flutter_element_adapter.dart';

class WebFCharacterDataToWidgetAdaptor extends RenderObjectWidget {
  final dom.CharacterData _webFCharacterData;
  dom.CharacterData get webFCharacter => _webFCharacterData;

  WebFCharacterDataToWidgetAdaptor(this._webFCharacterData, {Key? key}) : super(key: key) {
    _webFCharacterData.flutterWidget = this;
    _webFCharacterData.managedByFlutterWidget = true;
  }

  @override
  RenderObjectElement createElement() {
    _webFCharacterData.flutterElement = WebFCharacterDataToFlutterElementAdapter(this);
    return _webFCharacterData.flutterElement as RenderObjectElement;
  }

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _webFCharacterData.renderer!;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(AttributedStringProperty('WebFNodeType', AttributedString(_webFCharacterData.nodeType.toString())));
    properties.add(AttributedStringProperty('WebFNodeName', AttributedString(_webFCharacterData.nodeName.toString())));
  }
}
