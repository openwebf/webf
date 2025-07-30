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

    // Create runs based on element-level direction changes
    final List<BidiRun> runs = _createRunsFromItems();
    
    // Split inline items based on bidi runs
    _splitItemsByBidiRuns(runs);
    
    // Update inline items with BiDi levels
    _updateItemsWithBidiLevels(runs);
    
    return runs;
  }

  /// Create bidi runs from inline items considering element-level direction changes.
  List<BidiRun> _createRunsFromItems() {
    final runs = <BidiRun>[];
    
    // Base paragraph level - 1 for RTL, 0 for LTR
    final int baseLevel = baseDirection == TextDirection.rtl ? 1 : 0;
    
    // Process all text items to create runs
    int currentStart = 0;
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      
      if (item.type == InlineItemType.text) {
        final itemDirection = item.direction ?? baseDirection;
        final itemText = text.substring(item.startOffset, item.endOffset);
        final itemLevel = item.bidiLevel;
        
        // For mixed content, analyze character by character
        _analyzeTextSegment(runs, item.startOffset, item.endOffset, itemDirection, itemLevel);
      }
    }
    
    // If no runs were created, create a default run
    if (runs.isEmpty) {
      runs.add(BidiRun(
        startOffset: 0,
        endOffset: text.length,
        direction: baseDirection,
        level: baseLevel,
      ));
    }
    
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

  /// Analyze a text segment for character-level bidi changes.
  void _analyzeTextSegment(List<BidiRun> runs, int startOffset, int endOffset, TextDirection baseDir, int baseLevel) {
    int currentStart = startOffset;
    TextDirection? currentDirection;
    int? currentLevel;
    
    
    for (int i = startOffset; i < endOffset; i++) {
      final codeUnit = text.codeUnitAt(i);
      final isRtl = (codeUnit >= 0x0600 && codeUnit <= 0x06FF) ||
                    (codeUnit >= 0x0590 && codeUnit <= 0x05FF);
      
      TextDirection charDirection;
      int level;
      
      if (isRtl) {
        // RTL character
        if (baseLevel % 2 == 0) {
          // In LTR context (even level), RTL gets next odd level
          charDirection = TextDirection.rtl;
          level = baseLevel + 1;
        } else {
          // In RTL context (odd level), RTL stays at same level
          charDirection = TextDirection.rtl;
          level = baseLevel;
        }
      } else {
        // Latin characters
        if (baseLevel % 2 == 1) {
          // In RTL context (odd level), Latin gets next even level
          charDirection = TextDirection.ltr;
          level = baseLevel + 1;
        } else {
          // In LTR context (even level), Latin stays at same level
          charDirection = TextDirection.ltr;
          level = baseLevel;
        }
      }
      
      if (currentDirection == null) {
        currentDirection = charDirection;
        currentLevel = level;
      } else if (currentDirection != charDirection || currentLevel != level) {
        // Direction or level change, create a run
        runs.add(BidiRun(
          startOffset: currentStart,
          endOffset: i,
          direction: currentDirection,
          level: currentLevel!,
        ));
        currentStart = i;
        currentDirection = charDirection;
        currentLevel = level;
      }
    }
    
    // Add the last run
    if (currentDirection != null && currentStart < endOffset) {
      runs.add(BidiRun(
        startOffset: currentStart,
        endOffset: endOffset,
        direction: currentDirection,
        level: currentLevel!,
      ));
    }
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

  /// Split inline items based on bidi runs.
  void _splitItemsByBidiRuns(List<BidiRun> runs) {
    final newItems = <InlineItem>[];
    
    for (final item in items) {
      if (item.type == InlineItemType.text) {
        // Find all runs that overlap with this text item
        bool itemSplit = false;
        
        for (final run in runs) {
          // Check if this run overlaps with the item
          if (run.startOffset < item.endOffset && run.endOffset > item.startOffset) {
            // Calculate the overlap
            final overlapStart = run.startOffset > item.startOffset ? run.startOffset : item.startOffset;
            final overlapEnd = run.endOffset < item.endOffset ? run.endOffset : item.endOffset;
            
            if (overlapStart < overlapEnd) {
              // Create a new item for this overlap
              final newItem = InlineItem(
                type: InlineItemType.text,
                startOffset: overlapStart,
                endOffset: overlapEnd,
                style: item.style,
              );
              newItem.direction = item.direction;
              newItem.bidiLevel = run.level;
              newItems.add(newItem);
              itemSplit = true;
              
            }
          }
        }
        
        if (!itemSplit) {
          // No split needed, keep the original item
          newItems.add(item);
        }
      } else {
        // Non-text items are kept as-is
        newItems.add(item);
      }
    }
    
    // Replace the items list
    items.clear();
    items.addAll(newItems);
  }
  
  /// Update inline items with BiDi levels from runs.
  void _updateItemsWithBidiLevels(List<BidiRun> runs) {
    // Items should already have bidi levels set from _splitItemsByBidiRuns
    // This method is kept for compatibility but the work is already done
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
    // The algorithm reverses runs at odd levels
    for (int level = maxLevel; level >= 1; level--) {
      if (level % 2 == 1) {
        // Odd levels (RTL) - reverse sequences at this level or higher
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