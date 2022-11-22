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
  WebkitFontFeatureSettings,
  WebkitFontKerning,
  WebkitFontSmoothing,
  WebkitFontVariantLigatures,
  WebkitLocale,
  WebkitTextOrientation,
  WebkitWritingMode,
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
  WebkitClipPath,
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
  WebkitAnimation,
  WebkitAnimationDelay,
  WebkitAnimationDirection,
  WebkitAnimationDuration,
  WebkitAnimationFillMode,
  WebkitAnimationIterationCount,
  WebkitAnimationName,
  WebkitAnimationPlayState,
  WebkitAnimationTimingFunction,
  WebkitAppearance,
  WebkitAspectRatio,
  WebkitBackfaceVisibility,
  WebkitBackgroundBlendMode,
  WebkitBackgroundClip,
  WebkitBackgroundComposite,
  WebkitBackgroundOrigin,
  WebkitBackgroundSize,
  WebkitBorderAfter,
  WebkitBorderAfterColor,
  WebkitBorderAfterStyle,
  WebkitBorderAfterWidth,
  WebkitBorderBefore,
  WebkitBorderBeforeColor,
  WebkitBorderBeforeStyle,
  WebkitBorderBeforeWidth,
  WebkitBorderEnd,
  WebkitBorderEndColor,
  WebkitBorderEndStyle,
  WebkitBorderEndWidth,
  WebkitBorderFit,
  WebkitBorderHorizontalSpacing,
  WebkitBorderImage,
  WebkitBorderRadius,
  WebkitBorderStart,
  WebkitBorderStartColor,
  WebkitBorderStartStyle,
  WebkitBorderStartWidth,
  WebkitBorderVerticalSpacing,
  WebkitBoxAlign,
  WebkitBoxDirection,
  WebkitBoxFlex,
  WebkitBoxFlexGroup,
  WebkitBoxLines,
  WebkitBoxOrdinalGroup,
  WebkitBoxOrient,
  WebkitBoxPack,
  WebkitBoxReflect,
  WebkitBoxShadow,
  WebkitColorCorrection,
  WebkitColumnAxis,
  WebkitColumnBreakAfter,
  WebkitColumnBreakBefore,
  WebkitColumnBreakInside,
  WebkitColumnCount,
  WebkitColumnGap,
  WebkitColumnProgression,
  WebkitColumnRule,
  WebkitColumnRuleColor,
  WebkitColumnRuleStyle,
  WebkitColumnRuleWidth,
  WebkitColumnSpan,
  WebkitColumnWidth,
  WebkitColumns,
  WebkitBoxDecorationBreak,
  WebkitFilter,
  WebkitAlignContent,
  WebkitAlignItems,
  WebkitAlignSelf,
  WebkitFlex,
  WebkitFlexBasis,
  WebkitFlexDirection,
  WebkitFlexFlow,
  WebkitFlexGrow,
  WebkitFlexShrink,
  WebkitFlexWrap,
  WebkitJustifyContent,
  WebkitFontSizeDelta,
  WebkitGridArea,
  WebkitGridAutoColumns,
  WebkitGridAutoRows,
  WebkitGridColumnEnd,
  WebkitGridColumnStart,
  WebkitGridDefinitionColumns,
  WebkitGridDefinitionRows,
  WebkitGridRowEnd,
  WebkitGridRowStart,
  WebkitGridColumn,
  WebkitGridRow,
  WebkitGridTemplate,
  WebkitGridAutoFlow,
  WebkitHighlight,
  WebkitHyphenateCharacter,
  WebkitHyphenateLimitAfter,
  WebkitHyphenateLimitBefore,
  WebkitHyphenateLimitLines,
  WebkitHyphens,
  WebkitLineBoxContain,
  WebkitLineAlign,
  WebkitLineBreak,
  WebkitLineClamp,
  WebkitLineGrid,
  WebkitLineSnap,
  WebkitLogicalWidth,
  WebkitLogicalHeight,
  WebkitMarginAfterCollapse,
  WebkitMarginBeforeCollapse,
  WebkitMarginBottomCollapse,
  WebkitMarginTopCollapse,
  WebkitMarginCollapse,
  WebkitMarginAfter,
  WebkitMarginBefore,
  WebkitMarginEnd,
  WebkitMarginStart,
  WebkitMarquee,
  WebkitMarqueeDirection,
  WebkitMarqueeIncrement,
  WebkitMarqueeRepetition,
  WebkitMarqueeSpeed,
  WebkitMarqueeStyle,
  WebkitMask,
  WebkitMaskBoxImage,
  WebkitMaskBoxImageOutset,
  WebkitMaskBoxImageRepeat,
  WebkitMaskBoxImageSlice,
  WebkitMaskBoxImageSource,
  WebkitMaskBoxImageWidth,
  WebkitMaskClip,
  WebkitMaskComposite,
  WebkitMaskImage,
  WebkitMaskOrigin,
  WebkitMaskPosition,
  WebkitMaskPositionX,
  WebkitMaskPositionY,
  WebkitMaskRepeat,
  WebkitMaskRepeatX,
  WebkitMaskRepeatY,
  WebkitMaskSize,
  WebkitMaskSourceType,
  WebkitMaxLogicalWidth,
  WebkitMaxLogicalHeight,
  WebkitMinLogicalWidth,
  WebkitMinLogicalHeight,
  WebkitNbspMode,
  WebkitOrder,
  WebkitPaddingAfter,
  WebkitPaddingBefore,
  WebkitPaddingEnd,
  WebkitPaddingStart,
  WebkitPerspective,
  WebkitPerspectiveOrigin,
  WebkitPerspectiveOriginX,
  WebkitPerspectiveOriginY,
  WebkitPrintColorAdjust,
  WebkitRtlOrdering,
  WebkitRubyPosition,
  WebkitTextCombine,
  WebkitTextDecorationsInEffect,
  WebkitTextEmphasis,
  WebkitTextEmphasisColor,
  WebkitTextEmphasisPosition,
  WebkitTextEmphasisStyle,
  WebkitTextFillColor,
  WebkitTextSecurity,
  WebkitTextStroke,
  WebkitTextStrokeColor,
  WebkitTextStrokeWidth,
  WebkitTransform,
  WebkitTransformOrigin,
  WebkitTransformOriginX,
  WebkitTransformOriginY,
  WebkitTransformOriginZ,
  WebkitTransformStyle,
  WebkitTransition,
  WebkitTransitionDelay,
  WebkitTransitionDuration,
  WebkitTransitionProperty,
  WebkitTransitionTimingFunction,
  WebkitUserDrag,
  WebkitUserModify,
  WebkitUserSelect,
  WebkitFlowInto,
  WebkitFlowFrom,
  WebkitRegionFragment,
  WebkitRegionBreakAfter,
  WebkitRegionBreakBefore,
  WebkitRegionBreakInside,
  WebkitTapHighlightColor,
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
  WebkitSvgShadow,
}

const List<String> propertyNameStrings = [
  'color',
  'direction',
  'display',
  'font',
  'font-family',
  'font-size',
  'font-style',
  'font-variant',
  'font-weight',
  'text-rendering',
  '-webkit-font-feature-settings',
  '-webkit-font-kerning',
  '-webkit-font-smoothing',
  '-webkit-font-variant-ligatures',
  '-webkit-locale',
  '-webkit-text-orientation',
  '-webkit-writing-mode',
  'zoom',
  'line-height',
  'background',
  'background-attachment',
  'background-clip',
  'background-color',
  'background-image',
  'background-origin',
  'background-position',
  'background-position-x',
  'background-position-y',
  'background-repeat',
  'background-repeat-x',
  'background-repeat-y',
  'background-size',
  'border',
  'border-bottom',
  'border-bottom-color',
  'border-bottom-left-radius',
  'border-bottom-right-radius',
  'border-bottom-style',
  'border-bottom-width',
  'border-collapse',
  'border-color',
  'border-image',
  'border-image-outset',
  'border-image-repeat',
  'border-image-slice',
  'border-image-source',
  'border-image-width',
  'border-left',
  'border-left-color',
  'border-left-style',
  'border-left-width',
  'border-radius',
  'border-right',
  'border-right-color',
  'border-right-style',
  'border-right-width',
  'border-spacing',
  'border-style',
  'border-top',
  'border-top-color',
  'border-top-left-radius',
  'border-top-right-radius',
  'border-top-style',
  'border-top-width',
  'border-width',
  'bottom',
  'box-shadow',
  'box-sizing',
  'caption-side',
  'clear',
  'clip',
  '-webkit-clip-path',
  'content',
  'counter-increment',
  'counter-reset',
  'cursor',
  'empty-cells',
  'float',
  'font-stretch',
  'height',
  'image-rendering',
  'left',
  'letter-spacing',
  'list-style',
  'list-style-image',
  'list-style-position',
  'list-style-type',
  'margin',
  'margin-bottom',
  'margin-left',
  'margin-right',
  'margin-top',
  'max-height',
  'max-width',
  'min-height',
  'min-width',
  'object-fit',
  'opacity',
  'orphans',
  'outline',
  'outline-color',
  'outline-offset',
  'outline-style',
  'outline-width',
  'overflow',
  'overflow-wrap',
  'overflow-x',
  'overflow-y',
  'padding',
  'padding-bottom',
  'padding-left',
  'padding-right',
  'padding-top',
  'page',
  'page-break-after',
  'page-break-before',
  'page-break-inside',
  'pointer-events',
  'position',
  'quotes',
  'resize',
  'right',
  'size',
  'src',
  'speak',
  'table-layout',
  'tab-size',
  'text-align',
  'text-decoration',
  'text-indent',
  'text-line-through',
  'text-line-through-color',
  'text-line-through-mode',
  'text-line-through-style',
  'text-line-through-width',
  'text-overflow',
  'text-overline',
  'text-overline-color',
  'text-overline-mode',
  'text-overline-style',
  'text-overline-width',
  'text-shadow',
  'text-transform',
  'text-underline',
  'text-underline-color',
  'text-underline-mode',
  'text-underline-style',
  'text-underline-width',
  'top',
  'transition',
  'transition-delay',
  'transition-duration',
  'transition-property',
  'transition-timing-function',
  'unicode-bidi',
  'unicode-range',
  'vertical-align',
  'visibility',
  'white-space',
  'widows',
  'width',
  'word-break',
  'word-spacing',
  'word-wrap',
  'z-index',
  '-webkit-animation',
  '-webkit-animation-delay',
  '-webkit-animation-direction',
  '-webkit-animation-duration',
  '-webkit-animation-fill-mode',
  '-webkit-animation-iteration-count',
  '-webkit-animation-name',
  '-webkit-animation-play-state',
  '-webkit-animation-timing-function',
  '-webkit-appearance',
  '-webkit-aspect-ratio',
  '-webkit-backface-visibility',
  '-webkit-background-blend-mode',
  '-webkit-background-clip',
  '-webkit-background-composite',
  '-webkit-background-origin',
  '-webkit-background-size',
  '-webkit-border-after',
  '-webkit-border-after-color',
  '-webkit-border-after-style',
  '-webkit-border-after-width',
  '-webkit-border-before',
  '-webkit-border-before-color',
  '-webkit-border-before-style',
  '-webkit-border-before-width',
  '-webkit-border-end',
  '-webkit-border-end-color',
  '-webkit-border-end-style',
  '-webkit-border-end-width',
  '-webkit-border-fit',
  '-webkit-border-horizontal-spacing',
  '-webkit-border-image',
  '-webkit-border-radius',
  '-webkit-border-start',
  '-webkit-border-start-color',
  '-webkit-border-start-style',
  '-webkit-border-start-width',
  '-webkit-border-vertical-spacing',
  '-webkit-box-align',
  '-webkit-box-direction',
  '-webkit-box-flex',
  '-webkit-box-flex-group',
  '-webkit-box-lines',
  '-webkit-box-ordinal-group',
  '-webkit-box-orient',
  '-webkit-box-pack',
  '-webkit-box-reflect',
  '-webkit-box-shadow',
  '-webkit-color-correction',
  '-webkit-column-axis',
  '-webkit-column-break-after',
  '-webkit-column-break-before',
  '-webkit-column-break-inside',
  '-webkit-column-count',
  '-webkit-column-gap',
  '-webkit-column-progression',
  '-webkit-column-rule',
  '-webkit-column-rule-color',
  '-webkit-column-rule-style',
  '-webkit-column-rule-width',
  '-webkit-column-span',
  '-webkit-column-width',
  '-webkit-columns',
  '-webkit-box-decoration-break',
  '-webkit-filter',
  '-webkit-align-content',
  '-webkit-align-items',
  '-webkit-align-self',
  '-webkit-flex',
  '-webkit-flex-basis',
  '-webkit-flex-direction',
  '-webkit-flex-flow',
  '-webkit-flex-grow',
  '-webkit-flex-shrink',
  '-webkit-flex-wrap',
  '-webkit-justify-content',
  '-webkit-font-size-delta',
  '-webkit-grid-area',
  '-webkit-grid-auto-columns',
  '-webkit-grid-auto-rows',
  '-webkit-grid-column-end',
  '-webkit-grid-column-start',
  '-webkit-grid-definition-columns',
  '-webkit-grid-definition-rows',
  '-webkit-grid-row-end',
  '-webkit-grid-row-start',
  '-webkit-grid-column',
  '-webkit-grid-row',
  '-webkit-grid-template',
  '-webkit-grid-auto-flow',
  '-webkit-highlight',
  '-webkit-hyphenate-character',
  '-webkit-hyphenate-limit-after',
  '-webkit-hyphenate-limit-before',
  '-webkit-hyphenate-limit-lines',
  '-webkit-hyphens',
  '-webkit-line-box-contain',
  '-webkit-line-align',
  '-webkit-line-break',
  '-webkit-line-clamp',
  '-webkit-line-grid',
  '-webkit-line-snap',
  '-webkit-logical-width',
  '-webkit-logical-height',
  '-webkit-margin-after-collapse',
  '-webkit-margin-before-collapse',
  '-webkit-margin-bottom-collapse',
  '-webkit-margin-top-collapse',
  '-webkit-margin-collapse',
  '-webkit-margin-after',
  '-webkit-margin-before',
  '-webkit-margin-end',
  '-webkit-margin-start',
  '-webkit-marquee',
  '-webkit-marquee-direction',
  '-webkit-marquee-increment',
  '-webkit-marquee-repetition',
  '-webkit-marquee-speed',
  '-webkit-marquee-style',
  '-webkit-mask',
  '-webkit-mask-box-image',
  '-webkit-mask-box-image-outset',
  '-webkit-mask-box-image-repeat',
  '-webkit-mask-box-image-slice',
  '-webkit-mask-box-image-source',
  '-webkit-mask-box-image-width',
  '-webkit-mask-clip',
  '-webkit-mask-composite',
  '-webkit-mask-image',
  '-webkit-mask-origin',
  '-webkit-mask-position',
  '-webkit-mask-position-x',
  '-webkit-mask-position-y',
  '-webkit-mask-repeat',
  '-webkit-mask-repeat-x',
  '-webkit-mask-repeat-y',
  '-webkit-mask-size',
  '-webkit-mask-source-type',
  '-webkit-max-logical-width',
  '-webkit-max-logical-height',
  '-webkit-min-logical-width',
  '-webkit-min-logical-height',
  '-webkit-nbsp-mode',
  '-webkit-order',
  '-webkit-padding-after',
  '-webkit-padding-before',
  '-webkit-padding-end',
  '-webkit-padding-start',
  '-webkit-perspective',
  '-webkit-perspective-origin',
  '-webkit-perspective-origin-x',
  '-webkit-perspective-origin-y',
  '-webkit-print-color-adjust',
  '-webkit-rtl-ordering',
  '-webkit-ruby-position',
  '-webkit-text-combine',
  '-webkit-text-decorations-in-effect',
  '-webkit-text-emphasis',
  '-webkit-text-emphasis-color',
  '-webkit-text-emphasis-position',
  '-webkit-text-emphasis-style',
  '-webkit-text-fill-color',
  '-webkit-text-security',
  '-webkit-text-stroke',
  '-webkit-text-stroke-color',
  '-webkit-text-stroke-width',
  '-webkit-transform',
  '-webkit-transform-origin',
  '-webkit-transform-origin-x',
  '-webkit-transform-origin-y',
  '-webkit-transform-origin-z',
  '-webkit-transform-style',
  '-webkit-transition',
  '-webkit-transition-delay',
  '-webkit-transition-duration',
  '-webkit-transition-property',
  '-webkit-transition-timing-function',
  '-webkit-user-drag',
  '-webkit-user-modify',
  '-webkit-user-select',
  '-webkit-flow-into',
  '-webkit-flow-from',
  '-webkit-region-fragment',
  '-webkit-region-break-after',
  '-webkit-region-break-before',
  '-webkit-region-break-inside',
  '-webkit-tap-highlight-color',
  'buffered-rendering',
  'clip-path',
  'clip-rule',
  'mask',
  'enable-background',
  'filter',
  'flood-color',
  'flood-opacity',
  'lighting-color',
  'stop-color',
  'stop-opacity',
  'color-interpolation',
  'color-interpolation-filters',
  'color-profile',
  'color-rendering',
  'fill',
  'fill-opacity',
  'fill-rule',
  'marker',
  'marker-end',
  'marker-mid',
  'marker-start',
  'mask-type',
  'shape-rendering',
  'stroke',
  'stroke-dasharray',
  'stroke-dashoffset',
  'stroke-linecap',
  'stroke-linejoin',
  'stroke-miterlimit',
  'stroke-opacity',
  'stroke-width',
  'alignment-baseline',
  'baseline-shift',
  'dominant-baseline',
  'glyph-orientation-horizontal',
  'glyph-orientation-vertical',
  'kerning',
  'text-anchor',
  'vector-effect',
  'writing-mode',
  '-webkit-svg-shadow',
];

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
  '-webkit-order': CSSPropertyID.WebkitOrder,
  'margin-right': CSSPropertyID.MarginRight,
  'min-height': CSSPropertyID.MinHeight,
  '-webkit-border-end': CSSPropertyID.WebkitBorderEnd,
  '-webkit-marquee': CSSPropertyID.WebkitMarquee,
  'border-image-width': CSSPropertyID.BorderImageWidth,
  '-webkit-animation': CSSPropertyID.WebkitAnimation,
  '-webkit-animation-name': CSSPropertyID.WebkitAnimationName,
  '-webkit-margin-end': CSSPropertyID.WebkitMarginEnd,
  '-webkit-border-image': CSSPropertyID.WebkitBorderImage,
  '-webkit-grid-area': CSSPropertyID.WebkitGridArea,
  'border-right-width': CSSPropertyID.BorderRightWidth,
  'quotes': CSSPropertyID.Quotes,
  '-webkit-grid-row': CSSPropertyID.WebkitGridRow,
  '-webkit-grid-row-end': CSSPropertyID.WebkitGridRowEnd,
  '-webkit-animation-duration': CSSPropertyID.WebkitAnimationDuration,
  '-webkit-writing-mode': CSSPropertyID.WebkitWritingMode,
  'border-radius': CSSPropertyID.BorderRadius,
  'transition': CSSPropertyID.Transition,
  '-webkit-border-end-width': CSSPropertyID.WebkitBorderEndWidth,
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
  '-webkit-border-start': CSSPropertyID.WebkitBorderStart,
  '-webkit-user-drag': CSSPropertyID.WebkitUserDrag,
  '-epub-writing-mode': CSSPropertyID.WebkitWritingMode,
  '-webkit-border-radius': CSSPropertyID.WebkitBorderRadius,
  'stroke-width': CSSPropertyID.StrokeWidth,
  '-webkit-transition': CSSPropertyID.WebkitTransition,
  'border-top-width': CSSPropertyID.BorderTopWidth,
  'max-height': CSSPropertyID.MaxHeight,
  'content': CSSPropertyID.Content,
  '-epub-word-break': CSSPropertyID.WordBreak,
  '-webkit-margin-start': CSSPropertyID.WebkitMarginStart,
  '-webkit-mask': CSSPropertyID.WebkitMask,
  '-webkit-box-orient': CSSPropertyID.WebkitBoxOrient,
  '-webkit-grid-auto-rows': CSSPropertyID.WebkitGridAutoRows,
  '-webkit-transition-duration': CSSPropertyID.WebkitTransitionDuration,
  'padding-right': CSSPropertyID.PaddingRight,
  '-webkit-grid-row-start': CSSPropertyID.WebkitGridRowStart,
  'direction': CSSPropertyID.Direction,
  'unicode-range': CSSPropertyID.UnicodeRange,
  '-webkit-text-orientation': CSSPropertyID.WebkitTextOrientation,
  '-webkit-border-start-width': CSSPropertyID.WebkitBorderStartWidth,
  '-webkit-mask-image': CSSPropertyID.WebkitMaskImage,
  'unicode-bidi': CSSPropertyID.UnicodeBidi,
  '-webkit-padding-end': CSSPropertyID.WebkitPaddingEnd,
  'font': CSSPropertyID.Font,
  'outline': CSSPropertyID.Outline,
  '-webkit-mask-origin': CSSPropertyID.WebkitMaskOrigin,
  '-webkit-marquee-repetition': CSSPropertyID.WebkitMarqueeRepetition,
  '-webkit-border-bottom-right-radius': CSSPropertyID.BorderBottomRightRadius,
  'pointer-events': CSSPropertyID.PointerEvents,
  'position': CSSPropertyID.Position,
  'orphans': CSSPropertyID.Orphans,
  'background': CSSPropertyID.Background,
  '-webkit-region-break-inside': CSSPropertyID.WebkitRegionBreakInside,
  'font-variant': CSSPropertyID.FontVariant,
  'box-shadow': CSSPropertyID.BoxShadow,
  'zoom': CSSPropertyID.Zoom,
  'text-shadow': CSSPropertyID.TextShadow,
  'speak': CSSPropertyID.Speak,
  'background-image': CSSPropertyID.BackgroundImage,
  'shape-rendering': CSSPropertyID.ShapeRendering,
  '-webkit-marquee-increment': CSSPropertyID.WebkitMarqueeIncrement,
  'outline-width': CSSPropertyID.OutlineWidth,
  'src': CSSPropertyID.Src,
  'background-origin': CSSPropertyID.BackgroundOrigin,
  'cursor': CSSPropertyID.Cursor,
  '-epub-text-orientation': CSSPropertyID.WebkitTextOrientation,
  'font-weight': CSSPropertyID.FontWeight,
  'counter-reset': CSSPropertyID.CounterReset,
  '-webkit-nbsp-mode': CSSPropertyID.WebkitNbspMode,
  'padding-top': CSSPropertyID.PaddingTop,
  'line-height': CSSPropertyID.LineHeight,
  '-webkit-marquee-direction': CSSPropertyID.WebkitMarqueeDirection,
  'border-top-right-radius': CSSPropertyID.BorderTopRightRadius,
  '-webkit-border-before': CSSPropertyID.WebkitBorderBefore,
  '-webkit-svg-shadow': CSSPropertyID.WebkitSvgShadow,
  'page-break-inside': CSSPropertyID.PageBreakInside,
  '-webkit-marquee-speed': CSSPropertyID.WebkitMarqueeSpeed,
  '-webkit-animation-direction': CSSPropertyID.WebkitAnimationDirection,
  '-webkit-border-after': CSSPropertyID.WebkitBorderAfter,
  '-webkit-animation-iteration-count': CSSPropertyID.WebkitAnimationIterationCount,
  '-webkit-border-fit': CSSPropertyID.WebkitBorderFit,
  'border-image-source': CSSPropertyID.BorderImageSource,
  '-webkit-box-shadow': CSSPropertyID.WebkitBoxShadow,
  '-webkit-rtl-ordering': CSSPropertyID.WebkitRtlOrdering,
  '-webkit-margin-before': CSSPropertyID.WebkitMarginBefore,
  '-webkit-line-grid': CSSPropertyID.WebkitLineGrid,
  '-webkit-margin-after': CSSPropertyID.WebkitMarginAfter,
  '-webkit-padding-start': CSSPropertyID.WebkitPaddingStart,
  '-webkit-text-stroke': CSSPropertyID.WebkitTextStroke,
  '-webkit-mask-repeat': CSSPropertyID.WebkitMaskRepeat,
  'text-decoration': CSSPropertyID.TextDecoration,
  '-webkit-region-fragment': CSSPropertyID.WebkitRegionFragment,
  'text-anchor': CSSPropertyID.TextAnchor,
  '-webkit-line-break': CSSPropertyID.WebkitLineBreak,
  'dominant-baseline': CSSPropertyID.DominantBaseline,
  '-webkit-background-origin': CSSPropertyID.WebkitBackgroundOrigin,
  '-webkit-mask-box-image': CSSPropertyID.WebkitMaskBoxImage,
  '-webkit-border-before-width': CSSPropertyID.WebkitBorderBeforeWidth,
  '-webkit-border-after-width': CSSPropertyID.WebkitBorderAfterWidth,
  'size': CSSPropertyID.Size,
  '-webkit-font-kerning': CSSPropertyID.WebkitFontKerning,
  'resize': CSSPropertyID.Resize,
  'text-overline': CSSPropertyID.TextOverline,
  '-webkit-border-top-right-radius': CSSPropertyID.BorderTopRightRadius,
  'tab-size': CSSPropertyID.TabSize,
  '-webkit-region-break-before': CSSPropertyID.WebkitRegionBreakBefore,
  'text-underline': CSSPropertyID.TextUnderline,
  'text-overline-mode': CSSPropertyID.TextOverlineMode,
  '-webkit-region-break-after': CSSPropertyID.WebkitRegionBreakAfter,
  'text-underline-mode': CSSPropertyID.TextUnderlineMode,
  'text-align': CSSPropertyID.TextAlign,
  '-webkit-text-stroke-width': CSSPropertyID.WebkitTextStrokeWidth,
  'stroke-linejoin': CSSPropertyID.StrokeLinejoin,
  'background-repeat': CSSPropertyID.BackgroundRepeat,
  '-webkit-text-combine': CSSPropertyID.WebkitTextCombine,
  '-webkit-highlight': CSSPropertyID.WebkitHighlight,
  'counter-increment': CSSPropertyID.CounterIncrement,
  'z-index': CSSPropertyID.ZIndex,
  'stroke-miterlimit': CSSPropertyID.StrokeMiterlimit,
  '-webkit-transform': CSSPropertyID.WebkitTransform,
  '-webkit-mask-box-image-width': CSSPropertyID.WebkitMaskBoxImageWidth,
  '-webkit-box-direction': CSSPropertyID.WebkitBoxDirection,
  'color': CSSPropertyID.Color,
  'text-overline-width': CSSPropertyID.TextOverlineWidth,
  'clear': CSSPropertyID.Clear,
  'text-underline-width': CSSPropertyID.TextUnderlineWidth,
  'text-line-through': CSSPropertyID.TextLineThrough,
  '-webkit-align-items': CSSPropertyID.WebkitAlignItems,
  'border-color': CSSPropertyID.BorderColor,
  'page-break-before': CSSPropertyID.PageBreakBefore,
  'text-line-through-mode': CSSPropertyID.TextLineThroughMode,
  'border-bottom-color': CSSPropertyID.BorderBottomColor,
  'page-break-after': CSSPropertyID.PageBreakAfter,
  '-webkit-transform-origin': CSSPropertyID.WebkitTransformOrigin,
  'object-fit': CSSPropertyID.ObjectFit,
  '-webkit-box-align': CSSPropertyID.WebkitBoxAlign,
  '-webkit-font-smoothing': CSSPropertyID.WebkitFontSmoothing,
  'caption-side': CSSPropertyID.CaptionSide,
  '-webkit-box-decoration-break': CSSPropertyID.WebkitBoxDecorationBreak,
  'color-rendering': CSSPropertyID.ColorRendering,
  'border-spacing': CSSPropertyID.BorderSpacing,
  '-webkit-mask-position': CSSPropertyID.WebkitMaskPosition,
  '-webkit-mask-box-image-outset': CSSPropertyID.WebkitMaskBoxImageOutset,
  '-webkit-grid-template': CSSPropertyID.WebkitGridTemplate,
  'left': CSSPropertyID.Left,
  'word-spacing': CSSPropertyID.WordSpacing,
  'float': CSSPropertyID.Float,
  '-epub-text-combine': CSSPropertyID.WebkitTextCombine,
  'white-space': CSSPropertyID.WhiteSpace,
  '-webkit-padding-before': CSSPropertyID.WebkitPaddingBefore,
  '-webkit-mask-repeat-x': CSSPropertyID.WebkitMaskRepeatX,
  'text-transform': CSSPropertyID.TextTransform,
  'border-left': CSSPropertyID.BorderLeft,
  '-webkit-padding-after': CSSPropertyID.WebkitPaddingAfter,
  'text-line-through-width': CSSPropertyID.TextLineThroughWidth,
  'filter': CSSPropertyID.Filter,
  'border-right-color': CSSPropertyID.BorderRightColor,
  'background-attachment': CSSPropertyID.BackgroundAttachment,
  'overflow': CSSPropertyID.Overflow,
  '-webkit-grid-definition-rows': CSSPropertyID.WebkitGridDefinitionRows,
  'enable-background': CSSPropertyID.EnableBackground,
  'margin-left': CSSPropertyID.MarginLeft,
  '-webkit-mask-box-image-repeat': CSSPropertyID.WebkitMaskBoxImageRepeat,
  '-webkit-border-end-color': CSSPropertyID.WebkitBorderEndColor,
  'background-position': CSSPropertyID.BackgroundPosition,
  '-webkit-aspect-ratio': CSSPropertyID.WebkitAspectRatio,
  'buffered-rendering': CSSPropertyID.BufferedRendering,
  '-webkit-align-content': CSSPropertyID.WebkitAlignContent,
  '-webkit-grid-column': CSSPropertyID.WebkitGridColumn,
  '-webkit-grid-column-end': CSSPropertyID.WebkitGridColumnEnd,
  'box-sizing': CSSPropertyID.BoxSizing,
  'background-repeat-x': CSSPropertyID.BackgroundRepeatX,
  'border-left-width': CSSPropertyID.BorderLeftWidth,
  '-webkit-box-lines': CSSPropertyID.WebkitBoxLines,
  '-webkit-appearance': CSSPropertyID.WebkitAppearance,
  '-webkit-line-snap': CSSPropertyID.WebkitLineSnap,
  '-webkit-column-width': CSSPropertyID.WebkitColumnWidth,
  '-webkit-filter': CSSPropertyID.WebkitFilter,
  'font-stretch': CSSPropertyID.FontStretch,
  '-webkit-flow-into': CSSPropertyID.WebkitFlowInto,
  '-webkit-text-emphasis': CSSPropertyID.WebkitTextEmphasis,
  '-webkit-line-align': CSSPropertyID.WebkitLineAlign,
  '-webkit-background-blend-mode': CSSPropertyID.WebkitBackgroundBlendMode,
  'border-image-slice': CSSPropertyID.BorderImageSlice,
  '-webkit-box-pack': CSSPropertyID.WebkitBoxPack,
  'clip': CSSPropertyID.Clip,
  'border-top-color': CSSPropertyID.BorderTopColor,
  '-webkit-transform-origin-x': CSSPropertyID.WebkitTransformOriginX,
  '-webkit-animation-timing-function': CSSPropertyID.WebkitAnimationTimingFunction,
  '-webkit-mask-size': CSSPropertyID.WebkitMaskSize,
  '-webkit-grid-auto-flow': CSSPropertyID.WebkitGridAutoFlow,
  '-webkit-columns': CSSPropertyID.WebkitColumns,
  '-epub-caption-side': CSSPropertyID.CaptionSide,
  '-webkit-mask-position-x': CSSPropertyID.WebkitMaskPositionX,
  '-webkit-box-sizing': CSSPropertyID.BoxSizing,
  '-webkit-box-ordinal-group': CSSPropertyID.WebkitBoxOrdinalGroup,
  'alignment-baseline': CSSPropertyID.AlignmentBaseline,
  'border-bottom-left-radius': CSSPropertyID.BorderBottomLeftRadius,
  '-webkit-border-start-color': CSSPropertyID.WebkitBorderStartColor,
  'transition-timing-function': CSSPropertyID.TransitionTimingFunction,
  '-epub-text-transform': CSSPropertyID.TextTransform,
  'overflow-x': CSSPropertyID.OverflowX,
  'font-size': CSSPropertyID.FontSize,
  'text-overflow': CSSPropertyID.TextOverflow,
  '-webkit-grid-auto-columns': CSSPropertyID.WebkitGridAutoColumns,
  '-webkit-grid-column-start': CSSPropertyID.WebkitGridColumnStart,
  '-epub-text-emphasis': CSSPropertyID.WebkitTextEmphasis,
  'background-size': CSSPropertyID.BackgroundSize,
  'overflow-wrap': CSSPropertyID.OverflowWrap,
  'padding-left': CSSPropertyID.PaddingLeft,
  '-webkit-column-gap': CSSPropertyID.WebkitColumnGap,
  'background-position-x': CSSPropertyID.BackgroundPositionX,
  '-webkit-perspective': CSSPropertyID.WebkitPerspective,
  '-webkit-line-box-contain': CSSPropertyID.WebkitLineBoxContain,
  '-webkit-mask-composite': CSSPropertyID.WebkitMaskComposite,
  '-webkit-mask-box-image-source': CSSPropertyID.WebkitMaskBoxImageSource,
  'stop-color': CSSPropertyID.StopColor,
  '-webkit-column-break-inside': CSSPropertyID.WebkitColumnBreakInside,
  '-webkit-flex': CSSPropertyID.WebkitFlex,
  '-webkit-border-bottom-left-radius': CSSPropertyID.BorderBottomLeftRadius,
  'outline-color': CSSPropertyID.OutlineColor,
  '-webkit-transition-timing-function': CSSPropertyID.WebkitTransitionTimingFunction,
  '-webkit-perspective-origin': CSSPropertyID.WebkitPerspectiveOrigin,
  'background-color': CSSPropertyID.BackgroundColor,
  '-webkit-font-variant-ligatures': CSSPropertyID.WebkitFontVariantLigatures,
  'letter-spacing': CSSPropertyID.LetterSpacing,
  '-webkit-column-count': CSSPropertyID.WebkitColumnCount,
  '-webkit-user-select': CSSPropertyID.WebkitUserSelect,
  '-webkit-flex-grow': CSSPropertyID.WebkitFlexGrow,
  'vertical-align': CSSPropertyID.VerticalAlign,
  '-webkit-background-size': CSSPropertyID.WebkitBackgroundSize,
  'fill': CSSPropertyID.Fill,
  'baseline-shift': CSSPropertyID.BaselineShift,
  'stroke-linecap': CSSPropertyID.StrokeLinecap,
  '-webkit-transform-origin-z': CSSPropertyID.WebkitTransformOriginZ,
  'stroke-dasharray': CSSPropertyID.StrokeDasharray,
  'mask-type': CSSPropertyID.MaskType,
  '-webkit-locale': CSSPropertyID.WebkitLocale,
  '-webkit-column-rule': CSSPropertyID.WebkitColumnRule,
  '-webkit-column-span': CSSPropertyID.WebkitColumnSpan,
  'lighting-color': CSSPropertyID.LightingColor,
  'clip-path': CSSPropertyID.ClipPath,
  '-webkit-column-axis': CSSPropertyID.WebkitColumnAxis,
  'border-top-left-radius': CSSPropertyID.BorderTopLeftRadius,
  '-webkit-border-before-color': CSSPropertyID.WebkitBorderBeforeColor,
  '-webkit-border-after-color': CSSPropertyID.WebkitBorderAfterColor,
  '-webkit-print-color-adjust': CSSPropertyID.WebkitPrintColorAdjust,
  '-webkit-background-composite': CSSPropertyID.WebkitBackgroundComposite,
  '-webkit-ruby-position': CSSPropertyID.WebkitRubyPosition,
  '-webkit-text-stroke-color': CSSPropertyID.WebkitTextStrokeColor,
  '-webkit-animation-delay': CSSPropertyID.WebkitAnimationDelay,
  '-webkit-column-rule-width': CSSPropertyID.WebkitColumnRuleWidth,
  '-webkit-font-feature-settings': CSSPropertyID.WebkitFontFeatureSettings,
  '-webkit-mask-clip': CSSPropertyID.WebkitMaskClip,
  '-webkit-column-break-before': CSSPropertyID.WebkitColumnBreakBefore,
  'border-style': CSSPropertyID.BorderStyle,
  '-webkit-hyphens': CSSPropertyID.WebkitHyphens,
  '-webkit-column-break-after': CSSPropertyID.WebkitColumnBreakAfter,
  'border-bottom-style': CSSPropertyID.BorderBottomStyle,
  'opacity': CSSPropertyID.Opacity,
  '-webkit-flow-from': CSSPropertyID.WebkitFlowFrom,
  '-webkit-mask-repeat-y': CSSPropertyID.WebkitMaskRepeatY,
  '-webkit-box-flex': CSSPropertyID.WebkitBoxFlex,
  '-webkit-clip-path': CSSPropertyID.WebkitClipPath,
  '-webkit-logical-width': CSSPropertyID.WebkitLogicalWidth,
  '-webkit-border-top-left-radius': CSSPropertyID.BorderTopLeftRadius,
  'clip-rule': CSSPropertyID.ClipRule,
  'text-overline-color': CSSPropertyID.TextOverlineColor,
  'transition-delay': CSSPropertyID.TransitionDelay,
  'text-underline-color': CSSPropertyID.TextUnderlineColor,
  '-webkit-animation-fill-mode': CSSPropertyID.WebkitAnimationFillMode,
  '-webkit-min-logical-width': CSSPropertyID.WebkitMinLogicalWidth,
  '-webkit-perspective-origin-x': CSSPropertyID.WebkitPerspectiveOriginX,
  '-webkit-logical-height': CSSPropertyID.WebkitLogicalHeight,
  '-webkit-flex-wrap': CSSPropertyID.WebkitFlexWrap,
  'visibility': CSSPropertyID.Visibility,
  '-webkit-text-emphasis-position': CSSPropertyID.WebkitTextEmphasisPosition,
  'outline-offset': CSSPropertyID.OutlineOffset,
  'color-interpolation': CSSPropertyID.ColorInterpolation,
  '-webkit-min-logical-height': CSSPropertyID.WebkitMinLogicalHeight,
  'background-clip': CSSPropertyID.BackgroundClip,
  'border-right-style': CSSPropertyID.BorderRightStyle,
  '-webkit-flex-shrink': CSSPropertyID.WebkitFlexShrink,
  'background-repeat-y': CSSPropertyID.BackgroundRepeatY,
  'stroke-dashoffset': CSSPropertyID.StrokeDashoffset,
  'transition-property': CSSPropertyID.TransitionProperty,
  '-epub-hyphens': CSSPropertyID.WebkitHyphens,
  '-webkit-column-progression': CSSPropertyID.WebkitColumnProgression,
  '-webkit-border-end-style': CSSPropertyID.WebkitBorderEndStyle,
  '-webkit-opacity': CSSPropertyID.Opacity,
  '-webkit-marquee-style': CSSPropertyID.WebkitMarqueeStyle,
  'text-line-through-color': CSSPropertyID.TextLineThroughColor,
  '-webkit-user-modify': CSSPropertyID.WebkitUserModify,
  '-webkit-box-reflect': CSSPropertyID.WebkitBoxReflect,
  '-webkit-line-clamp': CSSPropertyID.WebkitLineClamp,
  '-webkit-flex-basis': CSSPropertyID.WebkitFlexBasis,
  '-webkit-transition-delay': CSSPropertyID.WebkitTransitionDelay,
  'vector-effect': CSSPropertyID.VectorEffect,
  '-webkit-align-self': CSSPropertyID.WebkitAlignSelf,
  '-webkit-flex-direction': CSSPropertyID.WebkitFlexDirection,
  '-webkit-transform-origin-y': CSSPropertyID.WebkitTransformOriginY,
  '-webkit-background-clip': CSSPropertyID.WebkitBackgroundClip,
  '-webkit-mask-box-image-slice': CSSPropertyID.WebkitMaskBoxImageSlice,
  'border-collapse': CSSPropertyID.BorderCollapse,
  '-webkit-grid-definition-columns': CSSPropertyID.WebkitGridDefinitionColumns,
  'flood-color': CSSPropertyID.FloodColor,
  '-webkit-color-correction': CSSPropertyID.WebkitColorCorrection,
  '-webkit-mask-position-y': CSSPropertyID.WebkitMaskPositionY,
  'border-left-color': CSSPropertyID.BorderLeftColor,
  'table-layout': CSSPropertyID.TableLayout,
  '-webkit-transition-property': CSSPropertyID.WebkitTransitionProperty,
  'border-top-style': CSSPropertyID.BorderTopStyle,
  'display': CSSPropertyID.Display,
  '-webkit-font-size-delta': CSSPropertyID.WebkitFontSizeDelta,
  'overflow-y': CSSPropertyID.OverflowY,
  '-webkit-max-logical-width': CSSPropertyID.WebkitMaxLogicalWidth,
  'stroke-opacity': CSSPropertyID.StrokeOpacity,
  'fill-rule': CSSPropertyID.FillRule,
  '-webkit-box-flex-group': CSSPropertyID.WebkitBoxFlexGroup,
  '-webkit-max-logical-height': CSSPropertyID.WebkitMaxLogicalHeight,
  '-webkit-text-security': CSSPropertyID.WebkitTextSecurity,
  '-webkit-border-start-style': CSSPropertyID.WebkitBorderStartStyle,
  'background-position-y': CSSPropertyID.BackgroundPositionY,
  '-webkit-border-vertical-spacing': CSSPropertyID.WebkitBorderVerticalSpacing,
  '-webkit-tap-highlight-color': CSSPropertyID.WebkitTapHighlightColor,
  '-webkit-margin-collapse': CSSPropertyID.WebkitMarginCollapse,
  '-webkit-margin-bottom-collapse': CSSPropertyID.WebkitMarginBottomCollapse,
  '-webkit-text-emphasis-color': CSSPropertyID.WebkitTextEmphasisColor,
  '-webkit-animation-play-state': CSSPropertyID.WebkitAnimationPlayState,
  'font-style': CSSPropertyID.FontStyle,
  'outline-style': CSSPropertyID.OutlineStyle,
  'stop-opacity': CSSPropertyID.StopOpacity,
  'color-profile': CSSPropertyID.ColorProfile,
  '-epub-text-emphasis-color': CSSPropertyID.WebkitTextEmphasisColor,
  '-webkit-justify-content': CSSPropertyID.WebkitJustifyContent,
  '-webkit-border-horizontal-spacing': CSSPropertyID.WebkitBorderHorizontalSpacing,
  '-webkit-mask-source-type': CSSPropertyID.WebkitMaskSourceType,
  '-webkit-border-before-style': CSSPropertyID.WebkitBorderBeforeStyle,
  '-webkit-border-after-style': CSSPropertyID.WebkitBorderAfterStyle,
  '-webkit-hyphenate-character': CSSPropertyID.WebkitHyphenateCharacter,
  'list-style': CSSPropertyID.ListStyle,
  '-webkit-margin-top-collapse': CSSPropertyID.WebkitMarginTopCollapse,
  '-webkit-perspective-origin-y': CSSPropertyID.WebkitPerspectiveOriginY,
  'list-style-image': CSSPropertyID.ListStyleImage,
  '-webkit-flex-flow': CSSPropertyID.WebkitFlexFlow,
  'text-overline-style': CSSPropertyID.TextOverlineStyle,
  '-webkit-column-rule-color': CSSPropertyID.WebkitColumnRuleColor,
  'text-underline-style': CSSPropertyID.TextUnderlineStyle,
  'font-family': CSSPropertyID.FontFamily,
  '-webkit-hyphenate-limit-before': CSSPropertyID.WebkitHyphenateLimitBefore,
  '-webkit-transform-style': CSSPropertyID.WebkitTransformStyle,
  '-webkit-hyphenate-limit-after': CSSPropertyID.WebkitHyphenateLimitAfter,
  '-webkit-text-decorations-in-effect': CSSPropertyID.WebkitTextDecorationsInEffect,
  'text-line-through-style': CSSPropertyID.TextLineThroughStyle,
  '-webkit-margin-before-collapse': CSSPropertyID.WebkitMarginBeforeCollapse,
  '-webkit-margin-after-collapse': CSSPropertyID.WebkitMarginAfterCollapse,
  'border-left-style': CSSPropertyID.BorderLeftStyle,
  'flood-opacity': CSSPropertyID.FloodOpacity,
  '-webkit-hyphenate-limit-lines': CSSPropertyID.WebkitHyphenateLimitLines,
  'glyph-orientation-vertical': CSSPropertyID.GlyphOrientationVertical,
  'empty-cells': CSSPropertyID.EmptyCells,
  '-webkit-text-emphasis-style': CSSPropertyID.WebkitTextEmphasisStyle,
  '-webkit-text-fill-color': CSSPropertyID.WebkitTextFillColor,
  'list-style-position': CSSPropertyID.ListStylePosition,
  '-epub-text-emphasis-style': CSSPropertyID.WebkitTextEmphasisStyle,
  'color-interpolation-filters': CSSPropertyID.ColorInterpolationFilters,
  'glyph-orientation-horizontal': CSSPropertyID.GlyphOrientationHorizontal,
  'fill-opacity': CSSPropertyID.FillOpacity,
  '-webkit-column-rule-style': CSSPropertyID.WebkitColumnRuleStyle,
  '-webkit-backface-visibility': CSSPropertyID.WebkitBackfaceVisibility,
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
  true, // CSSPropertyWebkitFontFeatureSettings
  true, // CSSPropertyWebkitFontKerning
  true, // CSSPropertyWebkitFontSmoothing
  true, // CSSPropertyWebkitFontVariantLigatures
  true, // CSSPropertyWebkitLocale
  true, // CSSPropertyWebkitTextOrientation
  true, // CSSPropertyWebkitWritingMode
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
  false, // CSSPropertyWebkitClipPath
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
  false, // CSSPropertyWebkitAnimation
  false, // CSSPropertyWebkitAnimationDelay
  false, // CSSPropertyWebkitAnimationDirection
  false, // CSSPropertyWebkitAnimationDuration
  false, // CSSPropertyWebkitAnimationFillMode
  false, // CSSPropertyWebkitAnimationIterationCount
  false, // CSSPropertyWebkitAnimationName
  false, // CSSPropertyWebkitAnimationPlayState
  false, // CSSPropertyWebkitAnimationTimingFunction
  false, // CSSPropertyWebkitAppearance
  true, // CSSPropertyWebkitAspectRatio
  false, // CSSPropertyWebkitBackfaceVisibility
  false, // CSSPropertyWebkitBackgroundBlendMode
  false, // CSSPropertyWebkitBackgroundClip
  false, // CSSPropertyWebkitBackgroundComposite
  false, // CSSPropertyWebkitBackgroundOrigin
  false, // CSSPropertyWebkitBackgroundSize
  false, // CSSPropertyWebkitBorderAfter
  false, // CSSPropertyWebkitBorderAfterColor
  false, // CSSPropertyWebkitBorderAfterStyle
  false, // CSSPropertyWebkitBorderAfterWidth
  false, // CSSPropertyWebkitBorderBefore
  false, // CSSPropertyWebkitBorderBeforeColor
  false, // CSSPropertyWebkitBorderBeforeStyle
  false, // CSSPropertyWebkitBorderBeforeWidth
  false, // CSSPropertyWebkitBorderEnd
  false, // CSSPropertyWebkitBorderEndColor
  false, // CSSPropertyWebkitBorderEndStyle
  false, // CSSPropertyWebkitBorderEndWidth
  false, // CSSPropertyWebkitBorderFit
  true, // CSSPropertyWebkitBorderHorizontalSpacing
  false, // CSSPropertyWebkitBorderImage
  false, // CSSPropertyWebkitBorderRadius
  false, // CSSPropertyWebkitBorderStart
  false, // CSSPropertyWebkitBorderStartColor
  false, // CSSPropertyWebkitBorderStartStyle
  false, // CSSPropertyWebkitBorderStartWidth
  true, // CSSPropertyWebkitBorderVerticalSpacing
  false, // CSSPropertyWebkitBoxAlign
  true, // CSSPropertyWebkitBoxDirection
  false, // CSSPropertyWebkitBoxFlex
  false, // CSSPropertyWebkitBoxFlexGroup
  false, // CSSPropertyWebkitBoxLines
  false, // CSSPropertyWebkitBoxOrdinalGroup
  false, // CSSPropertyWebkitBoxOrient
  false, // CSSPropertyWebkitBoxPack
  false, // CSSPropertyWebkitBoxReflect
  false, // CSSPropertyWebkitBoxShadow
  true, // CSSPropertyWebkitColorCorrection
  false, // CSSPropertyWebkitColumnAxis
  false, // CSSPropertyWebkitColumnBreakAfter
  false, // CSSPropertyWebkitColumnBreakBefore
  false, // CSSPropertyWebkitColumnBreakInside
  false, // CSSPropertyWebkitColumnCount
  false, // CSSPropertyWebkitColumnGap
  false, // CSSPropertyWebkitColumnProgression
  false, // CSSPropertyWebkitColumnRule
  false, // CSSPropertyWebkitColumnRuleColor
  false, // CSSPropertyWebkitColumnRuleStyle
  false, // CSSPropertyWebkitColumnRuleWidth
  false, // CSSPropertyWebkitColumnSpan
  false, // CSSPropertyWebkitColumnWidth
  false, // CSSPropertyWebkitColumns
  false, // CSSPropertyWebkitBoxDecorationBreak
  false, // CSSPropertyWebkitFilter
  false, // CSSPropertyWebkitAlignContent
  false, // CSSPropertyWebkitAlignItems
  false, // CSSPropertyWebkitAlignSelf
  false, // CSSPropertyWebkitFlex
  false, // CSSPropertyWebkitFlexBasis
  false, // CSSPropertyWebkitFlexDirection
  false, // CSSPropertyWebkitFlexFlow
  false, // CSSPropertyWebkitFlexGrow
  false, // CSSPropertyWebkitFlexShrink
  false, // CSSPropertyWebkitFlexWrap
  false, // CSSPropertyWebkitJustifyContent
  false, // CSSPropertyWebkitFontSizeDelta
  false, // CSSPropertyWebkitGridArea
  false, // CSSPropertyWebkitGridAutoColumns
  false, // CSSPropertyWebkitGridAutoRows
  false, // CSSPropertyWebkitGridColumnEnd
  false, // CSSPropertyWebkitGridColumnStart
  false, // CSSPropertyWebkitGridDefinitionColumns
  false, // CSSPropertyWebkitGridDefinitionRows
  false, // CSSPropertyWebkitGridRowEnd
  false, // CSSPropertyWebkitGridRowStart
  false, // CSSPropertyWebkitGridColumn
  false, // CSSPropertyWebkitGridRow
  false, // CSSPropertyWebkitGridTemplate
  false, // CSSPropertyWebkitGridAutoFlow
  true, // CSSPropertyWebkitHighlight
  true, // CSSPropertyWebkitHyphenateCharacter
  true, // CSSPropertyWebkitHyphenateLimitAfter
  true, // CSSPropertyWebkitHyphenateLimitBefore
  true, // CSSPropertyWebkitHyphenateLimitLines
  true, // CSSPropertyWebkitHyphens
  true, // CSSPropertyWebkitLineBoxContain
  true, // CSSPropertyWebkitLineAlign
  true, // CSSPropertyWebkitLineBreak
  false, // CSSPropertyWebkitLineClamp
  true, // CSSPropertyWebkitLineGrid
  true, // CSSPropertyWebkitLineSnap
  false, // CSSPropertyWebkitLogicalWidth
  false, // CSSPropertyWebkitLogicalHeight
  false, // CSSPropertyWebkitMarginAfterCollapse
  false, // CSSPropertyWebkitMarginBeforeCollapse
  false, // CSSPropertyWebkitMarginBottomCollapse
  false, // CSSPropertyWebkitMarginTopCollapse
  false, // CSSPropertyWebkitMarginCollapse
  false, // CSSPropertyWebkitMarginAfter
  false, // CSSPropertyWebkitMarginBefore
  false, // CSSPropertyWebkitMarginEnd
  false, // CSSPropertyWebkitMarginStart
  false, // CSSPropertyWebkitMarquee
  false, // CSSPropertyWebkitMarqueeDirection
  false, // CSSPropertyWebkitMarqueeIncrement
  false, // CSSPropertyWebkitMarqueeRepetition
  false, // CSSPropertyWebkitMarqueeSpeed
  false, // CSSPropertyWebkitMarqueeStyle
  false, // CSSPropertyWebkitMask
  false, // CSSPropertyWebkitMaskBoxImage
  false, // CSSPropertyWebkitMaskBoxImageOutset
  false, // CSSPropertyWebkitMaskBoxImageRepeat
  false, // CSSPropertyWebkitMaskBoxImageSlice
  false, // CSSPropertyWebkitMaskBoxImageSource
  false, // CSSPropertyWebkitMaskBoxImageWidth
  false, // CSSPropertyWebkitMaskClip
  false, // CSSPropertyWebkitMaskComposite
  false, // CSSPropertyWebkitMaskImage
  false, // CSSPropertyWebkitMaskOrigin
  false, // CSSPropertyWebkitMaskPosition
  false, // CSSPropertyWebkitMaskPositionX
  false, // CSSPropertyWebkitMaskPositionY
  false, // CSSPropertyWebkitMaskRepeat
  false, // CSSPropertyWebkitMaskRepeatX
  false, // CSSPropertyWebkitMaskRepeatY
  false, // CSSPropertyWebkitMaskSize
  false, // CSSPropertyWebkitMaskSourceType
  false, // CSSPropertyWebkitMaxLogicalWidth
  false, // CSSPropertyWebkitMaxLogicalHeight
  false, // CSSPropertyWebkitMinLogicalWidth
  false, // CSSPropertyWebkitMinLogicalHeight
  true, // CSSPropertyWebkitNbspMode
  false, // CSSPropertyWebkitOrder
  false, // CSSPropertyWebkitPaddingAfter
  false, // CSSPropertyWebkitPaddingBefore
  false, // CSSPropertyWebkitPaddingEnd
  false, // CSSPropertyWebkitPaddingStart
  false, // CSSPropertyWebkitPerspective
  false, // CSSPropertyWebkitPerspectiveOrigin
  false, // CSSPropertyWebkitPerspectiveOriginX
  false, // CSSPropertyWebkitPerspectiveOriginY
  true, // CSSPropertyWebkitPrintColorAdjust
  true, // CSSPropertyWebkitRtlOrdering
  true, // CSSPropertyWebkitRubyPosition
  true, // CSSPropertyWebkitTextCombine
  true, // CSSPropertyWebkitTextDecorationsInEffect
  true, // CSSPropertyWebkitTextEmphasis
  true, // CSSPropertyWebkitTextEmphasisColor
  true, // CSSPropertyWebkitTextEmphasisPosition
  true, // CSSPropertyWebkitTextEmphasisStyle
  true, // CSSPropertyWebkitTextFillColor
  true, // CSSPropertyWebkitTextSecurity
  true, // CSSPropertyWebkitTextStroke
  true, // CSSPropertyWebkitTextStrokeColor
  true, // CSSPropertyWebkitTextStrokeWidth
  false, // CSSPropertyWebkitTransform
  false, // CSSPropertyWebkitTransformOrigin
  false, // CSSPropertyWebkitTransformOriginX
  false, // CSSPropertyWebkitTransformOriginY
  false, // CSSPropertyWebkitTransformOriginZ
  false, // CSSPropertyWebkitTransformStyle
  false, // CSSPropertyWebkitTransition
  false, // CSSPropertyWebkitTransitionDelay
  false, // CSSPropertyWebkitTransitionDuration
  false, // CSSPropertyWebkitTransitionProperty
  false, // CSSPropertyWebkitTransitionTimingFunction
  false, // CSSPropertyWebkitUserDrag
  true, // CSSPropertyWebkitUserModify
  true, // CSSPropertyWebkitUserSelect
  false, // CSSPropertyWebkitFlowInto
  false, // CSSPropertyWebkitFlowFrom
  false, // CSSPropertyWebkitRegionFragment
  false, // CSSPropertyWebkitRegionBreakAfter
  false, // CSSPropertyWebkitRegionBreakBefore
  false, // CSSPropertyWebkitRegionBreakInside
  true, // CSSPropertyWebkitTapHighlightColor
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
  false, // CSSPropertyWebkitSvgShadow
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
