/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

import '../../dom.dart' as dom;
import '../../widget.dart';

const String LABEL = 'LABEL';
const String BUTTON = 'BUTTON';

const Map<String, dynamic> _defaultStyle = {DISPLAY: INLINE_BLOCK};

class LabelElement extends dom.Element {
  LabelElement([BindingContext? context]) : super(context);
}

class ButtonElement extends dom.Element {
  ButtonElement([BindingContext? context]) : super(context);

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}



const String BNIMAGE = 'BN-IMAGE';
const String BNVIEW = 'BN-VIEW';
const String BNTEXT = 'BN-TEXT';
const String BNSPAN = 'BN-SPAN';
const String BNSCROLLVIEW = 'BN-SCROLL-VIEW';
const String BNMARKDOWN = 'BN-MARKDOWN';
const String BNCONTEXTMENU = 'BN-CONTEXT-MENU';
const String BNCONTEXTMENUITEM = 'BN-CONTEXT-MENU-ITEM';

const Map<String, dynamic> _defaultViewStyle = {
  DISPLAY: BLOCK,
};


const Map<String, dynamic> _defaultSpanStyle = {
  DISPLAY: INLINE
};

class BNImageElement extends dom.Element {
  BNImageElement([BindingContext? context]) : super(context) {
    setDefaultID(BNIMAGE);
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultViewStyle;
}

class BNViewElement extends dom.Element {
  BNViewElement([BindingContext? context]) : super(context) {
    setDefaultID(BNVIEW);
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultViewStyle;
}

class BNSpanElement extends dom.Element {
  BNSpanElement([BindingContext? context]) : super(context) {
    setDefaultID(BNSPAN);
  }

    @override
  Map<String, dynamic> get defaultStyle => _defaultSpanStyle;
}

class BNTextElement extends dom.Element {
  BNTextElement([BindingContext? context]) : super(context) {
    setDefaultID(BNTEXT);
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}


class BNMarkdownElement extends dom.Element {
  BNMarkdownElement([BindingContext? context]) : super(context) {
    setDefaultID(BNMARKDOWN);
  }

  @override
  Map<String, dynamic> get defaultStyle => _defaultStyle;
}



class BNContextMenuElement extends WidgetElement {

  MaterialStateProperty<OutlinedBorder?>? get shape {
    final borderRadius = renderStyle.borderRadius;
    if (borderRadius == null) {
      return null;
    }
    return MaterialStateProperty.all<OutlinedBorder>(RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: borderRadius[0],
        topRight: borderRadius[1],
        bottomLeft: borderRadius[2],
        bottomRight: borderRadius[3],
      ))
    );
  }

  Alignment? get alignment {
    final align = attributes['menu-align'];
    if (align != null) {
      switch (align) {
        case 'topLeft':
          return Alignment.topLeft;
        case 'topCenter':
          return Alignment.topCenter;
        case 'topRight':
          return Alignment.topRight;
        case 'centerLeft':
          return Alignment.centerLeft;
        case 'center':
          return Alignment.center;
        case 'centerRight':
          return Alignment.centerRight;
        case 'bottomCenter':
          return Alignment.bottomCenter;
        case 'bottomLeft':
          return Alignment.bottomLeft;
        case 'bottomRight':
          return Alignment.bottomRight;
        default:
          break;
      }
    }
    return null;
  }

  // adjust the top alignment offset
  Offset? getAlignmentOffset(Size menuSize, Size slotSize) {
    final align = attributes['menu-align'];
    if (align != null && slotRect != null) {
      final double delta = 8;
      final screenW = ownerDocument.controller.view.window.screen.width;
      final double centerX = (slotRect!.left + slotRect!.width / 2) - screenW / 2 - menuSize.width / 2;
      final double dy = delta - slotRect!.top + menuSize.height;

      switch (align) {
        case 'topLeft':
          return Offset(slotRect!.left, -dy);
        case 'topCenter':
          return Offset(centerX, -dy);
        case 'topRight':
          return Offset(0, -dy);
        case 'centerLeft':
          return Offset(slotRect!.left, -menuSize.height / 2);
        case 'center':
          return Offset(centerX, -menuSize.height / 2);
        case 'centerRight':
          return Offset(0, -menuSize.height / 2);
        case 'bottomCenter':
        return Offset(centerX, -delta);
        case 'bottomLeft':
          return Offset(slotRect!.left, -delta);
        case 'bottomRight':
          return Offset(0, -delta);
        default:
          break;
      }
    }
    return null;
  }

  bool showMenu = true;
  Rect? slotRect;
  Size? slotSize;
  late MenuController menuController;
  GlobalKey? key;

  BNContextMenuElement([BindingContext? context]) : super(context) {
    setDefaultID(BNCONTEXTMENU);
  }

  @override
  void initState() {
    super.initState();
    menuController = MenuController();
  }

  @override
  Widget build(BuildContext context, List<Widget> children) {
    Widget? slotElement;
    List<Widget> menuChildren = [];

    final parentPadding = showMenu ? renderStyle.padding : EdgeInsets.zero;
    Size menuSize = showMenu ? Size(
      renderStyle.width.computedValue + 8,
      renderStyle.height.computedValue + 8
    ) : Size.zero;

    for (var child in children) {
      if (child is WebFHTMLElementStatefulWidget && child.webFElement is BNContextMenuItemElement) {
        if (showMenu == false) {
          continue;
        }
        final element = child.webFElement as BNContextMenuItemElement;
        element.recalculateStyle(rebuildNested: true, forceRecalculate: true);

        if (menuSize.width == 8 && menuSize.height == 8) {
          menuSize = Size(
            element.width + parentPadding.horizontal,
            element.height * (children.length - 1) + parentPadding.vertical
          );
        }

        final contentHeigh = (menuSize.height - parentPadding.vertical) / (children.length - 1);

        menuChildren.add(CustomPopupMenuItem(
          value: child.hashCode,
          child: element.content,
          padding: parentPadding,
          size: Size(menuSize.width - parentPadding.horizontal, contentHeigh),
          onPress: () {
            var box = context.findRenderObject() as RenderBox;
            Offset globalOffset = box.globalToLocal(Offset(Offset.zero.dx, Offset.zero.dy));
            double clientX = globalOffset.dx;
            double clientY = globalOffset.dy;
            Event event = MouseEvent(EVENT_CLICK, clientX: clientX, clientY: clientY, view: ownerDocument.defaultView);
            element.dispatchEvent(event);
            menuController.close();
          }
        ));

        final diver = element.divider;
        if (diver != null) {
          menuChildren.add(diver);
        }
      } else {
        slotElement = child;

        if (showMenu == true) {
          dom.Element? element;
          if (slotElement is WebFHTMLElementStatefulWidget) {
            element = slotElement.webFElement;
          } else if (slotElement is WebFWidgetElementStatefulWidget) {
            element = slotElement.widgetElement;
          }
          final boxModel = element?.renderBoxModel;
          if (boxModel?.hasSize == true) {
            slotSize = boxModel!.contentSize;
          }
        }
      }
    }

    return MenuAnchor(
      // key: key,
      controller: menuController,
      style: MenuStyle(
        backgroundColor: MaterialStatePropertyAll(renderStyle.backgroundColor?.value),
        padding: MaterialStatePropertyAll<EdgeInsetsGeometry>(renderStyle.padding),
        minimumSize: MaterialStateProperty.all<Size>(menuSize),
        shape: shape,
        alignment: alignment,
      ),
      alignmentOffset: getAlignmentOffset(menuSize, slotSize ?? Size.zero),
      builder: (BuildContext childContext, MenuController controller, Widget? child) {
        GestureTapCallback? onTapCallBack = controller.isOpen ? () {
          if (controller.isOpen) {
            controller.close();
          }
        }: null;
        return GestureDetector(
          onTap: onTapCallBack,
          onLongPress: () {
            if (showMenu == false) {
              final element = (slotElement as WebFHTMLElementStatefulWidget).webFElement.children.first;
              final boundingClientRect = Rect.fromLTRB(element.offsetLeft, element.offsetTop, element.offsetLeft + element.offsetWidth, element.offsetTop + offsetHeight);

              setState(() {
                slotRect = boundingClientRect;
                showMenu = true;
              });
              SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                menuController.open();
              });
              return;
            }
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: slotElement
        );
      },
      menuChildren: menuChildren
    );
  }
}

class BNContextMenuItemElement extends dom.Element {
  bool get hasLeadingIcon {
    return attributes.containsKey('leading-icon-url');
  }

  bool get hasTrailingIcon {
    return attributes.containsKey('trailing-icon-url');
  }

  CSSColor get color {
    if (style.getPropertyValue(COLOR) == INHERIT) {
      return CSSColor.resolveColor(INHERIT, renderStyle, COLOR) ?? renderStyle.color;
    }
    return renderStyle.color;
  }

  double get width {
    final value = style.getPropertyValue(WIDTH);
    return CSSLength.parseLength(value, renderStyle, WIDTH, Axis.horizontal).computedValue;
  }

  double get height {
    final value = style.getPropertyValue(HEIGHT);
    return CSSLength.parseLength(value, renderStyle, HEIGHT, Axis.vertical).computedValue;
  }

  TextStyle get textStyle => TextStyle(
    color: color.value,
    fontSize: renderStyle.fontSize.computedValue,
    fontWeight: renderStyle.fontWeight,
    fontFamily: renderStyle.fontFamily?.join(' '),
    height: renderStyle.lineHeight.value ?? 1.2,
    letterSpacing: renderStyle.letterSpacing?.computedValue ?? 0,
    backgroundColor: renderStyle.backgroundColor?.value,
  );

  Text get text {
    return Text(
      collectElementChildText() ?? '',
      style: textStyle,
      textAlign: renderStyle.textAlign,
    );
  }

  CustomPopupMenuDivider? get divider {
    List<BorderSide>? borderSides = renderStyle.borderSides;
    if (borderSides != null && borderSides.length == 4) {
      final bottomBorderSide = borderSides[3];
      return CustomPopupMenuDivider(
        height: bottomBorderSide.width,
        color: bottomBorderSide.color,
        indent: renderStyle.paddingLeft.computedValue,
        endIndent: renderStyle.paddingRight.computedValue,
      );
    }
    return null;
  }

  MainAxisAlignment convertToMainAxisAlignment(TextAlign alignment) {
  switch (alignment) {
      case TextAlign.left:
        return MainAxisAlignment.start;
      case TextAlign.right:
        return MainAxisAlignment.end;
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.justify:
        return MainAxisAlignment.spaceBetween;
      default:
        return MainAxisAlignment.start;
    }
  }

  BNContextMenuItemElement([BindingContext? context]) : super(context) {
    setDefaultID(BNCONTEXTMENUITEM);
  }

  Widget get content {
    final text = this.text;
    return Row(
      mainAxisAlignment: hasLeadingIcon || hasTrailingIcon ? MainAxisAlignment.spaceBetween : convertToMainAxisAlignment(text.textAlign!),
      children: <Widget>[
        text,
      ]
    );
  }
}


class CustomPopupMenuItem extends PopupMenuEntry<int> {
   @override
  final Key? key;

  final int value;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Size size;

  final GestureLongPressCallback? onPress;

  CustomPopupMenuItem({
    this.key,
    required this.value,
    required this.child,
    required this.padding,
    required this.size,
    required this.onPress
  }) : super(key: key);

  @override
  double get height => size.height + padding.vertical;

  @override
  bool represents(int? value) => this.value == value;

  @override
  State createState() => _CustomPopupMenuItemState();
}

class _CustomPopupMenuItemState extends State<CustomPopupMenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () {
        widget.onPress?.call();
      },
      child: Container(
        constraints: BoxConstraints(
          minWidth: widget.size.width,
          minHeight: widget.size.height,
        ),
        alignment: Alignment.center,
        // padding: widget.padding,
        child: widget.child
      ),
    );
  }
}


class CustomPopupMenuDivider extends PopupMenuEntry<void> {
  @override
  final Key? key;
  // @override
  final double height;
  final Color color;
  final double? indent;
  final double? endIndent;

  const CustomPopupMenuDivider({
    this.key,
    this.height = kMinInteractiveDimension,
    this.color = Colors.grey,
    this.indent,
    this.endIndent,
  }) : super(key: key);

  @override
  bool represents(void value) => false;

  @override
  _PopupMenuDividerState createState() => _PopupMenuDividerState();
}

class _PopupMenuDividerState extends State<CustomPopupMenuDivider> {
  @override
  Widget build(BuildContext context) {
    return Divider(height: widget.height, color: widget.color);
  }
}
