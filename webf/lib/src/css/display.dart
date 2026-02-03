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

enum CSSDisplay {
  inline,
  block,
  inlineBlock,

  flex,
  inlineFlex,

  // Grid containers
  grid,
  inlineGrid,

  none
}

mixin CSSDisplayMixin on RenderStyle {
  CSSDisplay? _display;

  @override
  CSSDisplay get display => _display ?? CSSDisplay.inline;
  set display(CSSDisplay? value) {
    if (_display != value) {
      _display = value;
      markNeedsLayout();
      // CSS display affects accessibility visibility (e.g., display:none)
      attachedRenderBoxModel?.markNeedsSemanticsUpdate();
    }
  }

  void initDisplay(CSSStyleDeclaration style) {
    // Must take from style because it inited before flush pending properties.
    _display ??= resolveDisplay(style[DISPLAY], renderStyle: this);
  }

  static CSSDisplay resolveDisplay(String? displayString, {RenderStyle? renderStyle}) {
    if (displayString == INHERIT) {
      final Element? parent = renderStyle?.target.parentElement;
      if (parent != null) {
        return parent.renderStyle.display;
      }
      // Root element: `inherit` behaves like `initial`.
      return resolveDisplay(cssInitialValues[DISPLAY] as String? ?? INLINE, renderStyle: renderStyle);
    }
    if (displayString == INITIAL) {
      return resolveDisplay(cssInitialValues[DISPLAY] as String? ?? INLINE, renderStyle: renderStyle);
    }

    switch (displayString) {
      case 'none':
        return CSSDisplay.none;
      case 'block':
        return CSSDisplay.block;
      case 'inline-block':
        return CSSDisplay.inlineBlock;
      case 'flex':
        return CSSDisplay.flex;
      case 'inline-flex':
        return CSSDisplay.inlineFlex;
      case 'grid':
        return CSSDisplay.grid;
      case 'inline-grid':
        return CSSDisplay.inlineGrid;
      case 'inline':
      default:
        return CSSDisplay.inline;
    }
  }

  /// Some layout effects require blockification or inlinification of the box type
  /// https://www.w3.org/TR/css-display-3/#transformations
  @override
  CSSDisplay get effectiveDisplay {
    CSSDisplay transformedDisplay = display;

    // Helper function to blockify display values
    CSSDisplay blockifyDisplay(CSSDisplay display) {
      switch (display) {
        case CSSDisplay.inline:
          return CSSDisplay.block;
        case CSSDisplay.inlineBlock:
          return CSSDisplay.block;
        case CSSDisplay.inlineFlex:
          return CSSDisplay.flex;
        case CSSDisplay.inlineGrid:
          return CSSDisplay.grid;
        // Note: inline-table would go here when supported
        default:
          // Block-level elements remain unchanged
          return display;
      }
    }

    // 1. Absolutely positioned elements are blockified
    // https://www.w3.org/TR/css-display-3/#transformations
    if (position == CSSPositionType.absolute || position == CSSPositionType.fixed) {
      return blockifyDisplay(transformedDisplay);
    }

    // 2. Floated elements are blockified
    // https://www.w3.org/TR/css-display-3/#transformations
    // TODO: Implement when float property is supported in WebF
    // if (float == CSSFloat.left || float == CSSFloat.right) {
    //   return blockifyDisplay(transformedDisplay);
    // }

    // 3. Flex items are blockified (children of flex containers)
    // https://www.w3.org/TR/css-display-3/#transformations
    // Do not rely on the Flutter render tree shape here: style/render wrappers
    // (e.g., overflow clips, event listeners, semantics) can sit between an item
    // and its container, but the CSS item relationship is defined by the DOM.
    final RenderStyle? parentRenderStyle = getAttachedRenderParentRenderStyle<RenderStyle>();
    if (parentRenderStyle != null) {
      final CSSDisplay parentDisplay = parentRenderStyle.display;
      // Check if parent is a flex container
      if (parentDisplay == CSSDisplay.flex || parentDisplay == CSSDisplay.inlineFlex) {
        transformedDisplay = blockifyDisplay(transformedDisplay);
      }

      // 4. Grid items are blockified
      if (parentDisplay == CSSDisplay.grid || parentDisplay == CSSDisplay.inlineGrid) {
        transformedDisplay = blockifyDisplay(transformedDisplay);
      }
    }

    return transformedDisplay;
  }
}
