/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:webf/rendering.dart';

/// Utility class to detect if a widget or render object contains contentful painting
/// that should trigger FCP (First Contentful Paint) and LCP (Largest Contentful Paint).
class ContentfulWidgetDetector {
  /// Checks if a RenderObject tree contains any contentful painting
  static bool hasContentfulPaint(RenderObject? renderObject) {
    if (renderObject == null) return false;

    // Check if the current render object is contentful
    if (_isContentfulRenderObject(renderObject)) {
      return true;
    }

    // Recursively check children
    bool hasContentfulChild = false;
    renderObject.visitChildren((child) {
      if (hasContentfulPaint(child)) {
        hasContentfulChild = true;
      }
    });

    return hasContentfulChild;
  }

  /// Determines if a specific RenderObject represents contentful painting
  static bool _isContentfulRenderObject(RenderObject renderObject) {
    // Text content
    if (renderObject is RenderParagraph) {
      // Check if text is not empty and visible
      return renderObject.text.toPlainText().trim().isNotEmpty;
    }

    // Images
    if (renderObject is RenderImage) {
      // Check if image has been loaded and has size
      return renderObject.image != null &&
             renderObject.size.width > 0 &&
             renderObject.size.height > 0;
    }

    // Custom painting
    if (renderObject is RenderCustomPaint) {
      // Custom paint is considered contentful if it has a painter
      return renderObject.painter != null || renderObject.foregroundPainter != null;
    }

    // Decorated boxes with visible decorations
    if (renderObject is RenderDecoratedBox) {
      final decoration = renderObject.decoration;
      if (decoration is BoxDecoration) {
        // Check for gradient
        if (decoration.gradient != null) {
          return true;
        }
        // Check for background image
        if (decoration.image != null) {
          return true;
        }
      }
    }

    // ShaderMask
    if (renderObject is RenderShaderMask) {
      return true; // Shader masks create visual effects
    }

    // BackdropFilter
    if (renderObject is RenderBackdropFilter) {
      return true; // Backdrop filters create visual effects
    }

    // ClipPath with visible content
    if (renderObject is RenderClipPath ||
        renderObject is RenderClipRRect ||
        renderObject is RenderClipOval) {
      // Clips are only contentful if they have contentful children
      return false; // Let recursion handle children
    }

    return false;
  }

  /// Gets the visible area of a render object for LCP calculation
  static double getVisibleArea(RenderObject renderObject) {
    if (renderObject is RenderBox && renderObject.hasSize) {
      final size = renderObject.size;
      if (size.width > 0 && size.height > 0) {
        // TODO: Calculate actual visible area considering clipping and viewport
        return size.width * size.height;
      }
    }
    return 0;
  }

  /// Checks if a RenderObject tree contains contentful painting, but only checks
  /// render objects created by Flutter widgets (not RenderBoxModel or RenderWidget)
  static bool hasContentfulPaintFromFlutterWidget(RenderObject? renderObject) {
    if (renderObject == null) return false;

    // Import check to avoid circular dependency
    // Skip if this is a RenderBoxModel or RenderWidget (from WebF elements)
    final typeName = renderObject.runtimeType.toString();
    if (typeName.contains('RenderBoxModel') || typeName.contains('RenderWidget')) {
      return false;
    }

    // Check if the current render object is contentful
    if (_isContentfulRenderObject(renderObject)) {
      return true;
    }

    // Recursively check children
    bool hasContentfulChild = false;
    renderObject.visitChildren((child) {
      if (hasContentfulPaintFromFlutterWidget(child)) {
        hasContentfulChild = true;
      }
    });

    return hasContentfulChild;
  }

  /// Gets the largest visible area of contentful render objects created by Flutter widgets.
  /// For LCP, we need the largest single contentful element, not the sum.
  /// Returns 0 if no contentful paint is found.
  static double getContentfulPaintAreaFromFlutterWidget(RenderObject? renderObject) {
    if (renderObject == null) return 0;

    double largestArea = 0;

    // Helper function to find largest contentful area recursively
    void findLargestContentfulArea(RenderObject node) {
      // Skip if this is a RenderLayoutBox or RenderWidget (from WebF elements)
      if (node is RenderLayoutBox || node is RenderWidget) {
        return;
      }

      // If this render object is contentful, check its area
      if (_isContentfulRenderObject(node)) {
        double area = getVisibleArea(node);
        if (area > largestArea) {
          largestArea = area;
        }
      }

      // Recursively check children
      node.visitChildren((child) {
        findLargestContentfulArea(child);
      });
    }

    // Start search from the given render object
    findLargestContentfulArea(renderObject);

    return largestArea;
  }

  /// Checks if a widget is inherently contentful (not including children)
  static bool _isInherentlyContentful(Widget widget) {
    // Text widgets
    if (widget is Text || widget is RichText || widget is SelectableText) {
      return true;
    }

    // Image widgets
    if (widget is Image || widget is RawImage || widget is Icon || widget is ImageIcon || widget is FadeInImage) {
      return true;
    }

    // Custom painting widgets
    if (widget is CustomPaint) {
      return true;
    }

    // Graphics widgets
    if (widget is CircleAvatar || widget is DrawerHeader || widget is UserAccountsDrawerHeader) {
      return true;
    }

    // Decorated containers
    if (widget is DecoratedBox) {
      final decoration = widget.decoration;
      if (decoration is BoxDecoration) {
        // Check for visible background color
        if (decoration.color != null && decoration.color!.a > 0) {
          return true;
        }
        // Check for gradient
        if (decoration.gradient != null) {
          return true;
        }
        // Check for background image
        if (decoration.image != null) {
          return true;
        }
        // Check for visible border
        if (decoration.border != null) {
          return true;
        }
        // Check for box shadow
        if (decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
          return true;
        }
      }
    }

    if (widget is Container) {
      // Check container color
      if (widget.color != null && widget.color!.a > 0) {
        return true;
      }
      // Check container decoration
      if (widget.decoration != null && widget.decoration is BoxDecoration) {
        final decoration = widget.decoration as BoxDecoration;
        if ((decoration.color != null && decoration.color!.a > 0) ||
            decoration.gradient != null ||
            decoration.image != null ||
            decoration.border != null ||
            (decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty)) {
          return true;
        }
      }
    }

    if (widget is ColoredBox) {
      return widget.color.a > 0;
    }

    if (widget is PhysicalModel || widget is PhysicalShape) {
      return true;
    }

    // Progress indicators
    if (widget is CircularProgressIndicator ||
        widget is LinearProgressIndicator ||
        widget is RefreshProgressIndicator ||
        widget is CupertinoActivityIndicator) {
      return true;
    }

    // Visibility widgets
    if (widget is Opacity) {
      if (widget.opacity <= 0) {
        return false;
      }
      // Check child if partially visible
      return widget.child != null && hasContentfulChild(widget.child!);
    }

    if (widget is Visibility) {
      if (!widget.visible) {
        return false;
      }
      return hasContentfulChild(widget.child);
    }

    if (widget is Offstage) {
      if (widget.offstage) {
        return false;
      }
      return widget.child != null && hasContentfulChild(widget.child!);
    }

    // Card widget
    if (widget is Card) {
      // Card with visible color
      if (widget.color != null && widget.color!.a > 0) {
        return true;
      }
      // Check child content
      return widget.child != null && hasContentfulChild(widget.child!);
    }

    // Default text style with content
    if (widget is DefaultTextStyle) {
      return hasContentfulChild(widget.child);
    }

    // For other widgets, they are not inherently contentful
    return false;
  }

  /// Checks if a widget is considered contentful (including checking children for layout widgets)
  static bool isContentfulWidget(Widget widget) {
    // First check if the widget is inherently contentful
    if (_isInherentlyContentful(widget)) {
      return true;
    }

    // For layout widgets, check if they have contentful children
    if (widget is SingleChildRenderObjectWidget || widget is ProxyWidget ||
        widget is MultiChildRenderObjectWidget || widget is Flex) {
      return hasContentfulChild(widget);
    }

    return false;
  }

  /// Recursively checks if a widget or its descendants contain contentful painting
  static bool hasContentfulChild(Widget widget) {
    if (_isInherentlyContentful(widget)) {
      return true;
    }

    final Widget? singleChild = switch (widget) {
      Opacity(:final opacity, :final child) when opacity > 0 => child,
      Visibility(:final visible, :final child) when visible => child,
      Offstage(:final offstage, :final child) when !offstage => child,
      SingleChildRenderObjectWidget(child: final child) => child,
      ProxyWidget(child: final child) => child,
      Container(:final child) => child,
      GestureDetector(:final child) => child,
      Dismissible(:final child) => child,
      Draggable(:final child) => child,
      Hero(:final child) => child,
      AnimatedContainer(:final child) => child,
      AnimatedPadding(:final child) => child,
      AnimatedPositioned(:final child) => child,
      AnimatedOpacity(:final child) => child,
      AnimatedDefaultTextStyle(:final child) => child,
      AnimatedPhysicalModel(:final child) => child,
      AnimatedSize(:final child) => child,
      AnimatedAlign(:final child) => child,
      DecoratedBoxTransition(:final child) => child,
      SlideTransition(:final child) => child,
      ScaleTransition(:final child) => child,
      RotationTransition(:final child) => child,
      SizeTransition(:final child) => child,
      PositionedTransition(:final child) => child,
      RelativePositionedTransition(:final child) => child,
      Card(:final child) => child,
      _ => null,
    };

    if (singleChild != null) {
      return hasContentfulChild(singleChild);
    }

    final List<Widget>? children = switch (widget) {
      MultiChildRenderObjectWidget(children: final children) => children,
      _ => null,
    };

    if (children != null) {
      for (final child in children) {
        if (hasContentfulChild(child)) {
          return true;
        }
      }
    }

    if (widget is Table) {
      for (final row in widget.children) {
        for (final cell in row.children) {
          if (hasContentfulChild(cell)) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
