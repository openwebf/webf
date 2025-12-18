/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
import 'package:flutter/rendering.dart';
import 'package:webf/rendering.dart';
import 'inline_item.dart';

/// A utility class to provide enhanced debugging information for inline layout.
/// This is used to provide detailed visual formatting of inline layout structure
/// for the Flutter RenderObject inspector.
class InlineLayoutDebugger {
  InlineLayoutDebugger(this.context);

  final InlineFormattingContext context;

  /// Generate a visual ASCII representation of paragraph line metrics.
  String generateLineBoxDiagram() {
    final lines = context.paragraphLineMetrics;
    if (lines.isEmpty) {
      return 'No paragraph lines';
    }

    final buffer = StringBuffer();
    buffer.writeln('Paragraph Lines:');
    buffer.writeln('================');

    double totalHeight = 0;
    double maxWidth = 0;
    for (int i = 0; i < lines.length; i++) {
      final lm = lines[i];
      buffer.writeln();
      buffer.writeln('Line ${i + 1}:');
      buffer.writeln('├─ Size: ${lm.width.toStringAsFixed(1)} × ${lm.height.toStringAsFixed(1)}');
      buffer.writeln('└─ Baseline: ${lm.baseline.toStringAsFixed(1)}');
      totalHeight += lm.height;
      if (lm.width > maxWidth) maxWidth = lm.width;
    }

    buffer.writeln();
    buffer.writeln('Summary:');
    buffer.writeln('├─ Total lines: ${lines.length}');
    buffer.writeln('├─ Total height: ${totalHeight.toStringAsFixed(1)}');
    buffer.writeln('└─ Max width: ${maxWidth.toStringAsFixed(1)}');

    return buffer.toString();
  }

  /// Generate a detailed inline item flow diagram.
  String generateInlineItemFlow() {
    if (context.items.isEmpty) {
      return 'No inline items';
    }

    final buffer = StringBuffer();
    buffer.writeln('Inline Item Flow:');
    buffer.writeln('=================');

    int currentOffset = 0;
    for (int i = 0; i < context.items.length && i < 20; i++) {
      final item = context.items[i];
      
      // Add offset indicator if there's a gap
      if (item.startOffset > currentOffset) {
        buffer.writeln('  [GAP: ${item.startOffset - currentOffset} chars]');
      }

      String itemDesc = '';
      switch (item.type) {
        case InlineItemType.text:
          final text = item.getText(context.textContent);
          final displayText = text.length > 30 ? '${text.substring(0, 30)}...' : text;
          itemDesc = 'TEXT: "$displayText"';
          if (item.bidiLevel > 0) {
            itemDesc += ' (bidi:${item.bidiLevel})';
          }
          break;
        case InlineItemType.openTag:
          itemDesc = 'OPEN: ${_getElementDescription(item.renderBox)}';
          break;
        case InlineItemType.closeTag:
          itemDesc = 'CLOSE: ${_getElementDescription(item.renderBox)}';
          break;
        case InlineItemType.atomicInline:
          itemDesc = 'ATOMIC: ${_getElementDescription(item.renderBox)}';
          break;
        case InlineItemType.lineBreakOpportunity:
          itemDesc = 'BREAK_OPPORTUNITY';
          break;
        case InlineItemType.bidiControl:
          itemDesc = 'BIDI_CONTROL (level:${item.bidiLevel})';
          break;
        default:
          itemDesc = item.type.toString().split('.').last.toUpperCase();
      }

      buffer.writeln('  [${item.startOffset}-${item.endOffset}] $itemDesc');
      
      if (item.shapeResult != null) {
        buffer.writeln('        └─ shape: ${_formatSize(Size(item.shapeResult!.width, item.shapeResult!.height))}');
      }

      currentOffset = item.endOffset;
    }

    if (context.items.length > 20) {
      buffer.writeln('  ... ${context.items.length - 20} more items');
    }

    return buffer.toString();
  }

  /// Generate text content visualization with bidi levels.
  String generateTextVisualization() {
    if (context.textContent.isEmpty) {
      return 'No text content';
    }

    final buffer = StringBuffer();
    buffer.writeln('Text Content Visualization:');
    buffer.writeln('===========================');

    // Show the actual text (truncated if too long)
    final displayText = context.textContent.length > 100
        ? '${context.textContent.substring(0, 100)}...'
        : context.textContent;
    buffer.writeln('Text: "$displayText"');

    // Show bidi levels if any
    final hasBidi = context.items.any((item) => item.bidiLevel > 0);
    if (hasBidi) {
      buffer.writeln();
      buffer.writeln('Bidi Levels:');
      for (final item in context.items.where((i) => i.type == InlineItemType.text && i.bidiLevel > 0)) {
        final text = item.getText(context.textContent);
        final displayText = text.length > 20 ? '${text.substring(0, 20)}...' : text;
        buffer.writeln('  Level ${item.bidiLevel}: "$displayText" [${item.startOffset}-${item.endOffset}]');
      }
    }

    return buffer.toString();
  }

  /// Format a size for display.
  String _formatSize(Size size) {
    return '${size.width.toStringAsFixed(1)}×${size.height.toStringAsFixed(1)}';
  }

  /// Get a short description of the RenderBoxModel.
  String _getElementDescription(RenderBoxModel? renderBox) {
    if (renderBox == null) return 'unknown';

    // Try to get element tag from the RenderBoxModel
    final element = renderBox.renderStyle.target;
    // For HTML elements, return the tag name
    final tagName = element.tagName;
    final lowerTagName = tagName.toLowerCase();
    if (tagName.isNotEmpty && tagName != 'DIV') {
      return lowerTagName;
    }

    // For elements with specific classes or IDs, include them
    final id = element.id;
    final className = element.className;

    if (id != null && id.isNotEmpty) {
      return '$lowerTagName#$id';
    } else if (className.isNotEmpty) {
      return '$lowerTagName.$className';
    }

    if (tagName.isNotEmpty) return lowerTagName;

    // Fallback to a short description
    final typeStr = renderBox.runtimeType.toString();
    if (typeStr.startsWith('Render')) {
      return typeStr.substring(6); // Remove 'Render' prefix
    }
    return typeStr;
  }

  /// Add comprehensive debug properties to a DiagnosticPropertiesBuilder.
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    // Add visual diagrams as multi-line string properties
    properties.add(StringProperty(
      'lineBoxDiagram',
      generateLineBoxDiagram(),
      style: DiagnosticsTreeStyle.whitespace,
    ));

    properties.add(StringProperty(
      'inlineItemFlow',
      generateInlineItemFlow(),
      style: DiagnosticsTreeStyle.whitespace,
    ));

    if (context.items.any((item) => item.bidiLevel > 0)) {
      properties.add(StringProperty(
        'textVisualization',
        generateTextVisualization(),
        style: DiagnosticsTreeStyle.whitespace,
      ));
    }
  }
}
