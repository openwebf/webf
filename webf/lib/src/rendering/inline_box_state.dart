import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'line_box.dart';

/// State for an open inline box during layout.
class InlineBoxState {
  InlineBoxState({
    required this.renderBox,
    required this.style,
    required this.startX,
    this.contentStartX,
  });

  /// The render box.
  final RenderBox renderBox;

  /// Box style.
  final CSSRenderStyle style;

  /// Start X position (includes padding area).
  final double startX;
  
  /// Content start X position (after padding).
  final double? contentStartX;

  /// Children of this box.
  final List<LineBoxItem> children = [];
}