/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(CSSStyleDeclaration, setStyleData) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "document.documentElement.style.backgroundColor = 'white';"
      "document.documentElement.style.backgroundColor = 'white';";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(CSSStyleDeclaration, enumerateStyles) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "['zoom', 'writingMode', 'wordSpacing', 'wordBreak', 'willChange', 'width', 'widows', 'visibility', 'vectorEffect', 'userZoom', 'userSelect', 'unicodeRange', 'unicodeBidi', 'transitionProperty', 'transition', 'touchAction', 'textRendering', 'range', 'textOverflow', 'breakAfter', 'order', 'textIndent', 'textUnderlineOffset', 'textEmphasisColor', 'textDecorationThickness', 'textDecorationSkipInk', 'markerEnd', 'textDecorationLine', 'textAnchor', 'tableLayout', 'listStyleType', 'tabSize', 'system', 'scrollMarginBlock', 'syntax', 'textEmphasisStyle', 'offsetDistance', 'isolation', 'symbols', 'scrollPaddingLeft', 'strokeWidth', 'strokeOpacity', 'strokeLinejoin', 'stopOpacity', 'fillOpacity', 'strokeMiterlimit', 'fontSynthesisWeight', 'sizeAdjust', 'direction', 'pageOrientation', 'size', 'ascentOverride', 'shapeOutside', 'shapeImageThreshold', 'scrollSnapType', 'borderTopStyle', 'scrollSnapAlign', 'borderBottomRightRadius', 'textTransform', 'textAlign', 'columnFill', 'scrollSnapStop', 'wordWrap', 'scrollPaddingTop', 'scrollPaddingRight', 'scrollPaddingInlineStart', 'gridArea', 'textEmphasisPosition', 'animationDuration', 'scrollPaddingBottom', 'scrollPaddingBlockEnd', 'stroke', 'scrollMarginLeft', 'scrollPadding', 'float', 'scrollMargin', 'backgroundClip', 'shapeRendering', 'borderStartEndRadius', 'rx', 'transitionDelay', 'flexShrink', 'rowGap', 'colorScheme', 'prefix', 'position', 'pageBreakAfter', 'pointerEvents', 'placeSelf', 'placeItems', 'scrollBehavior', 'scrollMarginBottom', 'perspective', 'borderInlineStartStyle', 'strokeDasharray', 'borderBottomStyle', 'gridTemplateAreas', 'pageBreakBefore', 'transitionTimingFunction', 'scrollPaddingInlineEnd', 'paddingLeft', 'paddingInlineStart', 'paddingInlineEnd', 'paddingInline', 'aspectRatio', 'paddingBlockStart', 'top', 'scrollPaddingBlock', 'paddingBlock', 'padding', 'overscrollBehaviorX', 'overscrollBehaviorInline', 'overscrollBehaviorBlock', 'overscrollBehavior', 'overflowWrap', 'listStylePosition', 'right', 'overflow', 'quotes', 'objectPosition', 'outlineWidth', 'outlineOffset', 'outline', 'orphans', 'borderBlockEndWidth', 'orientation', 'opacity', 'overflowY', 'maxZoom', 'objectFit', 'minWidth', 'textUnderlinePosition', 'minInlineSize', 'minHeight', 'y', 'paintOrder', 'columnGap', 'transformOrigin', 'borderLeft', 'minBlockSize', 'maxWidth', 'maxInlineSize', 'alignmentBaseline', 'color', 'maxHeight', 'maskType', 'markerMid', 'marker', 'marginInline', 'marginBottom', 'marginBlockStart', 'left', 'marginBlockEnd', 'textDecorationColor', 'marginBlock', 'textSizeAdjust', 'marginRight', 'margin', 'perspectiveOrigin', 'offsetPath', 'listStyle', 'lineGapOverride', 'overflowClipMargin', 'letterSpacing', 'justifySelf', 'markerStart', 'insetInlineStart', 'placeContent', 'insetInline', 'backgroundRepeatY', 'fontWeight', 'r', 'x', 'insetBlockEnd', 'borderSpacing', 'insetBlock', 'height', 'inset', 'offset', 'inlineSize', 'suffix', 'borderBlockColor', 'clip', 'initialValue', 'inherits', 'paddingBlockEnd', 'backgroundImage', 'imageRendering', 'mask', 'textEmphasis', 'hyphens', 'outlineStyle', 'textCombineUpright', 'borderRight', 'marginLeft', 'gridTemplateRows', 'marginInlineEnd', 'transformBox', 'resize', 'gridRowEnd', 'borderBlockEndColor', 'shapeMargin', 'gridColumnEnd', 'gridColumn', 'borderImageOutset', 'flexDirection', 'fallback', 'lightingColor', 'gridAutoFlow', 'borderRightWidth', 'gap', 'scrollMarginInline', 'fontVariantCaps', 'fontVariantEastAsian', 'textDecoration', 'insetBlockStart', 'fontSynthesisSmallCaps', 'fontStyle', 'appearance', 'overscrollBehaviorY', 'borderInlineWidth', 'filter', 'verticalAlign', 'backgroundAttachment', 'fontSize', 'gridColumnGap', 'flex', 'fontOpticalSizing', 'gridRowGap', 'fontFamily', 'font', 'colorInterpolationFilters', 'flexFlow', 'backgroundRepeatX', 'columnRuleColor', 'fillRule', 'emptyCells', 'display', 'textShadow', 'animationFillMode', 'floodColor', 'descentOverride', 'gridAutoRows', 'fontVariationSettings', 'stopColor', 'fontFeatureSettings', 'cursor', 'paddingRight', 'accentColor', 'borderColor', 'backdropFilter', 'counterReset', 'content', 'columns', 'cx', 'mixBlendMode', 'fontKerning', 'columnWidth', 'overflowAnchor', 'alignContent', 'columnSpan', 'zIndex', 'columnRule', 'backgroundRepeat', 'fontVariantNumeric', 'borderBlockStartStyle', 'columnCount', 'textAlignLast', 'fontVariant', 'colorRendering', 'lineHeight', 'borderBlockEndStyle', 'borderInlineEndColor', 'colorInterpolation', 'src', 'lineBreak', 'clipRule', 'clipPath', 'clear', 'floodOpacity', 'alignSelf', 'gridAutoColumns', 'caretColor', 'justifyItems', 'captionSide', 'backgroundBlendMode', 'bufferedRendering', 'listStyleImage', 'forcedColorAdjust', 'animationName', 'counterSet', 'breakInside', 'boxSizing', 'columnRuleStyle', 'justifyContent', 'textOrientation', 'breakBefore', 'outlineColor', 'borderTopWidth', 'all', 'gridColumnStart', 'minZoom', 'borderTopLeftRadius', 'marginTop', 'borderBlockStyle', 'backgroundOrigin', 'borderTop', 'cy', 'speakAs', 'negative', 'borderStartStartRadius', 'backgroundPositionY', 'borderLeftStyle', 'boxShadow', 'blockSize', 'borderInlineStartWidth', 'borderInlineEnd', 'borderInline', 'gridRowStart', 'fill', 'borderImageWidth', 'additiveSymbols', 'scrollMarginBlockEnd', 'borderImageSlice', 'borderImage', 'borderBottomLeftRadius', 'borderBottomWidth', 'borderImageRepeat', 'textDecorationStyle', 'borderRightStyle', 'page', 'imageOrientation', 'borderEndEndRadius', 'gridGap', 'scrollMarginInlineEnd', 'gridTemplateColumns', 'flexWrap', 'borderInlineColor', 'borderBottomColor', 'scrollMarginInlineStart', 'fontDisplay', 'dominantBaseline', 'borderRadius', 'borderBottom', 'borderBlockWidth', 'baselineShift', 'gridTemplate', 'borderBlockStartWidth', 'whiteSpace', 'fontSynthesis', 'fontSynthesisStyle', 'borderBlockStart', 'borderTopRightRadius', 'transformStyle', 'animation', 'marginInlineStart', 'borderInlineStyle', 'fontVariantLigatures', 'borderInlineStartColor', 'borderInlineStart', 'backgroundSize', 'scrollMarginBlockStart', 'borderEndStartRadius', 'backgroundPosition', 'scrollPaddingBlockStart', 'insetInlineEnd', 'borderLeftColor', 'border', 'flexBasis', 'borderInlineEndStyle', 'borderWidth', 'counterIncrement', 'ry', 'contentVisibility', 'background', 'borderCollapse', 'borderBlock', 'offsetRotate', 'animationTimingFunction', 'pad', 'maxBlockSize', 'fontStretch', 'animationDelay', 'speak', 'paddingBottom', 'borderLeftWidth', 'borderImageSource', 'gridRow', 'columnRuleWidth', 'backfaceVisibility', 'flexGrow', 'strokeDashoffset', 'grid', 'scrollbarGutter', 'scrollPaddingInline', 'borderStyle', 'animationIterationCount', 'animationPlayState', 'rubyPosition', 'animationDirection', 'paddingTop', 'pageBreakInside', 'd', 'transform', 'scrollMarginRight', 'bottom', 'overflowX', 'borderTopColor', 'appRegion', 'backgroundColor', 'transitionDuration', 'alignItems', 'borderBlockStartColor', 'borderBlockEnd', 'strokeLinecap', 'borderRightColor', 'scrollMarginTop', 'borderInlineEndWidth', 'backgroundPositionX']");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "console.log(Object.keys(document.body.style))";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
