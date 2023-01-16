import 'package:flutter/rendering.dart';
import 'package:webf/src/rendering/text.dart';

class LogicInlineBox {
  RenderBox renderObject;
  LogicLineBox? parentLine;
  LogicInlineBox? next;
  LogicInlineBox? pre;
  bool isDirty;

  LogicInlineBox({required this.renderObject, this.parentLine, this.isDirty = true});
}

class LogicTextInlineBox extends LogicInlineBox {
  int start;
  int length;

  LogicTextInlineBox(
      {this.start = 0, this.length = 0, required RenderTextBox renderObject, parentLine, isDirty = true})
      : super(renderObject: renderObject, parentLine: parentLine, isDirty: isDirty);

  get end {
    return start + length;
  }

  get isLineBreak {
    return false;
  }
}

class LogicLineBox {
  RenderBox renderObject;
  LogicLineBox? next;
  LogicLineBox? pre;
  bool isFirstLine;
  bool isLastLine;
  LogicInlineBox? fistChild;
  LogicInlineBox? lastChild;
  final double mainAxisExtent;
  final double crossAxisExtent;
  final double baselineExtent;

  LogicLineBox({
    required this.renderObject,
    this.isFirstLine = false,
    this.isLastLine = false,
    required this.mainAxisExtent,
    required this.crossAxisExtent,
    required this.baselineExtent,
  });

  appendInlineBox(LogicInlineBox box) {
    fistChild ??= box;
    if (lastChild != null) {
      lastChild!.next = box;
      box.pre = lastChild;
      lastChild = box;
    } else {
      lastChild = box;
    }
  }
}
