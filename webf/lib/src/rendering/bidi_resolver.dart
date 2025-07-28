import 'dart:ui' as ui;
import 'package:flutter/painting.dart';
import 'inline_item.dart';

/// Represents a run of text with the same direction.
class BidiRun {
  final int startOffset;
  final int endOffset;
  final TextDirection direction;
  final int level;

  BidiRun({
    required this.startOffset,
    required this.endOffset,
    required this.direction,
    required this.level,
  });

  bool get isRtl => direction == TextDirection.rtl;
}

/// Resolves bidirectional text according to the Unicode Bidirectional Algorithm.
/// This is a simplified implementation that handles basic LTR/RTL cases.
class BidiResolver {
  final String text;
  final TextDirection baseDirection;
  final List<InlineItem> items;

  BidiResolver({
    required this.text,
    required this.baseDirection,
    required this.items,
  });

  /// Resolve BiDi levels and create runs.
  List<BidiRun> resolve() {
    if (text.isEmpty) {
      return [];
    }

    // For now, use Flutter's built-in BiDi support through Paragraph
    final paragraphBuilder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textDirection: baseDirection,
    ));
    
    paragraphBuilder.addText(text);
    final paragraph = paragraphBuilder.build();
    
    // Layout with infinite width to get BiDi information
    paragraph.layout(const ui.ParagraphConstraints(width: double.infinity));
    
    // Get bidi regions from the paragraph
    final List<BidiRun> runs = [];
    
    // For now, create a simple implementation that respects base direction
    // In a full implementation, we would analyze the text using the Unicode
    // Bidirectional Algorithm and create runs based on character properties
    
    if (_containsRtlCharacters(text)) {
      // If text contains RTL characters, we need to analyze it more carefully
      runs.addAll(_analyzeTextForBidi());
    } else {
      // Simple case: all LTR
      runs.add(BidiRun(
        startOffset: 0,
        endOffset: text.length,
        direction: baseDirection,
        level: 0,
      ));
    }
    
    // Update inline items with BiDi levels
    _updateItemsWithBidiLevels(runs);
    
    return runs;
  }

  /// Check if text contains RTL characters (simplified check).
  bool _containsRtlCharacters(String text) {
    // Check for common RTL scripts: Arabic, Hebrew, etc.
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      // Arabic: U+0600-U+06FF
      // Hebrew: U+0590-U+05FF
      if ((codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
          (codeUnit >= 0x0590 && codeUnit <= 0x05FF)) {
        return true;
      }
    }
    return false;
  }

  /// Analyze text for BiDi runs (simplified implementation).
  List<BidiRun> _analyzeTextForBidi() {
    final runs = <BidiRun>[];
    int currentStart = 0;
    TextDirection? currentDirection;
    
    for (int i = 0; i < text.length; i++) {
      final codeUnit = text.codeUnitAt(i);
      final isRtl = (codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
                    (codeUnit >= 0x0590 && codeUnit <= 0x05FF);
      
      final charDirection = isRtl ? TextDirection.rtl : TextDirection.ltr;
      
      if (currentDirection == null) {
        currentDirection = charDirection;
      } else if (currentDirection != charDirection) {
        // Direction change, create a run
        runs.add(BidiRun(
          startOffset: currentStart,
          endOffset: i,
          direction: currentDirection,
          level: currentDirection == TextDirection.rtl ? 1 : 0,
        ));
        currentStart = i;
        currentDirection = charDirection;
      }
    }
    
    // Add the last run
    if (currentDirection != null) {
      runs.add(BidiRun(
        startOffset: currentStart,
        endOffset: text.length,
        direction: currentDirection,
        level: currentDirection == TextDirection.rtl ? 1 : 0,
      ));
    }
    
    return runs;
  }

  /// Update inline items with BiDi levels from runs.
  void _updateItemsWithBidiLevels(List<BidiRun> runs) {
    for (final item in items) {
      if (item.type == InlineItemType.text) {
        // Find the run that contains this item
        for (final run in runs) {
          if (item.startOffset >= run.startOffset && item.endOffset <= run.endOffset) {
            item.bidiLevel = run.level;
            break;
          }
        }
      }
    }
  }

  /// Reorder items for visual order based on BiDi levels.
  static List<InlineItem> reorderItemsForVisualOrder(List<InlineItem> items) {
    if (items.isEmpty) return items;
    
    // Find the highest BiDi level
    int maxLevel = 0;
    for (final item in items) {
      if (item.bidiLevel > maxLevel) {
        maxLevel = item.bidiLevel;
      }
    }
    
    // If all items are LTR (level 0), no reordering needed
    if (maxLevel == 0) {
      return items;
    }
    
    // Reorder items based on BiDi levels
    // This is a simplified implementation of the Unicode BiDi reordering algorithm
    final reordered = List<InlineItem>.from(items);
    
    // Process levels from highest to lowest
    for (int level = maxLevel; level >= 1; level--) {
      if (level % 2 == 1) {
        // Odd levels (RTL) - reverse sequences at this level
        int start = -1;
        for (int i = 0; i <= reordered.length; i++) {
          if (i < reordered.length && reordered[i].bidiLevel >= level) {
            if (start == -1) {
              start = i;
            }
          } else if (start != -1) {
            // Reverse the sequence
            final end = i - 1;
            _reverseRange(reordered, start, end);
            start = -1;
          }
        }
      }
    }
    
    return reordered;
  }

  /// Reverse a range of items in place.
  static void _reverseRange(List<InlineItem> items, int start, int end) {
    while (start < end) {
      final temp = items[start];
      items[start] = items[end];
      items[end] = temp;
      start++;
      end--;
    }
  }
}