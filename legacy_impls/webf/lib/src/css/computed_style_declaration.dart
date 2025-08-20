/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi' as ffi;
import 'package:collection/collection.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:flutter/painting.dart';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';
import 'package:webf/rendering.dart';

class ComputedCSSStyleDeclaration extends CSSStyleDeclaration {
  final Element _element;
  final String? _pseudoElementName;

  final ffi.Pointer<NativeBindingObject> _pointer;

  ComputedCSSStyleDeclaration(BindingContext context, this._element, this._pseudoElementName)
      : _pointer = context.pointer,
        super(context);

  @override
  get pointer => _pointer;

  @override
  void initializeMethods(Map<String, BindingObjectMethod> methods) {
    super.initializeMethods(methods);
    methods['getPropertyValue'] = BindingObjectMethodSync(call: (args) => getPropertyValue(args[0]));
    methods['setProperty'] = BindingObjectMethodSync(call: (args) => setProperty(args[0], args[1]));
    methods['removeProperty'] = BindingObjectMethodSync(call: (args) => removeProperty(args[0]));
    methods['checkCSSProperty'] = BindingObjectMethodSync(call: (args) => checkCSSProperty(args[0]));
    methods['getFullCSSPropertyList'] = BindingObjectMethodSync(call: (args) => getFullCSSPropertyList());
  }

  @override
  void initializeProperties(Map<String, BindingObjectProperty> properties) {
    super.initializeProperties(properties);
    properties['cssText'] = BindingObjectProperty(getter: () => cssText, setter: (value) => cssText = value);
    properties['length'] = BindingObjectProperty(getter: () => length);
  }

  @override
  String get cssText {
    Map<CSSPropertyID, String> reverse(Map map) => {for (var e in map.entries) e.value: e.key};
    final propertyMap = reverse(CSSPropertyNameMap);

    StringBuffer result = StringBuffer();
    ComputedProperties.forEach((id) {
      result.write(' ');
      result.write(propertyMap[id]);
      result.write(': ');
      result.write(propertyMap[id]);
      result.write(';');
    });
    return result.toString();
  }

  void set cssText(value) {}

  @override
  int get length => CSSPropertyID.values.length;

  bool checkCSSProperty(String key) {
    return CSSPropertyNameMap.containsKey(key);
  }

  List<String> getFullCSSPropertyList() {
    return CSSPropertyNameMap.keys.toList();
  }

  @override
  String getPropertyValue(String propertyName) {
    CSSPropertyID? propertyID = CSSPropertyNameMap[propertyName] ?? CSSPropertyNameMap[kebabize(propertyName)];
    if (propertyID == null) {
      return '';
    }
    return _valueForPropertyInStyle(propertyID, needUpdateStyle: true);
  }

  @override
  void setProperty(String propertyName, String? value, { bool? isImportant, String? baseHref }) {
    throw UnimplementedError('No Modification Allowed');
  }

  @override
  String removeProperty(String propertyName, [bool? isImportant]) {
    throw UnimplementedError('Not implemented');
  }

  String _valueForPropertyInStyle(CSSPropertyID propertyID, {bool needUpdateStyle = false}) {
    if (needUpdateStyle) {
      _element.ownerDocument.updateStyleIfNeeded();
    }
    RenderStyle? style = _element.computedStyle(_pseudoElementName);

    if (style == null) {
      return '';
    }

    switch (propertyID) {
      case CSSPropertyID.Invalid:
      case CSSPropertyID.Variable:
        break;
      case CSSPropertyID.Display:
        return style.display.cssText();
      case CSSPropertyID.Background:
        return _getBackgroundShorthandValue();
      case CSSPropertyID.BackgroundColor:
        return style.backgroundColor?.cssText() ?? '';
      case CSSPropertyID.BackgroundImage:
        return style.backgroundImage?.cssText() ?? 'none';
      case CSSPropertyID.BackgroundRepeat:
        return style.backgroundRepeat.cssText();
      case CSSPropertyID.BackgroundPosition:
        return style.backgroundPositionX.cssText() + ' ' + style.backgroundPositionY.cssText();
      case CSSPropertyID.BackgroundPositionX:
        return style.backgroundPositionX.cssText();
      case CSSPropertyID.BackgroundPositionY:
        return style.backgroundPositionY.cssText();
      case CSSPropertyID.BackgroundSize:
        return style.backgroundSize.cssText();
      case CSSPropertyID.BackgroundAttachment:
        return (style.backgroundAttachment ?? CSSBackgroundAttachmentType.scroll).cssText();
      case CSSPropertyID.BackgroundClip:
        return (style.backgroundClip ?? CSSBackgroundBoundary.borderBox).cssText();
      case CSSPropertyID.BackgroundOrigin:
        return (style.backgroundOrigin ?? CSSBackgroundBoundary.paddingBox).cssText();
      case CSSPropertyID.Border:
        final value = _valueForPropertyInStyle(CSSPropertyID.BorderTop);
        final ids = [CSSPropertyID.BorderRight, CSSPropertyID.BorderBottom, CSSPropertyID.BorderLeft];
        for (CSSPropertyID propertyID in ids) {
           if (_valueForPropertyInStyle(propertyID) != value) {
             return '';
           }
        }
        return value;
      case CSSPropertyID.BorderTopColor:
        return style.borderTopColor.cssText();
      case CSSPropertyID.BorderRightColor:
        return style.borderRightColor.cssText();
      case CSSPropertyID.BorderBottomColor:
        return style.borderBottomColor.cssText();
      case CSSPropertyID.BorderLeftColor:
        return style.borderLeftColor.cssText();
      case CSSPropertyID.BorderTopStyle:
        return style.borderTopStyle.cssText();
      case CSSPropertyID.BorderRightStyle:
        return style.borderRightStyle.cssText();
      case CSSPropertyID.BorderBottomStyle:
        return style.borderBottomStyle.cssText();
      case CSSPropertyID.BorderLeftStyle:
        return style.borderLeftStyle.cssText();
      case CSSPropertyID.BorderTopWidth:
        return '${style.effectiveBorderTopWidth.computedValue.cssText()}px';
      case CSSPropertyID.BorderRightWidth:
        return '${style.effectiveBorderRightWidth.computedValue.cssText()}px';
      case CSSPropertyID.BorderBottomWidth:
        return '${style.effectiveBorderBottomWidth.computedValue.cssText()}px';
      case CSSPropertyID.BorderLeftWidth:
        return '${style.effectiveBorderLeftWidth.computedValue.cssText()}px';
      case CSSPropertyID.BorderTop:
        final properties = [CSSPropertyID.BorderTopWidth,
                            CSSPropertyID.BorderTopStyle,
                            CSSPropertyID.BorderTopColor];
        return properties.map((e) => _valueForPropertyInStyle(e)).join(' ');
      case CSSPropertyID.BorderLeft:
        final properties = [CSSPropertyID.BorderLeftWidth,
                            CSSPropertyID.BorderLeftStyle,
                            CSSPropertyID.BorderLeftColor];
        return properties.map((e) => _valueForPropertyInStyle(e)).join(' ');
      case CSSPropertyID.BorderRight:
        final properties = [CSSPropertyID.BorderRightWidth,
                            CSSPropertyID.BorderRightStyle,
                            CSSPropertyID.BorderRightColor];
        return properties.map((e) => _valueForPropertyInStyle(e)).join(' ');
      case CSSPropertyID.BorderBottom:
        final properties = [CSSPropertyID.BorderBottomWidth,
                            CSSPropertyID.BorderBottomStyle,
                            CSSPropertyID.BorderBottomColor];
        return properties.map((e) => _valueForPropertyInStyle(e)).join(' ');
      case CSSPropertyID.BorderColor:
        return _getCSSPropertyValuesForSidesShorthand([CSSPropertyID.BorderTopColor,
                                                      CSSPropertyID.BorderRightColor,
                                                      CSSPropertyID.BorderBottomColor,
                                                      CSSPropertyID.BorderLeftColor])?.join(' ') ?? '';
      case CSSPropertyID.BorderStyle:
        return _getCSSPropertyValuesForSidesShorthand([CSSPropertyID.BorderTopStyle,
                                                      CSSPropertyID.BorderRightStyle,
                                                      CSSPropertyID.BorderBottomStyle,
                                                      CSSPropertyID.BorderLeftStyle])?.join(' ') ?? '';
      case CSSPropertyID.BorderWidth:
        return _getCSSPropertyValuesForSidesShorthand([CSSPropertyID.BorderTopWidth,
                                                      CSSPropertyID.BorderRightWidth,
                                                      CSSPropertyID.BorderBottomWidth,
                                                      CSSPropertyID.BorderLeftWidth])?.join(' ') ?? '';
      case CSSPropertyID.BorderTopLeftRadius:
         return style.borderTopLeftRadius.cssText();
      case CSSPropertyID.BorderTopRightRadius:
        return style.borderTopRightRadius.cssText();
      case CSSPropertyID.BorderBottomLeftRadius:
        return style.borderBottomLeftRadius.cssText();
      case CSSPropertyID.BorderBottomRightRadius:
        return style.borderBottomRightRadius.cssText();
      case CSSPropertyID.BorderRadius:
        return _borderRadiusShorthandValue(style);
      case CSSPropertyID.BorderImage:
      case CSSPropertyID.BorderImageOutset:
      case CSSPropertyID.BorderImageRepeat:
      case CSSPropertyID.BorderImageSlice:
      case CSSPropertyID.BorderImageWidth:
      case CSSPropertyID.BorderSpacing:
        break;
      case CSSPropertyID.Color:
        return style.color.cssText();
      case CSSPropertyID.Font:
        List<String> value = [];
        value.add(_valueForPropertyInStyle(CSSPropertyID.FontStyle));
        value.add(_valueForPropertyInStyle(CSSPropertyID.FontWeight));
        value.add(_valueForPropertyInStyle(CSSPropertyID.FontSize));
        value.add(_valueForPropertyInStyle(CSSPropertyID.LineHeight));
        value.add(_valueForPropertyInStyle(CSSPropertyID.FontFamily));
        return value.join(' ');
      case CSSPropertyID.FontFamily:
        return style.fontFamily?.join(', ') ?? '';
      case CSSPropertyID.FontSize:
        return style.fontSize.cssText();
      case CSSPropertyID.FontStyle:
        return style.fontStyle.cssText();
      case CSSPropertyID.FontWeight:
        return style.fontWeight.cssText();
      case CSSPropertyID.LineHeight:
        return style.lineHeight.cssText();
      case CSSPropertyID.FontVariant:
          break;
      case CSSPropertyID.Top:
        return style.top.cssText();
      case CSSPropertyID.Bottom:
        return style.bottom.cssText();
      case CSSPropertyID.Left:
        return style.left.cssText();
      case CSSPropertyID.Right:
        return style.right.cssText();
      case CSSPropertyID.Width:
        if (style.width.isAuto) {
          if (style.renderBoxModel?.hasSize == true) {
            final boxWidth = style.renderBoxModel?.boxSize?.width;
            if (boxWidth != null && boxWidth > 0) {
              return '${boxWidth.cssText()}px';
            }
          }
        }
        return style.width.cssText();
      case CSSPropertyID.Height:
        if (style.height.isAuto) {
          if (style.renderBoxModel?.hasSize == true) {
            final boxHeight = style.renderBoxModel?.boxSize?.height;
            if (boxHeight != null && boxHeight > 0) {
              return '${boxHeight.cssText()}px';
            }
          }
        }
        return style.height.cssText();
      case CSSPropertyID.MaxHeight:
        return style.maxHeight.cssText();
      case CSSPropertyID.MaxWidth:
        return style.maxHeight.cssText();
      case CSSPropertyID.MinHeight:
        return style.minHeight.cssText();
      case CSSPropertyID.MinWidth:
        return style.minWidth.cssText();
      case CSSPropertyID.Margin:
        return style.margin.cssText();
      case CSSPropertyID.MarginTop:
        return style.marginTop.cssText();
      case CSSPropertyID.MarginRight:
        return style.marginRight.cssText();
      case CSSPropertyID.MarginBottom:
        return style.marginBottom.cssText();
      case CSSPropertyID.MarginLeft:
        return style.marginLeft.cssText();
      case CSSPropertyID.Padding:
        return style.padding.cssText();
      case CSSPropertyID.PaddingTop:
        return style.paddingTop.cssText();
      case CSSPropertyID.PaddingRight:
        return style.paddingRight.cssText();
      case CSSPropertyID.PaddingBottom:
        return style.paddingBottom.cssText();
      case CSSPropertyID.PaddingLeft:
        return style.paddingLeft.cssText();
      case CSSPropertyID.LetterSpacing:
        return style.letterSpacing?.cssText() ?? '';
      case CSSPropertyID.ObjectFit:
        return style.objectFit.toString();
      case CSSPropertyID.Opacity:
        return style.opacity.toString();
      case CSSPropertyID.OverflowX:
        return style.overflowX.cssText();
      case CSSPropertyID.OverflowY:
        return style.overflowY.cssText();
      case CSSPropertyID.Overflow:
        if (style.overflowX.index > style.overflowY.index) {
          return _valueForPropertyInStyle(CSSPropertyID.OverflowX);
        } else {
          return _valueForPropertyInStyle(CSSPropertyID.OverflowY);
        }
      case CSSPropertyID.Position:
        return style.position.cssText();
      case CSSPropertyID.TextAlign:
        return style.textAlign.cssText();
      case CSSPropertyID.TextShadow:
        return style.textShadow?.map((e) => e.cssText()).join(', ') ?? 'none';
      case CSSPropertyID.TextOverflow:
        return style.textOverflow.cssText();
      case CSSPropertyID.VerticalAlign:
        return style.verticalAlign.cssText();
      case CSSPropertyID.Visibility:
        return style.visibility.cssText();
      case CSSPropertyID.WhiteSpace:
        return style.whiteSpace.cssText();
      case CSSPropertyID.ZIndex:
        return style.zIndex?.toString() ?? 'auto';
      case CSSPropertyID.TransitionDelay:
        return style.transitionDelay.join(', ');
      case CSSPropertyID.TransitionDuration:
        return style.transitionDuration.join(', ');
      case CSSPropertyID.TransitionProperty:
        return style.transitionProperty.join(', ');
      case CSSPropertyID.TransitionTimingFunction:
        return style.transitionTimingFunction.join(', ');
      case CSSPropertyID.Animation:
        break;
      case CSSPropertyID.AnimationName:
        return style.animationName.join(', ');
      case CSSPropertyID.AnimationDelay:
        return style.animationDelay.join(', ');
      case CSSPropertyID.AnimationIterationCount:
        return style.animationIterationCount.join(', ');
      case CSSPropertyID.AnimationDirection:
        return style.animationDirection.join(', ');
      case CSSPropertyID.AnimationDuration:
        return style.animationDuration.join(', ');
      case CSSPropertyID.AnimationTimingFunction:
        return style.animationTimingFunction.join(', ');
      case CSSPropertyID.AnimationFillMode:
        return style.animationFillMode.join(', ');
      case CSSPropertyID.AnimationPlayState:
        return style.animationPlayState.join(', ');
      case CSSPropertyID.Transform:
        final matrix4 = style.effectiveTransformMatrix;
        return matrix4?.cssText() ?? 'none';

      case CSSPropertyID.Stroke:
        return style.stroke.cssText();
      case CSSPropertyID.StrokeWidth:
        return style.strokeWidth.cssText();
      case CSSPropertyID.StrokeLinecap:
        return style.strokeLinecap.toString();
      case CSSPropertyID.StrokeLinejoin:
        return style.strokeLinejoin.toString();
      case CSSPropertyID.X:
        return style.x.cssText();
      case CSSPropertyID.Y:
        return style.y.cssText();
      case CSSPropertyID.RX:
        return style.rx.cssText();
      case CSSPropertyID.RY:
        return style.ry.cssText();
      case CSSPropertyID.Fill:
        return style.fill.cssText();
      case CSSPropertyID.FillRule:
        return style.fillRule.toString();
      case CSSPropertyID.D:
        return style.d.value;

      case CSSPropertyID.TransformOrigin:
      case CSSPropertyID.TransformOriginX:
      case CSSPropertyID.TransformOriginY:
      case CSSPropertyID.TransformOriginZ:
      case CSSPropertyID.TransformStyle:
        break;

      case CSSPropertyID.Outline:
      case CSSPropertyID.ListStyle:
      case CSSPropertyID.Widows:
      case CSSPropertyID.UnicodeBidi:
      case CSSPropertyID.TextTransform:
      case CSSPropertyID.WordBreak:
      case CSSPropertyID.WordSpacing:
      case CSSPropertyID.WordWrap:
      case CSSPropertyID.Resize:
      case CSSPropertyID.Zoom:
      case CSSPropertyID.BoxSizing:
      case CSSPropertyID.Transition:
      case CSSPropertyID.PointerEvents:
      case CSSPropertyID.Content:
      case CSSPropertyID.CounterIncrement:
      case CSSPropertyID.CounterReset:
      case CSSPropertyID.TextDecoration:
      case CSSPropertyID.TextIndent:
      case CSSPropertyID.TextRendering:
      case CSSPropertyID.PageBreakAfter:
      case CSSPropertyID.PageBreakBefore:
      case CSSPropertyID.PageBreakInside:
      case CSSPropertyID.OverflowWrap:
      case CSSPropertyID.Orphans:
      case CSSPropertyID.OutlineColor:
      case CSSPropertyID.OutlineOffset:
      case CSSPropertyID.OutlineStyle:
      case CSSPropertyID.OutlineWidth:
      case CSSPropertyID.ListStyleImage:
      case CSSPropertyID.ListStylePosition:
      case CSSPropertyID.ListStyleType:
      case CSSPropertyID.ImageRendering:
      case CSSPropertyID.TabSize:
      case CSSPropertyID.Cursor:
      case CSSPropertyID.EmptyCells:
      case CSSPropertyID.Direction:
      case CSSPropertyID.BorderCollapse:
      case CSSPropertyID.BorderImageSource:
      case CSSPropertyID.CaptionSide:
      case CSSPropertyID.Clear:
      case CSSPropertyID.Clip:
      case CSSPropertyID.Speak:
        break;
      /* Individual properties not part of the spec */
      case CSSPropertyID.BackgroundRepeatX:
      case CSSPropertyID.BackgroundRepeatY:
      case CSSPropertyID.TextLineThrough:
      case CSSPropertyID.TextLineThroughColor:
      case CSSPropertyID.TextLineThroughMode:
      case CSSPropertyID.TextLineThroughStyle:
      case CSSPropertyID.TextLineThroughWidth:
      case CSSPropertyID.TextOverline:
      case CSSPropertyID.TextOverlineColor:
      case CSSPropertyID.TextOverlineMode:
      case CSSPropertyID.TextOverlineStyle:
      case CSSPropertyID.TextOverlineWidth:
      case CSSPropertyID.TextUnderline:
      case CSSPropertyID.TextUnderlineColor:
      case CSSPropertyID.TextUnderlineMode:
      case CSSPropertyID.TextUnderlineStyle:
      case CSSPropertyID.TextUnderlineWidth:
        break;

      /* Unimplemented @font-face properties */
      case CSSPropertyID.FontStretch:
      case CSSPropertyID.Src:
      case CSSPropertyID.UnicodeRange:
        break;

      /* Other unimplemented properties */
      case CSSPropertyID.Page: // for @page
      case CSSPropertyID.Quotes: // FIXME: needs implementation
      case CSSPropertyID.Size: // for @page
        break;

      case CSSPropertyID.BufferedRendering:
      case CSSPropertyID.ClipPath:
      case CSSPropertyID.ClipRule:
      case CSSPropertyID.Mask:
      case CSSPropertyID.EnableBackground:
      case CSSPropertyID.Filter:
      case CSSPropertyID.FloodColor:
      case CSSPropertyID.FloodOpacity:
      case CSSPropertyID.LightingColor:
      case CSSPropertyID.StopColor:
      case CSSPropertyID.StopOpacity:
      case CSSPropertyID.ColorInterpolation:
      case CSSPropertyID.ColorInterpolationFilters:
      case CSSPropertyID.ColorProfile:
      case CSSPropertyID.ColorRendering:
      case CSSPropertyID.FillOpacity:
      case CSSPropertyID.Marker:
      case CSSPropertyID.MarkerEnd:
      case CSSPropertyID.MarkerMid:
      case CSSPropertyID.MarkerStart:
      case CSSPropertyID.MaskType:
      case CSSPropertyID.ShapeRendering:
      case CSSPropertyID.StrokeDasharray:
      case CSSPropertyID.StrokeDashoffset:
      case CSSPropertyID.StrokeOpacity:
      case CSSPropertyID.StrokeMiterlimit:
      case CSSPropertyID.AlignmentBaseline:
      case CSSPropertyID.BaselineShift:
      case CSSPropertyID.DominantBaseline:
      case CSSPropertyID.GlyphOrientationHorizontal:
      case CSSPropertyID.GlyphOrientationVertical:
      case CSSPropertyID.Kerning:
      case CSSPropertyID.TextAnchor:
      case CSSPropertyID.VectorEffect:
      case CSSPropertyID.WritingMode:
      case CSSPropertyID.BoxShadow:
      case CSSPropertyID.TableLayout:
        break;
    }
    return '';
  }

  String _borderRadiusShorthandValue(RenderStyle style) {
    final showHorizontalBottomLeft = style.borderTopRightRadius.x != style.borderBottomLeftRadius.x;
    final showHorizontalBottomRight = showHorizontalBottomLeft || (style.borderBottomRightRadius.x != style.borderTopLeftRadius.x);
    final showHorizontalTopRight = showHorizontalBottomRight || (style.borderTopRightRadius.x != style.borderTopLeftRadius.x);

    final showVerticalBottomLeft = style.borderTopRightRadius.y != style.borderBottomLeftRadius.y;
    final showVerticalBottomRight = showVerticalBottomLeft || (style.borderBottomRightRadius.y != style.borderTopLeftRadius.y);
    final showVerticalTopRight = showVerticalBottomRight || (style.borderTopRightRadius.y != style.borderTopLeftRadius.y);

    final topLeftRadius = style.borderTopLeftRadius;
    final topRightRadius = style.borderTopRightRadius;
    final bottomRightRadius = style.borderBottomRightRadius;
    final bottomLeftRadius = style.borderBottomLeftRadius;

    List<String> horizontalRadii = [topLeftRadius.x.cssText()];
    if (showHorizontalTopRight) {
      horizontalRadii.add(topRightRadius.x.cssText());
    }
    if (showHorizontalBottomRight) {
      horizontalRadii.add(bottomRightRadius.x.cssText());
    }
    if (showHorizontalBottomLeft) {
      horizontalRadii.add(bottomLeftRadius.x.cssText());
    }

    List<String> verticalRadii = [topLeftRadius.y.cssText()];
    if (showVerticalTopRight) {
      verticalRadii.add(topRightRadius.y.cssText());
    }
    if (showVerticalBottomRight) {
      verticalRadii.add(bottomRightRadius.y.cssText());
    }
    if (showVerticalBottomLeft) {
      verticalRadii.add(bottomLeftRadius.y.cssText());
    }

    if (!horizontalRadii.equals(verticalRadii)) {
      return horizontalRadii.join(' ') + ' / ' + verticalRadii.join(' ');
    }
    return horizontalRadii.join(' ');
  }

  // top -> right -> bottom -> left
  List<String>? _getCSSPropertyValuesForSidesShorthand(List<CSSPropertyID> propertyIDs) {
     assert(propertyIDs.length == 4, 'The sides dose not include top | right | bottom | left');
     final top = _valueForPropertyInStyle(propertyIDs[0]);
     final right = _valueForPropertyInStyle(propertyIDs[1]);
     final bottom = _valueForPropertyInStyle(propertyIDs[2]);
     final left = _valueForPropertyInStyle(propertyIDs[3]);
     return _compressSlidesValue<String>([top, right, bottom, left]);
  }

  String _getBackgroundShorthandValue() {
    List<CSSPropertyID> beforeSlashSeparator = [CSSPropertyID.BackgroundImage,
                                                CSSPropertyID.BackgroundRepeat,
                                                CSSPropertyID.BackgroundAttachment,
                                                CSSPropertyID.BackgroundPosition];
    List<CSSPropertyID> afterSlashSeparator = [CSSPropertyID.BackgroundSize,
                                              CSSPropertyID.BackgroundOrigin,
                                              CSSPropertyID.BackgroundClip];
    final backgroundColor = _valueForPropertyInStyle(CSSPropertyID.BackgroundColor);
    final beforeValue = beforeSlashSeparator.map((e) => _valueForPropertyInStyle(e)).join(' ');
    final afterValue = afterSlashSeparator.map((e) => _valueForPropertyInStyle(e)).join(' ');
    return backgroundColor + ' ' + beforeValue + ' / ' + afterValue;
  }

  @override
  String toString() {
    return 'ComputedCSSStyleDeclaration($_element)';
  }
}

List<T>? _compressSlidesValue<T>(List<T> values) {
  assert(values.length == 4, 'The sides dose not include top | right | bottom | left');
  final top = values[0];
  final right = values[1];
  final bottom = values[2];
  final left = values[3];
  if (left == null || right == null || top == null || bottom == null) {
    return null;
  }
  final showLeft = left != right;
  final showBottom = (top != bottom) || showLeft;
  final showRight = (top != right) || showBottom;

  List<T> list = [];
  list.add(top);
  if (showRight) {
    list.add(right);
  }
  if (showBottom) {
    list.add(bottom);
  }
  if (showLeft) {
    list.add(left);
  }
  return list;
}

extension CSSEdgeInsetsText on EdgeInsets {
  String cssText() {
    return _compressSlidesValue<double>([top,right,bottom,left])?.map((e) => '${e}px').join(' ') ?? '0px';
  }
}

extension CSSShadowText on Shadow {
  String cssText() {
    return '${offset.dx}px ${offset.dy}px ${blurRadius}px ${CSSColor(color).cssText()}';
  }
}

extension CSSFontWeightText on FontWeight {
  String cssText() {
    return const <int, String>{
      0: '100',
      1: '200',
      2: '300',
      3: '400',
      4: '500',
      5: '600',
      6: '700',
      7: '800',
      8: '900',
    }[index]!;
  }
}


extension DoubleText on double {
  String cssText() {
    var result = toStringAsFixed(6);
    if (result.endsWith('.000000') == true) {
      result = result.replaceAll('.000000', '');
    }
    return result;
  }
}

extension FontStyleText on FontStyle {
  String cssText() {
    switch (this) {
      case FontStyle.italic:
        return 'italic';
      case FontStyle.normal:
        return 'normal';
    }
  }
}

extension CSSDisplayText on CSSDisplay {
  String cssText() {
    switch (this) {
      case CSSDisplay.none:
        return 'none';
      case CSSDisplay.sliver:
        return 'sliver';
      case CSSDisplay.block:
        return 'block';
      case CSSDisplay.inlineBlock:
        return 'inline-block';
      case CSSDisplay.flex:
        return 'flex';
      case CSSDisplay.inlineFlex:
        return 'inline-flex';
      case CSSDisplay.inline:
      default:
        return 'inline';
    }
  }
}

extension CSSOverflowTypeText on CSSOverflowType {
  String cssText() {
    switch (this) {
      case CSSOverflowType.clip:
        return 'clip';
      case CSSOverflowType.auto:
        return 'auto';
      case CSSOverflowType.visible:
        return 'visible';
      case CSSOverflowType.hidden:
        return 'hidden';
      case CSSOverflowType.scroll:
        return 'scroll';
    }
  }
}

extension CSSPositionTypeText on CSSPositionType {
  String cssText() {
    switch (this) {
      case CSSPositionType.static:
        return 'static';
      case CSSPositionType.relative:
        return 'relative';
      case CSSPositionType.absolute:
        return 'absolute';
      case CSSPositionType.fixed:
        return 'fixed';
      case CSSPositionType.sticky:
        return 'sticky';
    }
  }
}

extension TextOverflowText on TextOverflow {
  String cssText() {
    switch (this) {
      case TextOverflow.clip:
        return 'clip';
      case TextOverflow.fade:
        return 'fade';
      case TextOverflow.ellipsis:
        return 'ellipsis';
      case TextOverflow.visible:
        return 'visible';
    }
  }
}

extension TextAlignText on TextAlign {
  String cssText() {
    switch (this) {
      case TextAlign.left:
        return 'left';
      case TextAlign.right:
        return 'right';
      case TextAlign.center:
        return 'center';
      case TextAlign.justify:
        return 'justify';
      case TextAlign.start:
        return 'start';
      case TextAlign.end:
        return 'end';
    }
  }
}

extension VerticalAlignText on VerticalAlign {
  String cssText() {
    switch (this) {
      case VerticalAlign.baseline:
        return 'baseline';
      case VerticalAlign.top:
        return 'top';
      case VerticalAlign.bottom:
        return 'bottom';
    }
  }
}

extension VisibilityText on Visibility {
  String cssText() {
    switch (this) {
      case Visibility.visible:
        return 'visible';
      case Visibility.hidden:
        return 'hidden';
    }
  }
}

extension WhiteSpaceText on WhiteSpace {
  String cssText() {
    switch (this) {
      case WhiteSpace.normal:
        return 'normal';
      case WhiteSpace.nowrap:
        return 'nowrap';
      case WhiteSpace.pre:
        return 'pre';
      case WhiteSpace.preWrap:
        return 'pre-wrap';
      case WhiteSpace.preLine:
        return 'pre-line';
      case WhiteSpace.breakSpaces:
        return 'break-spaces';
    }
  }
}

extension Matrix4CSSText on Matrix4 {
  String cssText() {
    if (isIdentity()) {
      return 'none';
    }
    if (CSSMatrix.isAffine(this)) {
      final a = entry(0, 0).cssText();
      final b = entry(1, 0).cssText();

      final c = entry(0, 1).cssText();
      final d = entry(1, 1).cssText();

      final e = entry(0, 3).cssText();
      final f = entry(1, 3).cssText();
      return 'matrix($a, $b, $c, $d, $e, $f)';
    } else {
      final m11 = entry(0, 0).cssText();
      final m12 = entry(0, 1).cssText();
      final m13 = entry(0, 2).cssText();
      final m14 = entry(0, 3).cssText();

      final m21 = entry(1, 0).cssText();
      final m22 = entry(1, 1).cssText();
      final m23 = entry(1, 2).cssText();
      final m24 = entry(1, 3).cssText();

      final m31 = entry(2, 0).cssText();
      final m32 = entry(2, 1).cssText();
      final m33 = entry(2, 2).cssText();
      final m34 = entry(2, 3).cssText();

      final m41 = entry(3, 0).cssText();
      final m42 = entry(3, 1).cssText();
      final m43 = entry(3, 2).cssText();
      final m44 = entry(3, 3).cssText();
      return 'matrix3d($m11, $m12, $m13, $m14, $m21, $m22, $m23, $m24, $m31, $m32, $m33, $m34, $m41, $m42, $m43, $m44)';
    }
  }
}
