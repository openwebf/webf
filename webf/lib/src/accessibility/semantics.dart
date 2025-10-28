/*
 * Copyright (C) 2025 The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';

/// Minimal ARIA → Flutter Semantics bridge for WebF.
///
/// Goals (MVP):
/// - Map common roles/HTML elements to Semantics flags/actions.
/// - Compute basic accessible names from aria-label/aria-labelledby/fallbacks.
/// - Avoid overriding semantics provided by embedded Flutter widgets.
class WebFAccessibility {
  /// Apply semantics for a generic WebF render object based on its DOM element.
  static void applyToRenderBoxModel(RenderBoxModel renderObject, SemanticsConfiguration config) {
    final dom.Element element = renderObject.renderStyle.target;

    // Skip if this element hosts a Flutter widget subtree; let child semantics speak.
    if (element.isWidgetElement) {
      // Ensure we don't cut off child semantics.
      config.isSemanticBoundary = false;
      return;
    }

    // Set a text direction so labeled nodes satisfy Semantics assertions.
    // Use CSS resolved direction for the element.
    config.textDirection = renderObject.renderStyle.direction;

    // aria-hidden
    final String? ariaHidden = element.getAttribute('aria-hidden');
    if (ariaHidden != null && _isTruthy(ariaHidden)) {
      // Hide from accessibility tree.
      // Keep children visitable if needed by Flutter; setting hidden suffices.
      config.isHidden = true;
      return;
    }

    // Determine explicit role and implicit role by tag/attributes.
    final String? explicitRole = element.getAttribute('role')?.toLowerCase();
    final _Role role = _inferRole(element, explicitRole);

    // Compute accessible name.
    final String? name = computeAccessibleName(element);
    if (name != null && name.trim().isNotEmpty) {
      config.label = name.trim();
    }

    // Disabled/enabled
    final bool disabled = _isDisabled(element);
    if (disabled) {
      config.isEnabled = false;
    }

    // Map flags by role
    switch (role) {
      case _Role.button:
        config.isButton = true;
        if (!disabled) {
          config.onTap = () => _dispatchClick(element);
        }
        break;
      case _Role.link:
        config.isLink = true;
        if (!disabled) {
          config.onTap = () => _dispatchClick(element);
        }
        break;
      case _Role.tab:
        final String? ariaSel = element.getAttribute('aria-selected');
        if (ariaSel != null) {
          final v = ariaSel.trim().toLowerCase();
          if (v == 'true' || v == 'false') {
            config.isSelected = (v == 'true');
            config.value = config.isSelected ? 'Selected' : 'Not selected';
          }
        }
        // Tabs are actionable and mutually exclusive within a tablist.
        config.isButton = true;
        break;
      case _Role.image:
        config.isImage = true;
        break;
      case _Role.checkbox:
        final String? ariaChecked = element.getAttribute('aria-checked');
        if (ariaChecked != null) {
          final v = ariaChecked.trim().toLowerCase();
          if (v == 'mixed') {
            // Tri-state
            config.isCheckStateMixed = true;
          } else {
            config.isChecked = _isTruthy(ariaChecked);
          }
        }
        break;
      case _Role.radio:
        // Radio is a mutually-exclusive selection; map to checked state.
        final String? ariaChecked = element.getAttribute('aria-checked');
        if (ariaChecked != null) {
          config.isChecked = _isTruthy(ariaChecked);
        }
        break;
      case _Role.textbox:
        config.isTextField = true;
        break;
      case _Role.header1:
      case _Role.header2:
      case _Role.header3:
      case _Role.header4:
      case _Role.header5:
      case _Role.header6:
        config.isHeader = true;
        break;
      case _Role.none:
        // No-op; let children provide semantics.
        break;
    }

    // Basic focusability for tabbable elements
    if (_isFocusable(element)) {
      config.isFocusable = true;
    }

    // Do not create an artificial boundary by default.
    config.isSemanticBoundary = false;
  }

  /// Compute a simple accessible name for an element.
  /// Order:
  /// 1) aria-label
  /// 2) aria-labelledby (concatenate referenced texts)
  /// 3) role-based fallbacks: img.alt, input[value]/button text, anchor text
  static String? computeAccessibleName(dom.Element element) {
    // aria-label
    final String? ariaLabel = element.getAttribute('aria-label');
    if (ariaLabel != null && ariaLabel.trim().isNotEmpty) {
      return ariaLabel.trim();
    }

    // aria-labelledby: space-separated idrefs
    final String? labelledby = element.getAttribute('aria-labelledby');
    if (labelledby != null && labelledby.trim().isNotEmpty) {
      final ids = labelledby.trim().split(RegExp(r'\s+'));
      final buffer = StringBuffer();
      for (final id in ids) {
        final list = element.ownerDocument.elementsByID[id];
        if (list != null && list.isNotEmpty) {
          // Choose the first in tree order
          final dom.Element ref = list.first;
          final String text = _collectText(ref);
          if (text.isNotEmpty) {
            if (buffer.isNotEmpty) buffer.write(' ');
            buffer.write(text);
          }
        }
      }
      if (buffer.isNotEmpty) return buffer.toString();
    }

    // Role-based fallbacks
    final String tag = element.tagName.toUpperCase();
    if (tag == IMAGE) {
      final String? alt = element.getAttribute('alt');
      if (alt != null && alt.trim().isNotEmpty) return alt.trim();
    }

    if (tag == ANCHOR) {
      final String text = _collectText(element);
      if (text.isNotEmpty) return text;
    }

    if (tag == BUTTON) {
      final String text = _collectText(element);
      if (text.isNotEmpty) return text;
    }

    if (tag == INPUT) {
      // Prefer raw attribute value for input[type=button|submit] to avoid getter recursion.
      final String type = element.getAttribute('type')?.toLowerCase() ?? 'text';
      final String? v = element.attributes['value'];
      if ((type == 'button' || type == 'submit') && v != null && v.trim().isNotEmpty) {
        return v.trim();
      }
    }

    // title as final fallback
    final String? title = element.getAttribute('title');
    if (title != null && title.trim().isNotEmpty) return title.trim();

    return null;
  }

  // Infer role from explicit role, tag, and attributes.
  static _Role _inferRole(dom.Element element, String? explicitRole) {
    switch (explicitRole) {
      case 'button':
        return _Role.button;
      case 'link':
        return _Role.link;
      case 'tab':
        return _Role.tab;
      case 'img':
      case 'image':
        return _Role.image;
      case 'checkbox':
        return _Role.checkbox;
      case 'radio':
        return _Role.radio;
      case 'textbox':
      case 'searchbox':
        return _Role.textbox;
      case 'heading':
        // Use header role without level
        return _Role.header1; // treat as header
    }

    final String tag = element.tagName.toUpperCase();
    if (tag == BUTTON) return _Role.button;
    if (tag == ANCHOR) {
      final String? href = element.getAttribute('href');
      if (href != null && href.isNotEmpty) return _Role.link;
    }
    if (tag == IMAGE) return _Role.image;
    if (tag == INPUT) {
      final String type = element.getAttribute('type')?.toLowerCase() ?? 'text';
      switch (type) {
        case 'button':
        case 'submit':
        case 'reset':
          return _Role.button;
        case 'checkbox':
          return _Role.checkbox;
        case 'radio':
          return _Role.radio;
        default:
          return _Role.textbox;
      }
    }
    if (tag == H1) return _Role.header1;
    if (tag == H2) return _Role.header2;
    if (tag == H3) return _Role.header3;
    if (tag == H4) return _Role.header4;
    if (tag == H5) return _Role.header5;
    if (tag == H6) return _Role.header6;

    return _Role.none;
  }

  static bool _isDisabled(dom.Element element) {
    // HTML disabled attribute; common on form controls and buttons.
    if (element.hasAttribute('disabled')) return true;
    // aria-disabled="true"
    final String? ariaDisabled = element.getAttribute('aria-disabled');
    if (ariaDisabled != null && _isTruthy(ariaDisabled)) return true;
    return false;
  }

  static bool _isFocusable(dom.Element element) {
    if (element.hasAttribute('tabindex')) return true;
    final _Role role = _inferRole(element, element.getAttribute('role'));
    switch (role) {
      case _Role.button:
      case _Role.link:
      case _Role.checkbox:
      case _Role.radio:
      case _Role.textbox:
      case _Role.tab:
        return true;
      default:
        return false;
    }
  }

  static bool _isTruthy(String value) {
    final v = value.trim().toLowerCase();
    return v == 'true' || v == '1' || v == 'yes';
  }

  static void _dispatchClick(dom.Element element) {
    try {
      element.dispatchEvent(dom.Event(dom.EVENT_CLICK));
    } catch (e) {
      if (kDebugMode) {
        // Best-effort; avoid crashing semantics action.
        debugPrint('[webf][a11y] dispatch click failed: $e');
      }
    }
  }

  /// Collect plain text recursively from descendant text nodes.
  static String _collectText(dom.Node node) {
    final buffer = StringBuffer();
    void walk(dom.Node n) {
      if (n is dom.TextNode) {
        final data = n.data;
        if (data.isNotEmpty) buffer.write(data);
        return;
      }
      final dom.Node? first = n.firstChild;
      dom.Node? c = first;
      while (c != null) {
        walk(c);
        c = c.nextSibling;
      }
    }

    walk(node);
    return buffer.toString().trim();
  }
}

enum _Role {
  none,
  button,
  link,
  image,
  checkbox,
  radio,
  textbox,
  tab,
  header1,
  header2,
  header3,
  header4,
  header5,
  header6,
}
