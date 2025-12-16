/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

// ignore: constant_identifier_names
const String BODY = 'BODY';

const Map<String, dynamic> _defaultStyle = {
  DISPLAY: BLOCK,
};

class BodyElement extends Element {
  BodyElement([super.context]);

  @override
  void addEventListener(String eventType, EventHandler eventHandler, {EventListenerOptions? addEventListenerOptions}) {
    // Scroll event not working on body.
    if (eventType == EVENT_SCROLL) return;

    super.addEventListener(eventType, eventHandler, addEventListenerOptions: addEventListenerOptions);
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;

  @override
  void setRenderStyle(String property, String present, { String? baseHref }) {
    final bool affectsViewportBackground = _affectsViewportBackground(property);
    if (DebugFlags.enableCssTrace) {
      cssLogger.info('[trace][body] setRenderStyle property=$property value=$present affectsViewportBackground=$affectsViewportBackground');
    }
    switch (property) {
      // The overflow of body should apply to html.
      // https://drafts.csswg.org/css-overflow-3/#overflow-propagation
      case OVERFLOW:
      case OVERFLOW_X:
      case OVERFLOW_Y:
        ownerDocument.documentElement?.setRenderStyle(property, present);
        break;
      // The background of body should apply to html.
      // https://www.w3.org/TR/css-backgrounds-3/#body-background
      case BACKGROUND_COLOR:
      case BACKGROUND_IMAGE:
        if (ownerDocument.documentElement?.renderStyle.backgroundImage == null &&
            (ownerDocument.documentElement?.renderStyle.backgroundColor == null || ownerDocument.documentElement?.renderStyle.backgroundColor?.value == CSSColor.transparent)) {
          ownerDocument.documentElement?.setRenderStyle(property, present);
        }
        super.setRenderStyle(property, present);
        break;
      default:
        super.setRenderStyle(property, present);
    }

    if (affectsViewportBackground) {
      ownerDocument.syncViewportBackground();
    }
  }
}

bool _affectsViewportBackground(String property) {
  return property == BACKGROUND || property.startsWith('background');
}
