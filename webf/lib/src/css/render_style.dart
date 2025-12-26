/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/html.dart';
import 'package:webf/rendering.dart';
import 'package:webf/foundation.dart';
import 'package:webf/widget.dart';
import 'package:webf/src/css/css_animation.dart';


typedef RenderStyleVisitor<T extends RenderObject> = void Function(T renderObject);

class AdapterUpdateReason {}

class WebFInitReason extends AdapterUpdateReason {}

class RenderViewportBoxAttachedReason extends AdapterUpdateReason {}

class DocumentElementChangedReason extends AdapterUpdateReason {}

class ControllerDisposeChangeReason extends AdapterUpdateReason {}

class UpdateDisplayReason extends AdapterUpdateReason {}

class UpdateTransformReason extends AdapterUpdateReason {}

class UpdateChildNodeUpdateReason extends AdapterUpdateReason {}

class UpdateRenderReplacedUpdateReason extends AdapterUpdateReason {}

class ToRepaintBoundaryUpdateReason extends AdapterUpdateReason {}

class AddEventUpdateReason extends AdapterUpdateReason {}

class AddScrollerUpdateReason extends AdapterUpdateReason {}

class ToPositionPlaceHolderUpdateReason extends AdapterUpdateReason {
  Element positionedElement;
  Element containingBlockElement;

  ToPositionPlaceHolderUpdateReason({required this.positionedElement, required this.containingBlockElement});
}

class AttachPositionedChild extends AdapterUpdateReason {
  Element positionedElement;
  Element containingBlockElement;

  AttachPositionedChild({required this.positionedElement, required this.containingBlockElement});
}

class ToStaticLayoutUpdateReason extends AdapterUpdateReason {}

class RemovePositionedChild extends AdapterUpdateReason {
  Element positionedElement;

  RemovePositionedChild(this.positionedElement);
}

typedef SomeRenderBoxModelHandlerCallback = bool Function(RenderBoxModel renderBoxModel);
typedef EveryRenderBoxModelHandlerCallback = bool Function(flutter.Element?, RenderBoxModel renderBoxModel);
typedef RenderObjectMatchers = dynamic Function(RenderObject? renderObject, RenderStyle? renderStyle);
typedef RenderBoxModelMatcher = bool Function(RenderBoxModel renderBoxModel, RenderStyle renderStyle);
typedef RenderStyleMatcher = bool Function(RenderStyle renderStyle);
typedef RenderStyleValueGetter = dynamic Function(RenderStyle renderStyle);
typedef RenderBoxModelGetter = dynamic Function(RenderBoxModel renderBoxModel, RenderStyle renderStyle);

enum RenderObjectGetType { self, parent, firstChild, lastChild, previousSibling, nextSibling }

/// The abstract class for render-style, declare the
/// getter interface for all available CSS rule.
abstract class RenderStyle extends DiagnosticableTree with Diagnosticable {
  @override
  String toStringShort() {
    return '${describeIdentity(this)} target: $target';
  }

  // Common
  Element get target;

  TextScaler get textScaler => target.ownerDocument.controller.textScaler;

  bool get boldText => target.ownerDocument.controller.boldText;

  @pragma('vm:prefer-inline')
  RenderStyle? get parent => target.parentElement?.renderStyle;

  dynamic getProperty(String key);

  /// Resolve the style value.
  dynamic resolveValue(String property, String present);

  // CSSVariable
  dynamic getCSSVariable(String identifier, String propertyName);

  void setCSSVariable(String identifier, String value);

  void resetBoxDecoration();

  // Geometry
  CSSLengthValue get top;

  CSSLengthValue get right;

  CSSLengthValue get bottom;

  CSSLengthValue get left;

  int? get zIndex;

  CSSLengthValue get width;

  CSSLengthValue get height;

  CSSLengthValue get minWidth;

  CSSLengthValue get minHeight;

  CSSLengthValue get maxWidth;

  CSSLengthValue get maxHeight;

  EdgeInsets get margin;

  CSSLengthValue get marginLeft;

  CSSLengthValue get marginRight;

  CSSLengthValue get marginTop;

  CSSLengthValue get marginBottom;

  EdgeInsets get padding;

  CSSLengthValue get paddingLeft;

  CSSLengthValue get paddingRight;

  CSSLengthValue get paddingBottom;

  CSSLengthValue get paddingTop;

  // Border
  EdgeInsets get border;

  CSSLengthValue? get borderTopWidth;

  CSSLengthValue? get borderRightWidth;

  CSSLengthValue? get borderBottomWidth;

  CSSLengthValue? get borderLeftWidth;

  CSSBorderStyleType get borderLeftStyle;

  CSSBorderStyleType get borderRightStyle;

  CSSBorderStyleType get borderTopStyle;

  CSSBorderStyleType get borderBottomStyle;

  CSSLengthValue get effectiveBorderLeftWidth;

  CSSLengthValue get effectiveBorderRightWidth;

  CSSLengthValue get effectiveBorderTopWidth;

  CSSLengthValue get effectiveBorderBottomWidth;

  double get contentMaxConstraintsWidth;

  CSSColor get borderLeftColor;

  CSSColor get borderRightColor;

  CSSColor get borderTopColor;

  CSSColor get borderBottomColor;

  List<Radius>? get borderRadius;

  CSSBorderRadius get borderTopLeftRadius;

  CSSBorderRadius get borderTopRightRadius;

  CSSBorderRadius get borderBottomRightRadius;

  CSSBorderRadius get borderBottomLeftRadius;

  List<BorderSide>? get borderSides;

  List<WebFBoxShadow>? get shadows;

  List<CSSBoxShadow>? get filterDropShadows;

  // Decorations
  CSSColor? get backgroundColor;

  CSSBackgroundImage? get backgroundImage;

  CSSBackgroundRepeatType get backgroundRepeat;

  CSSBackgroundPosition get backgroundPositionX;

  CSSBackgroundPosition get backgroundPositionY;

  CSSBackgroundSize get backgroundSize;

  CSSBackgroundAttachmentType? get backgroundAttachment;

  CSSBackgroundBoundary? get backgroundClip;

  CSSBackgroundBoundary? get backgroundOrigin;

  // Text
  CSSLengthValue get fontSize;

  FontWeight get fontWeight;

  FontStyle get fontStyle;

  String get fontVariant;

  List<String>? get fontFamily;

  List<Shadow>? get textShadow;

  WhiteSpace get whiteSpace;

  TextOverflow get textOverflow;

  TextAlign get textAlign;

  TextDirection get direction;

  // CSS word-break (inherited)
  WordBreak get wordBreak;

  int? get lineClamp;

  CSSLengthValue get lineHeight;

  CSSLengthValue? get letterSpacing;

  CSSLengthValue? get wordSpacing;

  // input
  Color? get caretColor;

  // BoxModel
  double? get borderBoxLogicalWidth;

  double? get borderBoxLogicalHeight;

  double? get borderBoxWidth;

  double? get borderBoxHeight;

  double? get paddingBoxLogicalWidth;

  double? get paddingBoxLogicalHeight;

  double? get paddingBoxWidth;

  double? get paddingBoxHeight;

  double? get contentBoxLogicalWidth;

  double? get contentBoxLogicalHeight;

  double? get contentBoxWidth;

  double? get contentBoxHeight;

  CSSPositionType get position;

  CSSDisplay get display;

  CSSDisplay get effectiveDisplay;

  Alignment get objectPosition;

  CSSOverflowType get overflowX;

  CSSOverflowType get overflowY;

  CSSOverflowType get effectiveOverflowX;

  CSSOverflowType get effectiveOverflowY;

  double get intrinsicWidth;

  double get intrinsicHeight;

  double? get aspectRatio;

  // Flex
  FlexDirection get flexDirection;

  FlexWrap get flexWrap;

  JustifyContent get justifyContent;
  GridAxisAlignment get justifyItems;
  GridAxisAlignment get justifySelf;

  AlignItems get alignItems;

  AlignContent get alignContent;

  AlignSelf get alignSelf;

  CSSLengthValue? get flexBasis;

  double get flexGrow;

  double get flexShrink;

  int get order;

  // Gap
  CSSLengthValue get gap;

  CSSLengthValue get rowGap;

  CSSLengthValue get columnGap;

  // Grid
  GridAutoFlow get gridAutoFlow;

  List<GridTrackSize> get gridAutoRows;

  List<GridTrackSize> get gridAutoColumns;

  List<GridTrackSize> get gridTemplateRows;

  List<GridTrackSize> get gridTemplateColumns;

  GridTemplateAreasDefinition? get gridTemplateAreasDefinition;

  GridPlacement get gridRowStart;

  GridPlacement get gridRowEnd;

  GridPlacement get gridColumnStart;

  GridPlacement get gridColumnEnd;

  String? get gridAreaName;

  // Color
  CSSColor get color;

  CSSColor get currentColor;

  // Filter
  ColorFilter? get colorFilter;

  ImageFilter? get imageFilter;

  List<CSSFunctionalNotation>? get filter;

  // Misc
  double get opacity;

  Visibility get visibility;

  ContentVisibility get contentVisibility;

  VerticalAlign get verticalAlign;

  BoxFit get objectFit;

  bool get isHeightStretch;

  // Transition
  List<String> get transitionProperty;

  List<String> get transitionDuration;

  List<String> get transitionTimingFunction;

  List<String> get transitionDelay;

  // Sliver
  Axis get sliverDirection;

  // Animation
  List<String> get animationName;

  List<String> get animationDuration;

  List<String> get animationTimingFunction;

  List<String> get animationDelay;

  List<String> get animationIterationCount;

  List<String> get animationDirection;

  List<String> get animationFillMode;

  List<String> get animationPlayState;

  // transform
  List<CSSFunctionalNotation>? get transform;

  Matrix4? get effectiveTransformMatrix;

  CSSOrigin get transformOrigin;

  double get effectiveTransformScale;

  void addFontRelativeProperty(String propertyName);

  void addRootFontRelativeProperty(String propertyName);

  void addColorRelativeProperty(String propertyName);

  void addViewportSizeRelativeProperty();

  void cleanContentBoxLogiclWidth();

  void cleanContentBoxLogiclHeight();

  double getWidthByAspectRatio();

  double getHeightByAspectRatio();

  final Map<flutter.RenderObjectElement, RenderBoxModel> _widgetRenderObjects = {};

  Map<flutter.RenderObjectElement, RenderBoxModel> get widgetRenderObjects => _widgetRenderObjects;

  Iterable<RenderBoxModel> get widgetRenderObjectIterator => _widgetRenderObjects.values;

  // For some style changes, we needs to upgrade
  void requestWidgetToRebuild(AdapterUpdateReason reason) {
    switch (reason) {
      case AddEventUpdateReason _:
        target.hasEvent = true;
        break;
      case AddScrollerUpdateReason _:
        target.hasScroll = true;
        break;
      case ToPositionPlaceHolderUpdateReason r:
        target.holderAttachedPositionedElement = r.positionedElement;
        target.holderAttachedContainingBlockElement = r.containingBlockElement;
        break;
      case ToStaticLayoutUpdateReason _:
        target.holderAttachedPositionedElement = null;
        target.holderAttachedContainingBlockElement = null;
        break;
      case AttachPositionedChild r:
        target.addOutOfFlowPositionedElement(r.positionedElement);
        break;
      default:
        break;
    }

    for (var element in _widgetRenderObjects.keys) {
      if (element is WebRenderLayoutRenderObjectElement) {
        element.requestForBuild(reason);
      } else if (element is RenderWidgetElement) {
        element.requestForBuild(reason);
      } else if (element is WebFRenderReplacedRenderObjectElement) {
        element.requestForBuild(reason);
      }
    }
  }

  bool someRenderBoxSatisfy(SomeRenderBoxModelHandlerCallback callback) {
    for (var renderBoxModel in widgetRenderObjectIterator) {
      if (renderBoxModel.attached) {
        bool success = callback(renderBoxModel);
        if (success) {
          return success;
        }
      }
    }

    return false;
  }

  @pragma('vm:prefer-inline')
  bool isDocumentRootBox() {
    return attachedRenderBoxModel?.isDocumentRootBox == true;
  }

  @pragma('vm:prefer-inline')
  bool isParentDocumentRootBox() {
    if (attachedRenderBoxModel?.parent is! RenderBoxModel) return false;
    return (attachedRenderBoxModel!.parent as RenderBoxModel).isDocumentRootBox;
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderViewportBox() {
    return attachedRenderBoxModel?.parent is RootRenderViewportBox ||
        attachedRenderBoxModel?.parent is RouterViewViewportBox;
  }

  @pragma('vm:prefer-inline')
  bool hasRenderBox() {
    return _widgetRenderObjects.isNotEmpty;
  }

  RenderBoxModel? getSelfRenderBox(flutter.RenderObjectElement? flutterWidgetElement) {
    return _widgetRenderObjects[flutterWidgetElement];
  }

  @pragma('vm:prefer-inline')
  bool isSelfParentDataAreRenderLayoutParentData() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject?.parentData is RenderLayoutParentData);
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderBoxModel() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.parent, (renderObject, _) => renderObject is RenderBoxModel);
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderLayoutBox() {
    return getAttachedRenderParentRenderStyle()?.isSelfRenderLayoutBox() == true;
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderFlexLayout() {
    return getAttachedRenderParentRenderStyle()?.isSelfRenderFlexLayout() == true;
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderGridLayout() {
    return getAttachedRenderParentRenderStyle()?.isSelfRenderGridLayout() == true;
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderFlowLayout() {
    return getAttachedRenderParentRenderStyle()?.isSelfRenderFlowLayout() == true;
  }

  @pragma('vm:prefer-inline')
  bool isLayoutBox() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderLayoutBox);
  }

  @pragma('vm:prefer-inline')
  bool isBoxModel() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderBoxModel);
  }

  @pragma('vm:prefer-inline')
  bool isNextSiblingAreRenderObject() {
    return target.attachedRenderNextSibling?.attachedRenderer is RenderObject;
  }

  @pragma('vm:prefer-inline')
  bool isPreviousSiblingAreRenderObject() {
    return target.attachedRenderPreviousSibling?.attachedRenderer is RenderObject;
  }

  // DOM-scanning helpers removed; sibling relationships are derived from attached render siblings.

  @pragma('vm:prefer-inline')
  bool isFirstChildAreRenderFlowLayoutBox() {
    return target.firstAttachedRenderChild?.attachedRenderer is RenderLayoutBox;
  }

  @pragma('vm:prefer-inline')
  bool isLastChildAreRenderLayoutBox() {
    return target.lastAttachedRenderChild?.attachedRenderer is RenderLayoutBox;
  }

  @pragma('vm:prefer-inline')
  bool isFirstChildAreRenderBoxModel() {
    return target.firstAttachedRenderChild?.attachedRenderer is RenderBoxModel;
  }

  @pragma('vm:prefer-inline')
  bool isLastChildAreRenderBoxModel() {
    return target.lastAttachedRenderChild?.attachedRenderer is RenderBoxModel;
  }

  @pragma('vm:prefer-inline')
  bool isFirstChildStyleMatch(RenderStyleMatcher matcher) {
    Node? firstAttachedChild = target.firstAttachedRenderChild;
    if (firstAttachedChild is Element) {
      return matcher(firstAttachedChild.renderStyle);
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  bool isLastChildStyleMatch(RenderStyleMatcher matcher) {
    Node? lastAttachedChild = target.lastAttachedRenderChild;
    if (lastAttachedChild is Element) {
      return matcher(lastAttachedChild.renderStyle);
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  bool isPreviousSiblingStyleMatch(RenderStyleMatcher matcher) {
    Node? previousSibling = target.attachedRenderPreviousSibling;
    if (previousSibling is Element) {
      return matcher(previousSibling.renderStyle);
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  bool isBoxModelHaveSize() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (boxModel, _) => boxModel is RenderBoxModel && boxModel.hasSize);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderBoxAttachedToSegmentTree() {
    return someRenderBoxSatisfy((boxModel) => boxModel.parent != null);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderBoxAttached() {
    return someRenderBoxSatisfy((boxModel) => boxModel.attached == true);
  }

  @pragma('vm:prefer-inline')
  bool isSelfScrollingContainer() {
    return (overflowX == CSSOverflowType.scroll || overflowX == CSSOverflowType.auto) ||
        (overflowY == CSSOverflowType.scroll || overflowY == CSSOverflowType.auto);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderFlexLayout() {
    return everyAttachedRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderFlexLayout);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderGridLayout() {
    return everyAttachedRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderGridLayout);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderFlowLayout() {
    return everyAttachedRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderFlowLayout);
  }

  @pragma('vm:prefer-inline')
  bool isSelfAnonymousFlowLayout() {
    return everyAttachedRenderObjectByTypeAndMatch(RenderObjectGetType.self,
        (renderObject, _) => renderObject is RenderBoxModel && renderObject.renderStyle.target.tagName == 'Anonymous');
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderReplaced() {
    return everyAttachedRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderReplaced);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderWidget() {
    return everyAttachedRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderWidget);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderLayoutBox() {
    return everyAttachedRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderLayoutBox);
  }

  @pragma('vm:prefer-inline')
  bool isSelfContainsRenderPositionPlaceHolder() {
    return attachedRenderBoxModel?.renderPositionPlaceholder != null;
  }

  @pragma('vm:prefer-inline')
  bool isPositionHolderParentIsRenderFlexLayout() {
    return attachedRenderBoxModel?.renderPositionPlaceholder?.parent is RenderFlexLayout;
  }

  @pragma('vm:prefer-inline')
  bool isPositionHolderParentIsRenderLayoutBox() {
    return attachedRenderBoxModel?.renderPositionPlaceholder?.parent is RenderLayoutBox;
  }

  @pragma('vm:prefer-inline')
  bool isSelfPositioned() {
    return position == CSSPositionType.absolute || position == CSSPositionType.fixed;
  }

  @pragma('vm:prefer-inline')
  bool isSelfStickyPosition() {
    return position == CSSPositionType.sticky;
  }

  @pragma('vm:prefer-inline')
  bool isSelfHTMLElement() {
    return target is HTMLElement;
  }

  @pragma('vm:prefer-inline')
  bool isSelfRouterLinkElement() {
    return target is RouterLinkElement;
  }

  @pragma('vm:prefer-inline')
  bool isSelfNeedsRelayout() {
    return someRenderBoxSatisfy((renderObject) => renderObject.needsRelayout);
  }

  @pragma('vm:prefer-inline')
  bool isSelfBoxModelMatch(RenderBoxModelMatcher matcher) {
    if (attachedRenderBoxModel != null) {
      return matcher(attachedRenderBoxModel!, attachedRenderBoxModel!.renderStyle);
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  bool isSelfBoxModelSizeTight() {
    return attachedRenderBoxModel?.isSizeTight == true;
  }

  @pragma('vm:prefer-inline')
  bool isParentBoxModelMatch(RenderBoxModelMatcher matcher) {
    RenderBoxModel? selfRender = attachedRenderBoxModel;
    if (selfRender == null) return false;
    if (selfRender is RenderEventListener && selfRender.parent is RenderBoxModel) {
      return matcher(selfRender.parent as RenderBoxModel, selfRender.renderStyle);
    }

    if (selfRender.parent is RenderEventListener) {
      selfRender = selfRender.parent as RenderBoxModel;
    }

    if (selfRender.parent is! RenderBoxModel) return false;

    return matcher(selfRender.parent as RenderBoxModel, (selfRender.parent as RenderBoxModel).renderStyle);
  }

  RenderViewportBox? getCurrentViewportBox() {
    flutter.RenderObject? current = attachedRenderBoxModel;
    while (current != null) {
      if (current is RenderViewportBox) {
        return current;
      }

      current = current.parent;
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  dynamic getSelfRenderBoxValue(RenderBoxModelGetter getter) {
    return getRenderBoxValueByType(RenderObjectGetType.self, getter);
  }

  @pragma('vm:prefer-inline')
  T? getSelfRenderStyle<T extends RenderStyle>() {
    return getRenderBoxValueByType(RenderObjectGetType.self, (_, renderStyle) => renderStyle) as T?;
  }

  @pragma('vm:prefer-inline')
  RenderPositionPlaceholder? getSelfPositionPlaceHolder() {
    return getSelfRenderBoxValue((renderBoxModel, renderStyle) {
      if (renderBoxModel is RenderLayoutBoxWrapper) {
        return renderStyle.target.attachedRenderer!.renderPositionPlaceholder;
      }

      return renderBoxModel.renderPositionPlaceholder;
    });
  }

  @pragma('vm:prefer-inline')
  T? getFirstChildRenderStyle<T extends RenderStyle>() {
    Node? firstChild = target.firstAttachedRenderChild;
    if (firstChild is Element) {
      return firstChild.renderStyle as T;
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  T? getLastChildRenderStyle<T extends RenderStyle>() {
    Node? lastChild = target.lastAttachedRenderChild;
    if (lastChild is Element) {
      return lastChild.renderStyle as T;
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  T? getPreviousSiblingRenderStyle<T extends RenderStyle>() {
    Node? previousSibling = target.attachedRenderPreviousSibling;
    if (previousSibling is Element) {
      return previousSibling.renderStyle as T;
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  T? getNextSiblingRenderStyle<T extends RenderStyle>() {
    Node? nextSibling = target.attachedRenderNextSibling;
    if (nextSibling is Element) {
      return nextSibling.renderStyle as T;
    }
    return null;
  }

  @pragma('vm:prefer-inline')
  T? getAttachedRenderParentRenderStyle<T extends RenderStyle>() {
    return getRenderBoxValueByType(RenderObjectGetType.parent, (_, renderStyle) => renderStyle) as T? ??
        target.parentElement?.renderStyle as T?;
  }

  @pragma('vm:prefer-inline')
  double? clientHeight() {
    return getSelfRenderBoxValue((renderBoxModel, _) => renderBoxModel.clientHeight);
  }

  @pragma('vm:prefer-inline')
  double? clientWidth() {
    return getSelfRenderBoxValue((renderBoxModel, _) => renderBoxModel.clientWidth);
  }

  // Get the offset of current element relative to specified ancestor element.
  // Per CSSOM View, offsetLeft/offsetTop are measured from the padding edge of
  // the offsetParent (its inner border edge). Therefore, when converting a
  // descendant’s position to the ancestor’s coordinate space we must subtract
  // the ancestor’s border so the result is relative to the padding edge.
  // This applies even when the ancestor is a RenderLayoutBoxWrapper for
  // scroll containers, since the wrapper shares the same RenderStyle (and thus
  // border metrics) as the scrolling element.
  Offset getOffset({RenderBoxModel? ancestorRenderBox, bool excludeScrollOffset = false}) {
    // Returns (0, 0) when ancestor is null.
    if (ancestorRenderBox == null) {
      return Offset.zero;
    }

    return getSelfRenderBoxValue((renderBoxModel, _) {
      // Always subtract ancestor border so the offset is from the padding edge.
      const bool excludeAncestorBorder = true;
      return renderBoxModel.getOffsetToAncestor(
        Offset.zero,
        ancestorRenderBox,
        excludeScrollOffset: excludeScrollOffset,
        excludeAncestorBorderTop: excludeAncestorBorder,
      );
    });
  }

  Future<Image> toImage(double pixelRatio) async {
    for (final renderObject in widgetRenderObjectIterator) {
      try {
        return await renderObject.toImage(pixelRatio: pixelRatio);
      } catch (_) {
        continue;
      }
    }
    throw FlutterError('Can not export images from $this');
  }

  @pragma('vm:prefer-inline')
  Size? scrollableSize() {
    return getSelfRenderBoxValue((renderBoxModel, _) => renderBoxModel.scrollableSize);
  }

  @pragma('vm:prefer-inline')
  BoxConstraints constraints() {
    return getRenderBoxValueByType(RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.constraints);
  }

  @pragma('vm:prefer-inline')
  BoxConstraints? contentConstraints() {
    return getRenderBoxValueByType(RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.contentConstraints);
  }

  @pragma('vm:prefer-inline')
  Size? boxSize() {
    return getRenderBoxValueByType(RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.boxSize);
  }

  @pragma('vm:prefer-inline')
  BoxSizeType widthSizeType() {
    return getRenderBoxValueByType(RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.widthSizeType);
  }

  @pragma('vm:prefer-inline')
  BoxSizeType heightSizeType() {
    return getRenderBoxValueByType(RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.heightSizeType);
  }

  @pragma('vm:prefer-inline')
  bool isRepaintBoundary() {
    return getRenderBoxValueByType(RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.isRepaintBoundary) ??
        false;
  }

  @pragma('vm:prefer-inline')
  Offset localToGlobal(Offset point, {RenderObject? ancestor}) {
    return getRenderBoxValueByType(
        RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.localToGlobal(point, ancestor: ancestor));
  }

  @pragma('vm:prefer-inline')
  void clearIntersectionChangeListeners([flutter.RenderObjectElement? flutterWidgetElement]) {
    RenderBoxModel? widgetRenderBox = _widgetRenderObjects[flutterWidgetElement];
    widgetRenderBox?.clearIntersectionChangeListeners();
  }

  @pragma('vm:prefer-inline')
  void markNeedsLayout() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.markNeedsLayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markNeedsRelayout() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.markNeedsRelayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markNeedsBuild() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      element!.markNeedsBuild();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markParentNeedsLayout() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.parent?.markNeedsLayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markPositionHolderParentNeedsLayout() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.renderPositionPlaceholder?.parent?.markNeedsLayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markNeedsPaint() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.markNeedsPaint();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markParentNeedsRelayout() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.markParentNeedsRelayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markChildrenNeedsSort() {
    everyAttachedWidgetRenderBox((_, renderBoxModel) {
      if (renderBoxModel is RenderLayoutBox) {
        renderBoxModel.markChildrenNeedsSort();
      } else if (renderBoxModel is RenderWidget) {
        renderBoxModel.markChildrenNeedsSort();
      }

      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void addIntersectionChangeListener(IntersectionChangeCallback entryCallback, List<double> thresholds) {
    everyWidgetRenderBox((_, renderBoxModel) {
      renderBoxModel.addIntersectionChangeListener(entryCallback, thresholds);
      if (renderBoxModel.attached) {
        renderBoxModel.markNeedsCompositingBitsUpdate();
        renderBoxModel.markNeedsPaint();
      }
      return true;
    });
  }

  void removeIntersectionChangeListener(IntersectionChangeCallback entryCallback) {
    everyWidgetRenderBox((_, renderBoxModel) {
      renderBoxModel.removeIntersectionChangeListener(entryCallback);
      if (renderBoxModel.attached) {
        renderBoxModel.markNeedsCompositingBitsUpdate();
      }
      return true;
    });
  }

  // Sizing may affect parent size, mark parent as needsLayout in case
  // renderBoxModel has tight constraints which will prevent parent from marking.
  @pragma('vm:prefer-inline')
  void markSelfAndParentBoxModelNeedsLayout() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.markNeedsLayout();

      if (renderObject.parent is RenderBoxModel) {
        renderObject.parent!.markNeedsLayout();
      }

      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markNeedsCompositingBitsUpdate() {
    everyAttachedWidgetRenderBox((element, renderObject) {
      renderObject.markNeedsCompositingBitsUpdate();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markParentNeedsSort() {
    getAttachedRenderParentRenderStyle()?.markChildrenNeedsSort();
  }

  // Whether this element itself establishes a stacking context.
  // Follows MDN/Specs triggers:
  // - Root element (<html>)
  // - position: fixed | sticky
  // - position: absolute|relative with z-index != auto
  // - flex item with z-index != auto
  // - opacity < 1
  // - transform != none
  // - filter != none
  bool get establishesStackingContext {
    // Root element of the document
    if (isDocumentRootBox()) return true;

    // Fixed or sticky always establish a stacking context
    if (position == CSSPositionType.fixed || position == CSSPositionType.sticky) return true;

    // Positioned with non-auto z-index
    if ((position == CSSPositionType.absolute || position == CSSPositionType.relative) && zIndex != null) {
      return true;
    }

    // Flex or Grid items with non-auto z-index
    final CSSRenderStyle? parent = getAttachedRenderParentRenderStyle();
    if (parent != null &&
        ((parent.display == CSSDisplay.flex || parent.display == CSSDisplay.inlineFlex) ||
            (parent.display == CSSDisplay.grid || parent.display == CSSDisplay.inlineGrid)) &&
        zIndex != null) {
      return true;
    }

    // Compositing triggers
    if (opacity < 1.0) return true;
    if (transform != null) return true;
    if (filter != null) return true;

    return false;
  }

  // Whether this element or any descendant needs stacking participation.
  // Used as a coarse optimization to mark parents for sorting.
  bool get needsStacking {
    if (establishesStackingContext) return true;
    Node? child = target.firstChild;
    while (child != null) {
      if (child is Element && child.renderStyle.needsStacking) return true;
      child = child.nextSibling;
    }
    return false;
  }

  void ensureEventResponderBound() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is! RenderBoxModel) return true;
      // Must bind event responder on render box model whatever there is no event listener.

      if (target.hasIntersectionObserverEvent()) {
        renderObject.addIntersectionChangeListener(target.handleIntersectionChange);
        // Mark the compositing state for this render object as dirty
        // cause it will create new layer.
        renderObject.markNeedsCompositingBitsUpdate();
      } else {
        // Remove listener when no intersection related event
        renderObject.removeIntersectionChangeListener(target.handleIntersectionChange);
      }
      if (target.hasResizeObserverEvent()) {
        renderObject.addResizeListener(target.handleResizeChange);
      } else {
        renderObject.removeResizeListener(target.handleResizeChange);
      }

      return true;
    });
  }

  dynamic getRenderBoxValueByType(RenderObjectGetType getType, RenderBoxModelGetter getter) {
    RenderBoxModel? widgetRenderBoxModel =
    widgetRenderObjectIterator.firstWhereOrNull((renderBox) => renderBox.attached);

    if (widgetRenderBoxModel == null) return null;

    return _renderObjectMatchFn(widgetRenderBoxModel, getType, (renderObject, renderStyle) {
      if (renderObject is RenderBoxModel && renderStyle != null) {
        return getter(renderObject, renderStyle);
      }
      return null;
    });
  }

  dynamic _renderObjectMatchFn(
      RenderBoxModel renderBoxModel,
      RenderObjectGetType getType,
      RenderObjectMatchers matcher,
      ) {
    switch (getType) {
      case RenderObjectGetType.self:
        return matcher(renderBoxModel, renderBoxModel.renderStyle);

      case RenderObjectGetType.parent:
        final directParent = renderBoxModel.parent;
        RenderObject? parent = directParent;
        while (parent is RenderEventListener ||
            parent is RenderLayoutBoxWrapper ||
            (parent is RenderFlowLayout && parent.renderStyle == this)) {
          parent = parent!.parent;
        }
        return matcher(directParent, parent is RenderBoxModel ? parent.renderStyle : null);

      case RenderObjectGetType.firstChild:
        if (renderBoxModel is RenderLayoutBox) {
          final firstChild = renderBoxModel.firstChild;
          return matcher(firstChild, firstChild is RenderBoxModel ? firstChild.renderStyle : null);
        }
        return false;

      case RenderObjectGetType.lastChild:
        if (renderBoxModel is RenderLayoutBox) {
          final lastChild = renderBoxModel.lastChild;
          return matcher(lastChild, lastChild is RenderBoxModel ? lastChild.renderStyle : null);
        }
        return false;

      case RenderObjectGetType.previousSibling:
        final pd = renderBoxModel.parentData;
        if (pd is RenderLayoutParentData) {
          final prev = pd.previousSibling;
          return matcher(prev, prev is RenderBoxModel ? prev.renderStyle : null);
        }
        return false;

      case RenderObjectGetType.nextSibling:
        final pd = renderBoxModel.parentData;
        if (pd is RenderLayoutParentData) {
          final next = pd.nextSibling;
          return matcher(next, next is RenderBoxModel ? next.renderStyle : null);
        }
        return false;
    }
  }

  bool everyRenderObjectByTypeAndMatch(RenderObjectGetType getType, RenderObjectMatchers matcher) {
    return everyWidgetRenderBox((_, renderBoxModel) {
      return _renderObjectMatchFn(renderBoxModel, getType, matcher);
    });
  }

  bool everyAttachedRenderObjectByTypeAndMatch(RenderObjectGetType getType, RenderObjectMatchers matcher) {
    return everyAttachedWidgetRenderBox((_, renderBoxModel) {
      return _renderObjectMatchFn(renderBoxModel, getType, matcher);
    });
  }

  bool everyRenderBox(EveryRenderBoxModelHandlerCallback callback) {
    bool hasMatch = everyWidgetRenderBox(callback);
    if (!hasMatch) {
      return false;
    }
    return true;
  }

  bool everyWidgetRenderBox(EveryRenderBoxModelHandlerCallback callback) {
    if (_widgetRenderObjects.isEmpty) return false;

    for (var entry in _widgetRenderObjects.entries) {
      bool result = callback(entry.key, entry.value);
      if (!result) return false;
    }

    return true;
  }

  bool everyAttachedWidgetRenderBox(EveryRenderBoxModelHandlerCallback callback) {
    for (final entry in _widgetRenderObjects.entries) {
      final ro = entry.value;
      if (ro.attached && !callback(entry.key, ro)) {
        return false;
      }
    }
    return true;
  }

  void removeRenderObject(flutter.Element? flutterWidgetElement) {
    if (flutterWidgetElement != null) {
      unmountWidgetRenderObject(flutterWidgetElement);
    }
  }

  void removeAllRenderObject() {
    _widgetRenderObjects.clear();
  }

  void setDebugShouldPaintOverlay(bool value) {
    getSelfRenderBoxValue((renderBoxModel, _) {
      renderBoxModel.debugShouldPaintOverlay = value;
      return null;
    });
  }

  void addOrUpdateWidgetRenderObjects(
      flutter.RenderObjectElement ownerRenderObjectElement, RenderBoxModel targetRenderBoxModel) {
    _widgetRenderObjects[ownerRenderObjectElement] = targetRenderBoxModel;
  }

  void unmountWidgetRenderObject(flutter.Element ownerRenderObjectElement) {
    _widgetRenderObjects.remove(ownerRenderObjectElement);
  }

  RenderBoxModel? getWidgetPairedRenderBoxModel(flutter.Element targetRenderObjectElement) {
    return _widgetRenderObjects[targetRenderObjectElement];
  }

  RenderBoxModel? get attachedRenderBoxModel {
    return _widgetRenderObjects.values.firstWhereOrNull((renderBox) => renderBox.attached);
  }

  flutter.RenderObjectElement? get attachedRenderObjectElement {
    return _widgetRenderObjects.entries.firstWhereOrNull((entry) => entry.value.attached)?.key;
  }

  Size get viewportSize => target.ownerDocument.viewport?.viewportSize ?? Size.zero;

  FlutterView get currentFlutterView => target.ownerDocument.controller.ownerFlutterView!;

  double get rootFontSize => target.ownerDocument.documentElement!.renderStyle.fontSize.computedValue;

  void visitChildren(RenderObjectVisitor visitor) {
    // The renderObjects rendered by RouterLinkElement is not as an child in RenderWidget
    // We needs delegate to DOM elements to indicate the roots
    if (target is RouterLinkElement) {
      for (var element in target.children) {
        element.renderStyle.visitChildren(visitor);
      }
      return;
    }

    everyAttachedWidgetRenderBox((_, renderBoxMode) {
      if (renderBoxMode is RenderEventListener) {
        renderBoxMode.child?.visitChildren(visitor);
      } else {
        renderBoxMode.visitChildren(visitor);
      }
      return true;
    });
    return;
  }

  void dispose() {
    _widgetRenderObjects.clear();
  }
}

class CSSRenderStyle extends RenderStyle
    with
        CSSWritingModeMixin,
        CSSSizingMixin,
        CSSPaddingMixin,
        CSSBorderMixin,
        CSSBorderRadiusMixin,
        CSSMarginMixin,
        CSSBackgroundMixin,
        CSSBoxShadowMixin,
        CSSBoxMixin,
        CSSTextMixin,
        CSSInputMixin,
        CSSPositionMixin,
        CSSTransformMixin,
        CSSVisibilityMixin,
        CSSContentVisibilityMixin,
        CSSGridMixin,
        CSSFlexboxMixin,
        CSSOrderMixin,
        CSSGapMixin,
        CSSDisplayMixin,
        CSSInlineMixin,
        CSSObjectFitMixin,
        CSSObjectPositionMixin,
        CSSSliverMixin,
        CSSOverflowMixin,
        CSSFilterEffectsMixin,
        CSSOpacityMixin,
        CSSTransitionMixin,
        CSSVariableMixin,
        CSSAnimationMixin {
  CSSRenderStyle({required this.target});

  // Transient flag for painting: when true on a container, its local painting
  // order computation will suppress direct children (or deeper descendants) that
  // are stacking context roots with positive z-index. Those participants are
  // expected to be promoted and painted by an ancestor stacking context to
  // satisfy cross-parent z-index ordering. This flag is only mutated during a
  // paint pass and should not be persisted.
  bool suppressPositiveStackingFromDescendants = false;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('position', position));
    properties.add(DiagnosticsProperty('backgroundColor', backgroundColor?.value));
    properties.add(DiagnosticsProperty('effectiveDisplay', effectiveDisplay));
    properties.add(DiagnosticsProperty('width', width.value));
    properties.add(DiagnosticsProperty('height', height.value));
    properties.add(DiagnosticsProperty('contentBoxLogicalWidth', contentBoxLogicalWidth));
    properties.add(DiagnosticsProperty('contentBoxLogicalHeight', contentBoxLogicalHeight));
    properties.add(DiagnosticsProperty('intrinsicWidth', intrinsicWidth));
    properties.add(DiagnosticsProperty('intrinsicHeight', intrinsicHeight));
    if (aspectRatio != null) properties.add(DiagnosticsProperty('intrinsicRatio', aspectRatio));

    debugBoxDecorationProperties(properties);
    debugVisibilityProperties(properties);
    debugTransformProperties(properties);
  }

  void debugBoxDecorationProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty('borderEdge', border));
    if (backgroundClip != null) properties.add(DiagnosticsProperty('backgroundClip', backgroundClip));
    if (backgroundOrigin != null) properties.add(DiagnosticsProperty('backgroundOrigin', backgroundOrigin));
    CSSBoxDecoration? decoration = this.decoration;
    if (decoration != null && decoration.hasBorderRadius) {
      properties.add(DiagnosticsProperty('borderRadius', decoration.borderRadius));
    }
    if (decoration != null && decoration.image != null) {
      properties.add(DiagnosticsProperty('backgroundImage', decoration.image));
    }
    if (decoration != null && decoration.boxShadow != null) {
      properties.add(DiagnosticsProperty('boxShadow', decoration.boxShadow));
    }
    if (decoration != null && decoration.gradient != null) {
      properties.add(DiagnosticsProperty('gradient', decoration.gradient));
    }
  }

  void debugVisibilityProperties(DiagnosticPropertiesBuilder properties) {
    properties.add(DiagnosticsProperty<ContentVisibility>('contentVisibility', contentVisibility));
  }

  void debugTransformProperties(DiagnosticPropertiesBuilder properties) {
    Offset transformOffset = this.transformOffset;
    Alignment transformAlignment = this.transformAlignment;
    properties.add(DiagnosticsProperty('transformMatrix', transformMatrix));
    properties.add(DiagnosticsProperty('transformOffset', transformOffset));
    properties.add(DiagnosticsProperty('transformAlignment', transformAlignment));
  }

  @override
  Element target;

  @override
  getProperty(String name) {
    switch (name) {
      case DISPLAY:
        return display;
      case Z_INDEX:
        return zIndex;
      case OVERFLOW_X:
        return overflowX;
      case OVERFLOW_Y:
        return overflowY;
      case OPACITY:
        return opacity;
      case VISIBILITY:
        return visibility;
      case CONTENT_VISIBILITY:
        return contentVisibility;
      case POSITION:
        return position;
      case TOP:
        return top;
      case LEFT:
        return left;
      case BOTTOM:
        return bottom;
      case RIGHT:
        return right;
      // Size
      case WIDTH:
        return width;
      case MIN_WIDTH:
        return minWidth;
      case MAX_WIDTH:
        return maxWidth;
      case HEIGHT:
        return height;
      case MIN_HEIGHT:
        return minHeight;
      case MAX_HEIGHT:
        return maxHeight;
      // Flex
      case FLEX_DIRECTION:
        return flexDirection;
      case FLEX_WRAP:
        return flexWrap;
      case ALIGN_CONTENT:
        return alignContent;
      case GRID_TEMPLATE_COLUMNS:
        return gridTemplateColumns;
      case GRID_TEMPLATE_ROWS:
        return gridTemplateRows;
      case GRID_TEMPLATE_AREAS:
        return gridTemplateAreasDefinition;
      case GRID_AUTO_ROWS:
        return gridAutoRows;
      case GRID_AUTO_COLUMNS:
        return gridAutoColumns;
      case GRID_AUTO_FLOW:
        return gridAutoFlow;
      case GRID_ROW_START:
        return gridRowStart;
      case GRID_ROW_END:
        return gridRowEnd;
      case GRID_COLUMN_START:
        return gridColumnStart;
      case GRID_COLUMN_END:
        return gridColumnEnd;
      case GRID_AREA_INTERNAL:
        return gridAreaName;
      case ALIGN_ITEMS:
        return alignItems;
      case JUSTIFY_CONTENT:
        return justifyContent;
      case JUSTIFY_ITEMS:
        return justifyItems;
      case JUSTIFY_SELF:
        return justifySelf;
      case ALIGN_SELF:
        return alignSelf;
      case FLEX_GROW:
        return flexGrow;
      case FLEX_SHRINK:
        return flexShrink;
      case FLEX_BASIS:
        return flexBasis;
      case ORDER:
        return order;
      // Gap
      case GAP:
        return gap;
      case ROW_GAP:
        return rowGap;
      case COLUMN_GAP:
        return columnGap;
      // Background
      case BACKGROUND_COLOR:
        return backgroundColor;
      case BACKGROUND_ATTACHMENT:
        return backgroundAttachment;
      case BACKGROUND_IMAGE:
        return backgroundImage;
      case BACKGROUND_REPEAT:
        return backgroundRepeat;
      case BACKGROUND_POSITION_X:
        return backgroundPositionX;
      case BACKGROUND_POSITION_Y:
        return backgroundPositionY;
      case BACKGROUND_SIZE:
        return backgroundSize;
      case BACKGROUND_CLIP:
        return backgroundClip;
      case BACKGROUND_ORIGIN:
        return backgroundOrigin;
      // Padding
      case PADDING_TOP:
        return paddingTop;
      case PADDING_RIGHT:
        return paddingRight;
      case PADDING_BOTTOM:
        return paddingBottom;
      case PADDING_LEFT:
        return paddingLeft;
      // Border
      case BORDER_LEFT_WIDTH:
        return borderLeftWidth;
      case BORDER_TOP_WIDTH:
        return borderTopWidth;
      case BORDER_RIGHT_WIDTH:
        return borderRightWidth;
      case BORDER_BOTTOM_WIDTH:
        return borderBottomWidth;
      case BORDER_LEFT_STYLE:
        return borderLeftStyle;
      case BORDER_TOP_STYLE:
        return borderTopStyle;
      case BORDER_RIGHT_STYLE:
        return borderRightStyle;
      case BORDER_BOTTOM_STYLE:
        return borderBottomStyle;
      case BORDER_LEFT_COLOR:
        return borderLeftColor;
      case BORDER_TOP_COLOR:
        return borderTopColor;
      case BORDER_RIGHT_COLOR:
        return borderRightColor;
      case BORDER_BOTTOM_COLOR:
        return borderBottomColor;
      case BOX_SHADOW:
        return boxShadow;
      case BORDER_TOP_LEFT_RADIUS:
        return borderTopLeftRadius;
      case BORDER_TOP_RIGHT_RADIUS:
        return borderTopRightRadius;
      case BORDER_BOTTOM_LEFT_RADIUS:
        return borderBottomLeftRadius;
      case BORDER_BOTTOM_RIGHT_RADIUS:
        return borderBottomRightRadius;
      // Margin
      case MARGIN_LEFT:
        return marginLeft;
      case MARGIN_TOP:
        return marginTop;
      case MARGIN_RIGHT:
        return marginRight;
      case MARGIN_BOTTOM:
        return marginBottom;
  // Text
  case COLOR:
    return color;
      case TEXT_DECORATION_LINE:
        return textDecorationLine;
      case TEXT_DECORATION_STYLE:
        return textDecorationStyle;
      case TEXT_DECORATION_COLOR:
        return textDecorationColor;
      case FONT_WEIGHT:
        return fontWeight;
      case FONT_STYLE:
        return fontStyle;
      case FONT_VARIANT:
        return fontVariant;
      case FONT_FAMILY:
        return fontFamily;
      case FONT_SIZE:
        return fontSize;
      case LINE_HEIGHT:
        return lineHeight;
      case LETTER_SPACING:
        return letterSpacing;
      case WORD_SPACING:
        return wordSpacing;
      case TEXT_SHADOW:
        return textShadow;
      case WHITE_SPACE:
        return whiteSpace;
  case TEXT_OVERFLOW:
    return textOverflow;
  case WORD_BREAK:
    return wordBreak;
      case LINE_CLAMP:
        return lineClamp;
      case TAB_SIZE:
        // Returns effective tab-size (number of spaces) from CSSTextMixin
        return tabSize;
      case TEXT_INDENT:
        return textIndent;
      case VERTICAL_ALIGN:
        return verticalAlign;
  case TEXT_ALIGN:
    return textAlign;
      case DIRECTION:
        return direction;
      // Transform
      case TRANSFORM:
        return transform;
      case TRANSFORM_ORIGIN:
        return transformOrigin;
      case SLIVER_DIRECTION:
        return sliverDirection;
      case OBJECT_FIT:
        return objectFit;
      case OBJECT_POSITION:
        return objectPosition;
      case FILTER:
        return filter;
    }
  }

  setProperty(String name, value) {

    // Memorize the variable value to renderStyle object.
    if (CSSVariable.isCSSSVariableProperty(name)) {
      // Custom properties can legally be set to an empty token stream:
      //   --x: ;
      // Some parsing paths represent that as `null`; do NOT stringify it to
      // "null", since it will leak into var() expansion and break consumers
      // like Tailwind gradients (e.g. "#3b82f6 null").
      setCSSVariable(name, value == null ? '' : value.toString());
      return;
    }

    // Get the computed value of CSS variable.
    if (value is CSSVariable) {
      value = value.computedValue(name);
    }

    if (value is CSSCalcValue) {
      if (name == BACKGROUND_POSITION_X || name == BACKGROUND_POSITION_Y) {
        value = CSSBackgroundPosition(calcValue: value);
      } else {
        value = value.computedValue(name);
        if (value != null) {
          value = CSSLengthValue(value, CSSLengthType.PX);
        }
      }
    }

    // Map logical properties to physical properties based on current direction.
    //
    // Note: Do NOT eagerly map padding-inline-start/end to physical paddings here.
    // `direction` is inherited and may change after the property is applied (e.g., when
    // an ancestor sets `direction` later in the same style flush). Eager mapping can
    // leave stale padding on the wrong side (LTR->RTL), shrinking the content box.
    String propertyName = name;
    final bool isRTL = direction == TextDirection.rtl;

    // Handle inline-start properties (maps to left in LTR, right in RTL)
    if (name == MARGIN_INLINE_START) {
      propertyName = isRTL ? MARGIN_RIGHT : MARGIN_LEFT;
    } else if (name == BORDER_INLINE_START) {
      propertyName = isRTL ? BORDER_RIGHT : BORDER_LEFT;
    } else if (name == BORDER_INLINE_START_WIDTH) {
      propertyName = isRTL ? BORDER_RIGHT_WIDTH : BORDER_LEFT_WIDTH;
    } else if (name == BORDER_INLINE_START_STYLE) {
      propertyName = isRTL ? BORDER_RIGHT_STYLE : BORDER_LEFT_STYLE;
    } else if (name == BORDER_INLINE_START_COLOR) {
      propertyName = isRTL ? BORDER_RIGHT_COLOR : BORDER_LEFT_COLOR;
    } else if (name == INSET_INLINE_START) {
      propertyName = isRTL ? RIGHT : LEFT;
    }
    // Handle inline-end properties (maps to right in LTR, left in RTL)
    else if (name == MARGIN_INLINE_END) {
      propertyName = isRTL ? MARGIN_LEFT : MARGIN_RIGHT;
    } else if (name == BORDER_INLINE_END) {
      propertyName = isRTL ? BORDER_LEFT : BORDER_RIGHT;
    } else if (name == BORDER_INLINE_END_WIDTH) {
      propertyName = isRTL ? BORDER_LEFT_WIDTH : BORDER_RIGHT_WIDTH;
    } else if (name == BORDER_INLINE_END_STYLE) {
      propertyName = isRTL ? BORDER_LEFT_STYLE : BORDER_RIGHT_STYLE;
    } else if (name == BORDER_INLINE_END_COLOR) {
      propertyName = isRTL ? BORDER_LEFT_COLOR : BORDER_RIGHT_COLOR;
    } else if (name == INSET_INLINE_END) {
      propertyName = isRTL ? LEFT : RIGHT;
    }
    // Handle block-start properties (maps to top)
    else if (name == MARGIN_BLOCK_START) {
      propertyName = MARGIN_TOP;
    } else if (name == PADDING_BLOCK_START) {
      propertyName = PADDING_TOP;
    } else if (name == BORDER_BLOCK_START) {
      propertyName = BORDER_TOP;
    } else if (name == BORDER_BLOCK_START_WIDTH) {
      propertyName = BORDER_TOP_WIDTH;
    } else if (name == BORDER_BLOCK_START_STYLE) {
      propertyName = BORDER_TOP_STYLE;
    } else if (name == BORDER_BLOCK_START_COLOR) {
      propertyName = BORDER_TOP_COLOR;
    } else if (name == INSET_BLOCK_START) {
      propertyName = TOP;
    }
    // Handle block-end properties (maps to bottom)
    else if (name == MARGIN_BLOCK_END) {
      propertyName = MARGIN_BOTTOM;
    } else if (name == PADDING_BLOCK_END) {
      propertyName = PADDING_BOTTOM;
    } else if (name == BORDER_BLOCK_END) {
      propertyName = BORDER_BOTTOM;
    } else if (name == BORDER_BLOCK_END_WIDTH) {
      propertyName = BORDER_BOTTOM_WIDTH;
    } else if (name == BORDER_BLOCK_END_STYLE) {
      propertyName = BORDER_BOTTOM_STYLE;
    } else if (name == BORDER_BLOCK_END_COLOR) {
      propertyName = BORDER_BOTTOM_COLOR;
    } else if (name == INSET_BLOCK_END) {
      propertyName = BOTTOM;
    }

    // Use the mapped property name for the switch statement
    name = propertyName;

    switch (name) {
      case DISPLAY:
        display = value;
        break;
      case Z_INDEX:
        zIndex = value;
        break;
      case OVERFLOW_X:
        overflowX = value;
        break;
      case OVERFLOW_Y:
        overflowY = value;
        break;
      case OPACITY:
        opacity = value;
        break;
      case VISIBILITY:
        visibility = value;
        break;
      case CONTENT_VISIBILITY:
        contentVisibility = value;
        break;
      case POSITION:
        position = value;
        break;
      case TOP:
        top = value;
        break;
      case LEFT:
        left = value;
        break;
      case BOTTOM:
        bottom = value;
        break;
      case RIGHT:
        right = value;
        break;
      // Size
      case WIDTH:
        width = value;
        break;
      case MIN_WIDTH:
        minWidth = value;
        break;
      case MAX_WIDTH:
        maxWidth = value;
        break;
      case HEIGHT:
        height = value;
        break;
      case MIN_HEIGHT:
        minHeight = value;
        break;
      case MAX_HEIGHT:
        maxHeight = value;
        break;
      case ASPECT_RATIO:
        // Preferred aspect ratio (width/height). Null means 'auto'.
        aspectRatio = value as double?;
        break;
      // Flex
      case FLEX_DIRECTION:
        flexDirection = value;
        break;
      case FLEX_WRAP:
        flexWrap = value;
        break;
      case ALIGN_CONTENT:
        alignContent = value;
        break;
      case GRID_TEMPLATE_COLUMNS:
        gridTemplateColumns = value;
        break;
      case GRID_TEMPLATE_ROWS:
        gridTemplateRows = value;
        break;
      case GRID_TEMPLATE_AREAS:
        gridTemplateAreasDefinition = value;
        break;
      case GRID_AUTO_ROWS:
        gridAutoRows = value;
        break;
      case GRID_AUTO_COLUMNS:
        gridAutoColumns = value;
        break;
      case GRID_AUTO_FLOW:
        gridAutoFlow = value;
        break;
      case GRID_ROW_START:
        gridRowStart = value;
        gridAreaName = null;
        break;
      case GRID_ROW_END:
        gridRowEnd = value;
        gridAreaName = null;
        break;
      case GRID_COLUMN_START:
        gridColumnStart = value;
        gridAreaName = null;
        break;
      case GRID_COLUMN_END:
        gridColumnEnd = value;
        gridAreaName = null;
        break;
      case GRID_AREA_INTERNAL:
        gridAreaName = value as String?;
        break;
      case ALIGN_ITEMS:
        alignItems = value;
        break;
      case JUSTIFY_CONTENT:
        justifyContent = value;
        break;
      case JUSTIFY_ITEMS:
        justifyItems = value;
        break;
      case JUSTIFY_SELF:
        justifySelf = value;
        break;
      case ALIGN_SELF:
        alignSelf = value;
        break;
      case FLEX_GROW:
        flexGrow = value;
        break;
      case FLEX_SHRINK:
        flexShrink = value;
        break;
      case FLEX_BASIS:
        flexBasis = value;
        break;
      case ORDER:
        order = value;
        break;
      // Gap
      case GAP:
        gap = value;
        break;
      case ROW_GAP:
        rowGap = value;
        break;
      case COLUMN_GAP:
        columnGap = value;
        break;
      // Background
      case BACKGROUND_COLOR:
        backgroundColor = value;
        break;
      case BACKGROUND_ATTACHMENT:
        backgroundAttachment = value;
        break;
      case BACKGROUND_IMAGE:
        backgroundImage = value;
        break;
      case BACKGROUND_REPEAT:
        backgroundRepeat = value;
        break;
      case BACKGROUND_POSITION_X:
        backgroundPositionX = value;
        if (DebugFlags.enableBackgroundLogs) {
          try {
            final CSSBackgroundPosition p = value as CSSBackgroundPosition;
            renderingLogger.finer('[Background] set BACKGROUND_POSITION_X -> ${p.cssText()} '
                '(len=${p.length != null} pct=${p.percentage != null} calc=${p.calcValue != null})');
          } catch (_) {}
        }
        break;
      case BACKGROUND_POSITION_Y:
        backgroundPositionY = value;
        if (DebugFlags.enableBackgroundLogs) {
          try {
            final CSSBackgroundPosition p = value as CSSBackgroundPosition;
            renderingLogger.finer('[Background] set BACKGROUND_POSITION_Y -> ${p.cssText()} '
                '(len=${p.length != null} pct=${p.percentage != null} calc=${p.calcValue != null})');
          } catch (_) {}
        }
        break;
      case BACKGROUND_SIZE:
        backgroundSize = value;
        break;
      case BACKGROUND_CLIP:
        backgroundClip = value;
        break;
      case BACKGROUND_ORIGIN:
        backgroundOrigin = value;
        break;
      // Padding
      case PADDING_TOP:
        paddingTop = value;
        break;
      case PADDING_RIGHT:
        paddingRight = value;
        break;
      case PADDING_BOTTOM:
        paddingBottom = value;
        break;
      case PADDING_LEFT:
        paddingLeft = value;
        break;
      case PADDING_INLINE_START:
        paddingInlineStart = value;
        break;
      case PADDING_INLINE_END:
        paddingInlineEnd = value;
        break;
      // Border
      case BORDER_LEFT_WIDTH:
        borderLeftWidth = value;
        break;
      case BORDER_TOP_WIDTH:
        borderTopWidth = value;
        break;
      case BORDER_RIGHT_WIDTH:
        borderRightWidth = value;
        break;
      case BORDER_BOTTOM_WIDTH:
        borderBottomWidth = value;
        break;
      case BORDER_LEFT_STYLE:
        borderLeftStyle = value;
        break;
      case BORDER_TOP_STYLE:
        borderTopStyle = value;
        break;
      case BORDER_RIGHT_STYLE:
        borderRightStyle = value;
        break;
      case BORDER_BOTTOM_STYLE:
        borderBottomStyle = value;
        break;
      case BORDER_LEFT_COLOR:
        borderLeftColor = value;
        break;
      case BORDER_TOP_COLOR:
        borderTopColor = value;
        break;
      case BORDER_RIGHT_COLOR:
        borderRightColor = value;
        break;
      case BORDER_BOTTOM_COLOR:
        borderBottomColor = value;
        break;
      case BOX_SHADOW:
        boxShadow = value;
        break;
      case BORDER_TOP_LEFT_RADIUS:
        borderTopLeftRadius = value;
        break;
      case BORDER_TOP_RIGHT_RADIUS:
        borderTopRightRadius = value;
        break;
      case BORDER_BOTTOM_LEFT_RADIUS:
        borderBottomLeftRadius = value;
        break;
      case BORDER_BOTTOM_RIGHT_RADIUS:
        borderBottomRightRadius = value;
        break;
      // Margin
      case MARGIN_LEFT:
        marginLeft = value;
        break;
      case MARGIN_TOP:
        marginTop = value;
        break;
      case MARGIN_RIGHT:
        marginRight = value;
        break;
      case MARGIN_BOTTOM:
        marginBottom = value;
        break;
      // Text
      case COLOR:
        color = value;
        break;
      case TEXT_DECORATION_LINE:
        textDecorationLine = value;
        break;
      case TEXT_DECORATION_STYLE:
        textDecorationStyle = value;
        break;
      case TEXT_DECORATION_COLOR:
        textDecorationColor = value;
        break;
      case FONT_WEIGHT:
        fontWeight = value;
        break;
      case FONT_STYLE:
        fontStyle = value;
        break;
      case FONT_VARIANT:
        fontVariant = value;
        break;
      case FONT_FAMILY:
        fontFamily = value;
        break;
      case FONT_SIZE:
        fontSize = value;
        break;
      case LINE_HEIGHT:
        lineHeight = value;
        break;
      case LETTER_SPACING:
        letterSpacing = value;
        break;
      case WORD_SPACING:
        wordSpacing = value;
        break;
      case TEXT_SHADOW:
        textShadow = value;
        break;
      case WHITE_SPACE:
        whiteSpace = value;
        break;
      case TEXT_OVERFLOW:
        textOverflow = value;
        break;
      case WORD_BREAK:
        wordBreak = value;
        break;
      case LINE_CLAMP:
        lineClamp = value;
        break;
      case TEXT_TRANSFORM:
        textTransform = value;
        break;
      case TAB_SIZE:
        tabSize = value;
        break;
      case TEXT_INDENT:
        // Accept CSSLengthValue or parse from string
        if (value is CSSLengthValue) {
          textIndent = value;
        } else if (value is String) {
          final parsed = CSSLength.parseLength(value, this, TEXT_INDENT, Axis.horizontal);
          if (parsed != CSSLengthValue.unknown) {
            textIndent = parsed;
          }
        }
        break;
      case VERTICAL_ALIGN:
        verticalAlign = value;
        break;
      case TEXT_ALIGN:
        textAlign = value;
        break;
      case DIRECTION:
        direction = value;
        break;
      case WRITING_MODE:
        writingMode = value as CSSWritingMode;
        break;
      // Transform
      case TRANSFORM:
        transform = value;
        break;
      case TRANSFORM_ORIGIN:
        transformOrigin = value;
        break;
      // Transition
      case TRANSITION_DELAY:
        transitionDelay = value;
        break;
      case TRANSITION_DURATION:
        transitionDuration = value;
        break;
      case TRANSITION_TIMING_FUNCTION:
        transitionTimingFunction = value;
        break;
      case TRANSITION_PROPERTY:
        transitionProperty = value;
        break;
      // Animation
      case ANIMATION_DELAY:
        animationDelay = value;
        break;
      case ANIMATION_NAME:
        animationName = value;
        break;
      case ANIMATION_DIRECTION:
        animationDirection = value;
        break;
      case ANIMATION_DURATION:
        animationDuration = value;
        break;
      case ANIMATION_PLAY_STATE:
        animationPlayState = value;
        break;
      case ANIMATION_FILL_MODE:
        animationFillMode = value;
        break;
      case ANIMATION_ITERATION_COUNT:
        animationIterationCount = value;
        break;
      case ANIMATION_TIMING_FUNCTION:
        animationTimingFunction = value;
        break;
      // Others
      case OBJECT_FIT:
        objectFit = value;
        break;
      case OBJECT_POSITION:
        objectPosition = value;
        break;
      case FILTER:
        filter = value;
        break;
      case SLIVER_DIRECTION:
        sliverDirection = value;
        break;
      case CARETCOLOR:
        caretColor = (value as CSSColor).value;
        break;
    }
  }

  @override
  dynamic resolveValue(String propertyName, String propertyValue, {String? baseHref}) {
    RenderStyle renderStyle = this;

    // For CSS custom properties (variables), do not attempt to interpret
    // or coerce values. Preserve the raw string verbatim so comma-separated
    // lists like "var(--a), var(--b)" are stored intact.
    if (CSSVariable.isCSSSVariableProperty(propertyName)) {
      return propertyValue;
    }

    // Map logical properties to physical properties based on current direction.
    //
    // Note: Do NOT eagerly map padding-inline-start/end to physical paddings here.
    // See [setProperty] above for rationale.
    String mappedPropertyName = propertyName;
    final bool isRTL = direction == TextDirection.rtl;

    // Handle inline-start properties (maps to left in LTR, right in RTL)
    if (propertyName == MARGIN_INLINE_START) {
      mappedPropertyName = isRTL ? MARGIN_RIGHT : MARGIN_LEFT;
    } else if (propertyName == BORDER_INLINE_START) {
      mappedPropertyName = isRTL ? BORDER_RIGHT : BORDER_LEFT;
    } else if (propertyName == BORDER_INLINE_START_WIDTH) {
      mappedPropertyName = isRTL ? BORDER_RIGHT_WIDTH : BORDER_LEFT_WIDTH;
    } else if (propertyName == BORDER_INLINE_START_STYLE) {
      mappedPropertyName = isRTL ? BORDER_RIGHT_STYLE : BORDER_LEFT_STYLE;
    } else if (propertyName == BORDER_INLINE_START_COLOR) {
      mappedPropertyName = isRTL ? BORDER_RIGHT_COLOR : BORDER_LEFT_COLOR;
    } else if (propertyName == INSET_INLINE_START) {
      mappedPropertyName = isRTL ? RIGHT : LEFT;
    }
    // Handle inline-end properties (maps to right in LTR, left in RTL)
    else if (propertyName == MARGIN_INLINE_END) {
      mappedPropertyName = isRTL ? MARGIN_LEFT : MARGIN_RIGHT;
    } else if (propertyName == BORDER_INLINE_END) {
      mappedPropertyName = isRTL ? BORDER_LEFT : BORDER_RIGHT;
    } else if (propertyName == BORDER_INLINE_END_WIDTH) {
      mappedPropertyName = isRTL ? BORDER_LEFT_WIDTH : BORDER_RIGHT_WIDTH;
    } else if (propertyName == BORDER_INLINE_END_STYLE) {
      mappedPropertyName = isRTL ? BORDER_LEFT_STYLE : BORDER_RIGHT_STYLE;
    } else if (propertyName == BORDER_INLINE_END_COLOR) {
      mappedPropertyName = isRTL ? BORDER_LEFT_COLOR : BORDER_RIGHT_COLOR;
    } else if (propertyName == INSET_INLINE_END) {
      mappedPropertyName = isRTL ? LEFT : RIGHT;
    }
    // Handle block-start properties (maps to top)
    else if (propertyName == MARGIN_BLOCK_START) {
      mappedPropertyName = MARGIN_TOP;
    } else if (propertyName == PADDING_BLOCK_START) {
      mappedPropertyName = PADDING_TOP;
    } else if (propertyName == BORDER_BLOCK_START) {
      mappedPropertyName = BORDER_TOP;
    } else if (propertyName == BORDER_BLOCK_START_WIDTH) {
      mappedPropertyName = BORDER_TOP_WIDTH;
    } else if (propertyName == BORDER_BLOCK_START_STYLE) {
      mappedPropertyName = BORDER_TOP_STYLE;
    } else if (propertyName == BORDER_BLOCK_START_COLOR) {
      mappedPropertyName = BORDER_TOP_COLOR;
    } else if (propertyName == INSET_BLOCK_START) {
      mappedPropertyName = TOP;
    }
    // Handle block-end properties (maps to bottom)
    else if (propertyName == MARGIN_BLOCK_END) {
      mappedPropertyName = MARGIN_BOTTOM;
    } else if (propertyName == PADDING_BLOCK_END) {
      mappedPropertyName = PADDING_BOTTOM;
    } else if (propertyName == BORDER_BLOCK_END) {
      mappedPropertyName = BORDER_BOTTOM;
    } else if (propertyName == BORDER_BLOCK_END_WIDTH) {
      mappedPropertyName = BORDER_BOTTOM_WIDTH;
    } else if (propertyName == BORDER_BLOCK_END_STYLE) {
      mappedPropertyName = BORDER_BOTTOM_STYLE;
    } else if (propertyName == BORDER_BLOCK_END_COLOR) {
      mappedPropertyName = BORDER_BOTTOM_COLOR;
    } else if (propertyName == INSET_BLOCK_END) {
      mappedPropertyName = BOTTOM;
    }

    // Use the mapped property name for further processing
    propertyName = mappedPropertyName;

    if (propertyValue == INITIAL) {
      propertyValue = cssInitialValues[propertyName] ?? propertyValue;
    }

    // Process CSSVariable only when the entire value is a single var(...)
    // wrapper. For mixed tokens (e.g., 'var(--a) solid var(--b)'), do not
    // return a CSSVariable here; instead expand inline below and parse.
    if (CSSWritingModeMixin._isEntireVarFunction(propertyValue)) {
      dynamic value = CSSVariable.tryParse(renderStyle, propertyValue);
      if (value != null) {

        return value;
      }
    }

    // Expand inline var(...) occurrences embedded within a value string (e.g.,
    // 'red var(--b)') so property-specific parsers see fully-resolved tokens.
    // If a referenced variable cannot be resolved (and has no fallback), the
    // var(...) is left intact so the property parser fails and the property
    // becomes invalid at computed-value time per spec (inherited or initial).
    if (propertyValue.contains('var(')) {
      propertyValue = CSSWritingModeMixin.expandInlineVars(propertyValue, renderStyle, propertyName);
    }

    dynamic value;
    switch (propertyName) {
      case DISPLAY:
        value = CSSDisplayMixin.resolveDisplay(propertyValue);
        break;
      case OVERFLOW_X:
      case OVERFLOW_Y:
        value = CSSOverflowMixin.resolveOverflowType(propertyValue);
        break;
      case POSITION:
        value = CSSPositionMixin.resolvePositionType(propertyValue);
        break;
      case Z_INDEX:
        value = int.tryParse(propertyValue);
        break;
      case TOP:
      case LEFT:
      case BOTTOM:
      case RIGHT:
      case FLEX_BASIS:
      case WIDTH:
      case MIN_WIDTH:
      case MAX_WIDTH:
      case HEIGHT:
      case MIN_HEIGHT:
      case MAX_HEIGHT:
      case X:
      case Y:
      case RX:
      case RY:
      case CX:
      case CY:
      case R:
      case X1:
      case X2:
      case Y1:
      case Y2:
      case STROKE_WIDTH:
        value = CSSLength.resolveLength(propertyValue, renderStyle, propertyName);
        break;
      case ASPECT_RATIO:
        value = CSSSizingMixin.resolveAspectRatio(propertyValue);
        break;
      case GAP:
      case ROW_GAP:
      case COLUMN_GAP:
        value = CSSGapMixin.resolveGap(propertyValue, renderStyle: renderStyle);
        break;
      case PADDING_TOP:
      case MARGIN_TOP:
        List<String?>? values = CSSStyleProperty.getEdgeValues(propertyValue);
        if (values != null && values[0] != null) {
          value = CSSLength.resolveLength(values[0]!, renderStyle, propertyName);
        } else {
          value = CSSLength.resolveLength(propertyValue, renderStyle, propertyName);
        }
        break;
      case MARGIN_RIGHT:
      case PADDING_RIGHT:
        List<String?>? values = CSSStyleProperty.getEdgeValues(propertyValue);
        if (values != null && values[1] != null) {
          value = CSSLength.resolveLength(values[1]!, renderStyle, propertyName);
        } else {
          value = CSSLength.resolveLength(propertyValue, renderStyle, propertyName);
        }
        break;
      case PADDING_BOTTOM:
      case MARGIN_BOTTOM:
        List<String?>? values = CSSStyleProperty.getEdgeValues(propertyValue);
        if (values != null && values[2] != null) {
          value = CSSLength.resolveLength(values[2]!, renderStyle, propertyName);
        } else {
          value = CSSLength.resolveLength(propertyValue, renderStyle, propertyName);
        }
        break;
      case PADDING_LEFT:
      case MARGIN_LEFT:
        List<String?>? values = CSSStyleProperty.getEdgeValues(propertyValue);
        if (values != null && values[3] != null) {
          value = CSSLength.resolveLength(values[3]!, renderStyle, propertyName);
        } else {
          value = CSSLength.resolveLength(propertyValue, renderStyle, propertyName);
        }
        break;
      case PADDING_INLINE_START:
      case PADDING_INLINE_END:
        value = CSSLength.resolveLength(propertyValue, renderStyle, propertyName);
        break;
      case FLEX_DIRECTION:
        value = CSSFlexboxMixin.resolveFlexDirection(propertyValue);
        break;
      case FLEX_WRAP:
        value = CSSFlexboxMixin.resolveFlexWrap(propertyValue);
        break;
      case ALIGN_CONTENT:
        value = CSSFlexboxMixin.resolveAlignContent(propertyValue);
        break;
      case ALIGN_ITEMS:
        value = CSSFlexboxMixin.resolveAlignItems(propertyValue);
        break;
      case JUSTIFY_CONTENT:
        value = CSSFlexboxMixin.resolveJustifyContent(propertyValue);
        break;
      case JUSTIFY_ITEMS:
        value = CSSGridParser.parseAxisAlignment(propertyValue, allowAuto: false);
        break;
      case JUSTIFY_SELF:
        value = CSSGridParser.parseAxisAlignment(propertyValue, allowAuto: true);
        break;
      case ALIGN_SELF:
        value = CSSFlexboxMixin.resolveAlignSelf(propertyValue);
        break;
      case FLEX_GROW:
        value = CSSFlexboxMixin.resolveFlexGrow(propertyValue);
        break;
      case FLEX_SHRINK:
        value = CSSFlexboxMixin.resolveFlexShrink(propertyValue);
        break;
      case ORDER:
        value = CSSOrderMixin.resolveOrder(propertyValue);
        break;
      case SLIVER_DIRECTION:
        value = CSSSliverMixin.resolveAxis(propertyValue);
        break;
      case TEXT_ALIGN:
        value = CSSTextMixin.resolveTextAlign(propertyValue);
        break;
      case TEXT_INDENT:
        value = CSSLength.resolveLength(propertyValue, renderStyle, TEXT_INDENT);
        break;
      case DIRECTION:
        value = CSSTextMixin.resolveDirection(propertyValue);
        break;
      case WRITING_MODE:
        value = CSSWritingModeMixin.resolveWritingMode(propertyValue);
        break;
      case BACKGROUND_ATTACHMENT:
        value = CSSBackground.resolveBackgroundAttachment(propertyValue);
        break;
      case BACKGROUND_IMAGE:
        value = CSSBackground.resolveBackgroundImage(
            propertyValue, renderStyle, propertyName, renderStyle.target.ownerDocument.controller, baseHref);
        break;
      case BACKGROUND_REPEAT:
        value = CSSBackground.resolveBackgroundRepeat(propertyValue);
        break;
      case BACKGROUND_POSITION_X:
        value = CSSPosition.resolveBackgroundPosition(propertyValue, renderStyle, propertyName, true);
        break;
      case BACKGROUND_POSITION_Y:
        value = CSSPosition.resolveBackgroundPosition(propertyValue, renderStyle, propertyName, false);
        break;
      case BACKGROUND_SIZE:
        value = CSSBackground.resolveBackgroundSize(propertyValue, renderStyle, propertyName);
        break;
      case BACKGROUND_CLIP:
        value = CSSBackground.resolveBackgroundClip(propertyValue);
        break;
      case BACKGROUND_ORIGIN:
        value = CSSBackground.resolveBackgroundOrigin(propertyValue);
        break;
      case BORDER_LEFT_WIDTH:
      case BORDER_TOP_WIDTH:
      case BORDER_RIGHT_WIDTH:
      case BORDER_BOTTOM_WIDTH:
        // If the value looks like a full border shorthand expanded via var()
        // (e.g., "2px solid red"), extract the width token and parse it.
        if (propertyValue.contains(' ')) {
          final triple = CSSStyleProperty.parseBorderTriple(propertyValue);
          final widthToken = triple != null ? triple[0] : null;
          value = widthToken != null
              ? CSSBorderSide.resolveBorderWidth(widthToken, renderStyle, propertyName)
              : CSSBorderSide.resolveBorderWidth(propertyValue, renderStyle, propertyName);
        } else {
          value = CSSBorderSide.resolveBorderWidth(propertyValue, renderStyle, propertyName);
        }
        break;
      case BORDER_LEFT_STYLE:
      case BORDER_TOP_STYLE:
      case BORDER_RIGHT_STYLE:
      case BORDER_BOTTOM_STYLE:
        if (propertyValue.contains(' ')) {
          final triple = CSSStyleProperty.parseBorderTriple(propertyValue);
          final styleToken = triple != null ? triple[1] : null;
          value = CSSBorderSide.resolveBorderStyle(styleToken ?? propertyValue);
        } else {
          value = CSSBorderSide.resolveBorderStyle(propertyValue);
        }
        break;
      case COLOR:
      case CARETCOLOR:
      case BACKGROUND_COLOR:
      case TEXT_DECORATION_COLOR:
      case BORDER_LEFT_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_RIGHT_COLOR:
      case BORDER_BOTTOM_COLOR:
        if (propertyValue.contains(' ')) {
          final triple = CSSStyleProperty.parseBorderTriple(propertyValue);
          final colorToken = triple != null ? triple[2] : null;
          value = CSSColor.resolveColor(colorToken ?? propertyValue, renderStyle, propertyName);
        } else {
          value = CSSColor.resolveColor(propertyValue, renderStyle, propertyName);
        }
        break;
      case STROKE:
      case FILL:
        value = CSSPaint.parsePaint(propertyValue, renderStyle: renderStyle);
        break;
      case BOX_SHADOW:
        value = CSSBoxShadow.parseBoxShadow(propertyValue, renderStyle, propertyName);
        break;
      case BORDER_TOP_LEFT_RADIUS:
      case BORDER_TOP_RIGHT_RADIUS:
      case BORDER_BOTTOM_LEFT_RADIUS:
      case BORDER_BOTTOM_RIGHT_RADIUS:
        value = CSSBorderRadius.parseBorderRadius(propertyValue, renderStyle, propertyName);
        break;
      case OPACITY:
        value = CSSOpacityMixin.resolveOpacity(propertyValue);
        break;
      case VISIBILITY:
        value = CSSVisibilityMixin.resolveVisibility(propertyValue);
        break;
      case CONTENT_VISIBILITY:
        value = CSSContentVisibilityMixin.resolveContentVisibility(propertyValue);
        break;
      case TRANSFORM:
        value = CSSTransformMixin.resolveTransform(propertyValue);
        break;
      case FILTER:
        value = CSSFunction.parseFunction(propertyValue);
        break;
      case TRANSFORM_ORIGIN:
        value = CSSOrigin.parseOrigin(propertyValue, renderStyle, propertyName);
        break;
      case OBJECT_FIT:
        value = CSSObjectFitMixin.resolveBoxFit(propertyValue);
        break;
      case OBJECT_POSITION:
        value = CSSObjectPositionMixin.resolveObjectPosition(propertyValue);
        break;
      case TEXT_DECORATION_LINE:
        value = CSSText.resolveTextDecorationLine(propertyValue);
        break;
      case TEXT_DECORATION_STYLE:
        value = CSSText.resolveTextDecorationStyle(propertyValue);
        break;
      case FONT_WEIGHT:
        value = CSSText.resolveFontWeight(propertyValue);
        break;
      case FONT_SIZE:
        value = CSSText.resolveFontSize(propertyValue, renderStyle, propertyName);
        break;
      case FONT_STYLE:
        value = CSSText.resolveFontStyle(propertyValue);
        break;
      case FONT_VARIANT:
        value = CSSText.resolveFontVariant(propertyValue);
        break;
      case FONT_FAMILY:
        value = CSSText.resolveFontFamilyFallback(propertyValue);
        break;
      case LINE_HEIGHT:
        value = CSSText.resolveLineHeight(propertyValue, renderStyle, propertyName);
        break;
      case LETTER_SPACING:
        value = CSSText.resolveSpacing(propertyValue, renderStyle, propertyName);
        break;
      case WORD_SPACING:
        value = CSSText.resolveSpacing(propertyValue, renderStyle, propertyName);
        break;
      case TEXT_SHADOW:
        value = CSSText.resolveTextShadow(propertyValue, renderStyle, propertyName);
        break;
      case WHITE_SPACE:
        value = CSSText.resolveWhiteSpace(propertyValue);
        break;
      case TEXT_OVERFLOW:
        // Overflow will affect text-overflow ellipsis taking effect
        value = CSSText.resolveTextOverflow(propertyValue);
        break;
      case WORD_BREAK:
        value = CSSText.resolveWordBreak(propertyValue);
        break;
      case GRID_TEMPLATE_COLUMNS:
        value = CSSGridParser.parseTrackList(propertyValue, this, propertyName, Axis.horizontal);
        break;
      case GRID_TEMPLATE_ROWS:
        value = CSSGridParser.parseTrackList(propertyValue, this, propertyName, Axis.vertical);
        break;
      case GRID_TEMPLATE_AREAS:
        value = CSSGridParser.parseTemplateAreas(propertyValue);
        break;
      case GRID_AUTO_ROWS:
        value = CSSGridParser.parseTrackList(propertyValue, this, propertyName, Axis.vertical);
        break;
      case GRID_AUTO_COLUMNS:
        value = CSSGridParser.parseTrackList(propertyValue, this, propertyName, Axis.horizontal);
        break;
      case GRID_AUTO_FLOW:
        value = CSSGridParser.parseAutoFlow(propertyValue);
        break;
      case GRID_ROW_START:
      case GRID_ROW_END:
      case GRID_COLUMN_START:
      case GRID_COLUMN_END:
        value = CSSGridParser.parsePlacement(propertyValue);
        break;
      case GRID_AREA_INTERNAL:
        value = propertyValue == 'auto' ? null : propertyValue;
        break;
      case TEXT_TRANSFORM:
        value = CSSText.resolveTextTransform(propertyValue);
        break;
      case LINE_CLAMP:
        value = CSSText.parseLineClamp(propertyValue);
        break;
      case TAB_SIZE:
        // CSS tab-size accepts <number> (and <length> in spec, but we currently treat it as number of spaces)
        value = CSSNumber.parseNumber(propertyValue);
        break;
      case VERTICAL_ALIGN:
        value = CSSInlineMixin.resolveVerticalAlign(propertyValue);
        break;
      // Transition
      case TRANSITION_DELAY:
      case TRANSITION_DURATION:
      case TRANSITION_TIMING_FUNCTION:
      case TRANSITION_PROPERTY:
        value = CSSStyleProperty.getMultipleValues(propertyValue);
        break;
      // Animation
      case ANIMATION_DELAY:
      case ANIMATION_DIRECTION:
      case ANIMATION_DURATION:
      case ANIMATION_FILL_MODE:
      case ANIMATION_ITERATION_COUNT:
      case ANIMATION_NAME:
      case ANIMATION_PLAY_STATE:
      case ANIMATION_TIMING_FUNCTION:
        value = CSSStyleProperty.getMultipleValues(propertyValue);
        break;
      case D:
        value = CSSPath.parseValue(propertyValue);
        break;
    }

    return value;
  }

  // Compute the content box width from render style.
  void computeContentBoxLogicalWidth() {
    // RenderBoxModel current = renderBoxModel!;
    RenderStyle renderStyle = this;
    double? logicalWidth;

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;

    // Special handling for absolutely/fixed positioned non-replaced elements.
    // Follow CSS abs-non-replaced width algorithm:
    // - If width is auto and both left and right are auto: keep width as auto (shrink-to-fit in layout).
    // - If width is auto and both left and right are not auto: solve width from containing block padding box.
    if ((renderStyle.position == CSSPositionType.absolute || renderStyle.position == CSSPositionType.fixed) &&
        !renderStyle.isSelfRenderReplaced()) {
      if (renderStyle.width.isNotAuto) {
        logicalWidth = renderStyle.width.computedValue;
      } else if (renderStyle.left.isNotAuto && renderStyle.right.isNotAuto) {
        // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
        if (renderStyle.isParentRenderBoxModel()) {
          RenderStyle parentRenderStyle = renderStyle.getAttachedRenderParentRenderStyle()!;
          if (parentRenderStyle.paddingBoxLogicalWidth != null) {
            // Width of positioned element should subtract its horizontal margin.
            logicalWidth = (parentRenderStyle.paddingBoxLogicalWidth!) -
                renderStyle.left.computedValue -
                renderStyle.right.computedValue -
                renderStyle.marginLeft.computedValue -
                renderStyle.marginRight.computedValue;
          }
        } else {
          logicalWidth = null;
        }
      }
    }

    // Width applies to all elements except non-replaced inline elements.
    // https://drafts.csswg.org/css-sizing-3/#propdef-width
    if (effectiveDisplay == CSSDisplay.inline && !renderStyle.isSelfRenderReplaced()) {
      _contentBoxLogicalWidth = null;
      return;
    } else if (effectiveDisplay == CSSDisplay.block ||
        effectiveDisplay == CSSDisplay.flex ||
        effectiveDisplay == CSSDisplay.grid) {
      RenderViewportBox? root = getCurrentViewportBox();
      CSSRenderStyle? parentStyle = renderStyle.getAttachedRenderParentRenderStyle();
      if (logicalWidth == null && renderStyle.width.isNotAuto) {
        logicalWidth = renderStyle.width.computedValue;
      } else if (logicalWidth == null && aspectRatio != null && renderStyle.height.isNotAuto) {
        // Prefer aspect-ratio when height is definite and width is auto.
        double contentH = renderStyle.height.computedValue - renderStyle.border.vertical - renderStyle.padding.vertical;
        contentH = math.max(0, contentH);
        final double contentW = contentH * aspectRatio!;
        logicalWidth = contentW + renderStyle.border.horizontal + renderStyle.padding.horizontal;
      } else if (logicalWidth == null && renderStyle.isSelfHTMLElement()) {
        // Avoid defaulting to the viewport width when this element participates
        // in an inline-block shrink-to-fit context. Children of an inline-block
        // with auto width must not assume a definite containing block width; doing so
        // causes percentage widths (e.g., 100%) to immediately resolve to the viewport
        // and force the inline-block to expand to the full line width. Instead, keep
        // width auto here so the child can measure intrinsically and the parent can
        // shrink-wrap to its contents.
        final CSSRenderStyle? p = renderStyle.getAttachedRenderParentRenderStyle();
        final bool parentInlineBlockAuto = p != null &&
            p.effectiveDisplay == CSSDisplay.inlineBlock && p.width.isAuto;
        if (!parentInlineBlockAuto) {
          logicalWidth = target.ownerView.currentViewport!.boxSize!.width;
        }
      } else if (logicalWidth == null && (renderStyle.isSelfRouterLinkElement() && root != null && root is! RootRenderViewportBox)) {
        logicalWidth = root!.boxSize!.width;
      } else if (logicalWidth == null && parentStyle != null) {
        // Resolve whether the direct parent is a flex item (its render box's parent is a flex container).
        // Determine if our direct parent is a flex item: i.e., the parent's parent is a flex container.
        final bool parentIsFlexItem = parentStyle.isParentRenderFlexLayout();
        // Whether THIS element is a flex item (its own parent is a flex container).
        // When true, width:auto must not be stretched to the parent’s width in the main axis;
        // the flex base size is content-based per CSS Flexbox §9.2.
        final bool thisIsFlexItem = isParentRenderFlexLayout();

        // Case A: inside a flex item — stretch block-level auto width to the flex item's measured width.
        // For WebF widget elements (custom elements backed by Flutter widgets), only use the
        // direct constraints exposed via `WebFWidgetElementChild` instead of inferring from
        // the RenderWidget's own content constraints, which can vary by adapter implementation.
        if (parentIsFlexItem && !thisIsFlexItem &&
            !renderStyle.isSelfRenderReplaced() &&
            renderStyle.position != CSSPositionType.absolute &&
            renderStyle.position != CSSPositionType.fixed) {
          if (parentStyle.isSelfRenderWidget()) {
            RenderWidgetElementChild? childWrapper = target.attachedRenderer?.findWidgetElementChild();
            double? maxConstraintWidth;
            try {
              maxConstraintWidth = childWrapper?.constraints.maxWidth;
            } catch (_) {}

            if (childWrapper != null && maxConstraintWidth != null) {
              logicalWidth = maxConstraintWidth;
            }
            // If there is no WebFWidgetElementChild (or no constraints yet),
            // fall through and let the parent (flex) constraints logic handle it.
          } else {
            final RenderBoxModel? parentBox = parentStyle.attachedRenderBoxModel;
            final BoxConstraints? pcc = parentBox?.contentConstraints;
            if (pcc != null && pcc.hasBoundedWidth && pcc.maxWidth.isFinite) {
              logicalWidth = pcc.maxWidth - renderStyle.margin.horizontal;
            }
          }

        // Case B: normal flow (not inside a flex item) — find the nearest non-inline ancestor
        // and adopt its content box logical width or bounded content constraints.
        } else if (!parentIsFlexItem &&
            !renderStyle.isSelfRenderReplaced() &&
            renderStyle.position != CSSPositionType.absolute &&
            renderStyle.position != CSSPositionType.fixed &&
            !renderStyle.isParentRenderFlexLayout()) {
          RenderStyle? ancestorRenderStyle = _findAncestorWithNoDisplayInline();
          // Should ignore renderStyle of display inline when searching for ancestors to stretch width.
          if (ancestorRenderStyle != null) {
            RenderWidgetElementChild? childWrapper = target.attachedRenderer?.findWidgetElementChild();
            double? maxConstraintWidth;
            try {
              maxConstraintWidth = childWrapper?.constraints.maxWidth;
            } catch (_) {}

            if (ancestorRenderStyle.isSelfRenderWidget() && childWrapper != null && maxConstraintWidth != null) {
              logicalWidth = maxConstraintWidth;
            } else {
              logicalWidth = ancestorRenderStyle.contentBoxLogicalWidth;
            }

            // No fallback to unrelated ancestors for flex scenarios here; if ancestor is a
            // flex item but has no bounded width yet, defer stretching (leave null).

            // Should subtract horizontal margin of own from its parent content width.
            if (logicalWidth != null) {
              logicalWidth -= renderStyle.margin.horizontal;
            }
          }
        }
      }
    } else if (effectiveDisplay == CSSDisplay.inlineBlock ||
        effectiveDisplay == CSSDisplay.inlineFlex ||
        effectiveDisplay == CSSDisplay.inlineGrid ||
        effectiveDisplay == CSSDisplay.inline) {
      if (logicalWidth == null && renderStyle.width.isNotAuto) {
        logicalWidth = renderStyle.width.computedValue;
      }
    }

    // Get width by aspect ratio if width is auto.
    if (logicalWidth == null && aspectRatio != null) {
      // If a definite height is specified, prefer converting via the preferred aspect-ratio.
      if (renderStyle.height.isNotAuto) {
        double contentH = renderStyle.height.computedValue - renderStyle.border.vertical - renderStyle.padding.vertical;
        contentH = math.max(0, contentH);
        final double contentW = contentH * aspectRatio!;
        logicalWidth = contentW + renderStyle.border.horizontal + renderStyle.padding.horizontal;
      }
      // Fallback for replaced/intrinsic scenarios.
      logicalWidth ??= renderStyle.getWidthByAspectRatio();
    }

    // Constrain width by min-width and max-width.
    if (renderStyle.minWidth.isNotAuto) {
      double minWidth = renderStyle.minWidth.computedValue;
      if (logicalWidth != null && logicalWidth < minWidth) {
        logicalWidth = minWidth;
      }
    }
    if (renderStyle.maxWidth.isNotNone) {
      double maxWidth = renderStyle.maxWidth.computedValue;
      if (logicalWidth != null && logicalWidth > maxWidth) {
        logicalWidth = maxWidth;
      }
    }

    double? logicalContentWidth;
    // Subtract padding and border width to get content width.
    if (logicalWidth != null) {
      logicalContentWidth = logicalWidth - renderStyle.border.horizontal - renderStyle.padding.horizontal;
      // Logical width may be smaller than its border and padding width,
      // in this case, content width will be negative which is illegal.
      logicalContentWidth = math.max(0, logicalContentWidth);
    }

    _contentBoxLogicalWidth = logicalContentWidth;
  }

  // Compute the content box height from render style.
  void computeContentBoxLogicalHeight() {
    RenderStyle renderStyle = this;
    double? logicalHeight;

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;

    // Height applies to all elements except non-replaced inline elements.
    // https://drafts.csswg.org/css-sizing-3/#propdef-height
    if (effectiveDisplay == CSSDisplay.inline && !renderStyle.isSelfRenderReplaced()) {
      _contentBoxLogicalHeight = null;
      return;
    } else {
      // Intrinsic sizing keywords (min-content/max-content/fit-content) depend on layout and
      // do not establish a definite containing block height for percentage resolution.
      // Treat them like auto here and let the layout algorithm determine the used height.
      if (renderStyle.height.isIntrinsic) {
        logicalHeight = null;
      } else if (renderStyle.height.isNotAuto) {
        logicalHeight = renderStyle.height.computedValue;
      } else if (aspectRatio != null && renderStyle.width.isNotAuto) {
        // Prefer aspect-ratio when width is definite and height is auto.
        double contentW = renderStyle.width.computedValue - renderStyle.border.horizontal - renderStyle.padding.horizontal;
        contentW = math.max(0, contentW);
        final double contentH = contentW / aspectRatio!;
        logicalHeight = contentH + renderStyle.border.vertical + renderStyle.padding.vertical;
      } else if (renderStyle.isSelfHTMLElement()) {
        logicalHeight = renderStyle.target.ownerView.currentViewport!.boxSize!.height;
      } else if ((renderStyle.position == CSSPositionType.absolute || renderStyle.position == CSSPositionType.fixed) &&
          !renderStyle.isSelfRenderReplaced() &&
          renderStyle.height.isAuto &&
          renderStyle.top.isNotAuto &&
          renderStyle.bottom.isNotAuto) {
        // The height of positioned, non-replaced element is determined as following algorithm.
        // https://www.w3.org/TR/css-position-3/#abs-non-replaced-height
        if (!renderStyle.isParentRenderBoxModel()) {
          logicalHeight = null;
        }
        // Should access the renderStyle of renderBoxModel parent but not renderStyle parent
        // cause the element of renderStyle parent may not equal to containing block.
        // RenderBoxModel parent = current.parent as RenderBoxModel;
        // Get the renderStyle of outer scrolling box cause the renderStyle of scrolling
        // content box is only a fraction of the complete renderStyle.
        RenderStyle parentRenderStyle = renderStyle.getAttachedRenderParentRenderStyle()!;
        // Height of positioned element should subtract its vertical margin.
        logicalHeight = (parentRenderStyle.paddingBoxLogicalHeight ?? 0) -
            renderStyle.top.computedValue -
            renderStyle.bottom.computedValue -
            renderStyle.marginTop.computedValue -
            renderStyle.marginBottom.computedValue;
      } else {
        CSSRenderStyle? parentRenderStyle = renderStyle.getAttachedRenderParentRenderStyle();

        if (parentRenderStyle != null) {
          RenderWidgetElementChild? childWrapper = target.attachedRenderer?.findWidgetElementChild();
          BoxConstraints? childWrapperConstraints;
          try {
            childWrapperConstraints = childWrapper?.constraints;
          } catch (_) {}
          // Override the default logicalHeight value is the parent is RenderWidget
          if (parentRenderStyle.isSelfRenderWidget() &&
              childWrapper != null &&
              childWrapperConstraints != null &&
              (childWrapperConstraints.maxHeight.isFinite &&
                  childWrapperConstraints.maxHeight != renderStyle.target.ownerView.currentViewport!.boxSize!.height)) {
            logicalHeight = childWrapperConstraints.maxHeight;
          } else if (renderStyle.isHeightStretch) {
            logicalHeight = parentRenderStyle.contentBoxLogicalHeight;
          }

          // Should subtract vertical margin of own from its parent content height.
          if (logicalHeight != null) {
            logicalHeight -= renderStyle.margin.vertical;
          }
        }
      }
    }

    // Get height by aspect ratio if height is auto.
    if (logicalHeight == null && aspectRatio != null) {
      // If a definite width is specified, prefer converting via the preferred aspect-ratio.
      if (renderStyle.width.isNotAuto) {
        double contentW = renderStyle.width.computedValue - renderStyle.border.horizontal - renderStyle.padding.horizontal;
        contentW = math.max(0, contentW);
        final double contentH = contentW / aspectRatio!;
        logicalHeight = contentH + renderStyle.border.vertical + renderStyle.padding.vertical;
      }
      // Fallback for replaced/intrinsic scenarios.
      logicalHeight ??= renderStyle.getHeightByAspectRatio();
    }

    // Constrain height by min-height and max-height.
    if (renderStyle.minHeight.isNotAuto) {
      double minHeight = renderStyle.minHeight.computedValue;
      if (logicalHeight != null && logicalHeight < minHeight) {
        logicalHeight = minHeight;
      }
    }
    if (renderStyle.maxHeight.isNotNone) {
      double maxHeight = renderStyle.maxHeight.computedValue;
      if (logicalHeight != null && logicalHeight > maxHeight) {
        logicalHeight = maxHeight;
      }
    }

    double? logicalContentHeight;
    // Subtract padding and border width to get content width.
    if (logicalHeight != null) {
      logicalContentHeight = logicalHeight - renderStyle.border.vertical - renderStyle.padding.vertical;
      // Logical height may be smaller than its border and padding width,
      // in this case, content height will be negative which is illegal.
      logicalContentHeight = math.max(0, logicalContentHeight);
    }

    _contentBoxLogicalHeight = logicalContentHeight;
  }

  // Whether height is stretched to fill its parent's content height.
  @override
  bool get isHeightStretch {
    RenderStyle renderStyle = this;
    CSSRenderStyle? parentRenderStyle = renderStyle.getAttachedRenderParentRenderStyle();
    if (parentRenderStyle == null) {
      return false;
    }
    bool isStretch = false;

    bool isParentFlex =
        parentRenderStyle.display == CSSDisplay.flex || parentRenderStyle.display == CSSDisplay.inlineFlex;
    bool isHorizontalDirection = false;
    bool isFlexNoWrap = false;
    bool isChildStretchSelf = false;
    if (isParentFlex) {
      // The absolutely-positioned box is considered to be “fixed-size”, a value of stretch
      // is treated the same as flex-start.
      // https://www.w3.org/TR/css-flexbox-1/#abspos-items
      bool isPositioned =
          renderStyle.position == CSSPositionType.absolute || renderStyle.position == CSSPositionType.fixed;
      if (isPositioned) {
        return false;
      }

      isHorizontalDirection = CSSFlex.isHorizontalFlexDirection(parentRenderStyle.flexDirection);
      isFlexNoWrap = parentRenderStyle.flexWrap != FlexWrap.wrap && parentRenderStyle.flexWrap != FlexWrap.wrapReverse;
      isChildStretchSelf = renderStyle.alignSelf != AlignSelf.auto
          ? renderStyle.alignSelf == AlignSelf.stretch
          : parentRenderStyle.alignItems == AlignItems.stretch;
    }

    CSSLengthValue marginTop = renderStyle.marginTop;
    CSSLengthValue marginBottom = renderStyle.marginBottom;

    // Display as block if flex vertical layout children and stretch children
    if (marginTop.isNotAuto &&
        marginBottom.isNotAuto &&
        isParentFlex &&
        isHorizontalDirection &&
        isFlexNoWrap &&
        isChildStretchSelf) {
      isStretch = true;
    }

    return isStretch;
  }

  // Max width to constrain its children, used in deciding the line wrapping timing of layout.
  @override
  double get contentMaxConstraintsWidth {
    // If renderBoxModel definite content constraints, use it as max constrains width of content.
    BoxConstraints? contentConstraints = this.contentConstraints();
    if (contentConstraints != null && contentConstraints.maxWidth != double.infinity) {
      return contentConstraints.maxWidth;
    }

    double contentMaxConstraintsWidth = double.infinity;
    RenderStyle renderStyle = this;
    double? borderBoxLogicalWidth;
    RenderStyle? ancestorRenderStyle = _findAncestorWithContentBoxLogicalWidth();

    // If renderBoxModel has no logical width (eg. display is inline-block/inline-flex and
    // has no width), the child width is constrained by its closest ancestor who has definite logical content box width.
    if (ancestorRenderStyle != null) {
      borderBoxLogicalWidth = ancestorRenderStyle.contentBoxLogicalWidth;
    }

    if (borderBoxLogicalWidth != null) {
      contentMaxConstraintsWidth =
          borderBoxLogicalWidth - renderStyle.border.horizontal - renderStyle.padding.horizontal;
      // Logical width may be smaller than its border and padding width,
      // in this case, content width will be negative which is illegal.
      // <div style="width: 300px;">
      //   <div style="display: inline-block; padding: 0 200px;">
      //   </div>
      // </div>
      contentMaxConstraintsWidth = math.max(0, contentMaxConstraintsWidth);
    }

    return contentMaxConstraintsWidth;
  }

  @override
  void cleanContentBoxLogiclWidth() {
    _contentBoxLogicalWidth = double.infinity;
  }

  @override
  void cleanContentBoxLogiclHeight() {
    _contentBoxLogicalHeight = double.infinity;
  }

  // Content width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // Use double.infinity refers to the value is not computed yet.
  double? _contentBoxLogicalWidth = double.infinity;

  @override
  double? get contentBoxLogicalWidth {
    // If renderBox has tight width, its logical size equals max size.
    // Compute logical width directly in case as renderBoxModel is not layouted yet,
    // eg. compute percentage length before layout.
    if (_contentBoxLogicalWidth == double.infinity) {
      // Ensure parent layout is complete before resolving child percentages
      CSSRenderStyle? parentStyle = getAttachedRenderParentRenderStyle();
      if (parentStyle != null && parentStyle._contentBoxLogicalWidth == double.infinity) {
        parentStyle.computeContentBoxLogicalWidth();
      }
      computeContentBoxLogicalWidth();
    }
    return _contentBoxLogicalWidth;
  }

  set contentBoxLogicalWidth(double? value) {
    if (_contentBoxLogicalWidth == value) return;
    _contentBoxLogicalWidth = value;
  }

  // Content height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  // Use double.infinity refers to the value is not computed yet.
  double? _contentBoxLogicalHeight = double.infinity;

  @override
  double? get contentBoxLogicalHeight {
    // Compute logical height directly in case as renderBoxModel is not layouted yet,
    // eg. compute percentage length before layout.
    if (_contentBoxLogicalHeight == double.infinity) {
      computeContentBoxLogicalHeight();
    }
    return _contentBoxLogicalHeight;
  }

  set contentBoxLogicalHeight(double? value) {
    if (_contentBoxLogicalHeight == value) return;
    _contentBoxLogicalHeight = value;
  }

  // Padding box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxLogicalWidth {
    if (contentBoxLogicalWidth == null) {
      return null;
    }
    return contentBoxLogicalWidth! + paddingLeft.computedValue + paddingRight.computedValue;
  }

  // Padding box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxLogicalHeight {
    if (contentBoxLogicalHeight == null) {
      return null;
    }
    return contentBoxLogicalHeight! + paddingTop.computedValue + paddingBottom.computedValue;
  }

  // Border box width calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxLogicalWidth {
    if (paddingBoxLogicalWidth == null) {
      return null;
    }
    return paddingBoxLogicalWidth! + effectiveBorderLeftWidth.computedValue + effectiveBorderRightWidth.computedValue;
  }

  // Border box height calculated from renderStyle tree.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxLogicalHeight {
    if (paddingBoxLogicalHeight == null) {
      return null;
    }
    return paddingBoxLogicalHeight! + effectiveBorderTopWidth.computedValue + effectiveBorderBottomWidth.computedValue;
  }

  // Border box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxWidth {
    if (isBoxModelHaveSize()) {
      return getSelfRenderBoxValue((renderBoxModel, _) => renderBoxModel.boxSize!.width);
    }
    return null;
  }

  // Border box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-border-box
  @override
  double? get borderBoxHeight {
    if (isBoxModelHaveSize()) {
      return getSelfRenderBoxValue((renderBoxModel, _) => renderBoxModel.boxSize!.height);
    }
    return null;
  }

  // Padding box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxWidth {
    if (borderBoxWidth == null) {
      return null;
    }
    return borderBoxWidth! - effectiveBorderLeftWidth.computedValue - effectiveBorderRightWidth.computedValue;
  }

  // Padding box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-padding-box
  @override
  double? get paddingBoxHeight {
    if (borderBoxHeight == null) {
      return null;
    }
    return borderBoxHeight! - effectiveBorderTopWidth.computedValue - effectiveBorderBottomWidth.computedValue;
  }

  // Content box width of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  @override
  double? get contentBoxWidth {
    if (paddingBoxWidth == null) {
      return null;
    }
    return paddingBoxWidth! - paddingLeft.computedValue - paddingRight.computedValue;
  }

  // Content box height of renderBoxModel after it was rendered.
  // https://www.w3.org/TR/css-box-3/#valdef-box-content-box
  @override
  double? get contentBoxHeight {
    if (paddingBoxHeight == null) {
      return null;
    }
    return paddingBoxHeight! - paddingTop.computedValue - paddingBottom.computedValue;
  }

  RenderWidget _createRenderWidget({RenderWidget? previousRenderWidget, bool isRepaintBoundary = false}) {
    RenderWidget nextReplaced;

    if (previousRenderWidget == null) {
      if (isRepaintBoundary) {
        nextReplaced = RenderRepaintBoundaryWidget(
          renderStyle: this,
        );
      } else {
        nextReplaced = RenderWidget(
          renderStyle: this,
        );
      }
    } else {
      nextReplaced = previousRenderWidget;
    }
    return nextReplaced;
  }

  // Create renderLayoutBox if type changed and copy children if there has previous renderLayoutBox.
  RenderBoxModel createRenderLayout({bool isRepaintBoundary = false}) {
    CSSDisplay display = this.display;
    RenderBoxModel nextRenderLayoutBox;

    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      if (isRepaintBoundary) {
        nextRenderLayoutBox = RenderRepaintBoundaryFlexLayout(
          renderStyle: this,
        );
      } else {
        nextRenderLayoutBox = RenderFlexLayout(
          renderStyle: this,
        );
      }
    } else if (display == CSSDisplay.grid || display == CSSDisplay.inlineGrid) {
      // Grid containers: create the grid render layout. For MVP, RenderGridLayout
      // inherits flow behavior and will be extended in subsequent steps.
      if (isRepaintBoundary) {
        nextRenderLayoutBox = RepaintBoundaryGridLayout(
          renderStyle: this
        );
      } else {
        nextRenderLayoutBox = RenderGridLayout(
          renderStyle: this,
        );
      }
    } else if (display == CSSDisplay.block ||
        display == CSSDisplay.none ||
        display == CSSDisplay.inline ||
        display == CSSDisplay.inlineBlock) {
      if (isRepaintBoundary) {
        nextRenderLayoutBox = RenderRepaintBoundaryFlowLayoutNext(
          renderStyle: this,
        );
      } else {
        nextRenderLayoutBox = RenderFlowLayout(
          renderStyle: this,
        );
      }
    } else {
      throw FlutterError('Not supported display type $display');
    }

    return nextRenderLayoutBox;
  }

  RenderReplaced _createRenderReplaced({bool isRepaintBoundary = false}) {
    RenderReplaced nextReplaced;

    if (isRepaintBoundary) {
      nextReplaced = RenderRepaintBoundaryReplaced(
        this,
      );
    } else {
      nextReplaced = RenderReplaced(
        this,
      );
    }
    return nextReplaced;
  }

  /// Check if anonymous block boxes should be created for inline elements.
  /// According to CSS spec, anonymous block boxes are needed when:
  /// 1. A block-level element is a child of an inline element
  /// 2. Inline content needs to be wrapped to maintain proper formatting context
  ///
  /// This function helps determine when the layout engine should generate
  /// anonymous block boxes to properly handle mixed inline/block content.
  ///
  /// Example usage:
  /// ```dart
  /// if (renderStyle.shouldCreateAnonymousBlockBoxForInlineElements()) {
  ///   // Create anonymous block boxes to wrap inline content
  ///   // before and after the block-level children
  /// }
  /// ```
  ///
  /// Returns true if anonymous block boxes are needed, false otherwise.
  bool shouldCreateAnonymousBlockBoxForInlineElements() {
    // Only check for inline elements
    if (display != CSSDisplay.inline) {
      return false;
    }

    // Check if this inline element contains any block-level children
    final element = target;
    bool hasBlockLevelChild = false;

    for (var child in element.childNodes) {
      if (child is Element) {
        final childDisplay = child.renderStyle.display;
        final childPosition = child.renderStyle.position;

        // Skip positioned elements (they're out of flow)
        if (childPosition == CSSPositionType.absolute || childPosition == CSSPositionType.fixed) {
          continue;
        }

        // Check if child is block-level
        if (childDisplay == CSSDisplay.block || childDisplay == CSSDisplay.flex) {
          hasBlockLevelChild = true;
          break;
        }
      }
    }

    // Anonymous block boxes are needed when inline elements contain block-level children
    return hasBlockLevelChild;
  }

  /// Check if this element should establish an inline formatting context.
  /// This method checks from the RenderObject perspective to properly handle
  /// anonymous blocks that may wrap inline elements.
  bool shouldEstablishInlineFormattingContext() {
    // Block and inline-block containers can establish inline formatting contexts
    if (effectiveDisplay != CSSDisplay.block && effectiveDisplay != CSSDisplay.inlineBlock) {
      return false;
    }

    // Per CSS Inline Layout (css-inline-3) and CSS 2.1 §9.4.2, a block container
    // establishes an inline formatting context for its inline-level content
    // regardless of the 'overflow' property. Overflow only affects painting and
    // scrollability (block formatting context establishment), not whether inline
    // content forms line boxes. Therefore, do NOT early-return here when overflow
    // is not visible; allow IFC when the content qualifies.

    // Do not special-case BODY/HTML here. They can also establish IFC
    // when they contain only inline content and no block-level content.

    // Positioned elements (absolute/fixed) are taken out of normal flow with
    // respect to their placement, but their in-flow descendants still form
    // formatting contexts as usual. Per CSS 2.1 §9.4.1 and css-position-3,
    // an absolutely positioned block container with inline-level content
    // still establishes an inline formatting context for its content.
    // Therefore, do NOT block IFC establishment solely due to positioning.

    // Flex items may establish their own IFC; do not block based on parent.

    // Do not suppress IFC solely because the parent is inline-level.
    // A block container inside an inline element creates anonymous block boxes
    // and still establishes an inline formatting context for its inline content
    // per CSS 2.1 §9.2.1.1 and §9.4.2.

    // Check children from RenderObject perspective
    // This properly accounts for anonymous blocks
    return _shouldEstablishIFCFromRenderObject();
  }

  /// Check render objects to determine if inline formatting context is needed
  /// This accounts for anonymous blocks that may have been created
  bool _shouldEstablishIFCFromRenderObject() {
    if (!isSelfRenderFlowLayout()) {
      return false;
    }

    final renderBoxModel = attachedRenderBoxModel as RenderFlowLayout;

    bool hasInlineContent = false;
    bool hasBlockContent = false;

    // Check actual render children instead of DOM nodes
    RenderBox? child = renderBoxModel.firstChild;
    while (child != null) {
      // Check for text content
      if (child is RenderTextBox) {
        // Text nodes indicate inline content
        if (child.data.trim().isNotEmpty) {
          hasInlineContent = true;
        }
      } else if (child is RenderBoxModel) {
        // Special handling: if this is an event listener wrapper, inspect its real child
        if (child is RenderEventListener) {
          final RenderBox? wrapped = child.child;
          if (wrapped is RenderTextBox) {
            if (wrapped.data.trim().isNotEmpty) {
              hasInlineContent = true;
            }
            child = renderBoxModel.childAfter(child);
            continue;
          } else if (wrapped is RenderBoxModel) {
            final childRenderStyle = wrapped.renderStyle;
            final childDisplay = childRenderStyle.display;
            final childPosition = childRenderStyle.position;

            if (childPosition != CSSPositionType.absolute && childPosition != CSSPositionType.fixed) {
              if (wrapped.renderStyle.isSelfAnonymousFlowLayout()) {
                hasInlineContent = true;
              } else if (childDisplay == CSSDisplay.block || childDisplay == CSSDisplay.flex) {
                hasBlockContent = true;
              } else if (childDisplay == CSSDisplay.inline ||
                  childDisplay == CSSDisplay.inlineBlock ||
                  childDisplay == CSSDisplay.inlineFlex) {
                hasInlineContent = true;
              }
            }
            child = renderBoxModel.childAfter(child);
            continue;
          }
        }
        final childRenderStyle = child.renderStyle;
        final childDisplay = childRenderStyle.display;
        final childPosition = childRenderStyle.position;

        // Skip positioned elements (out of flow)
        if (childPosition == CSSPositionType.absolute || childPosition == CSSPositionType.fixed) {
          child = renderBoxModel.childAfter(child);
          continue;
        }

        // Check for anonymous blocks using the built-in method
        if (child.renderStyle.isSelfAnonymousFlowLayout()) {
          // Anonymous blocks contain inline content
          hasInlineContent = true;
        } else if (childDisplay == CSSDisplay.block || childDisplay == CSSDisplay.flex) {
          // Regular block-level content
          hasBlockContent = true;
        } else if (childDisplay == CSSDisplay.inline ||
            childDisplay == CSSDisplay.inlineBlock ||
            childDisplay == CSSDisplay.inlineFlex) {
          // Inline-level content
          hasInlineContent = true;
        }
      } else if (child is RenderPositionPlaceholder) {
        // Position placeholders don't affect IFC decision
        child = renderBoxModel.childAfter(child);
        continue;
      }

      // If we have both inline and block content, we should NOT establish IFC
      // because anonymous blocks should have already been created to handle this
      if (hasInlineContent && hasBlockContent) {
        return false;
      }

      child = renderBoxModel.childAfter(child);
    }

    // Establish IFC if we have inline content (including anonymous blocks)
    // and no regular block content
    final bool establish = hasInlineContent && !hasBlockContent;
    return establish;
  }

  RenderBoxModel createRenderBoxModel() {
    RenderBoxModel nextRenderBoxModel;
    if (target.isWidgetElement) {
      nextRenderBoxModel = _createRenderWidget(isRepaintBoundary: target.isRepaintBoundary);
    } else if (target.isReplacedElement) {
      nextRenderBoxModel = _createRenderReplaced(isRepaintBoundary: target.isRepaintBoundary);
    } else if (target.isSVGElement) {
      nextRenderBoxModel = target.createRenderSVG(isRepaintBoundary: target.isRepaintBoundary);
    } else {
      nextRenderBoxModel = createRenderLayout(isRepaintBoundary: target.isRepaintBoundary);
    }

    return nextRenderBoxModel;
  }

  // Get height of replaced element by aspect ratio if height is not defined.
  @override
  double getHeightByAspectRatio() {
    double contentBoxHeight;
    double borderBoxWidth = width.isAuto ? wrapPaddingBorderWidth(intrinsicWidth) : width.computedValue;
    if (minWidth.isNotAuto && borderBoxWidth < minWidth.computedValue) {
      borderBoxWidth = minWidth.computedValue;
    }
    if (maxWidth.isNotNone && borderBoxWidth > maxWidth.computedValue) {
      borderBoxWidth = maxWidth.computedValue;
    }

    if (borderBoxWidth != 0 && intrinsicWidth != 0) {
      double contentBoxWidth = deflatePaddingBorderWidth(borderBoxWidth);
      contentBoxHeight = contentBoxWidth * intrinsicHeight / intrinsicWidth;
    } else {
      contentBoxHeight = intrinsicHeight;
      if (!minHeight.isAuto && contentBoxHeight < minHeight.computedValue) {
        contentBoxHeight = minHeight.computedValue;
      }
      if (!maxHeight.isNone && contentBoxHeight > maxHeight.computedValue) {
        contentBoxHeight = maxHeight.computedValue;
      }
    }

    double borderBoxHeight = wrapPaddingBorderHeight(contentBoxHeight);

    return borderBoxHeight;
  }

  // Get width of replaced element by aspect ratio if width is not defined.
  @override
  double getWidthByAspectRatio() {
    double contentBoxWidth;

    double borderBoxHeight = height.isAuto ? wrapPaddingBorderHeight(intrinsicHeight) : height.computedValue;
    if (!minHeight.isAuto && borderBoxHeight < minHeight.computedValue) {
      borderBoxHeight = minHeight.computedValue;
    }
    if (!maxHeight.isNone && borderBoxHeight > maxHeight.computedValue) {
      borderBoxHeight = maxHeight.computedValue;
    }

    if (borderBoxHeight != 0 && intrinsicHeight != 0) {
      double contentBoxHeight = deflatePaddingBorderHeight(borderBoxHeight);
      contentBoxWidth = contentBoxHeight * intrinsicWidth / intrinsicHeight;
    } else {
      contentBoxWidth = intrinsicWidth;
      if (minWidth.isNotAuto && contentBoxWidth < minWidth.computedValue) {
        contentBoxWidth = minWidth.computedValue;
      }
      if (maxWidth.isNotNone && contentBoxWidth > maxWidth.computedValue) {
        contentBoxWidth = maxWidth.computedValue;
      }
    }

    double borderBoxWidth = wrapPaddingBorderWidth(contentBoxWidth);

    return borderBoxWidth;
  }

  // Mark this node as detached.
  void detach() {
    // Clear reference to it's parent.
    backgroundImage = null;
  }

  // Find ancestor render style with display of not inline.
  RenderStyle? _findAncestorWithNoDisplayInline() {
    RenderStyle renderStyle = this;
    CSSRenderStyle? parentRenderStyle = renderStyle.getAttachedRenderParentRenderStyle();
    while (parentRenderStyle != null) {
      // If ancestor element is WidgetElement, should return it because should get maxWidth of constraints for logicalWidth.
      if (parentRenderStyle.effectiveDisplay != CSSDisplay.inline ||
          parentRenderStyle.target.renderObjectManagerType == RenderObjectManagerType.FLUTTER_ELEMENT) {
        break;
      }
      parentRenderStyle = parentRenderStyle.getAttachedRenderParentRenderStyle<CSSRenderStyle>();
    }
    return parentRenderStyle;
  }

  // Find ancestor render style with definite content box logical width.
  RenderStyle? _findAncestorWithContentBoxLogicalWidth() {
    RenderStyle renderStyle = this;
    RenderStyle? parentRenderStyle = renderStyle.getAttachedRenderParentRenderStyle();

    while (parentRenderStyle != null) {
      RenderStyle? grandParentRenderStyle = parentRenderStyle.getAttachedRenderParentRenderStyle();
      // Flex item with flex-shrink 0 and no width/max-width will have infinity constraints
      // even if parents have width when flex direction is row.
      if (grandParentRenderStyle != null) {
        bool isGrandParentFlex = grandParentRenderStyle.display == CSSDisplay.flex ||
            grandParentRenderStyle.display == CSSDisplay.inlineFlex;
        bool isHorizontalDirection = CSSFlex.isHorizontalFlexDirection(grandParentRenderStyle.flexDirection);
        if (isGrandParentFlex &&
            isHorizontalDirection &&
            parentRenderStyle.flexShrink == 0 &&
            parentRenderStyle.contentBoxLogicalWidth == null &&
            parentRenderStyle.maxWidth.value == null) {
          return null;
        }
      }

      if (parentRenderStyle.contentBoxLogicalWidth != null) {
        break;
      }

      parentRenderStyle = grandParentRenderStyle;
    }
    return parentRenderStyle;
  }

  // Whether current renderStyle is ancestor for child renderStyle in the renderStyle tree.
  bool isAncestorOf(RenderStyle childRenderStyle) {
    Element? childElement = childRenderStyle.target;
    Element? parentElement = childElement.parentElement;
    while (parentElement != null) {
      if (parentElement.renderStyle == this) {
        return true;
      }
      parentElement = parentElement.parentElement;
    }
    return false;
  }

  // Add padding and border to content-box height to get border-box height.
  double wrapPaddingBorderHeight(double contentBoxHeight) {
    return contentBoxHeight + paddingTop.computedValue + paddingBottom.computedValue + border.top + border.bottom;
  }

  // Add padding and border to content-box width to get border-box width.
  double wrapPaddingBorderWidth(double contentBoxWidth) {
    return contentBoxWidth + paddingLeft.computedValue + paddingRight.computedValue + border.left + border.right;
  }

  // Subtract padding and border to border-box height to get content-box height.
  double deflatePaddingBorderHeight(double borderBoxHeight) {
    return borderBoxHeight - paddingTop.computedValue - paddingBottom.computedValue - border.top - border.bottom;
  }

  // Subtract padding and border to border-box width to get content-box width.
  double deflatePaddingBorderWidth(double borderBoxWidth) {
    return borderBoxWidth - paddingLeft.computedValue - paddingRight.computedValue - border.left - border.right;
  }
}

// Writing-mode support (minimal): determines whether the inline axis is horizontal or vertical.
// This influences flex main/cross axis mapping in components that opt-in.
enum CSSWritingMode { horizontalTb, verticalRl, verticalLr }

mixin CSSWritingModeMixin on RenderStyle {
  CSSWritingMode get writingMode => _writingMode ?? CSSWritingMode.horizontalTb;
  CSSWritingMode? _writingMode;
  set writingMode(CSSWritingMode value) {
    if (_writingMode == value) return;
    _writingMode = value;
    if (isSelfRenderFlexLayout()) {
      markNeedsLayout();
    }
  }

  // Regex matching var(...) with minimal nesting support.
  static final RegExp _inlineVarFunctionRegExp = RegExp(r'var\(([^()]*\(.*?\)[^()]*)\)|var\(([^()]*)\)');

  static bool _isEntireVarFunction(String s) {
    final String trimmed = s.trimLeft();
    if (!trimmed.startsWith('var(')) return false;
    int start = trimmed.indexOf('(');
    int depth = 0;
    for (int i = start; i < trimmed.length; i++) {
      final int ch = trimmed.codeUnitAt(i);
      if (ch == 40) {
        depth++;
      } else if (ch == 41) {
        depth--;
        if (depth == 0) {
          final rest = trimmed.substring(i + 1).trim();
          return rest.isEmpty;
        }
      }
    }
    return false;
  }

  static String expandInlineVars(String input, RenderStyle renderStyle, String propertyName) {
    if (!input.contains('var(')) return input;
    String result = input;
    int guard = 0;
    while (result.contains('var(') && guard++ < 8) {
      final before = result;
      result = result.replaceAllMapped(_inlineVarFunctionRegExp, (Match match) {
        final String? varString = match[0];
        if (varString == null) return '';
        final CSSVariable? variable = CSSVariable.tryParse(renderStyle, varString);
        if (variable == null) return varString; // keep as-is

        final depKey = '${propertyName}_$input';
        final dynamic raw = renderStyle.getCSSVariable(variable.identifier, depKey);

        if (raw == null || raw == INITIAL) {
          // Use fallback if provided; otherwise preserve var(...) so the
          // property fails to parse and becomes invalid/inherited.
          final fallback = variable.defaultValue;
          return fallback?.toString() ?? varString;
        }
        // Avoid accidental token concatenation per CSS Variables spec: substitution
        // must not re-tokenize. When the replacement's boundary characters and
        // surrounding characters are ident-like, insert whitespace to keep tokens
        // separate (e.g., var(--b)red -> 'orange red', not 'orangered').
        bool isIdentCode(int c) {
          return (c >= 48 && c <= 57) || // 0-9
              (c >= 65 && c <= 90) || // A-Z
              (c >= 97 && c <= 122) || // a-z
              c == 45 || // '-'
              c == 95; // '_'
        }
        final int start = match.start;
        final int end = match.end;
        final int? leftChar = start > 0 ? before.codeUnitAt(start - 1) : null;
        final int? rightChar = end < before.length ? before.codeUnitAt(end) : null;
        String rep = raw.toString();
        String trimmed = rep.trim();
        final int? repFirst = trimmed.isNotEmpty ? trimmed.codeUnitAt(0) : null;
        final int? repLast = trimmed.isNotEmpty ? trimmed.codeUnitAt(trimmed.length - 1) : null;
        final bool addLeftSpace = leftChar != null && repFirst != null && isIdentCode(leftChar) && isIdentCode(repFirst);
        final bool addRightSpace = rightChar != null && repLast != null && isIdentCode(repLast) && isIdentCode(rightChar);
        if (addLeftSpace) rep = ' $rep';
        if (addRightSpace) rep = '$rep ';
        return rep;
      });
      if (result == before) break;
    }

    return result;
  }

  static CSSWritingMode resolveWritingMode(String raw) {
    switch (raw) {
      case 'vertical-rl':
        return CSSWritingMode.verticalRl;
      case 'vertical-lr':
        return CSSWritingMode.verticalLr;
      case 'horizontal-tb':
      default:
        return CSSWritingMode.horizontalTb;
    }
  }
}
