import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
import 'package:webf/src/rendering/text.dart';
import 'package:webf/src/rendering/event_listener.dart';
import 'package:webf/src/css/whitespace_processor.dart';
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
  final List<RenderBoxModel> _boxStack = [];

  /// Stack of directions for nested elements.
  final List<TextDirection> _directionStack = [];

  /// Stack of embedding levels for nested elements.
  final List<int> _levelStack = [];

  /// Track if the previous text ended with collapsible whitespace
  bool _endsWithCollapsibleSpace = false;

  /// Track if we're at the start of a line (paragraph start or after a forced break)
  bool _atLineStart = true;

  /// Get current direction from stack or base direction.
  TextDirection get _currentDirection =>
      _directionStack.isNotEmpty ? _directionStack.last : direction;

  /// Get current embedding level.
  int get _currentLevel =>
      _levelStack.isNotEmpty ? _levelStack.last : (direction == TextDirection.rtl ? 1 : 0);

  /// Current text offset.
  int get _currentOffset => _textContent.length;

  /// Build inline items from a render box.
  void build(RenderBox container) {
    items.clear();
    _textContent.clear();
    _boxStack.clear();
    _directionStack.clear();
    _levelStack.clear();
    _endsWithCollapsibleSpace = false;
    _atLineStart = true;

    // Initialize direction stack with container's direction if it has one
    if (container is RenderBoxModel) {
      _directionStack.add(container.renderStyle.direction);
      _levelStack.add(container.renderStyle.direction == TextDirection.rtl ? 1 : 0);
    }

    _collectInlines(container);

    // Add final close tags for any unclosed boxes
    while (_boxStack.isNotEmpty) {
      _addCloseTag(_boxStack.removeLast());
    }

    // Clean up the initial direction from stack
    if (container is RenderBoxModel) {
      if (_directionStack.isNotEmpty) {
        _directionStack.removeLast();
      }
      if (_levelStack.isNotEmpty) {
        _levelStack.removeLast();
      }
    }
  }

  /// Get the built text content.
  String get textContent => _textContent.toString();

  /// Collect inline content from render tree.
  void _collectInlines(RenderBox parent) {
    RenderBox? child;

    if (parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>) {
      child = (parent as ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>).firstChild;
    } else if (parent is RenderObjectWithChildMixin) {
      child = (parent as RenderObjectWithChildMixin<RenderBox>).child;
    }

    while (child != null) {
      if (child is RenderTextBox) {
        _addText(child);
      } else if (child is RenderBoxModel) {
        final display = child.renderStyle.display;

        // Handle <br/>: always force a line break in inline formatting context.
        final target = child.renderStyle.target;
        final String? tagName = target?.tagName;
        if (tagName == 'BR') {
          // Reset collapsible space tracking and insert a newline control
          _endsWithCollapsibleSpace = false;
          _addControl('\n');
          // <br> is a void element; skip descending into it
          // Move to next sibling
          if (parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>) {
            child = (parent as dynamic).childAfter(child);
            continue;
          } else {
            break;
          }
        }

        if (display == CSSDisplay.inline) {
          // Inline replaced elements and widget elements behave like atomic inlines
          // (similar to <img/>). Treat them as atomic so they generate a placeholder
          // in the paragraph and participate in line height/baseline properly.
          if (child.renderStyle.isSelfRenderReplaced() || child.renderStyle.isSelfRenderWidget()) {
            _addAtomicInline(child);
          } else {
            // Skip RenderEventListener wrappers - they're just for event handling
            // and shouldn't create separate inline boxes
            if (child is RenderEventListener && child.child != null) {
              _collectInlines(child);
            } else {
              _addInlineBox(child);
            }
          }
        } else if (display == CSSDisplay.inlineBlock || display == CSSDisplay.inlineFlex) {
          _addAtomicInline(child);
        } else if (child.renderStyle.position == CSSPositionType.fixed ||
            child.renderStyle.position == CSSPositionType.absolute) {
          // Skip positioned elements
        } else if (display == CSSDisplay.block || display == CSSDisplay.flex) {
          // Block-level elements inside inline context should be treated as inline-block
          // This creates an anonymous block box according to CSS spec
          _addAtomicInline(child);
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
    // Ensure RenderTextBox is laid out to avoid semantics errors
    // RenderTextBox doesn't participate in actual layout (handled by IFC),
    // but needs to be marked as laid out for Flutter's semantics system
    if (!textBox.hasSize) {
      textBox.layout(BoxConstraints.tight(Size.zero));
    }

    final text = textBox.data;
    if (text.isEmpty) return;

    final style = textBox.renderStyle;
    var processedText = _processWhiteSpace(text, style);
    // Process whitespace

    if (processedText.isNotEmpty) {
      // Trim leading collapsible spaces at line start for normal/nowrap/pre-line
      if (_atLineStart &&
          (style.whiteSpace == WhiteSpace.normal ||
              style.whiteSpace == WhiteSpace.nowrap ||
              style.whiteSpace == WhiteSpace.preLine)) {
        int trim = 0;
        while (trim < processedText.length && processedText.codeUnitAt(trim) == WhitespaceProcessor.SPACE) {
          trim++;
        }
        if (trim > 0) {
          processedText = processedText.substring(trim);
          // We've removed leading spaces; they shouldn't affect adjacency collapsing
          _endsWithCollapsibleSpace = false;
        }
      }

      // Skip if the text became empty after line-start trimming
      if (processedText.isEmpty) return;
      // Handle adjacent text node whitespace collapsing
      if (style.whiteSpace == WhiteSpace.normal ||
          style.whiteSpace == WhiteSpace.nowrap ||
          style.whiteSpace == WhiteSpace.preLine) {
        // Check if we need to collapse leading space with previous trailing space
        if (_endsWithCollapsibleSpace && processedText.startsWith(' ')) {
          processedText = processedText.substring(1);
        }

        // Update whether we end with collapsible space
        _endsWithCollapsibleSpace = processedText.endsWith(' ');
      } else {
        // For pre, pre-wrap, break-spaces, spaces are not collapsible
        _endsWithCollapsibleSpace = false;
      }

      // Skip if the text became empty after collapsing
      if (processedText.isEmpty) return;

      final startOffset = _currentOffset;
      _textContent.write(processedText);
      // After emitting any text content, we're no longer at line start
      _atLineStart = false;

      // Add text item

      // Associate this text item with the nearest enclosing inline box (if any)
      // so hit-testing can target the correct inline element (e.g., <span>).
      final item = InlineItem(
        type: InlineItemType.text,
        startOffset: startOffset,
        endOffset: _currentOffset,
        // When inside an inline element, the top of the box stack is the owner inline box.
        renderBox: _boxStack.isNotEmpty ? _boxStack.last : null,
        style: style,
      );
      // Set the direction from the current context
      item.direction = _currentDirection;
      item.bidiLevel = _currentLevel;
      items.add(item);
    }
  }

  /// Add inline box (non-atomic).
  void _addInlineBox(RenderBoxModel box) {
    // Add open tag
    _addOpenTag(box);

    // Calculate embedding level for this element
    final newDirection = box.renderStyle.direction;
    final parentLevel = _currentLevel;
    int newLevel;

    if (newDirection != _currentDirection) {
      // Direction change - increase embedding level
      newLevel = parentLevel + 1;
    } else {
      // Same direction - keep same level
      newLevel = parentLevel;
    }

    // Push direction and level for this element
    _directionStack.add(newDirection);
    _levelStack.add(newLevel);

    // Collect children
    _collectInlines(box);

    // Pop direction and level when leaving element
    if (_directionStack.isNotEmpty) {
      _directionStack.removeLast();
      _levelStack.removeLast();
    }

    // Add close tag
    _addCloseTag(box);
  }

  /// Add atomic inline (inline-block, replaced/widget inline element).
  void _addAtomicInline(RenderBoxModel box) {
    // Allow inline-block/inline-flex, or inline replaced/widget elements.
    assert(
      box.renderStyle.display == CSSDisplay.inlineBlock ||
      box.renderStyle.display == CSSDisplay.inlineFlex ||
      (box.renderStyle.display == CSSDisplay.inline &&
          (box.renderStyle.isSelfRenderReplaced() || box.renderStyle.isSelfRenderWidget()))
    );

    // Atomic inline elements break the text flow
    _endsWithCollapsibleSpace = false;

    // Insert object replacement character
    const objectReplacementChar = '\uFFFC';
    final startOffset = _currentOffset;
    _textContent.write(objectReplacementChar);

    items.add(InlineItem(
        type: InlineItemType.atomicInline,
        startOffset: startOffset,
        endOffset: _currentOffset,
        renderBox: box,
        style: box.renderStyle));

    // Atomic inline occupies content; we're no longer at line start
    _atLineStart = false;
  }

  /// Add open tag for inline box.
  void _addOpenTag(RenderBoxModel box) {
    _boxStack.add(box);

    final item = InlineItem(
      type: InlineItemType.openTag,
      startOffset: _currentOffset,
      endOffset: _currentOffset,
      renderBox: box,
      style: box.renderStyle,
    );
    item.direction = box.renderStyle.direction;
    items.add(item);
  }

  /// Add close tag for inline box.
  void _addCloseTag(RenderBoxModel box) {
    // Remove from stack to mark as closed
    _boxStack.remove(box);

    items.add(InlineItem(
      type: InlineItemType.closeTag,
      startOffset: _currentOffset,
      endOffset: _currentOffset,
      renderBox: box,
      style: box.renderStyle,
    ));
  }

  /// Process white space according to CSS rules.
  String _processWhiteSpace(String text, CSSRenderStyle style) {
    // Use the new WhitespaceProcessor for Phase I processing
    return WhitespaceProcessor.processPhaseOne(text, style.whiteSpace);
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

    // If control is a line break, we are at the start of a new line
    if (char == '\n') {
      _atLineStart = true;
      _endsWithCollapsibleSpace = false;
    }
  }
}
