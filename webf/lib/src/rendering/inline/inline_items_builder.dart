import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'inline_item.dart';

/// Builds a flat list of InlineItems from render tree.
/// Based on Blink's InlineItemsBuilder.
class InlineItemsBuilder {
  InlineItemsBuilder({
    required this.direction,
  });

  /// Text direction for the inline formatting context.
  final TextDirection direction;

  /// The collected inline items.
  final List<InlineItem> items = [];

  /// The text content string.
  final StringBuffer _textContent = StringBuffer();

  /// Stack of open inline boxes.
  final List<RenderBox> _boxStack = [];

  /// Current text offset.
  int get _currentOffset => _textContent.length;

  /// Build inline items from a render box.
  void build(RenderBox container) {
    items.clear();
    _textContent.clear();
    _boxStack.clear();

    _collectInlines(container);
    
    // Add final close tags for any unclosed boxes
    while (_boxStack.isNotEmpty) {
      _addCloseTag(_boxStack.removeLast());
    }
  }

  /// Get the built text content.
  String get textContent => _textContent.toString();

  /// Collect inline content from render tree.
  void _collectInlines(RenderBox parent) {
    RenderBox? child = parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>> ? 
        (parent as dynamic).firstChild : null;
    
    while (child != null) {
      if (child is RenderTextBox) {
        _addText(child);
      } else if (child is RenderBoxModel) {
        final display = child.renderStyle.display;
        
        if (display == CSSDisplay.inline) {
          _addInlineBox(child);
        } else if (display == CSSDisplay.inlineBlock || 
                   display == CSSDisplay.inlineFlex) {
          _addAtomicInline(child);
        } else if (child.renderStyle.position == CSSPositionType.fixed ||
                   child.renderStyle.position == CSSPositionType.absolute) {
          // Skip positioned elements
        } else if (display == CSSDisplay.block || 
                   display == CSSDisplay.flex) {
          // Block-level element breaks the inline formatting context
          break;
        }
      }
      
      // Get next sibling
      if (parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>) {
        child = (parent as dynamic).childAfter(child);
      } else {
        break;
      }
    }
  }

  /// Add text content.
  void _addText(RenderTextBox textBox) {
    final text = textBox.data;
    if (text.isEmpty) return;
    
    final style = textBox.renderStyle;
    final processedText = _processWhiteSpace(text, style);
    
    if (processedText.isNotEmpty) {
      final startOffset = _currentOffset;
      _textContent.write(processedText);
      
      items.add(InlineItem(
        type: InlineItemType.text,
        startOffset: startOffset,
        endOffset: _currentOffset,
        renderBox: textBox,
        style: style,
      ));
    }
  }

  /// Add inline box (non-atomic).
  void _addInlineBox(RenderBoxModel box) {
    // Add open tag
    _addOpenTag(box);
    
    // Collect children
    _collectInlines(box);
    
    // Add close tag
    _addCloseTag(box);
  }

  /// Add atomic inline (inline-block, replaced element).
  void _addAtomicInline(RenderBox box) {
    // Insert object replacement character
    const objectReplacementChar = '\uFFFC';
    final startOffset = _currentOffset;
    _textContent.write(objectReplacementChar);
    
    items.add(InlineItem(
      type: InlineItemType.atomicInline,
      startOffset: startOffset,
      endOffset: _currentOffset,
      renderBox: box,
      style: box is RenderBoxModel ? box.renderStyle : null,
    ));
  }

  /// Add floating element.
  void _addFloat(RenderBox box) {
    items.add(InlineItem(
      type: InlineItemType.floatingElement,
      startOffset: _currentOffset,
      endOffset: _currentOffset,
      renderBox: box,
      style: box is RenderBoxModel ? box.renderStyle : null,
    ));
  }

  /// Add open tag for inline box.
  void _addOpenTag(RenderBox box) {
    _boxStack.add(box);
    
    items.add(InlineItem(
      type: InlineItemType.openTag,
      startOffset: _currentOffset,
      endOffset: _currentOffset,
      renderBox: box,
      style: box is RenderBoxModel ? box.renderStyle : null,
    ));
  }

  /// Add close tag for inline box.
  void _addCloseTag(RenderBox box) {
    items.add(InlineItem(
      type: InlineItemType.closeTag,
      startOffset: _currentOffset,
      endOffset: _currentOffset,
      renderBox: box,
      style: box is RenderBoxModel ? box.renderStyle : null,
    ));
  }

  /// Process white space according to CSS rules.
  String _processWhiteSpace(String text, CSSRenderStyle style) {
    switch (style.whiteSpace) {
      case WhiteSpace.normal:
      case WhiteSpace.nowrap:
        // Collapse sequences of white space
        return text.replaceAll(RegExp(r'\s+'), ' ');
      
      case WhiteSpace.pre:
      case WhiteSpace.preWrap:
        // Preserve white space
        return text;
      
      case WhiteSpace.preLine:
        // Preserve line breaks, collapse other white space
        return text.replaceAll(RegExp(r'[^\S\n]+'), ' ');
      
      case WhiteSpace.breakSpaces:
        // Convert spaces to non-breaking spaces
        return text.replaceAll(' ', '\u00A0');
      
      default:
        return text;
    }
  }

  /// Add line break opportunity.
  void _addLineBreakOpportunity() {
    items.add(InlineItem(
      type: InlineItemType.lineBreakOpportunity,
      startOffset: _currentOffset,
      endOffset: _currentOffset,
    ));
  }

  /// Add control character (newline, tab, etc).
  void _addControl(String char) {
    final startOffset = _currentOffset;
    _textContent.write(char);
    
    items.add(InlineItem(
      type: InlineItemType.control,
      startOffset: startOffset,
      endOffset: _currentOffset,
    ));
  }
}