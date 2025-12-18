/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/css.dart';
import 'package:webf/rendering.dart';
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

  /// Whether we should trim a single leading newline at the very start
  /// of a PRE element. Per HTML spec, if a <pre> element's first child is
  /// a text node and that text node starts with a U+000A line feed, it is
  /// ignored (treated as if it were not there).
  bool _shouldTrimLeadingNewlineForPre = false;

  /// Have we already consumed any content at the container root level?
  bool _consumedRootContent = false;

  // Track cross-chunk word-start state for text-transform:capitalize so that
  // inline element boundaries inside a word do not restart capitalization.
  bool _capitalizeAtWordStart = true;

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
    _capitalizeAtWordStart = true;

    // Initialize direction stack with container's direction if it has one
    if (container is RenderBoxModel) {
      _directionStack.add(container.renderStyle.direction);
      _levelStack.add(container.renderStyle.direction == TextDirection.rtl ? 1 : 0);
      // Enable PRE leading newline trimming only for PRE tag
      final String tag = container.renderStyle.target.tagName;
      _shouldTrimLeadingNewlineForPre = (tag == 'PRE');
    }

    _collectInlines(container);

    // HTML PRE end-trim: If building a PRE formatting context, trim a trailing
    // indentation-only line (spaces/tabs before the close tag) and a single
    // final line feed, if present. This matches browser behavior where authors
    // often indent the closing </pre> and don't expect an extra blank line.
    if (container is RenderBoxModel) {
      final String tag0 = container.renderStyle.target.tagName;
      if (tag0 == 'PRE') {
        _trimTrailingIndentAndNewlineForPre();
      }
    }

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

        // Out-of-flow positioned elements (absolute/fixed) do not participate in IFC.
        // They must be skipped regardless of their display value.
        if (child.renderStyle.position == CSSPositionType.fixed ||
            child.renderStyle.position == CSSPositionType.absolute) {
          // Skip positioned elements entirely; their placeholder is handled separately in flow layout.
          // Move to next sibling.
          if (parent is ContainerRenderObjectMixin<RenderBox, ContainerBoxParentData<RenderBox>>) {
            child = (parent as dynamic).childAfter(child);
            continue;
          } else {
            break;
          }
        }

        // Handle <br/>: always force a line break in inline formatting context.
        final target = child.renderStyle.target;
        final String tagName = target.tagName;
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
              if (_boxStack.isEmpty) {
                _consumedRootContent = true;
              }
              _collectInlines(child);
            } else {
              _addInlineBox(child);
            }
          }
        } else if (display == CSSDisplay.inlineBlock || display == CSSDisplay.inlineFlex) {
          _addAtomicInline(child);
        } else if (display == CSSDisplay.block || display == CSSDisplay.flex) {
          // Block-level elements appearing inside an inline formatting context split the line.
          // Model this by forcing a hard line break before (if not already at line start)
          // and always after the atomic placeholder representing the block box.
          if (!_atLineStart) {
            _addControl('\n');
          }
          _addAtomicInline(child);
          // Always break after the block-level atomic so following inline content starts on a new line.
          _addControl('\n');
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

  // Note: Trailing segment breaks (\n/\r) in WhiteSpace.normal/nowrap are handled by
  // WhitespaceProcessor (transformed to a space and collapsed). We do not inject
  // extra line breaks here; block-level siblings already force a new line.

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
    // Apply text-transform after whitespace processing so word boundaries
    // reflect collapsed spaces. Inherited property; style.textTransform includes parent.
    final tt = style.textTransform;
    if (tt != TextTransform.none) {
      if (tt == TextTransform.capitalize) {
        final (tx, endAtWordStart) = CSSText.applyTextTransformWithCarry(
          processedText,
          tt,
          _capitalizeAtWordStart,
        );
        processedText = tx;
        _capitalizeAtWordStart = endAtWordStart;
      } else {
        processedText = CSSText.applyTextTransform(processedText, tt);
        // Update carry state based on last character boundary for future chunks.
        if (processedText.isNotEmpty) {
          _capitalizeAtWordStart = CSSText.isWordBoundary(processedText.codeUnitAt(processedText.length - 1));
        }
      }
    } else {
      // No transform; still update carry state based on trailing boundary.
      if (processedText.isNotEmpty) {
        _capitalizeAtWordStart = CSSText.isWordBoundary(processedText.codeUnitAt(processedText.length - 1));
      }
    }

    // HTML: If the first child of a PRE is a text node starting with a
    // single LF (or CRLF), ignore that line break. Only apply when the
    // text is directly under the container (no enclosing inline box).
    if (_shouldTrimLeadingNewlineForPre && !_consumedRootContent && _boxStack.isEmpty && processedText.isNotEmpty) {
      if (processedText.startsWith('\r\n')) {
        processedText = processedText.substring(2);
      } else if (processedText.startsWith('\n') || processedText.startsWith('\r')) {
        processedText = processedText.substring(1);
      }
      // Only trim once per PRE
      _shouldTrimLeadingNewlineForPre = false;
    }
    // Process whitespace

    if (processedText.isNotEmpty) {
      // For pre-like whitespace modes, expand tab characters to spaces using the
      // effective CSS tab-size and the current column position on the line. This
      // keeps Phase I semantics (tests expect tabs preserved) while ensuring
      // layout uses visual tab stops.
      if (style.whiteSpace == WhiteSpace.pre ||
          style.whiteSpace == WhiteSpace.preWrap ||
          style.whiteSpace == WhiteSpace.breakSpaces) {
        // Determine current column from accumulated text buffer since last line feed
        final String soFar = _textContent.toString();
        final int lastLf = soFar.lastIndexOf('\n');
        final int currentColumn = lastLf == -1 ? soFar.length : (soFar.length - lastLf - 1);
        final double ts = style.tabSize;
        processedText = WhitespaceProcessor.expandTabsForPre(processedText, currentColumn, ts);
      }
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

    // Mark that we've consumed some content at root level when not inside an inline box
    if (_boxStack.isEmpty) {
      _consumedRootContent = true;
    }
  }

  /// Add inline box (non-atomic).
  void _addInlineBox(RenderBoxModel box) {
    // If this inline box is at the root level, we've consumed root content
    if (_boxStack.isEmpty) {
      _consumedRootContent = true;
    }
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
    if (_boxStack.isEmpty) {
      _consumedRootContent = true;
    }
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

  /// Trim a trailing indentation-only line and one trailing newline
  /// for PRE elements. Implementation details:
  /// 1) Remove trailing spaces/tabs at end of the text buffer.
  /// 2) If there was at least one space/tab removed and the preceding
  ///    character is a line feed, remove that single line feed as well.
  /// 3) Otherwise (no trailing spaces/tabs), still remove a single
  ///    trailing line feed if present at the very end.
  /// After trimming, clamp all item offsets to the new text length so
  /// subsequent substring() operations remain valid.
  void _trimTrailingIndentAndNewlineForPre() {
    final String current = _textContent.toString();
    if (current.isEmpty) return;

    int end = current.length;

    // 1) Remove trailing spaces/tabs at the very end (indentation before </pre>)
    int i = end - 1;
    while (i >= 0) {
      final int cu = current.codeUnitAt(i);
      if (cu == WhitespaceProcessor.SPACE || cu == WhitespaceProcessor.TAB) {
        i--;
        continue;
      }
      break;
    }

    bool removedIndent = i < end - 1;

    // 2) If we removed indentation and the preceding char is a line feed, drop it too.
    if (removedIndent && i >= 0 && current.codeUnitAt(i) == WhitespaceProcessor.LINE_FEED) {
      end = i; // trim to just before the line feed
    } else {
      // 3) If no indentation removed, still trim a single terminal LF if present
      if (end > 0 && current.codeUnitAt(end - 1) == WhitespaceProcessor.LINE_FEED) {
        end = end - 1;
      }
    }

    // If nothing to trim, bail.
    if (end == current.length) return;

    // Rebuild the text buffer to the trimmed content.
    final String trimmed = current.substring(0, end);
    _textContent
      ..clear()
      ..write(trimmed);

    // Clamp all item offsets to the new content length.
    if (items.isNotEmpty) {
      final int newLen = end;
      final List<InlineItem> adjusted = <InlineItem>[];
      for (final it in items) {
        int ns = it.startOffset;
        int ne = it.endOffset;
        if (ns > newLen) ns = newLen;
        if (ne > newLen) ne = newLen;
        if (ne < ns) ne = ns;
        final ni = InlineItem(
          type: it.type,
          startOffset: ns,
          endOffset: ne,
          renderBox: it.renderBox,
          style: it.style,
          bidiLevel: it.bidiLevel,
        );
        ni.direction = it.direction;
        adjusted.add(ni);
      }
      items
        ..clear()
        ..addAll(adjusted);
    }
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
