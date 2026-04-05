/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'package:flutter/material.dart';
import 'package:webf/widget.dart';
import 'package:webf/html.dart';
import 'package:webf/bridge.dart';
import 'package:webf/dom.dart';
import 'package:webf/css.dart';
import 'dart:math' as math;

import 'base_input.dart';

// ignore: constant_identifier_names
const TEXTAREA = 'TEXTAREA';

const Map<String, dynamic> _textAreaDefaultStyle = {
  BORDER: '1px solid rgb(118, 118, 118)',
  DISPLAY: INLINE_BLOCK,
};

class FlutterTextAreaElement extends WidgetElement with BaseInputElement {
  FlutterTextAreaElement(super.context);

  @override
  Map<String, dynamic> get defaultStyle => _textAreaDefaultStyle;

  bool _dirtyDefaultValue = false;
  String _defaultValue = '';

  @override
  void initializeDynamicProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeDynamicProperties(properties);
    // Ensure `textarea.value` property maps to element value storage.
    properties['value'] = BindingObjectProperty(getter: () => value, setter: (v) => value = v);
    // Optionally expose defaultValue for symmetry; this mirrors BaseInputElement behavior.
    properties['defaultValue'] = BindingObjectProperty(getter: () => defaultValue, setter: (v) => defaultValue = v);
  }

  @override
  void initializeDynamicMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeDynamicMethods(methods);
    methods['blur'] = BindingObjectMethodSync(call: (List args) {
      state?.blur();
      ownerDocument.clearFocusTarget(this);
    });
    methods['focus'] = BindingObjectMethodSync(call: (List args) {
      if (state != null) {
        state?.focus();
      } else {
        (this as BaseInputElement).markPendingFocus();
      }
      ownerDocument.updateFocusTarget(this);
    });
  }

  // The concatenation of the data of all the Text node descendants of node.
  // https://dom.spec.whatwg.org/#concept-descendant-text-content
  String get textContent {
    String str = '';
    // Set data of all text node children as value of textarea.
    for (Node child in childNodes) {
      if (child is TextNode) {
        str += child.data;
      }
    }
    return str;
  }

  @override
  void childrenChanged(ChildrenChange change) {
    super.childrenChanged(change);
    // Sync live value from text content when not dirty.
    if (!isValueDirty) {
      setElementValue(textContent, markDirty: false);
    }
  }

  // For textarea, defaultValue reflects its text content.
  @override
  String? get defaultValue => _dirtyDefaultValue ? _defaultValue : textContent;

  @override
  set defaultValue(String? text) {
    final String v = text?.toString() ?? '';
    _defaultValue = v;
    _dirtyDefaultValue = true;
    // Find all text nodes and prefer updating the first one (original node passed in creation),
    // then remove other text siblings to keep a single text node, preserving external references.
    List<TextNode> textNodes = [];
    Node? cursor = firstChild;
    while (cursor != null) {
      if (cursor is TextNode) textNodes.add(cursor);
      cursor = cursor.nextSibling;
    }

    if (textNodes.isNotEmpty) {
      TextNode keep = textNodes.first;
      keep.data = v;
      for (final tn in textNodes) {
        if (!identical(tn, keep)) {
          removeChild(tn);
        }
      }
    } else {
      // No existing text nodes; create one.
      appendChild(TextNode(v));
    }
    // If value isn't dirty, sync live value as well without marking dirty.
    if (!isValueDirty) {
      setElementValue(v, markDirty: false);
    }
  }

  // When value hasn't been changed programmatically (not dirty), reflect text content.
  @override
  get value => isValueDirty ? elementValue : textContent;

  @override
  WebFWidgetElementState createState() {
    return FlutterTextAreaElementState(this);
  }
}

class FlutterTextAreaElementState extends FlutterInputElementState {
  FlutterTextAreaElementState(super.widgetElement);

  static const double _kGripVisualFontScale = 0.55;
  static const double _kGripHitScale = 2.0;
  static const double _kGripMinVisualSize = 7;
  static const double _kGripMaxVisualSize = 10;
  static const double _kGripStrokeScale = 0.12;
  static const int _kGripLineCount = 2;

  Size? _resizeStartSize;
  Size? _resizeMinimumSize;
  double? _dragWidth;
  double? _dragHeight;
  double? _committedWidth;
  double? _committedHeight;

  String get _resizeMode {
    final String specified = widgetElement.style
        .getPropertyValue('resize')
        .trim()
        .toLowerCase();
    return specified.isEmpty ? 'both' : specified;
  }

  bool get _allowHorizontalResize =>
      _resizeMode == 'both' || _resizeMode == 'horizontal';

  bool get _allowVerticalResize =>
      _resizeMode == 'both' || _resizeMode == 'vertical';

  bool get _showResizeHandle =>
      !widgetElement.disabled &&
      !widgetElement.readonly &&
      (_allowHorizontalResize || _allowVerticalResize) &&
      _resizeMode != 'none';

  double? get _effectiveWidth => _dragWidth ?? _committedWidth;

  double? get _effectiveHeight => _dragHeight ?? _committedHeight;

  double get _lineExtent {
    return widgetElement.lineHeight > 0
        ? widgetElement.lineHeight
        : math.max(widgetElement.fontSize * 1.2, 1.0);
  }

  int get _preferredRows {
    final String? rowsAttr = widgetElement.getAttribute('rows');
    if (rowsAttr == null) return 3;
    final int? parsed = int.tryParse(rowsAttr);
    return parsed != null && parsed > 0 ? parsed : 3;
  }

  double _clampDouble(double value, double lower, double upper) {
    return value.clamp(lower, upper).toDouble();
  }

  _TextareaResizeGripGeometry get _gripGeometry {
    final double visualSize = _clampDouble(
      math.max(widgetElement.fontSize, _lineExtent) * _kGripVisualFontScale,
      _kGripMinVisualSize,
      _kGripMaxVisualSize,
    );
    return _TextareaResizeGripGeometry(
      visualSize: visualSize,
      hitSize: visualSize * _kGripHitScale,
      strokeWidth: math.max(1.0, visualSize * _kGripStrokeScale),
      lineCount: _kGripLineCount,
    );
  }

  Size _resolveMinimumResizeSize(_TextareaResizeGripGeometry gripGeometry) {
    final RenderStyle renderStyle = widgetElement.renderStyle;
    final double cssMinWidth = renderStyle.minWidth.isNotAuto ? renderStyle.minWidth.computedValue : 0;
    final double cssMinHeight = renderStyle.minHeight.isNotAuto ? renderStyle.minHeight.computedValue : 0;
    final double paddingWidth = renderStyle.padding.horizontal + renderStyle.border.horizontal;
    final double paddingHeight = renderStyle.padding.vertical + renderStyle.border.vertical;
    final double textWidthFloor = math.max(widgetElement.fontSize * 3, _lineExtent * 2);
    final double textHeightFloor = _lineExtent;

    return Size(
      math.max(cssMinWidth, paddingWidth + textWidthFloor + gripGeometry.hitSize),
      math.max(cssMinHeight, paddingHeight + textHeightFloor + gripGeometry.hitSize * 0.5),
    );
  }

  void _applyResizeStyles({double? width, double? height}) {
    if (_allowHorizontalResize && width != null) {
      widgetElement.style.setProperty(WIDTH, '${width.round()}px');
    }
    if (_allowVerticalResize && height != null) {
      widgetElement.style.setProperty(HEIGHT, '${height.round()}px');
    }
    widgetElement.ownerDocument.updateStyleIfNeeded();
    widgetElement.renderStyle.markNeedsLayout();
  }

  int _rowsForHeight(double height) {
    return math.max(1, (height / _lineExtent).floor());
  }

  void _handleResizeStart(DragStartDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    _resizeStartSize = box.size;
    _dragWidth = box.size.width;
    _dragHeight = box.size.height;
    _resizeMinimumSize = _resolveMinimumResizeSize(_gripGeometry);
  }

  void _handleResizeUpdate(DragUpdateDetails details) {
    final Size? resizeStartSize = _resizeStartSize;
    if (resizeStartSize == null) return;
    final Size minimumSize = _resizeMinimumSize ?? _resolveMinimumResizeSize(_gripGeometry);
    final double nextWidth = _allowHorizontalResize
        ? math.max(
            minimumSize.width,
            (_dragWidth ?? resizeStartSize.width) + details.delta.dx,
          )
        : (_dragWidth ?? resizeStartSize.width);
    final double nextHeight = _allowVerticalResize
        ? math.max(
            minimumSize.height,
            (_dragHeight ?? resizeStartSize.height) + details.delta.dy,
          )
        : (_dragHeight ?? resizeStartSize.height);

    setState(() {
      if (_allowHorizontalResize) {
        _dragWidth = nextWidth;
      }
      if (_allowVerticalResize) {
        _dragHeight = nextHeight;
      }
    });
    _applyResizeStyles(width: nextWidth, height: nextHeight);
  }

  void _commitResize() {
    final double? width = _dragWidth;
    final double? height = _dragHeight;

    if (width == null && height == null) return;

    if (_allowHorizontalResize && width != null) {
      _committedWidth = width;
    }
    if (_allowVerticalResize && height != null) {
      _committedHeight = height;
    }

    _dragWidth = null;
    _dragHeight = null;
    _resizeStartSize = null;
    _resizeMinimumSize = null;
    _applyResizeStyles(width: width, height: height);
  }

  void _cancelResize() {
    setState(() {
      _dragWidth = null;
      _dragHeight = null;
      _resizeStartSize = null;
      _resizeMinimumSize = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isAutoHeight = widgetElement.renderStyle.height.isAuto;
    final double? resizedHeight = _effectiveHeight;
    final double? resizedWidth = _effectiveWidth;
    final _TextareaResizeGripGeometry gripGeometry = _gripGeometry;

    Widget input;
    if (resizedHeight != null) {
      final int resizedRows = _rowsForHeight(resizedHeight);
      input = createInput(context, minLines: resizedRows, maxLines: resizedRows);
    } else if (isAutoHeight) {
      input = createInput(context, minLines: _preferredRows, maxLines: _preferredRows);
    } else {
      input = createInput(context, minLines: 3, maxLines: 5);
    }

    if (resizedWidth != null || resizedHeight != null) {
      input = SizedBox(
        width: resizedWidth,
        height: resizedHeight,
        child: input,
      );
    }

    if (!_showResizeHandle) {
      return input;
    }

    return Stack(
      key: const ValueKey('webf-textarea-resize-shell'),
      clipBehavior: Clip.none,
      children: [
        input,
        PositionedDirectional(
          end: 0,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: _handleResizeStart,
            onPanUpdate: _handleResizeUpdate,
            onPanEnd: (_) => setState(_commitResize),
            onPanCancel: _cancelResize,
            child: SizedBox(
              key: const ValueKey('webf-textarea-resize-handle'),
              width: gripGeometry.hitSize,
              height: gripGeometry.hitSize,
              child: Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: gripGeometry.visualSize,
                  height: gripGeometry.visualSize,
                  child: CustomPaint(
                    painter: _TextareaResizeHandlePainter(
                      color: Color.lerp(
                        widgetElement.renderStyle.borderRightColor.value,
                        widgetElement.renderStyle.color.value,
                        0.32,
                      )!,
                      geometry: gripGeometry,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextareaResizeHandlePainter extends CustomPainter {
  const _TextareaResizeHandlePainter({required this.color, required this.geometry});

  final Color color;
  final _TextareaResizeGripGeometry geometry;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = geometry.strokeWidth
      ..strokeCap = StrokeCap.square;

    final double step = size.shortestSide / (geometry.lineCount + 1);
    for (int index = 1; index <= geometry.lineCount; index++) {
      final double offset = step * index;
      canvas.drawLine(
        Offset(size.width - offset, size.height),
        Offset(size.width, size.height - offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TextareaResizeHandlePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.geometry != geometry;
  }
}

class _TextareaResizeGripGeometry {
  const _TextareaResizeGripGeometry({
    required this.visualSize,
    required this.hitSize,
    required this.strokeWidth,
    required this.lineCount,
  });

  final double visualSize;
  final double hitSize;
  final double strokeWidth;
  final int lineCount;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is _TextareaResizeGripGeometry &&
        other.visualSize == visualSize &&
        other.hitSize == hitSize &&
        other.strokeWidth == strokeWidth &&
        other.lineCount == lineCount;
  }

  @override
  int get hashCode => Object.hash(visualSize, hitSize, strokeWidth, lineCount);
}
