/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/css.dart';
import 'package:webf/dom.dart';

class CSSComputedStyleDeclaration extends CSSStyleDeclaration {
  final Element _element;
  final String? _pseudoElementName;

  CSSComputedStyleDeclaration(this._element, this._pseudoElementName);

  @override
  String get cssText {
    return "";
  }

//   String CSSComputedStyleDeclaration::cssText() const
//   {
//   StringBuilder result;
//
//   for (unsigned i = 0; i < numComputedProperties; i++) {
//   if (i)
//   result.append(' ');
//   result.append(getPropertyName(computedProperties[i]));
//   result.append(": ", 2);
//   result.append(getPropertyValue(computedProperties[i]));
//   result.append(';');
//   }
//
//   return result.toString();
// }

  @override
  String getPropertyValue(String propertyName) {
    CSSPropertyID? propertyID = CSSPropertyNameMap[propertyName];
    if (propertyID == null) {
      return '';
    }
    return valueForPropertyInStyle(propertyID);
  }

  dynamic valueForPropertyInStyle(CSSPropertyID propertyID) {
    _element.ownerDocument.updateStyleIfNeeded();
    RenderStyle? style = _element.computedStyle(_pseudoElementName);

    if (style == null) {
      return null;
    }

    switch (propertyID) {
      case CSSPropertyID.Invalid:
      case CSSPropertyID.Variable:
        break;
      case CSSPropertyID.Background:
        break;
      case CSSPropertyID.BackgroundColor:
        return style.backgroundColor.toString();
      case CSSPropertyID.BackgroundImage:
        return style.backgroundImage;
      case CSSPropertyID.BackgroundRepeat:
        return style.backgroundRepeat;
      case CSSPropertyID.BackgroundPositionX:
        return style.backgroundPositionX;
      case CSSPropertyID.BackgroundPositionY:
        return style.backgroundPositionY;
      case CSSPropertyID.BorderTopColor:
        return style.borderTopColor;
      case CSSPropertyID.BorderRightColor:
        return style.borderRightColor;
      case CSSPropertyID.BorderBottomColor:
        return style.borderBottomColor;
      case CSSPropertyID.BorderLeftColor:
        return style.borderLeftColor;
      case CSSPropertyID.BorderTopStyle:
        return style.borderTopStyle;
      case CSSPropertyID.BorderRightStyle:
        return style.borderRightStyle;
      case CSSPropertyID.BorderBottomStyle:
        return style.borderBottomStyle;
      case CSSPropertyID.BorderLeftStyle:
        return style.borderLeftStyle;
      case CSSPropertyID.BorderTopWidth:
        return style.borderTopWidth;
      case CSSPropertyID.BorderRightWidth:
        return style.borderRightWidth;
      case CSSPropertyID.BorderBottomWidth:
        return style.borderBottomWidth;
      case CSSPropertyID.BorderLeftWidth:
        return style.borderLeftWidth;
      case CSSPropertyID.Bottom:
        return style.bottom;
      case CSSPropertyID.Color:
        return style.color;
      case CSSPropertyID.Display:
        return style.display;
      case CSSPropertyID.Font:
        break;
      case CSSPropertyID.FontFamily:
        return style.fontFamily;
      case CSSPropertyID.FontSize:
        return style.fontSize;
      case CSSPropertyID.FontStyle:
        return style.fontStyle;
      case CSSPropertyID.FontWeight:
        return style.fontWeight;
      case CSSPropertyID.Height:
        return style.height;
      case CSSPropertyID.Left:
        return style.left;
      case CSSPropertyID.LetterSpacing:
        return style.letterSpacing;
      case CSSPropertyID.LineHeight:
        return style.lineHeight;
      case CSSPropertyID.MarginTop:
        return style.marginTop;
      case CSSPropertyID.MarginRight:
        return style.marginRight;
      case CSSPropertyID.MarginBottom:
        return style.marginBottom;
      case CSSPropertyID.MarginLeft:
        return style.marginLeft;
      case CSSPropertyID.MaxHeight:
        return style.maxHeight;
      case CSSPropertyID.MaxWidth:
        return style.maxHeight;
      case CSSPropertyID.MinHeight:
        return style.minHeight;
      case CSSPropertyID.MinWidth:
        return style.minWidth;
      case CSSPropertyID.ObjectFit:
        return style.objectFit;
      case CSSPropertyID.Opacity:
        return style.opacity;
      case CSSPropertyID.OverflowX:
        return style.overflowX;
      case CSSPropertyID.OverflowY:
        return style.overflowY;
      case CSSPropertyID.PaddingTop:
        return style.paddingTop;
      case CSSPropertyID.PaddingRight:
        return style.paddingRight;
      case CSSPropertyID.PaddingBottom:
        return style.paddingBottom;
      case CSSPropertyID.PaddingLeft:
        return style.paddingLeft;
      case CSSPropertyID.Position:
        return style.position;
      case CSSPropertyID.Right:
        return style.right;
      case CSSPropertyID.TableLayout:
      case CSSPropertyID.TextAlign:
        return style.textAlign;
      case CSSPropertyID.TextShadow:
        return style.textShadow;
      case CSSPropertyID.TextOverflow:
        return style.textShadow;
      case CSSPropertyID.Top:
        return style.top;
      case CSSPropertyID.VerticalAlign:
        switch (style.verticalAlign) {
          case VerticalAlign.baseline:
            return 'baseline';
          case VerticalAlign.top:
            return 'top';
          case VerticalAlign.bottom:
            return 'bottom';
        }
      case CSSPropertyID.Visibility:
        return style.visibility;
      case CSSPropertyID.WhiteSpace:
        return style.whiteSpace;
      case CSSPropertyID.Width:
        return style.width;
      case CSSPropertyID.ZIndex:
        return style.zIndex;
      case CSSPropertyID.TransitionDelay:
        return style.transitionDelay;
      case CSSPropertyID.TransitionDuration:
        return style.transitionDuration;
      case CSSPropertyID.TransitionProperty:
        return style.transitionProperty;
      case CSSPropertyID.TransitionTimingFunction:
        return style.transitionTimingFunction;
      case CSSPropertyID.Border:
        return style.border;
      case CSSPropertyID.BorderBottom:
        break;
      case CSSPropertyID.BorderColor:
        return style.borderTopColor;
      case CSSPropertyID.BorderLeft:
        return style.borderLeftStyle;
      case CSSPropertyID.BorderRadius:
        return style.borderRadius;
      case CSSPropertyID.BorderImage:
      case CSSPropertyID.BorderRight:
      case CSSPropertyID.BorderStyle:
      case CSSPropertyID.BorderTop:
      case CSSPropertyID.BorderWidth:
        break;

      case CSSPropertyID.Margin:
        return style.margin;
      case CSSPropertyID.Outline:
        break;
      case CSSPropertyID.Padding:
        break;
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
      case CSSPropertyID.BackgroundSize:
      case CSSPropertyID.BackgroundAttachment:
      case CSSPropertyID.BackgroundClip:
      case CSSPropertyID.BackgroundOrigin:
      case CSSPropertyID.BackgroundPosition:
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
        break;
    }
    return null;
  }

  @override
  void setProperty(String propertyName, String? value, [bool? isImportant]) {
    throw UnimplementedError('No Modification Allowed');
  }
}
