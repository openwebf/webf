/*
 * Copyright (C) 2025 The WebF authors. All rights reserved.
 */

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/semantics.dart';
import 'package:webf/dom.dart' as dom;
import 'package:webf/css.dart';
import 'package:webf/foundation.dart';
import 'package:webf/html.dart' as html;
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

    final bool suppressSelfLabel = _shouldSuppressAutoLabel(element, role);

    // Compute accessible name and description.
    if (!suppressSelfLabel) {
      final String? name = computeAccessibleName(element)?.trim();
      if (name != null && name.isNotEmpty) {
        config.label = name;
      }
      final String? hint = computeAccessibleDescription(element)?.trim();
      if (hint != null && hint.isNotEmpty) {
        config.hint = hint;
      }
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
      case _Role.none:
        break;
    }

    final bool focusable = _isFocusable(element);
    if (focusable) {
      config.isFocusable = true;
    }

    // Establish semantics boundaries so that standalone headings and static
    // text nodes remain discoverable even inside larger containers.
    bool boundary = false;
    bool explicitChildNodes = false;
    if (_isHeadingRole(role)) {
      boundary = true;
      // Keep heading text nodes explicit so screen readers treat them as standalone entries.
      explicitChildNodes = true;
    } else if (!focusable && role == _Role.none && (config.label != null && config.label!.isNotEmpty)) {
      boundary = true;
      explicitChildNodes = true;
    }
    config.isSemanticBoundary = boundary;
    config.explicitChildNodes = explicitChildNodes;
    config.isSemanticBoundary = boundary;
    if (kDebugMode && DebugFlags.debugLogSemanticsEnabled) {
      // Attach focus logs to every semantics node without overriding custom handlers.
      config.onDidGainAccessibilityFocus ??= () => _logSemanticsEvent(element, role, 'focus gained');
      config.onDidLoseAccessibilityFocus ??= () => _logSemanticsEvent(element, role, 'focus lost');
      config.addTagForChildren(_webfSemanticsLogTag);
    }
    if (kDebugMode && DebugFlags.debugLogSemanticsEnabled) {
      _debugDumpSemantics(element, role, config, focusable: focusable);
    }
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
    final String? explicitRole = element.getAttribute('role')?.toLowerCase();
    if (tag == html.IMAGE) {
      final String? alt = element.getAttribute('alt');
      if (alt != null && alt.trim().isNotEmpty) return alt.trim();
    }
    if (tag == html.ANCHOR) {
      final String text = _collectText(element);
      if (text.isNotEmpty) return text;
    }
    if (tag == html.BUTTON) {
      final String text = _collectText(element);
      if (text.isNotEmpty) return text;
    }
    if (tag == html.INPUT) {
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
              return text;
            }
          }
        }
        // Ancestor <label>
        final labelAncestor = element.closest(['label']);
        if (labelAncestor is dom.Element) {
          final String text = _collectText(labelAncestor);
          if (text.isNotEmpty) {
            return text;
          }
        }
      } catch (_) {}

      // Pragmatic fallback: use placeholder as accessible name when no other
      // name sources are present. Many browsers/AT announce placeholder as the
      // control's name when unlabeled.
      final String? placeholder = element.getAttribute('placeholder');
      if (placeholder != null && placeholder.trim().isNotEmpty) {
        return placeholder.trim();
      }
      // Note: the `name`/`id` attributes are not used for accessible name per spec.
    }

    // title as fallback
    final String? title = element.getAttribute('title');
    if (title != null && title.trim().isNotEmpty) return title.trim();

    if (_allowsNameFromContent(tag, explicitRole)) {
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
    if (tag == html.BUTTON) return _Role.button;
    if (tag == html.ANCHOR) {
      final String? href = element.getAttribute('href');
      if (href != null && href.isNotEmpty) return _Role.link;
    }
    if (tag == html.IMAGE) return _Role.image;
    if (tag == html.INPUT) {
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
    if (tag == html.H1) return _Role.header1;
    if (tag == html.H2) return _Role.header2;
    if (tag == html.H3) return _Role.header3;
    if (tag == html.H4) return _Role.header4;
    if (tag == html.H5) return _Role.header5;
    if (tag == html.H6) return _Role.header6;

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

  static bool _shouldSuppressAutoLabel(dom.Element element, _Role role) {
    if (role != _Role.none) return false;
    if (element.hasAttribute('aria-label') || element.hasAttribute('aria-labelledby')) return false;
    final String tag = element.tagName.toUpperCase();
    switch (tag) {
      case html.LI:
      case html.DT:
      case html.DD:
        return _hasFocusableDescendant(element);
      // Structural containers should defer to their children unless explicitly labeled.
      case html.DIV:
      case html.HEADER:
      case html.MAIN:
      case html.NAV:
      case html.SECTION:
      case html.ARTICLE:
      case html.ASIDE:
      case html.FOOTER:
        return true;
      default:
        return false;
    }
  }

  static bool _hasFocusableDescendant(dom.Element element) {
    dom.Node? child = element.firstChild;
    while (child != null) {
      if (child is dom.Element) {
        if (_isFocusable(child)) return true;
        if (_hasFocusableDescendant(child)) return true;
      }
      child = child.nextSibling;
    }
    return false;
  }

  static void _dispatchClick(dom.Element element) {
    try {
      element.dispatchEvent(dom.Event(dom.EVENT_CLICK));
    } catch (_) {}
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

  static bool _allowsNameFromContent(String tag, String? explicitRole) {
    if (_nameFromContentTags.contains(tag)) {
      return true;
    }
    if (explicitRole != null && _nameFromContentRoles.contains(explicitRole)) {
      return true;
    }
    return false;
  }
}

const Set<String> _nameFromContentTags = <String>{
  html.DIV,
  html.SPAN,
  html.PARAGRAPH,
  html.H1,
  html.H2,
  html.H3,
  html.H4,
  html.H5,
  html.H6,
  html.SECTION,
  html.ARTICLE,
  html.ASIDE,
  html.NAV,
  html.MAIN,
  html.HEADER,
  html.FOOTER,
  html.FIGCAPTION,
  html.LI,
  html.DT,
  html.DD,
  // Phrasing content that HTML AAM maps to static text semantics.
  html.STRONG,
  html.B,
  html.EM,
  html.I,
  html.MARK,
  html.SMALL,
  html.S,
  html.U,
  html.Q,
  html.CITE,
  html.CODE,
  html.DATA,
  html.KBD,
  html.DFN,
  html.TIME,
  html.VAR,
  html.ABBR,
  html.SUB,
  html.SUP,
  html.SAMP,
  html.TT,
};

const Set<String> _nameFromContentRoles = <String>{
  'heading',
  'region',
  'group',
  'article',
  'navigation',
  'main',
  'complementary',
  'contentinfo',
  'banner',
  'note',
  'figure',
  'listitem',
  'term',
  'definition',
};

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

void _debugDumpSemantics(dom.Element element, _Role role, SemanticsConfiguration config, {required bool focusable}) {
  final description = <String>[
    'role=$role',
    if (config.label != null) 'label="${config.label}"',
    'focusable=$focusable',
    'boundary=${config.isSemanticBoundary}',
    'explicitChildNodes=${config.explicitChildNodes}',
    'enabled=${config.isEnabled}',
    'hidden=${config.isHidden}',
  ].join(', ');
  // debugPrint('[webf][a11y] semantics ${_formatElement(element)} => $description');
  // debugDumpSemanticsTree(DebugSemanticsDumpOrder.traversalOrder);
}

void _logSemanticsEvent(dom.Element element, _Role role, String event) {
  debugPrint('[webf][a11y] $event ${_formatElement(element)} role=$role');
}

const SemanticsTag _webfSemanticsLogTag = SemanticsTag('webf-a11y-log-focus');

String _formatElement(dom.Element element) {
  final buffer = StringBuffer('<${element.tagName.toLowerCase()}');
  if (element.id != null && element.id!.isNotEmpty) {
    buffer.write('#${element.id}');
  }
  buffer.write('>');
  return buffer.toString();
}

bool _isHeadingRole(_Role role) {
  switch (role) {
    case _Role.header1:
    case _Role.header2:
    case _Role.header3:
    case _Role.header4:
    case _Role.header5:
    case _Role.header6:
      return true;
    default:
      return false;
  }
}

int _headingLevelForRole(_Role role) {
  switch (role) {
    case _Role.header1:
      return 1;
    case _Role.header2:
      return 2;
    case _Role.header3:
      return 3;
    case _Role.header4:
      return 4;
    case _Role.header5:
      return 5;
    case _Role.header6:
      return 6;
    default:
      return 0;
  }
}
