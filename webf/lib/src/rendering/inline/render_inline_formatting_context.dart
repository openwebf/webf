import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_formatting_context.dart';

/// Render object that establishes an inline formatting context.
/// Replaces RenderFlowLayout for inline layout.
class RenderInlineFormattingContext extends RenderLayoutBox {
  
  RenderInlineFormattingContext({
    required CSSRenderStyle renderStyle,
  }) : super(renderStyle: renderStyle) {
    _context = InlineFormattingContext(container: this);
  }

  /// The inline formatting context.
  late InlineFormattingContext _context;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! RenderLayoutParentData) {
      child.parentData = RenderLayoutParentData();
    }
  }

  @override
  void insert(RenderBox child, {RenderBox? after}) {
    super.insert(child, after: after);
    _context.setNeedsCollectInlines();
  }

  @override
  void remove(RenderBox child) {
    super.remove(child);
    _context.setNeedsCollectInlines();
  }

  @override
  void performLayout() {
    // Layout children that need sizing (e.g., inline-block elements)
    RenderBox? child = firstChild;
    while (child != null) {
      if (_needsLayout(child)) {
        child.layout(constraints, parentUsesSize: true);
      }
      child = childAfter(child);
    }

    // Perform inline layout
    size = _context.layout(constraints);
  }

  /// Check if child needs layout before inline formatting.
  bool _needsLayout(RenderBox child) {
    if (child is RenderBoxModel) {
      final display = child.renderStyle.display;
      return display == CSSDisplay.inlineBlock ||
             display == CSSDisplay.inlineFlex ||
             (child is RenderImage || child is RenderBoxModel && child.renderStyle.display == CSSDisplay.inlineBlock);
    }
    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint background and borders is handled by base class in paintBackground
    // which is called automatically by Flutter
    
    // Paint inline content
    _context.paint(context, offset);
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return _context.hitTest(result, position: position);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    return _context.getDistanceToBaseline(baseline);
  }
}