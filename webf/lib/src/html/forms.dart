/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */
// ignore_for_file: constant_identifier_names

import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/src/dom/node_traversal.dart';

const String LABEL = 'LABEL';
const String BUTTON = 'BUTTON';

// UA default styling for <button>: inline-block with a visible border and padding.
// We keep values conservative and consistent with input[type=button] UA defaults.
const Map<String, dynamic> _defaultStyle = {
  DISPLAY: INLINE_BLOCK,
  BORDER: '2px solid rgb(118, 118, 118)',
  PADDING: '1px 6px',
  // Match UA default sizing for form controls (smaller than body text).
  FONT_SIZE: SMALLER,
  LINE_HEIGHT: NORMAL,
};

class LabelElement extends Element {
  LabelElement([super.context]) {
    addEventListener('click', _handleActivation);
  }

  Future<void> _handleActivation(Event event) async {
    if (event.defaultPrevented) return;

    final Element? control = _findAssociatedControl();
    if (control == null) return;

    // Avoid double activation when the control itself handled the click.
    if (event.target == control) return;

    if (_isDisabled(control)) return;

    _activateControl(control, event);
  }

  Element? _findAssociatedControl() {
    final String? forId = getAttribute('for');
    if (forId != null && forId.isNotEmpty) {
      final Element? referenced = ownerDocument.getElementById([forId]) as Element?;
      if (referenced != null && _isLabelable(referenced)) {
        return referenced;
      }
      return null;
    }

    for (final Node node in NodeTraversal.inclusiveDescendantsOf(this)) {
      if (node is Element && _isLabelable(node)) {
        return node;
      }
    }
    return null;
  }

  bool _isLabelable(Element element) {
    switch (element.tagName.toUpperCase()) {
      case 'INPUT':
        final String? type = element.getAttribute('type');
        return type == null || type.toLowerCase() != 'hidden';
      case BUTTON:
      case 'SELECT':
      case 'TEXTAREA':
        return true;
    }
    return false;
  }

  void _activateControl(Element control, Event originEvent) {
    final MouseEvent syntheticClick = _createSyntheticClick(originEvent);
    control.dispatchEvent(syntheticClick);
    if (syntheticClick.defaultPrevented) return;

    if (control.tagName.toUpperCase() == 'INPUT') {
      final String type = (control.getAttribute('type') ?? 'text').toLowerCase();
      if (type == 'checkbox' || type == 'radio') {
        final dynamic input = control;
        final bool current = input.getChecked() == true;
        final bool nextChecked = type == 'checkbox' ? !current : true;
        input.setChecked(nextChecked);
        input.dispatchEvent(InputEvent(inputType: type, data: nextChecked.toString()));
        input.dispatchEvent(Event('change'));
        _focusControl(control);
        return;
      }
    }

    _focusControl(control);
  }

  void _focusControl(Element control) {
    try {
      final dynamic target = control;
      target.state?.focus();
    } catch (_) {
      // Ignore controls without focus support.
    }
    control.ownerDocument.updateFocusTarget(control);
  }

  bool _isDisabled(Element control) {
    try {
      final dynamic target = control;
      if (target.disabled == true) return true;
    } catch (_) {
      // Fall through to attribute check.
    }
    if (control.attributes.containsKey('disabled')) return true;
    final String? ariaDisabled = control.attributes['aria-disabled'];
    return ariaDisabled != null && ariaDisabled.toLowerCase() == 'true';
  }

  MouseEvent _createSyntheticClick(Event originEvent) {
    if (originEvent is MouseEvent) {
      return MouseEvent(EVENT_CLICK,
          clientX: originEvent.clientX,
          clientY: originEvent.clientY,
          offsetX: originEvent.offsetX,
          offsetY: originEvent.offsetY,
          detail: originEvent.detail,
          which: originEvent.which,
          view: originEvent.view ?? ownerDocument.defaultView);
    }
    return MouseEvent(EVENT_CLICK, view: ownerDocument.defaultView);
  }
}

class ButtonElement extends Element {
  ButtonElement([super.context]);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}
