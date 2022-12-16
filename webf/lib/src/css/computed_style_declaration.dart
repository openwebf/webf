/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'dart:ffi' as ffi;
import 'package:flutter/painting.dart';
import 'package:webf/bridge.dart';
import 'package:webf/css.dart';
import 'package:webf/dom.dart';
import 'package:webf/foundation.dart';

class ComputedCSSStyleDeclaration extends CSSStyleDeclaration {
  final Element _element;
  final String? _pseudoElementName;

  final ffi.Pointer<NativeBindingObject> _pointer;

  ComputedCSSStyleDeclaration(this._element, this._pseudoElementName)
      : _pointer = allocateNewBindingObject(),
        super();

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
    CSSPropertyID? propertyID = CSSPropertyNameMap[propertyName];
    if (propertyID == null) {
      return '';
    }
    return valueForPropertyInStyle(propertyID);
  }

  String valueForPropertyInStyle(CSSPropertyID propertyID) {
    _element.ownerDocument.updateStyleIfNeeded();
    RenderStyle? style = _element.computedStyle(_pseudoElementName);

    if (style == null) {
      return '';
    }

    switch (propertyID) {
      case CSSPropertyID.Invalid:
      case CSSPropertyID.Variable:
        break;
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
      case CSSPropertyID.BackgroundAttachment:
      case CSSPropertyID.BackgroundClip:
      case CSSPropertyID.BackgroundOrigin:
        break;
      case CSSPropertyID.BorderTopColor:
        return style.borderTopColor.cssText();
      case CSSPropertyID.BorderRightColor:
        return style.borderRightColor.cssText();
      case CSSPropertyID.BorderBottomColor:
        return style.borderBottomColor.cssText();
      case CSSPropertyID.BorderLeftColor:
        return style.borderLeftColor.cssText();
      case CSSPropertyID.BorderTopStyle:
        return style.borderTopStyle.toString();
      case CSSPropertyID.BorderRightStyle:
        return style.borderRightStyle.toString();
      case CSSPropertyID.BorderBottomStyle:
        return style.borderBottomStyle.toString();
      case CSSPropertyID.BorderLeftStyle:
        return style.borderLeftStyle.toString();
      case CSSPropertyID.BorderTopWidth:
        return '${style.borderTopWidth?.computedValue}px';
      case CSSPropertyID.BorderRightWidth:
        return '${style.borderRightWidth?.computedValue}px';
      case CSSPropertyID.BorderBottomWidth:
        return '${style.borderRightWidth?.computedValue}px';
      case CSSPropertyID.BorderLeftWidth:
        return '${style.borderLeftWidth?.computedValue}px';
      case CSSPropertyID.Color:
        return style.color.cssText();
      case CSSPropertyID.Display:
        return style.display.toString();
      case CSSPropertyID.Font:
        break;
      case CSSPropertyID.FontFamily:
        return style.fontFamily?.join(',') ?? '';
      case CSSPropertyID.FontSize:
        return '${style.fontSize.computedValue}px';
      case CSSPropertyID.FontStyle:
        return style.fontStyle.toString();
      case CSSPropertyID.FontWeight:
        return style.fontWeight.index.toString();
      case CSSPropertyID.Top:
        return '${style.top.computedValue}px';
      case CSSPropertyID.Bottom:
        return '${style.bottom.computedValue}px';
      case CSSPropertyID.Left:
        return '${style.left.computedValue}px';
      case CSSPropertyID.Right:
        return '${style.right.computedValue}px';
      case CSSPropertyID.Width:
        return '${style.width.computedValue}px';
      case CSSPropertyID.Height:
        return '${style.height.computedValue}px';
      case CSSPropertyID.MaxHeight:
        return '${style.maxHeight.computedValue}px';
      case CSSPropertyID.MaxWidth:
        return '${style.maxHeight.computedValue}px';
      case CSSPropertyID.MinHeight:
        return '${style.minHeight.computedValue}px';
      case CSSPropertyID.MinWidth:
        return '${style.minWidth.computedValue}px';
      case CSSPropertyID.Margin:
        return style.margin.cssText();
      case CSSPropertyID.MarginTop:
        return '${style.marginTop.computedValue}px';
      case CSSPropertyID.MarginRight:
        return '${style.marginRight.computedValue}px';
      case CSSPropertyID.MarginBottom:
        return '${style.marginBottom.computedValue}px';
      case CSSPropertyID.MarginLeft:
        return '${style.marginLeft.computedValue}px';
      case CSSPropertyID.Padding:
        return style.padding.cssText();
      case CSSPropertyID.PaddingTop:
        return '${style.paddingTop.computedValue}px';
      case CSSPropertyID.PaddingRight:
        return '${style.paddingRight.computedValue}px';
      case CSSPropertyID.PaddingBottom:
        return '${style.paddingBottom.computedValue}px';
      case CSSPropertyID.PaddingLeft:
        return '${style.paddingLeft.computedValue}px';
      case CSSPropertyID.LetterSpacing:
        return '${style.letterSpacing?.computedValue}px';
      case CSSPropertyID.LineHeight:
        return '${style.lineHeight.computedValue}px';
      case CSSPropertyID.ObjectFit:
        return style.objectFit.toString();
      case CSSPropertyID.Opacity:
        return style.opacity.toString();
      case CSSPropertyID.OverflowX:
        return style.overflowX.toString();
      case CSSPropertyID.OverflowY:
        return style.overflowY.toString();
      case CSSPropertyID.Position:
        return style.position.toString();
      case CSSPropertyID.TextAlign:
        return style.textAlign.toString();
      case CSSPropertyID.TextShadow:
        // return style.textShadow;
        break;
      case CSSPropertyID.TextOverflow:
        return style.textOverflow.toString();
      case CSSPropertyID.VerticalAlign:
        return style.verticalAlign.toString();
      case CSSPropertyID.Visibility:
        return style.visibility.toString();
      case CSSPropertyID.WhiteSpace:
        return style.whiteSpace.toString();
      case CSSPropertyID.ZIndex:
        return style.zIndex?.toString() ?? '';
      // case CSSPropertyID.TransitionDelay:
      //   return style.transitionDelay;
      // case CSSPropertyID.TransitionDuration:
      //   return style.transitionDuration;
      // case CSSPropertyID.TransitionProperty:
      //   return style.transitionProperty;
      // case CSSPropertyID.TransitionTimingFunction:
      //   return style.transitionTimingFunction;
      case CSSPropertyID.Border:
        return style.border.cssText();
      // case CSSPropertyID.BorderBottom:
      //   break;
      // case CSSPropertyID.BorderColor:
      //   break;
      // case CSSPropertyID.BorderLeft:
      //   return style.borderLeftStyle;
      // case CSSPropertyID.BorderRadius:
      //   return style.borderRadius;
      case CSSPropertyID.BorderImage:
      case CSSPropertyID.BorderRight:
      case CSSPropertyID.BorderStyle:
      case CSSPropertyID.BorderTop:
      case CSSPropertyID.BorderWidth:
        break;
      // case CSSPropertyID.TableLayout:
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
      case CSSPropertyID.Overflow:
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
      case CSSPropertyID.FontVariant:
      case CSSPropertyID.TabSize:
      case CSSPropertyID.Cursor:
      case CSSPropertyID.EmptyCells:
      case CSSPropertyID.Direction:

      case CSSPropertyID.BorderCollapse:
      case CSSPropertyID.BorderImageSource:
      case CSSPropertyID.CaptionSide:
      case CSSPropertyID.Clear:
      case CSSPropertyID.BorderImageOutset:
      case CSSPropertyID.BorderImageRepeat:
      case CSSPropertyID.BorderImageSlice:
      case CSSPropertyID.BorderImageWidth:
      case CSSPropertyID.BorderBottomLeftRadius:
      case CSSPropertyID.BorderBottomRightRadius:
      case CSSPropertyID.BorderTopLeftRadius:
      case CSSPropertyID.BorderTopRightRadius:
      case CSSPropertyID.Clip:
      case CSSPropertyID.Speak:
        break;
      /* Individual properties not part of the spec */
      case CSSPropertyID.BackgroundRepeatX:
      case CSSPropertyID.BackgroundRepeatY:
        break;
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
      case CSSPropertyID.Fill:
      case CSSPropertyID.FillOpacity:
      case CSSPropertyID.FillRule:
      case CSSPropertyID.Marker:
      case CSSPropertyID.MarkerEnd:
      case CSSPropertyID.MarkerMid:
      case CSSPropertyID.MarkerStart:
      case CSSPropertyID.MaskType:
      case CSSPropertyID.ShapeRendering:
      case CSSPropertyID.Stroke:
      case CSSPropertyID.StrokeDasharray:
      case CSSPropertyID.StrokeDashoffset:
      case CSSPropertyID.StrokeLinecap:
      case CSSPropertyID.StrokeLinejoin:
      case CSSPropertyID.StrokeMiterlimit:
      case CSSPropertyID.StrokeOpacity:
      case CSSPropertyID.StrokeWidth:
      case CSSPropertyID.AlignmentBaseline:
      case CSSPropertyID.BaselineShift:
      case CSSPropertyID.DominantBaseline:
      case CSSPropertyID.GlyphOrientationHorizontal:
      case CSSPropertyID.GlyphOrientationVertical:
      case CSSPropertyID.Kerning:
      case CSSPropertyID.TextAnchor:
      case CSSPropertyID.VectorEffect:
      case CSSPropertyID.WritingMode:
      case CSSPropertyID.BorderSpacing:
      case CSSPropertyID.BoxShadow:
        break;
    }
    return '';
  }

  @override
  void setProperty(String propertyName, String? value, [bool? isImportant]) {
    throw UnimplementedError('No Modification Allowed');
  }

  @override
  String removeProperty(String propertyName, [bool? isImportant]) {
    throw UnimplementedError('Not implemented');
  }

  String _getBackgroundShorthandValue() {
    // Before Slash { CSSPropertyBackgroundImage,
    //                CSSPropertyBackgroundRepeat,
    //          *TODO CSSPropertyBackgroundAttachment,
    //                CSSPropertyBackgroundPosition };
    // After Slash { *TODO CSSPropertyBackgroundSize,
    //               *TODO CSSPropertyBackgroundOrigin,
    //               *TODO CSSPropertyBackgroundClip };
    List<CSSPropertyID> beforeSlashSeparator = [CSSPropertyID.BackgroundImage,
                                                CSSPropertyID.BackgroundRepeat,
                                                CSSPropertyID.BackgroundPosition];
    final backgroundColor = valueForPropertyInStyle(CSSPropertyID.BackgroundColor);
    final value = beforeSlashSeparator.map((e) => valueForPropertyInStyle(e)).join(' ');
    return backgroundColor + ' ' + value;
  }
}

extension CSSEdgeInsetsText on EdgeInsets {
  String cssText() {
    if (left == 0 && right == 0 && top == 0 && bottom == 0) {
      return '0px';
    }
    final showLeft = left != right;
    final showBottom = (top != bottom) || showLeft;
    final showRight = (top != right) || showBottom;

    List<String> list = [];
    list.add('${top}px');
    if (showRight) {
      list.add('${right}px');
    }
    if (showBottom) {
      list.add('${bottom}px');
    }
    if (showLeft) {
      list.add('${left}px');
    }
    return list.join(' ');
  }
}
