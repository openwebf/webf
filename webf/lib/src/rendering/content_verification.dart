/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/rendering.dart';
import 'package:webf/dom.dart';
import 'package:webf/launcher.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';

/// A standalone content verification system for WebF that checks if actual content
/// has been rendered instead of a blank screen.
/// This can be used by applications to verify content visibility before taking
/// screenshots, running tests, or reporting custom metrics.
///
/// Example usage:
/// ```dart
/// final controller = WebFController(...);
/// // ... after page loads ...
///
/// if (ContentVerification.hasVisibleContent(controller)) {
///   print('Page has visible content');
/// } else {
///   print('Page appears to be blank');
/// }
///
/// // Get detailed information
/// final info = ContentVerification.getContentInfo(controller);
/// print('Visible elements: ${info.totalElements}');
/// print('Text elements: ${info.textElements}');
/// ```
class ContentVerification {
  /// Minimum visible area (in pixels squared) to consider content as meaningful
  static const double _minVisibleArea = 100.0; // 10x10 pixels

  /// Minimum opacity to consider content as visible
  static const double _minVisibleOpacity = 0.01;


  /// Recursively checks if a render tree contains visible content
  static bool _hasVisibleContentInTree(RenderObject renderObject) {
    // Check if this render object itself has visible content
    if (_isVisibleContent(renderObject)) {
      return true;
    }

    // Recursively check children
    bool hasVisibleChild = false;
    renderObject.visitChildren((child) {
      if (_hasVisibleContentInTree(child)) {
        hasVisibleChild = true;
      }
    });

    return hasVisibleChild;
  }

  /// Determines if a specific render object represents visible content
  static bool _isVisibleContent(RenderObject renderObject) {
    if (renderObject is RenderBox && !renderObject.hasSize) return false;

    // Check size - must have meaningful dimensions
    if (renderObject is RenderBox) {
      if (!renderObject.hasSize || renderObject.size.isEmpty) {
        return false;
      }

      final area = renderObject.size.width * renderObject.size.height;
      if (area < _minVisibleArea) {
        return false;
      }
    }

    // Check opacity - must be visible
    if (renderObject is RenderOpacity && renderObject.opacity < _minVisibleOpacity) {
      return false;
    }

    // Check text content
    if (renderObject is RenderParagraph) {
      final text = renderObject.text.toPlainText().trim();
      return text.isNotEmpty;
    }

    // Check images
    if (renderObject is RenderImage) {
      return renderObject.image != null &&
             renderObject.size.width > 0 &&
             renderObject.size.height > 0;
    }

    // Check custom painting
    if (renderObject is RenderCustomPaint) {
      return renderObject.painter != null || renderObject.foregroundPainter != null;
    }

    // Check decorated boxes
    if (renderObject is RenderDecoratedBox) {
      final decoration = renderObject.decoration;
      if (decoration is BoxDecoration) {
        // Has visible background color
        if (decoration.color != null && decoration.color!.a > 0) {
          return true;
        }
        // Has gradient
        if (decoration.gradient != null) {
          return true;
        }
        // Has background image
        if (decoration.image != null) {
          return true;
        }
        // Has visible border
        if (decoration.border != null) {
          return true;
        }
        // Has box shadow
        if (decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
          return true;
        }
      }
    }

    // Check WebF box model with decorations
    if (renderObject is RenderBoxModel) {
      final decoration = renderObject.renderStyle.decoration;
      if (decoration != null) {
        // Has background color
        if (decoration.color != null && decoration.color!.a > 0) {
          return true;
        }
        // Has gradient
        if (decoration.gradient != null) {
          return true;
        }
        // Has border
        if (decoration.border != null) {
          return true;
        }
        // Has box shadow
        if (decoration.boxShadow != null && decoration.boxShadow!.isNotEmpty) {
          return true;
        }
      }
    }

    // Check viewport with background
    if (renderObject is RenderViewportBox) {
      return renderObject.background != null && renderObject.background!.a > 0;
    }

    // For widget elements, use the ContentfulWidgetDetector
    if (renderObject is RenderWidget) {
      return ContentfulWidgetDetector.hasContentfulPaint(renderObject.firstChild);
    }

    return false;
  }

  /// Gets the total visible content area in the document
  static double getTotalVisibleContentArea(Document document) {
    final viewport = document.viewport;
    if (viewport == null) {
      return 0;
    }

    return _calculateVisibleArea(viewport);
  }

  /// Calculates the total visible area of content in a render tree
  static double _calculateVisibleArea(RenderObject renderObject) {
    double totalArea = 0;

    // Calculate area for this render object if it's visible content
    if (_isVisibleContent(renderObject) && renderObject is RenderBox && renderObject.hasSize) {
      totalArea += renderObject.size.width * renderObject.size.height;
    }

    // Add areas from children
    renderObject.visitChildren((child) {
      totalArea += _calculateVisibleArea(child);
    });

    return totalArea;
  }

  /// Verifies if a specific element has rendered visible content
  static bool elementHasVisibleContent(Element element) {
    final renderer = element.attachedRenderer;
    if (renderer == null || !renderer.hasSize) {
      return false;
    }

    return _isVisibleContent(renderer) || _hasVisibleContentInTree(renderer);
  }

  /// Convenient method to check content visibility from a WebFController
  static bool hasVisibleContent(WebFController controller) {
    return hasVisibleContentInDocument(controller.view.document);
  }

  /// Verifies if the document has any visible content rendered
  static bool hasVisibleContentInDocument(Document document) {
    final viewport = document.viewport;
    if (viewport == null) {
      return false;
    }

    return _hasVisibleContentInTree(viewport);
  }

  /// Gets detailed content information from a WebFController
  static ContentInfo getContentInfo(WebFController controller) {
    return getContentInfoFromDocument(controller.view.document);
  }

  /// Gets detailed content information from a document
  static ContentInfo getContentInfoFromDocument(Document document) {
    final info = ContentInfo._();

    info.hasVisibleContent = hasVisibleContentInDocument(document);
    info.totalVisibleArea = getTotalVisibleContentArea(document);

    // Count different types of visible content
    void countContent(RenderObject renderObject) {
      if (!_isVisibleContent(renderObject)) {
        renderObject.visitChildren(countContent);
        return;
      }

      info.totalElements++;

      if (renderObject is RenderParagraph) {
        info.textElements++;
      } else if (renderObject is RenderImage) {
        info.imageElements++;
      } else if (renderObject is RenderBoxModel || renderObject is RenderDecoratedBox) {
        info.decoratedElements++;
      } else if (renderObject is RenderWidget) {
        info.widgetElements++;
      } else if (renderObject is RenderCustomPaint) {
        info.customPaintElements++;
      }

      renderObject.visitChildren(countContent);
    }

    final viewport = document.viewport;
    if (viewport != null) {
      countContent(viewport);
    }

    return info;
  }

  /// Waits for visible content to appear with a timeout
  static Future<bool> waitForVisibleContent(
    WebFController controller, {
    Duration timeout = const Duration(seconds: 10),
    Duration checkInterval = const Duration(milliseconds: 100),
  }) async {
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < timeout) {
      if (hasVisibleContent(controller)) {
        return true;
      }
      await Future.delayed(checkInterval);
    }

    return false;
  }
}

/// Detailed information about visible content in a WebF page
class ContentInfo {
  /// Whether the page has any visible content
  bool hasVisibleContent = false;

  /// Total visible area in pixels squared
  double totalVisibleArea = 0;

  /// Total number of visible elements
  int totalElements = 0;

  /// Number of visible text elements
  int textElements = 0;

  /// Number of visible image elements
  int imageElements = 0;

  /// Number of visible decorated elements (with backgrounds, borders, etc)
  int decoratedElements = 0;

  /// Number of visible widget elements
  int widgetElements = 0;

  /// Number of custom paint elements
  int customPaintElements = 0;

  ContentInfo._();

  /// Returns true if the page appears to be blank
  bool get isBlank => !hasVisibleContent || totalElements == 0;

  /// Returns a human-readable description of the content
  String get description {
    if (isBlank) {
      return 'Page is blank (no visible content)';
    }

    final parts = <String>[];
    if (textElements > 0) parts.add('$textElements text');
    if (imageElements > 0) parts.add('$imageElements images');
    if (decoratedElements > 0) parts.add('$decoratedElements decorated elements');
    if (widgetElements > 0) parts.add('$widgetElements widgets');
    if (customPaintElements > 0) parts.add('$customPaintElements custom painted');

    return 'Page has ${parts.join(', ')}';
  }

  @override
  String toString() => 'ContentInfo($description)';
}
