import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui show ParagraphBuilder, PlaceholderAlignment, Locale;

class WebFTextSpan extends TextSpan {
  WebFTextSpan(
      {String? text,
      List<InlineSpan>? children,
      GestureRecognizer? recognizer,
      MouseCursor? mouseCursor,
      PointerEnterEventListener? onEnter,
      PointerExitEventListener? onExit,
      String? semanticsLabel,
      ui.Locale? locale,
      TextStyle? style,
      bool? spellOut})
      : super(
            text: text,
            children: children,
            style: style,
            recognizer: recognizer,
            mouseCursor: mouseCursor,
            onEnter: onEnter,
            onExit: onExit,
            semanticsLabel: semanticsLabel,
            locale: locale,
            spellOut: spellOut);

  final Map<InlineSpan, bool> textSpanPosition = <InlineSpan, bool>{};

  List<InlineSpan>? preInsertChildren() {
    return children
        ?.where((element) => textSpanPosition.containsKey(element) && textSpanPosition[element]! == true)
        .toList();
  }

  List<InlineSpan>? backInsertChildren() {
    return children
        ?.where((element) => !(textSpanPosition.containsKey(element) && textSpanPosition[element]! == true))
        .toList();
  }

  List<Object> subContent(int start, int end) {
    List<Object> content = [];
    int prePlaceHolderLength = (preInsertChildren()?.length ?? 0);

    if (start < prePlaceHolderLength) {
      for (int i = start; i < prePlaceHolderLength && i < end; i++) {
        content.add(preInsertChildren()![i]);
      }
    }

    if (start > prePlaceHolderLength || end > prePlaceHolderLength) {
      int subStart = start - prePlaceHolderLength >= 0 ? (start - prePlaceHolderLength) : 0;
      int subEnd = end - prePlaceHolderLength;
      content.add(text!.substring(subStart, subEnd));
    }
    return content;
  }

  int get contentLength {
    return (text?.length ?? 0) + (preInsertChildren()?.length ?? 0);
  }

  WebFTextPlaceHolderSpan? firstPlaceHolderSpan() {
    List<InlineSpan>? children = preInsertChildren();
    if (children != null && children.isNotEmpty) {
      return children[0] as WebFTextPlaceHolderSpan;
    }
    return null;
  }

  String? subContentFilterString(int start, int end) {
    List<Object> content = subContent(start, end);
    List<Object> filterContent = content.whereType<String>().toList();
    if (filterContent.isNotEmpty) {
      return filterContent[0] as String;
    }
    return null;
  }

  @override
  void build(
      ui.ParagraphBuilder builder, {
        double textScaleFactor = 1.0,
        List<PlaceholderDimensions>? dimensions,
      }) {
    assert(debugAssertIsValid());
    final bool hasStyle = style != null;
    if (hasStyle) builder.pushStyle(style!.getTextStyle(textScaleFactor: textScaleFactor));

    preInsertChildren()?.forEach((child) {
      child.build(
        builder,
        textScaleFactor: textScaleFactor,
        dimensions: dimensions,
      );
    });
    if (text != null) {
      try {
        builder.addText(text!);
      } on ArgumentError catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'painting library',
          context: ErrorDescription('while building a TextSpan'),
        ));
        // Use a Unicode replacement character as a substitute for invalid text.
        builder.addText('\uFFFD');
      }
    }
    backInsertChildren()?.forEach((child) {
      child.build(
        builder,
        textScaleFactor: textScaleFactor,
        dimensions: dimensions,
      );
    });
    if (hasStyle) builder.pop();
  }
}

class WebFTextPlaceHolderSpan extends PlaceholderSpan {
  WebFTextPlaceHolderSpan({
    ui.PlaceholderAlignment alignment = ui.PlaceholderAlignment.bottom,
    TextBaseline? baseline,
    TextStyle? style,
  })  : assert(
  baseline != null ||
      !(identical(alignment, ui.PlaceholderAlignment.aboveBaseline) ||
          identical(alignment, ui.PlaceholderAlignment.belowBaseline) ||
          identical(alignment, ui.PlaceholderAlignment.baseline)),
  ),
        super(
        alignment: alignment,
        baseline: baseline,
        style: style,
      );
  PlaceholderDimensions? lastDimensions;

  /// Adds a placeholder box to the paragraph builder if a size has been
  /// calculated for the widget.
  ///
  /// Sizes are provided through `dimensions`, which should contain a 1:1
  /// in-order mapping of widget to laid-out dimensions. If no such dimension
  /// is provided, the widget will be skipped.
  ///
  /// The `textScaleFactor` will be applied to the laid-out size of the widget.
  @override
  void build(ui.ParagraphBuilder builder, {double textScaleFactor = 1.0, List<PlaceholderDimensions>? dimensions}) {
    assert(debugAssertIsValid());
    assert(dimensions != null);
    final bool hasStyle = style != null;
    if (hasStyle) {
      builder.pushStyle(style!.getTextStyle(textScaleFactor: textScaleFactor));
    }
    assert(builder.placeholderCount < dimensions!.length);
    final PlaceholderDimensions currentDimensions = lastDimensions = dimensions![builder.placeholderCount];

    builder.addPlaceholder(
      currentDimensions.size.width,
      currentDimensions.size.height,
      alignment,
      scale: textScaleFactor,
      baseline: currentDimensions.baseline,
      baselineOffset: currentDimensions.baselineOffset,
    );
    if (hasStyle) {
      builder.pop();
    }
  }

  /// Calls `visitor` on this [WidgetSpan]. There are no children spans to walk.
  @override
  bool visitChildren(InlineSpanVisitor visitor) {
    return visitor(this);
  }

  @override
  InlineSpan? getSpanForPositionVisitor(TextPosition position, Accumulator offset) {
    if (position.offset == offset.value) {
      return this;
    }
    offset.increment(1);
    return null;
  }

  @override
  int? codeUnitAtVisitor(int index, Accumulator offset) {
    return null;
  }

  @override
  RenderComparison compareTo(InlineSpan other) {
    if (identical(this, other)) return RenderComparison.identical;
    if (other.runtimeType != runtimeType) return RenderComparison.layout;
    if ((style == null) != (other.style == null)) return RenderComparison.layout;
    final WebFTextPlaceHolderSpan typedOther = other as WebFTextPlaceHolderSpan;
    if (alignment != typedOther.alignment) {
      return RenderComparison.layout;
    }
    RenderComparison result = RenderComparison.identical;
    if (style != null) {
      final RenderComparison candidate = style!.compareTo(other.style!);
      if (candidate.index > result.index) result = candidate;
      if (result == RenderComparison.layout) return result;
    }
    return result;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    if (super != other) return false;
    return other is WebFTextPlaceHolderSpan && other.alignment == alignment && other.baseline == baseline;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, alignment, baseline);

  /// Returns the text span that contains the given position in the text.
  @override
  InlineSpan? getSpanForPosition(TextPosition position) {
    assert(debugAssertIsValid());
    return null;
  }

  @override
  bool debugAssertIsValid() {
    return true;
  }
}
