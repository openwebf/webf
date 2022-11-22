/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

enum CSSPropertyID {
  Invalid,
  Variable,
  Color,
  Direction,
  Display,
  Font,
  FontFamily,
  FontSize,
  FontStyle,
  FontVariant,
  FontWeight,
  TextRendering,
  Zoom,
  LineHeight,
  Background,
  BackgroundAttachment,
  BackgroundClip,
  BackgroundColor,
  BackgroundImage,
  BackgroundOrigin,
  BackgroundPosition,
  BackgroundPositionX,
  BackgroundPositionY,
  BackgroundRepeat,
  BackgroundRepeatX,
  BackgroundRepeatY,
  BackgroundSize,
  Border,
  BorderBottom,
  BorderBottomColor,
  BorderBottomLeftRadius,
  BorderBottomRightRadius,
  BorderBottomStyle,
  BorderBottomWidth,
  BorderCollapse,
  BorderColor,
  BorderImage,
  BorderImageOutset,
  BorderImageRepeat,
  BorderImageSlice,
  BorderImageSource,
  BorderImageWidth,
  BorderLeft,
  BorderLeftColor,
  BorderLeftStyle,
  BorderLeftWidth,
  BorderRadius,
  BorderRight,
  BorderRightColor,
  BorderRightStyle,
  BorderRightWidth,
  BorderSpacing,
  BorderStyle,
  BorderTop,
  BorderTopColor,
  BorderTopLeftRadius,
  BorderTopRightRadius,
  BorderTopStyle,
  BorderTopWidth,
  BorderWidth,
  Bottom,
  BoxShadow,
  BoxSizing,
  CaptionSide,
  Clear,
  Clip,
  Content,
  CounterIncrement,
  CounterReset,
  Cursor,
  EmptyCells,
  Float,
  FontStretch,
  Height,
  ImageRendering,
  Left,
  LetterSpacing,
  ListStyle,
  ListStyleImage,
  ListStylePosition,
  ListStyleType,
  Margin,
  MarginBottom,
  MarginLeft,
  MarginRight,
  MarginTop,
  MaxHeight,
  MaxWidth,
  MinHeight,
  MinWidth,
  ObjectFit,
  Opacity,
  Orphans,
  Outline,
  OutlineColor,
  OutlineOffset,
  OutlineStyle,
  OutlineWidth,
  Overflow,
  OverflowWrap,
  OverflowX,
  OverflowY,
  Padding,
  PaddingBottom,
  PaddingLeft,
  PaddingRight,
  PaddingTop,
  Page,
  PageBreakAfter,
  PageBreakBefore,
  PageBreakInside,
  PointerEvents,
  Position,
  Quotes,
  Resize,
  Right,
  Size,
  Src,
  Speak,
  TableLayout,
  TabSize,
  TextAlign,
  TextDecoration,
  TextIndent,
  TextLineThrough,
  TextLineThroughColor,
  TextLineThroughMode,
  TextLineThroughStyle,
  TextLineThroughWidth,
  TextOverflow,
  TextOverline,
  TextOverlineColor,
  TextOverlineMode,
  TextOverlineStyle,
  TextOverlineWidth,
  TextShadow,
  TextTransform,
  TextUnderline,
  TextUnderlineColor,
  TextUnderlineMode,
  TextUnderlineStyle,
  TextUnderlineWidth,
  Top,
  Transition,
  TransitionDelay,
  TransitionDuration,
  TransitionProperty,
  TransitionTimingFunction,
  UnicodeBidi,
  UnicodeRange,
  VerticalAlign,
  Visibility,
  WhiteSpace,
  Widows,
  Width,
  WordBreak,
  WordSpacing,
  WordWrap,
  ZIndex,
  BufferedRendering,
  ClipPath,
  ClipRule,
  Mask,
  EnableBackground,
  Filter,
  FloodColor,
  FloodOpacity,
  LightingColor,
  StopColor,
  StopOpacity,
  ColorInterpolation,
  ColorInterpolationFilters,
  ColorProfile,
  ColorRendering,
  Fill,
  FillOpacity,
  FillRule,
  Marker,
  MarkerEnd,
  MarkerMid,
  MarkerStart,
  MaskType,
  ShapeRendering,
  Stroke,
  StrokeDasharray,
  StrokeDashoffset,
  StrokeLinecap,
  StrokeLinejoin,
  StrokeMiterlimit,
  StrokeOpacity,
  StrokeWidth,
  AlignmentBaseline,
  BaselineShift,
  DominantBaseline,
  GlyphOrientationHorizontal,
  GlyphOrientationVertical,
  Kerning,
  TextAnchor,
  VectorEffect,
  WritingMode,
}

const Map<String, CSSPropertyID> properyNameMap = {
  'bottom': CSSPropertyID.Bottom,
  'border': CSSPropertyID.Border,
  'border-bottom': CSSPropertyID.BorderBottom,
  'margin': CSSPropertyID.Margin,
  'margin-bottom': CSSPropertyID.MarginBottom,
  'border-image': CSSPropertyID.BorderImage,
  'marker': CSSPropertyID.Marker,
  'right': CSSPropertyID.Right,
  'width': CSSPropertyID.Width,
  'marker-end': CSSPropertyID.MarkerEnd,
  'writing-mode': CSSPropertyID.WritingMode,
  'border-right': CSSPropertyID.BorderRight,
  'image-rendering': CSSPropertyID.ImageRendering,
  'border-width': CSSPropertyID.BorderWidth,
  'min-width': CSSPropertyID.MinWidth,
  'marker-mid': CSSPropertyID.MarkerMid,
  'border-bottom-width': CSSPropertyID.BorderBottomWidth,
  'word-break': CSSPropertyID.WordBreak,
  'height': CSSPropertyID.Height,
  'kerning': CSSPropertyID.Kerning,
  'margin-right': CSSPropertyID.MarginRight,
  'min-height': CSSPropertyID.MinHeight,
  'border-image-width': CSSPropertyID.BorderImageWidth,
  'border-right-width': CSSPropertyID.BorderRightWidth,
  'quotes': CSSPropertyID.Quotes,
  'border-radius': CSSPropertyID.BorderRadius,
  'transition': CSSPropertyID.Transition,
  'top': CSSPropertyID.Top,
  'border-image-outset': CSSPropertyID.BorderImageOutset,
  'widows': CSSPropertyID.Widows,
  'mask': CSSPropertyID.Mask,
  'stroke': CSSPropertyID.Stroke,
  'border-top': CSSPropertyID.BorderTop,
  'page': CSSPropertyID.Page,
  'transition-duration': CSSPropertyID.TransitionDuration,
  'text-indent': CSSPropertyID.TextIndent,
  'marker-start': CSSPropertyID.MarkerStart,
  'margin-top': CSSPropertyID.MarginTop,
  'text-rendering': CSSPropertyID.TextRendering,
  'padding': CSSPropertyID.Padding,
  'word-wrap': CSSPropertyID.WordWrap,
  'padding-bottom': CSSPropertyID.PaddingBottom,
  'border-image-repeat': CSSPropertyID.BorderImageRepeat,
  'border-bottom-right-radius': CSSPropertyID.BorderBottomRightRadius,
  'max-width': CSSPropertyID.MaxWidth,
  'stroke-width': CSSPropertyID.StrokeWidth,
  'border-top-width': CSSPropertyID.BorderTopWidth,
  'max-height': CSSPropertyID.MaxHeight,
  'content': CSSPropertyID.Content,
  '-epub-word-break': CSSPropertyID.WordBreak,
  'padding-right': CSSPropertyID.PaddingRight,
  'direction': CSSPropertyID.Direction,
  'unicode-range': CSSPropertyID.UnicodeRange,
  'unicode-bidi': CSSPropertyID.UnicodeBidi,
  'font': CSSPropertyID.Font,
  'outline': CSSPropertyID.Outline,
  '-webkit-border-bottom-right-radius': CSSPropertyID.BorderBottomRightRadius,
  'pointer-events': CSSPropertyID.PointerEvents,
  'position': CSSPropertyID.Position,
  'orphans': CSSPropertyID.Orphans,
  'background': CSSPropertyID.Background,
  'font-variant': CSSPropertyID.FontVariant,
  'box-shadow': CSSPropertyID.BoxShadow,
  'zoom': CSSPropertyID.Zoom,
  'text-shadow': CSSPropertyID.TextShadow,
  'speak': CSSPropertyID.Speak,
  'background-image': CSSPropertyID.BackgroundImage,
  'shape-rendering': CSSPropertyID.ShapeRendering,
  'outline-width': CSSPropertyID.OutlineWidth,
  'src': CSSPropertyID.Src,
  'background-origin': CSSPropertyID.BackgroundOrigin,
  'cursor': CSSPropertyID.Cursor,
  'font-weight': CSSPropertyID.FontWeight,
  'counter-reset': CSSPropertyID.CounterReset,
  'padding-top': CSSPropertyID.PaddingTop,
  'line-height': CSSPropertyID.LineHeight,
  'border-top-right-radius': CSSPropertyID.BorderTopRightRadius,
  'page-break-inside': CSSPropertyID.PageBreakInside,
  'border-image-source': CSSPropertyID.BorderImageSource,
  'text-decoration': CSSPropertyID.TextDecoration,
  'text-anchor': CSSPropertyID.TextAnchor,
  'dominant-baseline': CSSPropertyID.DominantBaseline,
  'size': CSSPropertyID.Size,
  'resize': CSSPropertyID.Resize,
  'text-overline': CSSPropertyID.TextOverline,
  '-webkit-border-top-right-radius': CSSPropertyID.BorderTopRightRadius,
  'tab-size': CSSPropertyID.TabSize,
  'text-underline': CSSPropertyID.TextUnderline,
  'text-overline-mode': CSSPropertyID.TextOverlineMode,
  'text-underline-mode': CSSPropertyID.TextUnderlineMode,
  'text-align': CSSPropertyID.TextAlign,
  'stroke-linejoin': CSSPropertyID.StrokeLinejoin,
  'background-repeat': CSSPropertyID.BackgroundRepeat,
  'counter-increment': CSSPropertyID.CounterIncrement,
  'z-index': CSSPropertyID.ZIndex,
  'stroke-miterlimit': CSSPropertyID.StrokeMiterlimit,
  'color': CSSPropertyID.Color,
  'text-overline-width': CSSPropertyID.TextOverlineWidth,
  'clear': CSSPropertyID.Clear,
  'text-underline-width': CSSPropertyID.TextUnderlineWidth,
  'text-line-through': CSSPropertyID.TextLineThrough,
  'border-color': CSSPropertyID.BorderColor,
  'page-break-before': CSSPropertyID.PageBreakBefore,
  'text-line-through-mode': CSSPropertyID.TextLineThroughMode,
  'border-bottom-color': CSSPropertyID.BorderBottomColor,
  'page-break-after': CSSPropertyID.PageBreakAfter,
  'object-fit': CSSPropertyID.ObjectFit,
  'caption-side': CSSPropertyID.CaptionSide,
  'color-rendering': CSSPropertyID.ColorRendering,
  'border-spacing': CSSPropertyID.BorderSpacing,
  'left': CSSPropertyID.Left,
  'word-spacing': CSSPropertyID.WordSpacing,
  'float': CSSPropertyID.Float,
  'white-space': CSSPropertyID.WhiteSpace,
  'text-transform': CSSPropertyID.TextTransform,
  'border-left': CSSPropertyID.BorderLeft,
  'text-line-through-width': CSSPropertyID.TextLineThroughWidth,
  'filter': CSSPropertyID.Filter,
  'border-right-color': CSSPropertyID.BorderRightColor,
  'background-attachment': CSSPropertyID.BackgroundAttachment,
  'overflow': CSSPropertyID.Overflow,
  'enable-background': CSSPropertyID.EnableBackground,
  'margin-left': CSSPropertyID.MarginLeft,
  'background-position': CSSPropertyID.BackgroundPosition,
  'buffered-rendering': CSSPropertyID.BufferedRendering,
  'box-sizing': CSSPropertyID.BoxSizing,
  'background-repeat-x': CSSPropertyID.BackgroundRepeatX,
  'border-left-width': CSSPropertyID.BorderLeftWidth,
  'font-stretch': CSSPropertyID.FontStretch,
  'border-image-slice': CSSPropertyID.BorderImageSlice,
  'clip': CSSPropertyID.Clip,
  'border-top-color': CSSPropertyID.BorderTopColor,
  '-epub-caption-side': CSSPropertyID.CaptionSide,
  '-webkit-box-sizing': CSSPropertyID.BoxSizing,
  'alignment-baseline': CSSPropertyID.AlignmentBaseline,
  'border-bottom-left-radius': CSSPropertyID.BorderBottomLeftRadius,
  'transition-timing-function': CSSPropertyID.TransitionTimingFunction,
  '-epub-text-transform': CSSPropertyID.TextTransform,
  'overflow-x': CSSPropertyID.OverflowX,
  'font-size': CSSPropertyID.FontSize,
  'text-overflow': CSSPropertyID.TextOverflow,
  'background-size': CSSPropertyID.BackgroundSize,
  'overflow-wrap': CSSPropertyID.OverflowWrap,
  'padding-left': CSSPropertyID.PaddingLeft,
  'background-position-x': CSSPropertyID.BackgroundPositionX,
  'stop-color': CSSPropertyID.StopColor,
  '-webkit-border-bottom-left-radius': CSSPropertyID.BorderBottomLeftRadius,
  'outline-color': CSSPropertyID.OutlineColor,
  'background-color': CSSPropertyID.BackgroundColor,
  'letter-spacing': CSSPropertyID.LetterSpacing,
  'vertical-align': CSSPropertyID.VerticalAlign,
  'fill': CSSPropertyID.Fill,
  'baseline-shift': CSSPropertyID.BaselineShift,
  'stroke-linecap': CSSPropertyID.StrokeLinecap,
  'stroke-dasharray': CSSPropertyID.StrokeDasharray,
  'mask-type': CSSPropertyID.MaskType,
  'lighting-color': CSSPropertyID.LightingColor,
  'clip-path': CSSPropertyID.ClipPath,
  'border-top-left-radius': CSSPropertyID.BorderTopLeftRadius,
  'border-style': CSSPropertyID.BorderStyle,
  'border-bottom-style': CSSPropertyID.BorderBottomStyle,
  'opacity': CSSPropertyID.Opacity,
  '-webkit-border-top-left-radius': CSSPropertyID.BorderTopLeftRadius,
  'clip-rule': CSSPropertyID.ClipRule,
  'text-overline-color': CSSPropertyID.TextOverlineColor,
  'transition-delay': CSSPropertyID.TransitionDelay,
  'text-underline-color': CSSPropertyID.TextUnderlineColor,
  'visibility': CSSPropertyID.Visibility,
  'outline-offset': CSSPropertyID.OutlineOffset,
  'color-interpolation': CSSPropertyID.ColorInterpolation,
  'background-clip': CSSPropertyID.BackgroundClip,
  'border-right-style': CSSPropertyID.BorderRightStyle,
  'background-repeat-y': CSSPropertyID.BackgroundRepeatY,
  'stroke-dashoffset': CSSPropertyID.StrokeDashoffset,
  'transition-property': CSSPropertyID.TransitionProperty,
  '-webkit-opacity': CSSPropertyID.Opacity,
  'text-line-through-color': CSSPropertyID.TextLineThroughColor,
  'vector-effect': CSSPropertyID.VectorEffect,
  'border-collapse': CSSPropertyID.BorderCollapse,
  'flood-color': CSSPropertyID.FloodColor,
  'border-left-color': CSSPropertyID.BorderLeftColor,
  'table-layout': CSSPropertyID.TableLayout,
  'border-top-style': CSSPropertyID.BorderTopStyle,
  'display': CSSPropertyID.Display,
  'overflow-y': CSSPropertyID.OverflowY,
  'stroke-opacity': CSSPropertyID.StrokeOpacity,
  'fill-rule': CSSPropertyID.FillRule,
  'background-position-y': CSSPropertyID.BackgroundPositionY,
  'font-style': CSSPropertyID.FontStyle,
  'outline-style': CSSPropertyID.OutlineStyle,
  'stop-opacity': CSSPropertyID.StopOpacity,
  'color-profile': CSSPropertyID.ColorProfile,
  'list-style': CSSPropertyID.ListStyle,
  'list-style-image': CSSPropertyID.ListStyleImage,
  'text-overline-style': CSSPropertyID.TextOverlineStyle,
  'text-underline-style': CSSPropertyID.TextUnderlineStyle,
  'font-family': CSSPropertyID.FontFamily,
  'text-line-through-style': CSSPropertyID.TextLineThroughStyle,
  'border-left-style': CSSPropertyID.BorderLeftStyle,
  'flood-opacity': CSSPropertyID.FloodOpacity,
  'glyph-orientation-vertical': CSSPropertyID.GlyphOrientationVertical,
  'empty-cells': CSSPropertyID.EmptyCells,
  'list-style-position': CSSPropertyID.ListStylePosition,
  'color-interpolation-filters': CSSPropertyID.ColorInterpolationFilters,
  'glyph-orientation-horizontal': CSSPropertyID.GlyphOrientationHorizontal,
  'fill-opacity': CSSPropertyID.FillOpacity,
  'list-style-type': CSSPropertyID.ListStyleType
};

const List<bool> _isInheritedPropertyTable = [
  false, // CSSPropertyInvalid
  false, // CSSPropertyVariable
  true, // CSSPropertyColor
  true, // CSSPropertyDirection
  false, // CSSPropertyDisplay
  true, // CSSPropertyFont
  true, // CSSPropertyFontFamily
  true, // CSSPropertyFontSize
  true, // CSSPropertyFontStyle
  true, // CSSPropertyFontVariant
  true, // CSSPropertyFontWeight
  true, // CSSPropertyTextRendering
  false, // CSSPropertyZoom
  true, // CSSPropertyLineHeight
  false, // CSSPropertyBackground
  false, // CSSPropertyBackgroundAttachment
  false, // CSSPropertyBackgroundClip
  false, // CSSPropertyBackgroundColor
  false, // CSSPropertyBackgroundImage
  false, // CSSPropertyBackgroundOrigin
  false, // CSSPropertyBackgroundPosition
  false, // CSSPropertyBackgroundPositionX
  false, // CSSPropertyBackgroundPositionY
  false, // CSSPropertyBackgroundRepeat
  false, // CSSPropertyBackgroundRepeatX
  false, // CSSPropertyBackgroundRepeatY
  false, // CSSPropertyBackgroundSize
  false, // CSSPropertyBorder
  false, // CSSPropertyBorderBottom
  false, // CSSPropertyBorderBottomColor
  false, // CSSPropertyBorderBottomLeftRadius
  false, // CSSPropertyBorderBottomRightRadius
  false, // CSSPropertyBorderBottomStyle
  false, // CSSPropertyBorderBottomWidth
  true, // CSSPropertyBorderCollapse
  false, // CSSPropertyBorderColor
  false, // CSSPropertyBorderImage
  false, // CSSPropertyBorderImageOutset
  false, // CSSPropertyBorderImageRepeat
  false, // CSSPropertyBorderImageSlice
  false, // CSSPropertyBorderImageSource
  false, // CSSPropertyBorderImageWidth
  false, // CSSPropertyBorderLeft
  false, // CSSPropertyBorderLeftColor
  false, // CSSPropertyBorderLeftStyle
  false, // CSSPropertyBorderLeftWidth
  false, // CSSPropertyBorderRadius
  false, // CSSPropertyBorderRight
  false, // CSSPropertyBorderRightColor
  false, // CSSPropertyBorderRightStyle
  false, // CSSPropertyBorderRightWidth
  true, // CSSPropertyBorderSpacing
  false, // CSSPropertyBorderStyle
  false, // CSSPropertyBorderTop
  false, // CSSPropertyBorderTopColor
  false, // CSSPropertyBorderTopLeftRadius
  false, // CSSPropertyBorderTopRightRadius
  false, // CSSPropertyBorderTopStyle
  false, // CSSPropertyBorderTopWidth
  false, // CSSPropertyBorderWidth
  false, // CSSPropertyBottom
  false, // CSSPropertyBoxShadow
  false, // CSSPropertyBoxSizing
  true, // CSSPropertyCaptionSide
  false, // CSSPropertyClear
  false, // CSSPropertyClip
  false, // CSSPropertyContent
  false, // CSSPropertyCounterIncrement
  false, // CSSPropertyCounterReset
  true, // CSSPropertyCursor
  true, // CSSPropertyEmptyCells
  false, // CSSPropertyFloat
  false, // CSSPropertyFontStretch
  false, // CSSPropertyHeight
  true, // CSSPropertyImageRendering
  false, // CSSPropertyLeft
  true, // CSSPropertyLetterSpacing
  true, // CSSPropertyListStyle
  true, // CSSPropertyListStyleImage
  true, // CSSPropertyListStylePosition
  true, // CSSPropertyListStyleType
  false, // CSSPropertyMargin
  false, // CSSPropertyMarginBottom
  false, // CSSPropertyMarginLeft
  false, // CSSPropertyMarginRight
  false, // CSSPropertyMarginTop
  false, // CSSPropertyMaxHeight
  false, // CSSPropertyMaxWidth
  false, // CSSPropertyMinHeight
  false, // CSSPropertyMinWidth
  false, // CSSPropertyObjectFit
  false, // CSSPropertyOpacity
  true, // CSSPropertyOrphans
  false, // CSSPropertyOutline
  false, // CSSPropertyOutlineColor
  false, // CSSPropertyOutlineOffset
  false, // CSSPropertyOutlineStyle
  false, // CSSPropertyOutlineWidth
  false, // CSSPropertyOverflow
  false, // CSSPropertyOverflowWrap
  false, // CSSPropertyOverflowX
  false, // CSSPropertyOverflowY
  false, // CSSPropertyPadding
  false, // CSSPropertyPaddingBottom
  false, // CSSPropertyPaddingLeft
  false, // CSSPropertyPaddingRight
  false, // CSSPropertyPaddingTop
  false, // CSSPropertyPage
  false, // CSSPropertyPageBreakAfter
  false, // CSSPropertyPageBreakBefore
  false, // CSSPropertyPageBreakInside
  true, // CSSPropertyPointerEvents
  false, // CSSPropertyPosition
  true, // CSSPropertyQuotes
  true, // CSSPropertyResize
  false, // CSSPropertyRight
  false, // CSSPropertySize
  false, // CSSPropertySrc
  true, // CSSPropertySpeak
  false, // CSSPropertyTableLayout
  true, // CSSPropertyTabSize
  true, // CSSPropertyTextAlign
  false, // CSSPropertyTextDecoration
  true, // CSSPropertyTextIndent
  false, // CSSPropertyTextLineThrough
  false, // CSSPropertyTextLineThroughColor
  false, // CSSPropertyTextLineThroughMode
  false, // CSSPropertyTextLineThroughStyle
  false, // CSSPropertyTextLineThroughWidth
  false, // CSSPropertyTextOverflow
  false, // CSSPropertyTextOverline
  false, // CSSPropertyTextOverlineColor
  false, // CSSPropertyTextOverlineMode
  false, // CSSPropertyTextOverlineStyle
  false, // CSSPropertyTextOverlineWidth
  true, // CSSPropertyTextShadow
  true, // CSSPropertyTextTransform
  false, // CSSPropertyTextUnderline
  false, // CSSPropertyTextUnderlineColor
  false, // CSSPropertyTextUnderlineMode
  false, // CSSPropertyTextUnderlineStyle
  false, // CSSPropertyTextUnderlineWidth
  false, // CSSPropertyTop
  false, // CSSPropertyTransition
  false, // CSSPropertyTransitionDelay
  false, // CSSPropertyTransitionDuration
  false, // CSSPropertyTransitionProperty
  false, // CSSPropertyTransitionTimingFunction
  false, // CSSPropertyUnicodeBidi
  false, // CSSPropertyUnicodeRange
  false, // CSSPropertyVerticalAlign
  true, // CSSPropertyVisibility
  true, // CSSPropertyWhiteSpace
  true, // CSSPropertyWidows
  false, // CSSPropertyWidth
  true, // CSSPropertyWordBreak
  true, // CSSPropertyWordSpacing
  true, // CSSPropertyWordWrap
  false, // CSSPropertyZIndex
  false, // CSSPropertyBufferedRendering
  false, // CSSPropertyClipPath
  true, // CSSPropertyClipRule
  false, // CSSPropertyMask
  false, // CSSPropertyEnableBackground
  false, // CSSPropertyFilter
  false, // CSSPropertyFloodColor
  false, // CSSPropertyFloodOpacity
  false, // CSSPropertyLightingColor
  false, // CSSPropertyStopColor
  false, // CSSPropertyStopOpacity
  true, // CSSPropertyColorInterpolation
  true, // CSSPropertyColorInterpolationFilters
  false, // CSSPropertyColorProfile
  true, // CSSPropertyColorRendering
  true, // CSSPropertyFill
  true, // CSSPropertyFillOpacity
  true, // CSSPropertyFillRule
  true, // CSSPropertyMarker
  true, // CSSPropertyMarkerEnd
  true, // CSSPropertyMarkerMid
  true, // CSSPropertyMarkerStart
  false, // CSSPropertyMaskType
  true, // CSSPropertyShapeRendering
  true, // CSSPropertyStroke
  true, // CSSPropertyStrokeDasharray
  true, // CSSPropertyStrokeDashoffset
  true, // CSSPropertyStrokeLinecap
  true, // CSSPropertyStrokeLinejoin
  true, // CSSPropertyStrokeMiterlimit
  true, // CSSPropertyStrokeOpacity
  true, // CSSPropertyStrokeWidth
  false, // CSSPropertyAlignmentBaseline
  false, // CSSPropertyBaselineShift
  false, // CSSPropertyDominantBaseline
  true, // CSSPropertyGlyphOrientationHorizontal
  true, // CSSPropertyGlyphOrientationVertical
  true, // CSSPropertyKerning
  true, // CSSPropertyTextAnchor
  false, // CSSPropertyVectorEffect
  true, // CSSPropertyWritingMode
];

bool isInheritedPropertyString(String property) {
  CSSPropertyID? id = properyNameMap[property];
  if (id == null) {
    return false;
  }
  return isInheritedPropertyID(id);
}

bool isInheritedPropertyID(CSSPropertyID id) {
  assert(id != CSSPropertyID.Invalid);
  return _isInheritedPropertyTable[id.index];
}
