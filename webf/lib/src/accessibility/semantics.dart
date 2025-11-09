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
/// - Maps common roles/HTML elements to Semantics flags/actions.
/// - Computes accessible names from aria-label/aria-labelledby/fallbacks.
/// - Avoids overriding semantics provided by embedded Flutter widgets.
class WebFAccessibility {
  /// Apply semantics for a generic WebF render object based on its DOM element.
  static void applyToRenderBoxModel(RenderBoxModel renderObject, SemanticsConfiguration config) {
    final dom.Element element = renderObject.renderStyle.target;
    final CSSRenderStyle rs = renderObject.renderStyle as CSSRenderStyle;

    // Skip if this element hosts a Flutter widget subtree; let child semantics speak.
    if (element.isWidgetElement) {
      config.isSemanticBoundary = false;
      return;
    }

    // Set a text direction so labeled nodes satisfy Semantics assertions.
    config.textDirection = renderObject.renderStyle.direction;

    // CSS-driven visibility → hide from a11y tree
    // - display:none
    // - visibility:hidden
    // - content-visibility:hidden
    if (rs.display == CSSDisplay.none ||
        rs.visibility == Visibility.hidden ||
        rs.contentVisibility == ContentVisibility.hidden) {
      config.isHidden = true;
      return;
    }

    // aria-hidden → hide node from a11y tree
    final String? ariaHidden = element.getAttribute('aria-hidden');
    if (ariaHidden != null && _isTruthy(ariaHidden)) {
      config.isHidden = true;
      return;
    }

    // Determine explicit role and implicit role by tag/attributes.
    final String? explicitRole = element.getAttribute('role')?.toLowerCase();
    final _Role role = _inferRole(element, explicitRole);

    // Compute accessible name and description.
    final String? name = computeAccessibleName(element);
    final String? hint = computeAccessibleDescription(element);
    if (name != null && name.trim().isNotEmpty) {
      config.label = name.trim();
    }
    final String? ariaDescribedBy = element.getAttribute('aria-describedby');
    if (ariaDescribedBy != null && ariaDescribedBy.trim().isNotEmpty) {
      final String? hint = computeAccessibleDescription(element);
      if (hint != null && hint.trim().isNotEmpty) {
        config.hint = hint.trim();
      }
    }
    if (hint != null && hint.trim().isNotEmpty) {
      config.hint = hint.trim();
    }

    // Disabled/enabled
    final bool disabled = _isDisabled(element);
    if (disabled) {
      config.isEnabled = false;
    }

    // Map flags/actions by role
    switch (role) {
      case _Role.button:
        config.isButton = true;
        if (!disabled) config.onTap = () => _dispatchClick(element);
        final String? ariaPressed = element.getAttribute('aria-pressed');
        if (ariaPressed != null) {
          final String v = ariaPressed.trim().toLowerCase();
          bool? toggled;
          switch (v) {
            case 'mixed':
              toggled = true;
              config.isCheckStateMixed = true;
              config.value = 'Mixed';
              break;
            case 'true':
            case '1':
            case 'yes':
              toggled = true;
              config.value = 'Pressed';
              break;
            case 'false':
            case '0':
            case 'no':
              toggled = false;
              config.value = 'Not pressed';
              break;
            default:
              toggled = _isTruthy(ariaPressed);
              config.value = toggled ? 'Pressed' : 'Not pressed';
          }
          if (toggled != null) {
            config.isToggled = toggled;
          }
        }
        break;
      case _Role.link:
        config.isLink = true;
        if (!disabled) config.onTap = () => _dispatchClick(element);
        // aria-current indicates the current item within a set (e.g., nav)
        final String? ariaCurrent = element.getAttribute('aria-current');
        if (ariaCurrent != null && ariaCurrent.trim().toLowerCase() != 'false') {
          final String v = ariaCurrent.trim().toLowerCase();
          config.value = (v == 'page') ? 'Current page' : 'Current';
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
            config.isCheckStateMixed = true;
          } else {
            config.isChecked = _isTruthy(ariaChecked);
          }
        }
        break;
      case _Role.radio:
        final String? ariaChecked = element.getAttribute('aria-checked');
        if (ariaChecked != null) config.isChecked = _isTruthy(ariaChecked);
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
        break;
    }

    final bool focusable = _isFocusable(element);
    if (focusable) {
      config.isFocusable = true;
    }

    // Expose standalone static text nodes (like DIVs with text) as separate
    // semantics nodes so they are read in traversal even when adjacent to
    // interactive controls. This mirrors how browsers expose text nodes.
    // Only do this for non-interactive roles with a computed name.
    bool boundary = false;
    if (!focusable && role == _Role.none && (config.label != null && config.label!.isNotEmpty)) {
      boundary = true;
    }
    config.isSemanticBoundary = boundary;
  }

  /// Compute accessible name for an element.
  /// Order:
  /// 1) aria-label
  /// 2) aria-labelledby (concatenate referenced elements' names)
  /// 3) role-based fallbacks: img.alt, input[value]/button text, anchor text
  /// 4) title
  /// 5) generic text content (e.g., DIV textContent)
  static String? computeAccessibleName(dom.Element element) {
    return _computeAccessibleNameInternal(element, <dom.Element>{});
  }

  static String? _computeAccessibleNameInternal(dom.Element element, Set<dom.Element> visited) {
    if (visited.contains(element)) return null;
    visited.add(element);

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
          final dom.Element ref = list.first;
          final String? refName = _computeAccessibleNameInternal(ref, visited) ?? _collectText(ref);
          if (refName != null && refName.isNotEmpty) {
            if (buffer.isNotEmpty) buffer.write(' ');
            buffer.write(refName);
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
      final String type = element.getAttribute('type')?.toLowerCase() ?? 'text';
      final String? v = element.attributes['value'];
      if ((type == 'button' || type == 'submit') && v != null && v.trim().isNotEmpty) {
        return v.trim();
      }

      // HTML label association (host-language labeling per accname spec):
      // 1) <label for="id"> ... </label>
      // 2) <label> ... <input> ... </label> (ancestor label)
      try {
        final String? id = element.id;
        if (id != null && id.isNotEmpty) {
          final labels = element.ownerDocument.querySelectorAll(['label[for="' + id + '"]']);
          if (labels is List && labels.isNotEmpty) {
            final dom.Element labelEl = labels.first as dom.Element;
            final String text = _collectText(labelEl);
            if (text.isNotEmpty) {
              if (kDebugMode) {
                debugPrint('[webf][a11y] name via <label for> on <input#${id}>: "$text"');
              }
              return text;
            }
          }
        }
        // Ancestor <label>
        final labelAncestor = element.closest(['label']);
        if (labelAncestor is dom.Element) {
          final String text = _collectText(labelAncestor);
          if (text.isNotEmpty) {
            if (kDebugMode) {
              debugPrint('[webf][a11y] name via ancestor <label> on <input#${element.id}>: "$text"');
            }
            return text;
          }
        }
      } catch (_) {}

      // Pragmatic fallback: use placeholder as accessible name when no other
      // name sources are present. Many browsers/AT announce placeholder as the
      // control's name when unlabeled.
      final String? placeholder = element.getAttribute('placeholder');
      if (placeholder != null && placeholder.trim().isNotEmpty) {
        if (kDebugMode) {
          try {
            debugPrint('[webf][a11y] fallback name via placeholder on <input#${element.id}>: "${placeholder.trim()}"');
          } catch (_) {}
        }
        return placeholder.trim();
      }
      // Note: the `name`/`id` attributes are not used for accessible name per spec.
    }

    // title as fallback
    final String? title = element.getAttribute('title');
    if (title != null && title.trim().isNotEmpty) return title.trim();

    // generic text content (e.g., DIV textContent)
    if (tag == DIV) {
      final String text = _collectText(element);
      if (text.isNotEmpty) return text;
    }
    return null;
  }

  /// Compute accessible description from aria-describedby (space-separated idrefs).
  static String? computeAccessibleDescription(dom.Element element) {
    final String? describedby = element.getAttribute('aria-describedby');
    if (describedby == null || describedby.trim().isEmpty) return null;
    final ids = describedby.trim().split(RegExp(r'\s+'));
    final buffer = StringBuffer();
    for (final id in ids) {
      final list = element.ownerDocument.elementsByID[id];
      if (list != null && list.isNotEmpty) {
        final dom.Element ref = list.first;
        final String text = _collectText(ref);
        if (text.isNotEmpty) {
          if (buffer.isNotEmpty) buffer.write(' ');
          buffer.write(text);
        }
      }
    }
    return buffer.isNotEmpty ? buffer.toString() : null;
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
        return _Role.header1;
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
    if (element.hasAttribute('disabled')) return true;
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
