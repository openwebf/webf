import 'dart:math';
import 'dart:ui';

import 'package:webf/rendering.dart';

/// RenderBoxOverflowLayout is a class for tracking content that spills out of a box
/// This class is used by RenderBox
mixin RenderBoxOverflowLayout on RenderBoxModelBase {
  Rect? _layoutOverflowRect;
  Rect? _visualOverflowRect;

  void initOverflowLayout(Rect layoutRect, Rect visualRect) {
    _layoutOverflowRect = layoutRect;
    _visualOverflowRect = visualRect;
  }

  Rect? get overflowRect {
    return _layoutOverflowRect;
  }

  Rect? get visualOverflowRect {
    return _visualOverflowRect;
  }

  void addLayoutOverflow(Rect rect) {
    assert(_layoutOverflowRect != null, 'add overflow rect failed, _layoutOverflowRect not init');
    _layoutOverflowRect = Rect.fromLTRB(
        min(_layoutOverflowRect!.left, rect.left),
        min(_layoutOverflowRect!.top, rect.top),
        max(_layoutOverflowRect!.right, rect.right),
        max(_layoutOverflowRect!.bottom, rect.bottom));
  }

  void addVisualOverflow(Rect rect) {
    assert(_visualOverflowRect != null, 'add overflow rect failed, _visualOverflowRect not init');
    _visualOverflowRect = Rect.fromLTWH(
        min(_visualOverflowRect!.left, rect.left),
        min(_visualOverflowRect!.top, rect.top),
        max(_visualOverflowRect!.right, rect.right),
        max(_visualOverflowRect!.bottom, rect.bottom));
  }

  void moveOverflowLayout(Offset offset) {
    assert(_layoutOverflowRect != null, 'add overflow rect failed, _layoutOverflowRect not init');
    _layoutOverflowRect = _layoutOverflowRect!.shift(offset);
    assert(_visualOverflowRect != null, 'add overflow rect failed, _visualOverflowRect not init');
    _visualOverflowRect = _visualOverflowRect!.shift(offset);
  }

  void setLayoutOverflow(Rect rect) {
    _layoutOverflowRect = rect;
  }

  void setVisualOverflow(Rect rect) {
    _layoutOverflowRect = rect;
  }

  void clearOverflowLayout() {
    _layoutOverflowRect = null;
    _visualOverflowRect = null;
  }
}
