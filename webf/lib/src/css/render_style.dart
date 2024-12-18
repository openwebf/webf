/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';
import 'package:webf/widget.dart';
import 'package:webf/src/css/css_animation.dart';
import 'package:webf/src/svg/rendering/shape.dart';

import 'svg.dart';

typedef RenderStyleVisitor<T extends RenderObject> = void Function(T renderObject);

enum RenderObjectUpdateReason {
  updateChildNodes,
  updateRenderReplaced,
  toRepaintBoundary
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
abstract class RenderStyle extends DiagnosticableTree {
  // Common
  Element get target;

  RenderStyle? get parent;

  dynamic getProperty(String key);

  /// Resolve the style value.
  dynamic resolveValue(String property, String present);

  // CSSVariable
  dynamic getCSSVariable(String identifier, String propertyName);

  void setCSSVariable(String identifier, String value);

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

  List<String>? get fontFamily;

  List<Shadow>? get textShadow;

  WhiteSpace get whiteSpace;

  TextOverflow get textOverflow;

  TextAlign get textAlign;

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

  AlignItems get alignItems;

  AlignContent get alignContent;

  AlignSelf get alignSelf;

  CSSLengthValue? get flexBasis;

  double get flexGrow;

  double get flexShrink;

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

  // SVG
  CSSPaint get fill;

  CSSPaint get stroke;

  CSSLengthValue get x;

  CSSLengthValue get y;

  CSSLengthValue get rx;

  CSSLengthValue get ry;

  CSSLengthValue get cx;

  CSSLengthValue get cy;

  CSSLengthValue get r;

  CSSLengthValue get strokeWidth;

  CSSPath get d;

  CSSFillRule get fillRule;

  CSSStrokeLinecap get strokeLinecap;

  CSSStrokeLinejoin get strokeLinejoin;

  CSSLengthValue get x1;

  CSSLengthValue get y1;

  CSSLengthValue get x2;

  CSSLengthValue get y2;

  void addFontRelativeProperty(String propertyName);

  void addRootFontRelativeProperty(String propertyName);

  void addColorRelativeProperty(String propertyName);

  void addViewportSizeRelativeProperty();

  double getWidthByAspectRatio();

  double getHeightByAspectRatio();

  RenderBoxModel? _domRenderObjects;
  final Map<flutter.RenderObjectElement, RenderBoxModel> _widgetRenderObjects = {};

  Map<flutter.RenderObjectElement, RenderBoxModel> get widgetRenderObjects => _widgetRenderObjects;

  Iterable<RenderBoxModel> get widgetRenderObjectIterator => _widgetRenderObjects.values;

  // For some style changes, we needs to upgrade
  void requestWidgetToRebuild(RenderObjectUpdateReason reason) {
    _widgetRenderObjects.keys.forEach((element) {
      if (element is WebRenderLayoutRenderObjectElement) {
        element.requestForBuild();
      } else if (element is RenderWidgetElement) {
        element.requestForBuild();
      } else if (element is WebFRenderReplacedRenderObjectElement) {
        element.requestForBuild(reason);
      }
    });
  }

  bool someRenderBoxSatisfy(SomeRenderBoxModelHandlerCallback callback) {
    for (var renderBoxModel in widgetRenderObjectIterator) {
      bool success = callback(renderBoxModel);
      if (success) {
        return success;
      }
    }

    if (domRenderBoxModel != null) {
      return callback(domRenderBoxModel!);
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  bool isDocumentRootBox() {
    return _domRenderObjects?.isDocumentRootBox == true;
  }

  @pragma('vm:prefer-inline')
  bool isParentDocumentRootBox() {
    if (_domRenderObjects?.parent is! RenderBoxModel) return false;
    return (_domRenderObjects!.parent as RenderBoxModel).isDocumentRootBox;
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderViewportBox() {
    return _domRenderObjects?.parent is RenderViewportBox;
  }

  @pragma('vm:prefer-inline')
  bool hasRenderBox() {
    return _widgetRenderObjects.isNotEmpty || domRenderBoxModel != null;
  }

  RenderBoxModel? getSelfRenderBox(flutter.RenderObjectElement? flutterWidgetElement) {
    if (flutterWidgetElement == null) {
      return _domRenderObjects;
    }
    return _widgetRenderObjects[flutterWidgetElement];
  }

  @pragma('vm:prefer-inline')
  bool isSelfScrollingContentBox() {
    return everyRenderObjectByTypeAndMatch(RenderObjectGetType.self,
        (renderObject, _) => renderObject is RenderBoxModel && renderObject.isScrollingContentBox);
  }

  @pragma('vm:prefer-inline')
  bool isSelfParentDataAreRenderLayoutParentData() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject?.parentData is RenderLayoutParentData);
  }

  @pragma('vm:prefer-inline')
  CSSRenderStyle? getScrollContentRenderStyle() {
    if (target.managedByFlutterWidget) {
      for (var renderBoxModel in widgetRenderObjectIterator) {
        if (renderBoxModel is RenderLayoutBox) {
          return renderBoxModel.renderScrollingContent?.renderStyle;
        }
      }
      return null;
    }

    if (_domRenderObjects is RenderLayoutBox) {
      RenderLayoutBox? scrollingContentBox = (_domRenderObjects as RenderLayoutBox).renderScrollingContent;
      return scrollingContentBox?.renderStyle;
    }

    return null;
  }

  @pragma('vm:prefer-inline')
  bool isParentScrollingContentBox() {
    return everyRenderObjectByTypeAndMatch(RenderObjectGetType.parent,
        (renderObject, _) => renderObject is RenderBoxModel && renderObject.isScrollingContentBox);
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderBoxModel() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.parent, (renderObject, _) => renderObject is RenderBoxModel);
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderBox() {
    return everyRenderObjectByTypeAndMatch(RenderObjectGetType.parent, (renderObject, _) => renderObject is RenderBox);
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderLayoutBox() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.parent, (renderObject, _) => renderObject is RenderLayoutBox);
  }

  @pragma('vm:prefer-inline')
  bool isParentRenderFlexLayout() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.parent, (renderObject, _) => renderObject is RenderFlexLayout);
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
  bool isNextSiblingAreRenderBoxModel() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.nextSibling, (renderObject, _) => renderObject is RenderBoxModel);
  }

  @pragma('vm:prefer-inline')
  bool isPreviousSiblingAreRenderObject() {
    return everyAttachedRenderObjectByTypeAndMatch(
        RenderObjectGetType.previousSibling, (renderObject, _) => renderObject is RenderObject);
  }

  @pragma('vm:prefer-inline')
  bool isFirstChildAreRenderFlowLayoutBox() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.firstChild, (renderObject, _) => renderObject is RenderFlowLayout);
  }

  @pragma('vm:prefer-inline')
  bool isLastChildAreRenderLayoutBox() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.lastChild, (renderObject, _) => renderObject is RenderLayoutBox);
  }

  @pragma('vm:prefer-inline')
  bool isFirstChildAreRenderBoxModel() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.firstChild, (renderObject, _) => renderObject is RenderBoxModel);
  }

  @pragma('vm:prefer-inline')
  bool isLastChildAreRenderBoxModel() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.lastChild, (renderObject, _) => renderObject is RenderBoxModel);
  }

  @pragma('vm:prefer-inline')
  bool isFirstChildStyleMatch(RenderStyleMatcher matcher) {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.firstChild, (_, renderStyle) => renderStyle != null ? matcher(renderStyle) : false);
  }

  @pragma('vm:prefer-inline')
  bool isLastChildStyleMatch(RenderStyleMatcher matcher) {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.lastChild, (_, renderStyle) => renderStyle != null ? matcher(renderStyle) : false);
  }

  @pragma('vm:prefer-inline')
  bool isPreviousSiblingStyleMatch(RenderStyleMatcher matcher) {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.previousSibling, (_, renderStyle) => renderStyle != null ? matcher(renderStyle) : false);
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
  bool isSelfRenderFlexLayout() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderFlexLayout);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderFlowLayout() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderFlowLayout);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderSVGShape() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderSVGShape);
  }

  @pragma('vm:prefer-inline')
  bool isSelfContainsRenderPositionPlaceHolder() {
    if (target.managedByFlutterWidget) {
      return false;
    }

    return _domRenderObjects?.renderPositionPlaceholder != null;
  }

  @pragma('vm:prefer-inline')
  bool isPositionHolderParentIsRenderFlexLayout() {
    if (target.managedByFlutterWidget) {
      return false;
    }

    return _domRenderObjects?.renderPositionPlaceholder?.parent is RenderFlexLayout;
  }

  @pragma('vm:prefer-inline')
  bool isPositionHolderParentIsRenderLayoutBox() {
    if (target.managedByFlutterWidget) {
      return false;
    }
    return _domRenderObjects?.renderPositionPlaceholder?.parent is RenderLayoutBox;
  }

  @pragma('vm:prefer-inline')
  bool isSelfPositioned() {
    assert(!target.managedByFlutterWidget, 'Currently not supported in widget mode');
    if (_domRenderObjects?.parentData is RenderLayoutParentData) {
      RenderLayoutParentData childParentData = _domRenderObjects?.parentData as RenderLayoutParentData;
      return childParentData.isPositioned;
    }
    return false;
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderReplaced() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderReplaced);
  }

  @pragma('vm:prefer-inline')
  bool isSelfRenderLayoutBox() {
    return everyRenderObjectByTypeAndMatch(
        RenderObjectGetType.self, (renderObject, _) => renderObject is RenderLayoutBox);
  }

  @pragma('vm:prefer-inline')
  bool isSelfBoxModelMatch(RenderBoxModelMatcher matcher) {
    return everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, renderStyle) {
      if (renderObject is! RenderBoxModel) return false;

      return matcher(renderObject, renderObject.renderStyle);
    });
  }

  @pragma('vm:prefer-inline')
  bool isSelfBoxModelSizeTight() {
    return everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, renderStyle) {
      if (renderObject is! RenderBoxModel) return false;

      return renderObject.isSizeTight == true;
    });
  }

  @pragma('vm:prefer-inline')
  bool isParentBoxModelMatch(RenderBoxModelMatcher matcher) {
    return everyRenderObjectByTypeAndMatch(RenderObjectGetType.parent, (renderObject, renderStyle) {
      if (renderObject is! RenderBoxModel) return false;

      return matcher(renderObject, renderObject.renderStyle);
    });
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
  T? getFirstChildRenderStyle<T extends RenderStyle>() {
    return getRenderBoxValueByType(RenderObjectGetType.firstChild, (_, renderStyle) => renderStyle) as T?;
  }

  @pragma('vm:prefer-inline')
  T? getLastChildRenderStyle<T extends RenderStyle>() {
    return getRenderBoxValueByType(RenderObjectGetType.lastChild, (_, renderStyle) => renderStyle) as T?;
  }

  @pragma('vm:prefer-inline')
  T? getPreviousSiblingRenderStyle<T extends RenderStyle>() {
    return getRenderBoxValueByType(RenderObjectGetType.previousSibling, (_, renderStyle) => renderStyle) as T?;
  }

  @pragma('vm:prefer-inline')
  T? getNextSiblingRenderStyle<T extends RenderStyle>() {
    return getRenderBoxValueByType(RenderObjectGetType.nextSibling, (_, renderStyle) => renderStyle) as T?;
  }

  @pragma('vm:prefer-inline')
  T? getParentRenderStyle<T extends RenderStyle>() {
    return getRenderBoxValueByType(RenderObjectGetType.parent, (_, renderStyle) => renderStyle) as T?;
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
  Offset getOffset({RenderBoxModel? ancestorRenderBox, bool excludeScrollOffset = false}) {
    // Need to flush layout to get correct size.
    flushLayout();

    // Returns (0, 0) when ancestor is null.
    if (ancestorRenderBox == null) {
      return Offset.zero;
    }

    return getSelfRenderBoxValue((renderBoxModel, _) {
      return renderBoxModel.getOffsetToAncestor(Offset.zero, ancestorRenderBox,
          excludeScrollOffset: excludeScrollOffset);
    });
  }

  Future<Image> toImage(double pixelRatio) {
    return getSelfRenderBoxValue((renderBoxModel, _) {
      return renderBoxModel.toImage(pixelRatio: pixelRatio);
    });
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
    return getRenderBoxValueByType(RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.isRepaintBoundary);
  }

  @pragma('vm:prefer-inline')
  Offset localToGlobal(Offset point, {RenderObject? ancestor}) {
    return getRenderBoxValueByType(
        RenderObjectGetType.self, (renderBoxModel, _) => renderBoxModel.localToGlobal(point, ancestor: ancestor));
  }

  @pragma('vm:prefer-inline')
  void flushLayout() {
    everyRenderBox((_, renderObject) {
      if (renderObject.attached) {
        renderObject.owner!.flushLayout();
      } else if (renderObject.parent != null) {
        renderObject.performLayout();
      }
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void clearIntersectionChangeListeners([flutter.RenderObjectElement? flutterWidgetElement]) {
    if (flutterWidgetElement == null) {
      domRenderBoxModel?.clearIntersectionChangeListeners();
      return;
    }

    RenderBoxModel? widgetRenderBox = _widgetRenderObjects[flutterWidgetElement];
    widgetRenderBox?.clearIntersectionChangeListeners();
  }

  void attachToRenderBoxModel() {
  }

  @pragma('vm:prefer-inline')
  void markNeedsLayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      renderObject?.markNeedsLayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markParentNeedsLayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      renderObject?.parent?.markNeedsLayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markPositionHolderParentNeedsLayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is RenderBoxModel) {
        renderObject.renderPositionPlaceholder?.parent?.markNeedsLayout();
      }
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markScrollingContainerNeedsLayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is! RenderBoxModel) return false;
      RenderLayoutBox? scrollContainer = renderObject.findScrollContainer() as RenderLayoutBox?;
      scrollContainer?.renderScrollingContent?.markNeedsLayout();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markSVGShapeNeedsUpdate() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is RenderSVGShape) {
        renderObject.markNeedUpdateShape();
      }
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markNeedsPaint() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      renderObject?.markNeedsPaint();
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markRenderParagraphNeedsLayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is RenderTextBox) {
        renderObject.markRenderParagraphNeedsLayout();
      }
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markAdjacentRenderParagraphNeedsLayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is RenderBoxModel) {
        renderObject.markAdjacentRenderParagraphNeedsLayout();
      }
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markParentNeedsRelayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is RenderBoxModel) {
        renderObject.markParentNeedsRelayout();
      }
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markChildrenNeedsSort() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is RenderLayoutBox) {
        renderObject.markChildrenNeedsSort();
      }
      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markParentNeedsSort() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.parent, (renderObject, _) {
      if (renderObject is RenderLayoutBox) {
        renderObject.markChildrenNeedsSort();
      }
      return true;
    });
  }

  // Sizing may affect parent size, mark parent as needsLayout in case
  // renderBoxModel has tight constraints which will prevent parent from marking.
  @pragma('vm:prefer-inline')
  void markSelfAndParentBoxModelNeedsLayout() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      renderObject?.markNeedsLayout();

      if (renderObject?.parent is RenderBoxModel) {
        renderObject!.parent!.markNeedsLayout();
      }

      return true;
    });
  }

  @pragma('vm:prefer-inline')
  void markNeedsCompositingBitsUpdate() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      renderObject?.markNeedsCompositingBitsUpdate();
      return true;
    });
  }

  void ensureEventResponderBound() {
    everyRenderObjectByTypeAndMatch(RenderObjectGetType.self, (renderObject, _) {
      if (renderObject is! RenderBoxModel) return true;
      // Must bind event responder on render box model whatever there is no event listener.

      // Make sure pointer responder bind.
      renderObject.getEventTarget = target.getEventTarget;

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
    if (target.managedByFlutterWidget) {
      RenderBoxModel? widgetRenderBoxModel = widgetRenderObjectIterator.firstWhereOrNull((renderBox) => renderBox.attached);

      if (widgetRenderBoxModel == null) return null;

      return _renderObjectMatchFn(widgetRenderBoxModel, getType, (renderObject, renderStyle) {
        if (renderObject is RenderBoxModel) {
          return getter(renderObject, renderStyle!);
        }
        return null;
      });
    }
    if (domRenderBoxModel != null) {
      return _renderObjectMatchFn(domRenderBoxModel!, getType, (renderObject, renderStyle) {
        if (renderObject is RenderBoxModel) {
          return getter(renderObject, renderStyle!);
        }
        return null;
      });
    }
    return null;
  }

  dynamic _renderObjectMatchFn(RenderBoxModel renderBoxModel, RenderObjectGetType getType, RenderObjectMatchers matcher) {
    switch (getType) {
      case RenderObjectGetType.self:
        return matcher(renderBoxModel, renderBoxModel.renderStyle);
      case RenderObjectGetType.parent:
        return matcher(renderBoxModel.parent, renderBoxModel.parent is RenderBoxModel ? (renderBoxModel.parent as RenderBoxModel).renderStyle : null);
      case RenderObjectGetType.firstChild:
        if (renderBoxModel is RenderLayoutBox) {
          RenderObject? firstChild = renderBoxModel.firstChild;

          return matcher(firstChild, firstChild is RenderBoxModel ? firstChild.renderStyle : null);
        }
        return false;
      case RenderObjectGetType.lastChild:
        if (renderBoxModel is RenderLayoutBox) {
          RenderObject? lastChild = renderBoxModel.lastChild;
          return matcher(lastChild, lastChild is RenderBoxModel ? lastChild.renderStyle : null);
        }
        return false;
      case RenderObjectGetType.previousSibling:
        var parentData = renderBoxModel.parentData;
        if (parentData is RenderLayoutParentData) {
          RenderObject? previousSibling = parentData.previousSibling;
          return matcher(previousSibling, previousSibling is RenderBoxModel ? previousSibling.renderStyle : null);
        }
        return false;
      case RenderObjectGetType.nextSibling:
        var parentData = renderBoxModel.parentData;
        if (parentData is RenderLayoutParentData) {
          RenderObject? nextSibling = parentData.nextSibling;
          return matcher(nextSibling, nextSibling is RenderBoxModel ? nextSibling.renderStyle : null);
        }
        return false;
    }
  }

  bool everyRenderObjectByTypeAndMatch(RenderObjectGetType getType, RenderObjectMatchers matcher) {
    if (target.managedByFlutterWidget) {
      return everyWidgetRenderBox((_, renderBoxModel) {
        return _renderObjectMatchFn(renderBoxModel, getType, matcher);
      });
    }
    if (domRenderBoxModel != null) {
      return _renderObjectMatchFn(domRenderBoxModel!, getType, matcher);
    }
    return false;
  }

  bool everyAttachedRenderObjectByTypeAndMatch(RenderObjectGetType getType, RenderObjectMatchers matcher) {
    if (target.managedByFlutterWidget) {
      return everyAttachedWidgetRenderBox((_, renderBoxModel) {
        return _renderObjectMatchFn(renderBoxModel, getType, matcher);
      });
    }
    if (domRenderBoxModel != null) {
      return _renderObjectMatchFn(domRenderBoxModel!, getType, matcher);
    }
    return false;
  }

  bool everyRenderBox(EveryRenderBoxModelHandlerCallback callback) {
    bool hasMatch = everyWidgetRenderBox(callback);
    if (!hasMatch) {
      return false;
    }
    if (!target.managedByFlutterWidget && domRenderBoxModel != null) {
      bool domMatch = callback(null, domRenderBoxModel!);
      if (!domMatch) return false;
    }
    return true;
  }

  bool everyWidgetRenderBox(EveryRenderBoxModelHandlerCallback callback) {
    for (var entry in _widgetRenderObjects.entries) {
      bool result = callback(entry.key, entry.value);
      if (!result) return false;
    }

    return true;
  }

  bool everyAttachedWidgetRenderBox(EveryRenderBoxModelHandlerCallback callback) {
    for (var entry in _widgetRenderObjects.entries) {
      RenderObject renderObject = entry.value;
      if (!renderObject.attached) {
        continue;
      }
      bool result = callback(entry.key, entry.value);
      if (!result) return false;
    }
    return true;
  }

  void removeRenderObject(flutter.Element? flutterWidgetElement) {
    if (flutterWidgetElement != null) {
      unmountWidgetRenderObject(flutterWidgetElement);
    } else {
      setDomRenderObject(null);
    }
  }

  void setDomRenderObject(RenderBoxModel? renderBoxModel) {
    _domRenderObjects = renderBoxModel;
  }

  void setDebugShouldPaintOverlay(bool value) {
    getSelfRenderBoxValue((renderBoxModel, _) {
      renderBoxModel.debugShouldPaintOverlay = value;
      return null;
    });
  }

  void addOrUpdateWidgetRenderObjects(flutter.RenderObjectElement ownerRenderObjectElement, RenderBoxModel targetRenderBoxModel) {
    assert(!_widgetRenderObjects.containsKey(ownerRenderObjectElement));
    _widgetRenderObjects[ownerRenderObjectElement] = targetRenderBoxModel;
  }

  void unmountWidgetRenderObject(flutter.Element ownerRenderObjectElement) {
    _widgetRenderObjects.remove(ownerRenderObjectElement);
  }

  // Following properties used for exposing APIs
  // for class that extends [AbstractRenderStyle].
  @pragma('vm:prefer-inline')
  RenderBoxModel? get domRenderBoxModel {
    return _domRenderObjects;
  }

  RenderBoxModel? getWidgetPairedRenderBoxModel(flutter.Element targetRenderObjectElement) {
    return _widgetRenderObjects[targetRenderObjectElement];
  }

  RenderBoxModel? get attachedRenderBoxModel {
    if (target.managedByFlutterWidget) {
      return _widgetRenderObjects.values.firstWhereOrNull((renderBox) => renderBox.attached);
    }

    return _domRenderObjects;
  }

  Size get viewportSize => target.ownerDocument.viewport?.viewportSize ?? Size.zero;

  FlutterView get currentFlutterView => target.ownerDocument.controller.ownerFlutterView;

  double get rootFontSize => target.ownerDocument.documentElement!.renderStyle.fontSize.computedValue;

  void visitChildren(RenderObjectVisitor visitor) {
    if (target.managedByFlutterWidget) {
      everyWidgetRenderBox((_, renderBoxMode) {
        visitor(renderBoxMode);
        return true;
      });
      return;
    }
    _domRenderObjects!.visitChildren(visitor);
  }

  void disposeScrollable();

  void dispose() {
    disposeScrollable();
    _domRenderObjects = null;
    _widgetRenderObjects.clear();
  }
}

class CSSRenderStyle extends RenderStyle
    with
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
        CSSFlexboxMixin,
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
        CSSAnimationMixin,
        CSSSvgMixin {
  CSSRenderStyle({required this.target});

  @override
  Element target;

  @override
  CSSRenderStyle? parent;

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
      case ALIGN_ITEMS:
        return alignItems;
      case JUSTIFY_CONTENT:
        return justifyContent;
      case ALIGN_SELF:
        return alignSelf;
      case FLEX_GROW:
        return flexGrow;
      case FLEX_SHRINK:
        return flexShrink;
      case FLEX_BASIS:
        return flexBasis;
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
      case LINE_CLAMP:
        return lineClamp;
      case VERTICAL_ALIGN:
        return verticalAlign;
      case TEXT_ALIGN:
        return textAlign;
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
    if (CSSVariable.isVariable(name)) {
      setCSSVariable(name, value.toString());
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
      case ALIGN_ITEMS:
        alignItems = value;
        break;
      case JUSTIFY_CONTENT:
        justifyContent = value;
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
        break;
      case BACKGROUND_POSITION_Y:
        backgroundPositionY = value;
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
      case LINE_CLAMP:
        lineClamp = value;
        break;
      case VERTICAL_ALIGN:
        verticalAlign = value;
        break;
      case TEXT_ALIGN:
        textAlign = value;
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
      case FILL:
        fill = value;
        break;
      case STROKE:
        stroke = value;
        break;
      case STROKE_WIDTH:
        strokeWidth = value;
        break;
      case X:
        x = value;
        break;
      case Y:
        y = value;
        break;
      case RX:
        rx = value;
        break;
      case RY:
        ry = value;
        break;
      case CX:
        cx = value;
        break;
      case CY:
        cy = value;
        break;
      case R:
        r = value;
        break;
      case X1:
        x1 = value;
        break;
      case X2:
        x2 = value;
        break;
      case Y1:
        y1 = value;
        break;
      case Y2:
        y2 = value;
        break;
      case D:
        d = value;
        break;
      case FILL_RULE:
        fillRule = value;
        break;
      case STROKE_LINECAP:
        strokeLinecap = value;
        break;
      case STROKE_LINEJOIN:
        strokeLinejoin = value;
        break;
    }
  }

  @override
  dynamic resolveValue(String propertyName, String propertyValue, {String? baseHref}) {
    bool uiCommandTracked = false;
    if (enableWebFProfileTracking) {
      if (!WebFProfiler.instance.currentPipeline.containsActiveUICommand()) {
        WebFProfiler.instance.startTrackUICommand();
        uiCommandTracked = true;
      }
      WebFProfiler.instance.startTrackUICommandStep('$this.renderStyle.resolveValue');
    }
    RenderStyle renderStyle = this;

    if (propertyValue == INITIAL) {
      propertyValue = CSSInitialValues[propertyName] ?? propertyValue;
    }

    // Process CSSVariable.
    dynamic value = CSSVariable.tryParse(renderStyle, propertyValue);
    if (value != null) {
      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackUICommandStep();
        if (uiCommandTracked) {
          WebFProfiler.instance.finishTrackUICommand();
        }
      }
      return value;
    }

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
      case ALIGN_SELF:
        value = CSSFlexboxMixin.resolveAlignSelf(propertyValue);
        break;
      case FLEX_GROW:
        value = CSSFlexboxMixin.resolveFlexGrow(propertyValue);
        break;
      case FLEX_SHRINK:
        value = CSSFlexboxMixin.resolveFlexShrink(propertyValue);
        break;
      case SLIVER_DIRECTION:
        value = CSSSliverMixin.resolveAxis(propertyValue);
        break;
      case TEXT_ALIGN:
        value = CSSTextMixin.resolveTextAlign(propertyValue);
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
        value = CSSBorderSide.resolveBorderWidth(propertyValue, renderStyle, propertyName);
        break;
      case BORDER_LEFT_STYLE:
      case BORDER_TOP_STYLE:
      case BORDER_RIGHT_STYLE:
      case BORDER_BOTTOM_STYLE:
        value = CSSBorderSide.resolveBorderStyle(propertyValue);
        break;
      case COLOR:
      case CARETCOLOR:
      case BACKGROUND_COLOR:
      case TEXT_DECORATION_COLOR:
      case BORDER_LEFT_COLOR:
      case BORDER_TOP_COLOR:
      case BORDER_RIGHT_COLOR:
      case BORDER_BOTTOM_COLOR:
        value = CSSColor.resolveColor(propertyValue, renderStyle, propertyName);
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
      case LINE_CLAMP:
        value = CSSText.parseLineClamp(propertyValue);
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
      case FILL_RULE:
        value = CSSSvgMixin.resolveFillRule(propertyValue);
        break;
      case STROKE_LINECAP:
        value = CSSSvgMixin.resolveStrokeLinecap(propertyValue);
        break;
      case STROKE_LINEJOIN:
        value = CSSSvgMixin.resolveStrokeLinejoin(propertyValue);
        break;
    }

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackUICommandStep();
      if (uiCommandTracked) {
        WebFProfiler.instance.finishTrackUICommand();
      }
    }

    // --x: foo;
    // Directly passing the value, not to resolve now.
    if (CSSVariable.isVariable(propertyName)) {
      return propertyValue;
    }

    return value;
  }

  // Compute the content box width from render style.
  void computeContentBoxLogicalWidth() {
    // RenderBoxModel current = renderBoxModel!;
    RenderStyle renderStyle = this;
    double? logicalWidth;

    CSSDisplay? effectiveDisplay = renderStyle.effectiveDisplay;

    // Width applies to all elements except non-replaced inline elements.
    // https://drafts.csswg.org/css-sizing-3/#propdef-width
    if (effectiveDisplay == CSSDisplay.inline && !renderStyle.isSelfRenderReplaced()) {
      _contentBoxLogicalWidth = null;
      return;
    } else if (effectiveDisplay == CSSDisplay.block || effectiveDisplay == CSSDisplay.flex) {
      // Use width directly if defined.
      if (renderStyle.width.isNotAuto) {
        logicalWidth = renderStyle.width.computedValue;
      } else if (renderStyle.parent != null) {
        // Block element (except replaced element) will stretch to the content width of its parent in flow layout.
        // Replaced element also stretch in flex layout if align-items is stretch.
        if (!renderStyle.isSelfRenderReplaced() || renderStyle.isParentRenderFlexLayout()) {
          RenderStyle? ancestorRenderStyle = _findAncestorWithNoDisplayInline();
          // Should ignore renderStyle of display inline when searching for ancestors to stretch width.
          if (ancestorRenderStyle != null) {
            logicalWidth = ancestorRenderStyle.contentBoxLogicalWidth;
            // Should subtract horizontal margin of own from its parent content width.
            if (logicalWidth != null) {
              logicalWidth -= renderStyle.margin.horizontal;
            }
          }
        }
      }
    } else if (effectiveDisplay == CSSDisplay.inlineBlock ||
        effectiveDisplay == CSSDisplay.inlineFlex ||
        effectiveDisplay == CSSDisplay.inline) {
      if (renderStyle.width.isNotAuto) {
        logicalWidth = renderStyle.width.computedValue;
      } else if ((renderStyle.position == CSSPositionType.absolute || renderStyle.position == CSSPositionType.fixed) &&
          !renderStyle.isSelfRenderReplaced() &&
          renderStyle.width.isAuto &&
          renderStyle.left.isNotAuto &&
          renderStyle.right.isNotAuto) {
        // The width of positioned, non-replaced element is determined as following algorithm.
        // https://www.w3.org/TR/css-position-3/#abs-non-replaced-width
        if (!renderStyle.isParentRenderBoxModel()) {
          logicalWidth = null;
        }
        // Should access the renderStyle of renderBoxModel parent but not renderStyle parent
        // cause the element of renderStyle parent may not equal to containing block.
        // RenderBoxModel parent = current.parent as RenderBoxModel;
        // Get the renderStyle of outer scrolling box cause the renderStyle of scrolling
        // content box is only a fraction of the complete renderStyle.
        RenderStyle parentRenderStyle = renderStyle.isParentScrollingContentBox()
            ? (renderStyle.getParentRenderStyle())!.getParentRenderStyle()!
            : renderStyle.getParentRenderStyle()!;
        // Width of positioned element should subtract its horizontal margin.
        logicalWidth = (parentRenderStyle.paddingBoxLogicalWidth ?? 0) -
            renderStyle.left.computedValue -
            renderStyle.right.computedValue -
            renderStyle.marginLeft.computedValue -
            renderStyle.marginRight.computedValue;
      } else if (renderStyle.isBoxModelHaveSize() && renderStyle.constraints().hasTightWidth) {
        logicalWidth = renderStyle.constraints().maxWidth;
      }
    }

    // Get width by aspect ratio for replaced element if width is auto.
    if (logicalWidth == null && aspectRatio != null) {
      logicalWidth = renderStyle.getWidthByAspectRatio();
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
      if (renderStyle.height.isNotAuto) {
        logicalHeight = renderStyle.height.computedValue;
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
        RenderStyle parentRenderStyle = renderStyle.isParentScrollingContentBox()
            ? renderStyle.getParentRenderStyle()!.getParentRenderStyle()!
            : renderStyle.getParentRenderStyle()!;
        // Height of positioned element should subtract its vertical margin.
        logicalHeight = (parentRenderStyle.paddingBoxLogicalHeight ?? 0) -
            renderStyle.top.computedValue -
            renderStyle.bottom.computedValue -
            renderStyle.marginTop.computedValue -
            renderStyle.marginBottom.computedValue;
      } else {
        if (renderStyle.parent != null) {
          RenderStyle parentRenderStyle = renderStyle.parent!;

          if (renderStyle.isHeightStretch) {
            logicalHeight = parentRenderStyle.contentBoxLogicalHeight;
            // Should subtract vertical margin of own from its parent content height.
            if (logicalHeight != null) {
              logicalHeight -= renderStyle.margin.vertical;
            }
          }
        }
      }
    }

    // Get height by aspect ratio for replaced element if height is auto.
    if (logicalHeight == null && aspectRatio != null) {
      logicalHeight = renderStyle.getHeightByAspectRatio();
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
    if (renderStyle.parent == null) {
      return false;
    }
    bool isStretch = false;
    RenderStyle parentRenderStyle = renderStyle.parent!;

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
    if (enableWebFProfileTracking) {
      WebFProfiler.instance.startTrackLayoutStep('RenderStyle.contentMaxConstraintsWidth');
    }

    // If renderBoxModel definite content constraints, use it as max constrains width of content.
    BoxConstraints? contentConstraints = this.contentConstraints();
    if (contentConstraints != null && contentConstraints.maxWidth != double.infinity) {
      if (enableWebFProfileTracking) {
        WebFProfiler.instance.finishTrackLayoutStep();
      }
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

    if (enableWebFProfileTracking) {
      WebFProfiler.instance.finishTrackLayoutStep();
    }

    return contentMaxConstraintsWidth;
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

  RenderWidget _createRenderWidget({RenderWidget? previousRenderWidget}) {
    RenderWidget nextReplaced;

    if (previousRenderWidget == null || target.managedByFlutterWidget) {
      nextReplaced = RenderWidget(
        renderStyle: this,
      );
    } else {
      nextReplaced = previousRenderWidget;
    }
    return nextReplaced;
  }

  // Create renderLayoutBox if type changed and copy children if there has previous renderLayoutBox.
  RenderLayoutBox createRenderLayout(
      {RenderLayoutBox? previousRenderLayoutBox, bool isRepaintBoundary = false, CSSRenderStyle? cssRenderStyle}) {
    CSSDisplay display = this.display;
    RenderLayoutBox? nextRenderLayoutBox;

    if (display == CSSDisplay.flex || display == CSSDisplay.inlineFlex) {
      if (previousRenderLayoutBox == null || target.managedByFlutterWidget) {
        if (isRepaintBoundary) {
          nextRenderLayoutBox = RenderRepaintBoundaryFlexLayout(
            renderStyle: cssRenderStyle ?? this,
          );
        } else {
          nextRenderLayoutBox = RenderFlexLayout(
            renderStyle: cssRenderStyle ?? this,
          );
        }
      } else if (previousRenderLayoutBox is RenderFlowLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlowLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlowLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderRepaintBoundaryFlowLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlowLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderFlowLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        }
      } else if (previousRenderLayoutBox is RenderFlexLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlexLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlexLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          } else {
            // RenderRepaintBoundaryFlexLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlexLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlexLayout --> RenderRepaintBoundaryFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlexLayout();
          } else {
            // RenderFlexLayout --> RenderFlexLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          }
        }
      }
    } else if (display == CSSDisplay.block ||
        display == CSSDisplay.none ||
        display == CSSDisplay.inline ||
        display == CSSDisplay.inlineBlock) {
      if (previousRenderLayoutBox == null || target.managedByFlutterWidget) {
        if (isRepaintBoundary) {
          nextRenderLayoutBox = RenderRepaintBoundaryFlowLayout(
            renderStyle: cssRenderStyle ?? this,
          );
        } else {
          nextRenderLayoutBox = RenderFlowLayout(
            renderStyle: cssRenderStyle ?? this,
          );
        }
      } else if (previousRenderLayoutBox is RenderFlowLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlowLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlowLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          } else {
            // RenderRepaintBoundaryFlowLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlowLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderFlowLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox;
          }
        }
      } else if (previousRenderLayoutBox is RenderFlexLayout) {
        if (previousRenderLayoutBox is RenderRepaintBoundaryFlexLayout) {
          if (isRepaintBoundary) {
            // RenderRepaintBoundaryFlexLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderRepaintBoundaryFlexLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        } else {
          if (isRepaintBoundary) {
            // RenderFlexLayout --> RenderRepaintBoundaryFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toRepaintBoundaryFlowLayout();
          } else {
            // RenderFlexLayout --> RenderFlowLayout
            nextRenderLayoutBox = previousRenderLayoutBox.toFlowLayout();
          }
        }
      }
    } else {
      throw FlutterError('Not supported display type $display');
    }

    // Update scrolling content layout type.
    if (previousRenderLayoutBox != nextRenderLayoutBox &&
        previousRenderLayoutBox?.renderScrollingContent != null &&
        !target.managedByFlutterWidget) {
      target.updateScrollingContentBox();
    }

    return nextRenderLayoutBox!;
  }

  RenderReplaced _createRenderReplaced({RenderReplaced? previousReplaced, bool isRepaintBoundary = false}) {
    RenderReplaced nextReplaced;

    if (previousReplaced == null || target.managedByFlutterWidget) {
      if (isRepaintBoundary) {
        nextReplaced = RenderRepaintBoundaryReplaced(
          this,
        );
      } else {
        nextReplaced = RenderReplaced(
          this,
        );
      }
    } else {
      if (previousReplaced is RenderRepaintBoundaryReplaced) {
        if (isRepaintBoundary) {
          // RenderRepaintBoundaryReplaced --> RenderRepaintBoundaryReplaced
          nextReplaced = previousReplaced;
        } else {
          // RenderRepaintBoundaryReplaced --> RenderReplaced
          nextReplaced = previousReplaced.toReplaced();
        }
      } else {
        if (isRepaintBoundary) {
          // RenderReplaced --> RenderRepaintBoundaryReplaced
          nextReplaced = previousReplaced.toRepaintBoundaryReplaced();
        } else {
          // RenderReplaced --> RenderReplaced
          nextReplaced = previousReplaced;
        }
      }
    }
    return nextReplaced;
  }

  RenderBoxModel updateOrCreateRenderBoxModel() {
    RenderBoxModel nextRenderBoxModel;
    if (target.isWidgetElement) {
      nextRenderBoxModel = _createRenderWidget();
    } else if (target.isReplacedElement) {
      nextRenderBoxModel = _createRenderReplaced(
          isRepaintBoundary: target.isRepaintBoundary,
          previousReplaced: _domRenderObjects is RenderReplaced ? _domRenderObjects as RenderReplaced : null);
    } else if (target.isSVGElement) {
      nextRenderBoxModel =
          target.createRenderSVG(isRepaintBoundary: target.isRepaintBoundary, previous: _domRenderObjects);
    } else {
      nextRenderBoxModel = createRenderLayout(
          isRepaintBoundary: target.isRepaintBoundary,
          previousRenderLayoutBox: _domRenderObjects is RenderLayoutBox ? _domRenderObjects as RenderLayoutBox : null);
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
    parent = null;
    backgroundImage = null;
  }

  // Find ancestor render style with display of not inline.
  RenderStyle? _findAncestorWithNoDisplayInline() {
    RenderStyle renderStyle = this;
    RenderStyle? parentRenderStyle = renderStyle.parent;
    while (parentRenderStyle != null) {
      // If ancestor element is WidgetElement, should return it because should get maxWidth of constraints for logicalWidth.
      if (parentRenderStyle.effectiveDisplay != CSSDisplay.inline ||
          parentRenderStyle.target.renderObjectManagerType == RenderObjectManagerType.FLUTTER_ELEMENT) {
        break;
      }
      parentRenderStyle = parentRenderStyle.parent;
    }
    return parentRenderStyle;
  }

  // Find ancestor render style with definite content box logical width.
  RenderStyle? _findAncestorWithContentBoxLogicalWidth() {
    RenderStyle renderStyle = this;
    RenderStyle? parentRenderStyle = renderStyle.parent;

    while (parentRenderStyle != null) {
      RenderStyle? grandParentRenderStyle = parentRenderStyle.parent;
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
    RenderStyle? parentRenderStyle = childRenderStyle.parent;
    while (parentRenderStyle != null) {
      if (parentRenderStyle == this) {
        return true;
      }
      parentRenderStyle = parentRenderStyle.parent;
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

  @override
  List<DiagnosticsNode> getChildren() {
    // TODO: implement getChildren
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> getProperties() {
    // TODO: implement getProperties
    throw UnimplementedError();
  }

  @override
  String toDescription({TextTreeConfiguration? parentConfiguration}) {
    // TODO: implement toDescription
    throw UnimplementedError();
  }

  @override
  // TODO: implement value
  Object? get value => throw UnimplementedError();
}
