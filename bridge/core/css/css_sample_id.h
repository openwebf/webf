//
// Created by 谢作兵 on 17/06/24.
//

#ifndef WEBF_CSS_SAMPLE_ID_H
#define WEBF_CSS_SAMPLE_ID_H

namespace webf {

enum CSSSampleId {
  kInvalid = 0,

  // These internal properties exist but are mapped to 0 to ensure they don't get
  // reported in use counter.
  kInternalAlignContentBlock = 0,
  kInternalAlignSelfBlock = 0,
  kInternalEmptyLineHeight = 0,
  kInternalVisitedBackgroundColor = 0,
  kInternalVisitedBorderBlockEndColor = 0,
  kInternalVisitedBorderBlockStartColor = 0,
  kInternalVisitedBorderBottomColor = 0,
  kInternalVisitedBorderInlineEndColor = 0,
  kInternalVisitedBorderInlineStartColor = 0,
  kInternalVisitedBorderLeftColor = 0,
  kInternalVisitedBorderRightColor = 0,
  kInternalVisitedBorderTopColor = 0,
  kInternalVisitedCaretColor = 0,
  kInternalVisitedColor = 0,
  kInternalVisitedColumnRuleColor = 0,
  kInternalVisitedFill = 0,
  kInternalVisitedOutlineColor = 0,
  kInternalVisitedStroke = 0,
  kInternalVisitedTextDecorationColor = 0,
  kInternalVisitedTextEmphasisColor = 0,
  kInternalVisitedTextFillColor = 0,
  kInternalVisitedTextStrokeColor = 0,
  kInternalFontSizeDelta = 0,
  kInternalForcedBackgroundColor = 0,
  kInternalForcedBorderColor = 0,
  kInternalForcedColor = 0,
  kInternalForcedOutlineColor = 0,
  kInternalForcedVisitedColor = 0,
  kInternalOverflowBlock = 0,
  kInternalOverflowInline = 0,

  // This CSSSampleId represents page load for CSS histograms. It is recorded once
  // per page visit for each CSS histogram being logged on the blink side and the
  // browser side.
  kTotalPagesMeasured = 1,

  // These enum names should map exactly to CSSPropertyID keys. The mapping between the two is
  // done by auto-generated function  `GetCSSSampleId(CSSPropertyID)`.

  kColor = 2,
  kDirection = 3,
  kDisplay = 4,
  kFont = 5,
  kFontFamily = 6,
  kFontSize = 7,
  kFontStyle = 8,
  kFontVariant = 9,
  kFontWeight = 10,
  kTextRendering = 11,
  kAliasWebkitFontFeatureSettings = 12,
  kFontKerning = 13,
  kWebkitFontSmoothing = 14,
  kFontVariantLigatures = 15,
  kWebkitLocale = 16,
  kWebkitTextOrientation = 17,
  kWebkitWritingMode = 18,
  kZoom = 19,
  kLineHeight = 20,
  kBackground = 21,
  kBackgroundAttachment = 22,
  kBackgroundClip = 23,
  kBackgroundColor = 24,
  kBackgroundImage = 25,
  kBackgroundOrigin = 26,
  kBackgroundPosition = 27,
  kBackgroundPositionX = 28,
  kBackgroundPositionY = 29,
  kBackgroundRepeat = 30,
  // kBackgroundRepeatX = 31,
  // kBackgroundRepeatY = 32,
  kBackgroundSize = 33,
  kBorder = 34,
  kBorderBottom = 35,
  kBorderBottomColor = 36,
  kBorderBottomLeftRadius = 37,
  kBorderBottomRightRadius = 38,
  kBorderBottomStyle = 39,
  kBorderBottomWidth = 40,
  kBorderCollapse = 41,
  kBorderColor = 42,
  kBorderImage = 43,
  kBorderImageOutset = 44,
  kBorderImageRepeat = 45,
  kBorderImageSlice = 46,
  kBorderImageSource = 47,
  kBorderImageWidth = 48,
  kBorderLeft = 49,
  kBorderLeftColor = 50,
  kBorderLeftStyle = 51,
  kBorderLeftWidth = 52,
  kBorderRadius = 53,
  kBorderRight = 54,
  kBorderRightColor = 55,
  kBorderRightStyle = 56,
  kBorderRightWidth = 57,
  kBorderSpacing = 58,
  kBorderStyle = 59,
  kBorderTop = 60,
  kBorderTopColor = 61,
  kBorderTopLeftRadius = 62,
  kBorderTopRightRadius = 63,
  kBorderTopStyle = 64,
  kBorderTopWidth = 65,
  kBorderWidth = 66,
  kBottom = 67,
  kBoxShadow = 68,
  kBoxSizing = 69,
  kCaptionSide = 70,
  kClear = 71,
  kClip = 72,
  kAliasWebkitClipPath = 73,
  kContent = 74,
  kCounterIncrement = 75,
  kCounterReset = 76,
  kCursor = 77,
  kEmptyCells = 78,
  kFloat = 79,
  kFontStretch = 80,
  kHeight = 81,
  kImageRendering = 82,
  kLeft = 83,
  kLetterSpacing = 84,
  kListStyle = 85,
  kListStyleImage = 86,
  kListStylePosition = 87,
  kListStyleType = 88,
  kMargin = 89,
  kMarginBottom = 90,
  kMarginLeft = 91,
  kMarginRight = 92,
  kMarginTop = 93,
  kMaxHeight = 94,
  kMaxWidth = 95,
  kMinHeight = 96,
  kMinWidth = 97,
  kOpacity = 98,
  kOrphans = 99,
  kOutline = 100,
  kOutlineColor = 101,
  kOutlineOffset = 102,
  kOutlineStyle = 103,
  kOutlineWidth = 104,
  kOverflow = 105,
  kOverflowWrap = 106,
  kOverflowX = 107,
  kOverflowY = 108,
  kPadding = 109,
  kPaddingBottom = 110,
  kPaddingLeft = 111,
  kPaddingRight = 112,
  kPaddingTop = 113,
  kPage = 114,
  kPageBreakAfter = 115,
  kPageBreakBefore = 116,
  kPageBreakInside = 117,
  kPointerEvents = 118,
  kPosition = 119,
  kQuotes = 120,
  kResize = 121,
  kRight = 122,
  kSize = 123,
  kSrc = 124,
  kSpeak = 125,
  kTableLayout = 126,
  kTabSize = 127,
  kTextAlign = 128,
  kTextDecoration = 129,
  kTextIndent = 130,
  // kTextLineThrough = 131,
  // kTextLineThroughColor = 132,
  // kTextLineThroughMode = 133,
  // kTextLineThroughStyle = 134,
  // kTextLineThroughWidth = 135,
  kTextOverflow = 136,
  // kTextOverline = 137,
  // kTextOverlineColor = 138,
  // kTextOverlineMode = 139,
  // kTextOverlineStyle = 140,
  // kTextOverlineWidth = 141,
  kTextShadow = 142,
  kTextTransform = 143,
  // kTextUnderline = 144,
  // kTextUnderlineColor = 145,
  // kTextUnderlineMode = 146,
  // kTextUnderlineStyle = 147,
  // kTextUnderlineWidth = 148,
  kTop = 149,
  kTransition = 150,
  kTransitionDelay = 151,
  kTransitionDuration = 152,
  kTransitionProperty = 153,
  kTransitionTimingFunction = 154,
  kUnicodeBidi = 155,
  kUnicodeRange = 156,
  kVerticalAlign = 157,
  kVisibility = 158,
  kWhiteSpace = 159,
  kWidows = 160,
  kWidth = 161,
  kWordBreak = 162,
  kWordSpacing = 163,
  kAliasWordWrap = 164,
  kZIndex = 165,
  kAliasWebkitAnimation = 166,
  kAliasWebkitAnimationDelay = 167,
  kAliasWebkitAnimationDirection = 168,
  kAliasWebkitAnimationDuration = 169,
  kAliasWebkitAnimationFillMode = 170,
  kAliasWebkitAnimationIterationCount = 171,
  kAliasWebkitAnimationName = 172,
  kAliasWebkitAnimationPlayState = 173,
  kAliasWebkitAnimationTimingFunction = 174,
  kAliasWebkitAppearance = 175,
  // kWebkitAspectRatio = 176,
  kAliasWebkitBackfaceVisibility = 177,
  kAliasWebkitBackgroundClip = 178,
  // kWebkitBackgroundComposite = 179,
  kAliasWebkitBackgroundOrigin = 180,
  kAliasWebkitBackgroundSize = 181,
  kAliasWebkitBorderAfter = 182,
  kAliasWebkitBorderAfterColor = 183,
  kAliasWebkitBorderAfterStyle = 184,
  kAliasWebkitBorderAfterWidth = 185,
  kAliasWebkitBorderBefore = 186,
  kAliasWebkitBorderBeforeColor = 187,
  kAliasWebkitBorderBeforeStyle = 188,
  kAliasWebkitBorderBeforeWidth = 189,
  kAliasWebkitBorderEnd = 190,
  kAliasWebkitBorderEndColor = 191,
  kAliasWebkitBorderEndStyle = 192,
  kAliasWebkitBorderEndWidth = 193,
  // kWebkitBorderFit = 194,
  kWebkitBorderHorizontalSpacing = 195,
  kWebkitBorderImage = 196,
  kAliasWebkitBorderRadius = 197,
  kAliasWebkitBorderStart = 198,
  kAliasWebkitBorderStartColor = 199,
  kAliasWebkitBorderStartStyle = 200,
  kAliasWebkitBorderStartWidth = 201,
  kWebkitBorderVerticalSpacing = 202,
  kWebkitBoxAlign = 203,
  kWebkitBoxDirection = 204,
  kWebkitBoxFlex = 205,
  // kWebkitBoxFlexGroup = 206,
  // kWebkitBoxLines = 207,
  kWebkitBoxOrdinalGroup = 208,
  kWebkitBoxOrient = 209,
  kWebkitBoxPack = 210,
  kWebkitBoxReflect = 211,
  kAliasWebkitBoxShadow = 212,
  // kWebkitColorCorrection = 213,
  // kWebkitColumnAxis = 214,
  kWebkitColumnBreakAfter = 215,
  kWebkitColumnBreakBefore = 216,
  kWebkitColumnBreakInside = 217,
  kAliasWebkitColumnCount = 218,
  kAliasWebkitColumnGap = 219,
  // kWebkitColumnProgression = 220,
  kAliasWebkitColumnRule = 221,
  kAliasWebkitColumnRuleColor = 222,
  kAliasWebkitColumnRuleStyle = 223,
  kAliasWebkitColumnRuleWidth = 224,
  kAliasWebkitColumnSpan = 225,
  kAliasWebkitColumnWidth = 226,
  kAliasWebkitColumns = 227,
  // kWebkitBoxDecorationBreak = 228, (duplicated due to #ifdef)
  // kWebkitFilter = 229, (duplicated due to #ifdef)
  kAlignContent = 230,
  kAlignItems = 231,
  kAlignSelf = 232,
  kFlex = 233,
  kFlexBasis = 234,
  kFlexDirection = 235,
  kFlexFlow = 236,
  kFlexGrow = 237,
  kFlexShrink = 238,
  kFlexWrap = 239,
  kJustifyContent = 240,
  // kWebkitFontSizeDelta = 241,
  kGridTemplateColumns = 242,
  kGridTemplateRows = 243,
  kGridColumnStart = 244,
  kGridColumnEnd = 245,
  kGridRowStart = 246,
  kGridRowEnd = 247,
  kGridColumn = 248,
  kGridRow = 249,
  kGridAutoFlow = 250,
  // kWebkitHighlight = 251,
  kAliasWebkitHyphenateCharacter = 252,
  // kWebkitHyphenateLimitAfter = 253,
  // kWebkitHyphenateLimitBefore = 254,
  // kWebkitHyphenateLimitLines = 255,
  // kWebkitHyphens = 256,
  // kWebkitLineBoxContain = 257,
  // kWebkitLineAlign = 258,
  kWebkitLineBreak = 259,
  kWebkitLineClamp = 260,
  // kWebkitLineGrid = 261,
  // kWebkitLineSnap = 262,
  kAliasWebkitLogicalWidth = 263,
  kAliasWebkitLogicalHeight = 264,
  kWebkitMarginAfterCollapse = 265,
  kWebkitMarginBeforeCollapse = 266,
  kWebkitMarginBottomCollapse = 267,
  kWebkitMarginTopCollapse = 268,
  kWebkitMarginCollapse = 269,
  kAliasWebkitMarginAfter = 270,
  kAliasWebkitMarginBefore = 271,
  kAliasWebkitMarginEnd = 272,
  kAliasWebkitMarginStart = 273,
  // kWebkitMarquee = 274,
  // kWebkitMarqueeDirection = 275,
  // kWebkitMarqueeIncrement = 276,
  // kWebkitMarqueeRepetition = 277,
  // kWebkitMarqueeSpeed = 278,
  // kWebkitMarqueeStyle = 279,
  kAliasWebkitMask = 280,
  kWebkitMaskBoxImage = 281,
  kWebkitMaskBoxImageOutset = 282,
  kWebkitMaskBoxImageRepeat = 283,
  kWebkitMaskBoxImageSlice = 284,
  kWebkitMaskBoxImageSource = 285,
  kWebkitMaskBoxImageWidth = 286,
  kAliasWebkitMaskClip = 287,
  kAliasWebkitMaskComposite = 288,
  kAliasWebkitMaskImage = 289,
  kAliasWebkitMaskOrigin = 290,
  kAliasWebkitMaskPosition = 291,
  kWebkitMaskPositionX = 292,
  kWebkitMaskPositionY = 293,
  kAliasWebkitMaskRepeat = 294,
  // kWebkitMaskRepeatX = 295,
  // kWebkitMaskRepeatY = 296,
  kAliasWebkitMaskSize = 297,
  kAliasWebkitMaxLogicalWidth = 298,
  kAliasWebkitMaxLogicalHeight = 299,
  kAliasWebkitMinLogicalWidth = 300,
  kAliasWebkitMinLogicalHeight = 301,
  // kWebkitNbspMode = 302,
  kOrder = 303,
  kAliasWebkitPaddingAfter = 304,
  kAliasWebkitPaddingBefore = 305,
  kAliasWebkitPaddingEnd = 306,
  kAliasWebkitPaddingStart = 307,
  kAliasWebkitPerspective = 308,
  kAliasWebkitPerspectiveOrigin = 309,
  kWebkitPerspectiveOriginX = 310,
  kWebkitPerspectiveOriginY = 311,
  kWebkitPrintColorAdjust = 312,
  kWebkitRtlOrdering = 313,
  kWebkitRubyPosition = 314,
  kWebkitTextCombine = 315,
  kWebkitTextDecorationsInEffect = 316,
  kAliasWebkitTextEmphasis = 317,
  kAliasWebkitTextEmphasisColor = 318,
  kAliasWebkitTextEmphasisPosition = 319,
  kAliasWebkitTextEmphasisStyle = 320,
  kWebkitTextFillColor = 321,
  kWebkitTextSecurity = 322,
  kWebkitTextStroke = 323,
  kWebkitTextStrokeColor = 324,
  kWebkitTextStrokeWidth = 325,
  kAliasWebkitTransform = 326,
  kAliasWebkitTransformOrigin = 327,
  kWebkitTransformOriginX = 328,
  kWebkitTransformOriginY = 329,
  kWebkitTransformOriginZ = 330,
  kAliasWebkitTransformStyle = 331,
  kAliasWebkitTransition = 332,
  kAliasWebkitTransitionDelay = 333,
  kAliasWebkitTransitionDuration = 334,
  kAliasWebkitTransitionProperty = 335,
  kAliasWebkitTransitionTimingFunction = 336,
  kWebkitUserDrag = 337,
  kWebkitUserModify = 338,
  kAliasWebkitUserSelect = 339,
  // kWebkitFlowInto = 340,
  // kWebkitFlowFrom = 341,
  // kWebkitRegionFragment = 342,
  // kWebkitRegionBreakAfter = 343,
  // kWebkitRegionBreakBefore = 344,
  // kWebkitRegionBreakInside = 345,
  // kShapeInside = 346,
  kShapeOutside = 347,
  kShapeMargin = 348,
  // kShapePadding = 349,
  // kWebkitWrapFlow = 350,
  // kWebkitWrapThrough = 351,
  // kWebkitWrap = 352,
  // kWebkitTapHighlightColor = 353, (duplicated due to #ifdef)
  // kWebkitAppRegion = 354, (duplicated due to #ifdef)
  kClipPath = 355,
  kClipRule = 356,
  kMask = 357,
  // kEnableBackground = 358,
  kFilter = 359,
  kFloodColor = 360,
  kFloodOpacity = 361,
  kLightingColor = 362,
  kStopColor = 363,
  kStopOpacity = 364,
  kColorInterpolation = 365,
  kColorInterpolationFilters = 366,
  // kColorProfile = 367,
  kColorRendering = 368,
  kFill = 369,
  kFillOpacity = 370,
  kFillRule = 371,
  kMarker = 372,
  kMarkerEnd = 373,
  kMarkerMid = 374,
  kMarkerStart = 375,
  kMaskType = 376,
  kShapeRendering = 377,
  kStroke = 378,
  kStrokeDasharray = 379,
  kStrokeDashoffset = 380,
  kStrokeLinecap = 381,
  kStrokeLinejoin = 382,
  kStrokeMiterlimit = 383,
  kStrokeOpacity = 384,
  kStrokeWidth = 385,
  kAlignmentBaseline = 386,
  kBaselineShift = 387,
  kDominantBaseline = 388,
  // kGlyphOrientationHorizontal = 389,
  // kGlyphOrientationVertical = 390,
  // kKerning = 391,
  kTextAnchor = 392,
  kVectorEffect = 393,
  kWritingMode = 394,
  // kWebkitSvgShadow = 395,
  // kWebkitCursorVisibility = 396,
  // kImageOrientation = 397,
  // kImageResolution = 398,
  // kWebkitBlendMode = 399, (behind defunct #ifdef)
  // kWebkitBackgroundBlendMode = 400, (behind defunct #ifdef)
  kTextDecorationLine = 401,
  kTextDecorationStyle = 402,
  kTextDecorationColor = 403,
  kTextAlignLast = 404,
  kTextUnderlinePosition = 405,
  kMaxZoom = 406,
  kMinZoom = 407,
  kOrientation = 408,
  kUserZoom = 409,
  // kWebkitDashboardRegion = 410,
  // kWebkitOverflowScrolling = 411,
  kAliasWebkitAppRegion = 412,
  kAliasWebkitFilter = 413,
  kWebkitBoxDecorationBreak = 414,
  kWebkitTapHighlightColor = 415,
  kBufferedRendering = 416,
  kGridAutoRows = 417,
  kGridAutoColumns = 418,
  kBackgroundBlendMode = 419,
  kMixBlendMode = 420,
  kTouchAction = 421,
  kGridArea = 422,
  kGridTemplateAreas = 423,
  kAnimation = 424,
  kAnimationDelay = 425,
  kAnimationDirection = 426,
  kAnimationDuration = 427,
  kAnimationFillMode = 428,
  kAnimationIterationCount = 429,
  kAnimationName = 430,
  kAnimationPlayState = 431,
  kAnimationTimingFunction = 432,
  kObjectFit = 433,
  kPaintOrder = 434,
  kMaskSourceType = 435,
  kIsolation = 436,
  kObjectPosition = 437,
  // kInternalCallback = 438,
  kShapeImageThreshold = 439,
  kColumnFill = 440,
  kTextJustify = 441,
  // kTouchActionDelay = 442,
  kJustifySelf = 443,
  kScrollBehavior = 444,
  kWillChange = 445,
  kTransform = 446,
  kTransformOrigin = 447,
  kTransformStyle = 448,
  kPerspective = 449,
  kPerspectiveOrigin = 450,
  kBackfaceVisibility = 451,
  kGridTemplate = 452,
  kGrid = 453,
  kAll = 454,
  kJustifyItems = 455,
  // kScrollBlocksOn = 456,
  // kAliasMotionPath = 457,
  // kAliasMotionOffset = 458,
  // kAliasMotionRotation = 459,
  // kMotion = 460,
  kX = 461,
  kY = 462,
  kRx = 463,
  kRy = 464,
  kFontSizeAdjust = 465,
  kCx = 466,
  kCy = 467,
  kR = 468,
  kAliasEpubCaptionSide = 469,
  kAliasEpubTextCombine = 470,
  kAliasEpubTextEmphasis = 471,
  kAliasEpubTextEmphasisColor = 472,
  kAliasEpubTextEmphasisStyle = 473,
  kAliasEpubTextOrientation = 474,
  kAliasEpubTextTransform = 475,
  kAliasEpubWordBreak = 476,
  kAliasEpubWritingMode = 477,
  kAliasWebkitAlignContent = 478,
  kAliasWebkitAlignItems = 479,
  kAliasWebkitAlignSelf = 480,
  kAliasWebkitBorderBottomLeftRadius = 481,
  kAliasWebkitBorderBottomRightRadius = 482,
  kAliasWebkitBorderTopLeftRadius = 483,
  kAliasWebkitBorderTopRightRadius = 484,
  kAliasWebkitBoxSizing = 485,
  kAliasWebkitFlex = 486,
  kAliasWebkitFlexBasis = 487,
  kAliasWebkitFlexDirection = 488,
  kAliasWebkitFlexFlow = 489,
  kAliasWebkitFlexGrow = 490,
  kAliasWebkitFlexShrink = 491,
  kAliasWebkitFlexWrap = 492,
  kAliasWebkitJustifyContent = 493,
  kAliasWebkitOpacity = 494,
  kAliasWebkitOrder = 495,
  kAliasWebkitShapeImageThreshold = 496,
  kAliasWebkitShapeMargin = 497,
  kAliasWebkitShapeOutside = 498,
  kScrollSnapType = 499,
  // kScrollSnapPointsX = 500,
  // kScrollSnapPointsY = 501,
  // kScrollSnapCoordinate = 502,
  // kScrollSnapDestination = 503,
  kTranslate = 504,
  kRotate = 505,
  kScale = 506,
  kImageOrientation = 507,
  kBackdropFilter = 508,
  kTextCombineUpright = 509,
  kTextOrientation = 510,
  kAliasGridColumnGap = 511,
  kAliasGridRowGap = 512,
  kAliasGridGap = 513,
  kFontFeatureSettings = 514,
  kVariable = 515,
  kFontDisplay = 516,
  kContain = 517,
  kD = 518,
  // kLineHeightStep = 519,
  kBreakAfter = 520,
  kBreakBefore = 521,
  kBreakInside = 522,
  kColumnCount = 523,
  kColumnGap = 524,
  kColumnRule = 525,
  kColumnRuleColor = 526,
  kColumnRuleStyle = 527,
  kColumnRuleWidth = 528,
  kColumnSpan = 529,
  kColumnWidth = 530,
  kColumns = 531,
  // kApplyAtRule = 532,
  kFontVariantCaps = 533,
  kHyphens = 534,
  kFontVariantNumeric = 535,
  kTextSizeAdjust = 536,
  kAliasWebkitTextSizeAdjust = 537,
  kOverflowAnchor = 538,
  kUserSelect = 539,
  kOffsetDistance = 540,
  kOffsetPath = 541,
  // kOffsetRotation = 542,
  kOffset = 543,
  kOffsetAnchor = 544,
  kOffsetPosition = 545,
  // kTextDecorationSkip = 546,
  kCaretColor = 547,
  kOffsetRotate = 548,
  kFontVariationSettings = 549,
  kInlineSize = 550,
  kBlockSize = 551,
  kMinInlineSize = 552,
  kMinBlockSize = 553,
  kMaxInlineSize = 554,
  kMaxBlockSize = 555,
  kLineBreak = 556,
  kPlaceContent = 557,
  kPlaceItems = 558,
  kTransformBox = 559,
  kPlaceSelf = 560,
  kScrollSnapAlign = 561,
  kScrollPadding = 562,
  kScrollPaddingTop = 563,
  kScrollPaddingRight = 564,
  kScrollPaddingBottom = 565,
  kScrollPaddingLeft = 566,
  kScrollPaddingBlock = 567,
  kScrollPaddingBlockStart = 568,
  kScrollPaddingBlockEnd = 569,
  kScrollPaddingInline = 570,
  kScrollPaddingInlineStart = 571,
  kScrollPaddingInlineEnd = 572,
  kScrollMargin = 573,
  kScrollMarginTop = 574,
  kScrollMarginRight = 575,
  kScrollMarginBottom = 576,
  kScrollMarginLeft = 577,
  kScrollMarginBlock = 578,
  kScrollMarginBlockStart = 579,
  kScrollMarginBlockEnd = 580,
  kScrollMarginInline = 581,
  kScrollMarginInlineStart = 582,
  kScrollMarginInlineEnd = 583,
  kScrollSnapStop = 584,
  kOverscrollBehavior = 585,
  kOverscrollBehaviorX = 586,
  kOverscrollBehaviorY = 587,
  kFontVariantEastAsian = 588,
  kTextDecorationSkipInk = 589,
  kScrollCustomization = 590,
  kRowGap = 591,
  kGap = 592,
  kViewportFit = 593,
  kMarginBlockStart = 594,
  kMarginBlockEnd = 595,
  kMarginInlineStart = 596,
  kMarginInlineEnd = 597,
  kPaddingBlockStart = 598,
  kPaddingBlockEnd = 599,
  kPaddingInlineStart = 600,
  kPaddingInlineEnd = 601,
  kBorderBlockEndColor = 602,
  kBorderBlockEndStyle = 603,
  kBorderBlockEndWidth = 604,
  kBorderBlockStartColor = 605,
  kBorderBlockStartStyle = 606,
  kBorderBlockStartWidth = 607,
  kBorderInlineEndColor = 608,
  kBorderInlineEndStyle = 609,
  kBorderInlineEndWidth = 610,
  kBorderInlineStartColor = 611,
  kBorderInlineStartStyle = 612,
  kBorderInlineStartWidth = 613,
  kBorderBlockStart = 614,
  kBorderBlockEnd = 615,
  kBorderInlineStart = 616,
  kBorderInlineEnd = 617,
  kMarginBlock = 618,
  kMarginInline = 619,
  kPaddingBlock = 620,
  kPaddingInline = 621,
  kBorderBlockColor = 622,
  kBorderBlockStyle = 623,
  kBorderBlockWidth = 624,
  kBorderInlineColor = 625,
  kBorderInlineStyle = 626,
  kBorderInlineWidth = 627,
  kBorderBlock = 628,
  kBorderInline = 629,
  kInsetBlockStart = 630,
  kInsetBlockEnd = 631,
  kInsetBlock = 632,
  kInsetInlineStart = 633,
  kInsetInlineEnd = 634,
  kInsetInline = 635,
  kInset = 636,
  kColorScheme = 637,
  kOverflowInline = 638,
  kOverflowBlock = 639,
  kForcedColorAdjust = 640,
  kInherits = 641,
  kInitialValue = 642,
  kSyntax = 643,
  kOverscrollBehaviorInline = 644,
  kOverscrollBehaviorBlock = 645,
  // kContentSize = 646,
  kFontOpticalSizing = 647,
  kContainIntrinsicBlockSize = 648,
  kContainIntrinsicHeight = 649,
  kContainIntrinsicInlineSize = 650,
  kContainIntrinsicSize = 651,
  kContainIntrinsicWidth = 652,
  // kRenderSubtree = 653,
  kOriginTrialTestProperty = 654,
  // kSubtreeVisibility = 655,
  kMathStyle = 656,
  kAspectRatio = 657,
  kAppearance = 658,
  // kMathSuperscriptShiftStyle = 659,
  kRubyPosition = 660,
  kTextUnderlineOffset = 661,
  kContentVisibility = 662,
  kTextDecorationThickness = 663,
  kPageOrientation = 664,
  kAnimationTimeline = 665,
  kCounterSet = 666,
  kSource = 667,
  kStart = 668,
  kEnd = 669,
  kTimeRange = 670,
  kScrollbarGutter = 671,
  kAscentOverride = 672,
  kDescentOverride = 673,
  kAdvanceOverride = 674,
  kLineGapOverride = 675,
  kMathShift = 676,
  kMathDepth = 677,
  // kAdvanceProportionalOverride = 678,
  kOverflowClipMargin = 679,
  kScrollbarWidth = 680,
  // @counter-style descriptors
  kSystem = 681,
  kNegative = 682,
  kPrefix = 683,
  kSuffix = 684,
  kRange = 685,
  kPad = 686,
  kFallback = 687,
  kSymbols = 688,
  kAdditiveSymbols = 689,
  kSpeakAs = 690,
  kBorderStartStartRadius = 691,
  kBorderStartEndRadius = 692,
  kBorderEndStartRadius = 693,
  kBorderEndEndRadius = 694,
  kAccentColor = 695,
  kSizeAdjust = 696,
  kContainerName = 697,
  kContainerType = 698,
  kContainer = 699,
  kFontSynthesisWeight = 700,
  kFontSynthesisStyle = 701,
  kAppRegion = 702,
  kFontSynthesisSmallCaps = 703,
  kFontSynthesis = 704,
  kTextEmphasis = 705,
  kTextEmphasisColor = 706,
  kTextEmphasisPosition = 707,
  kTextEmphasisStyle = 708,
  kFontPalette = 709,
  kBasePalette = 710,
  kOverrideColors = 711,
  kViewTransitionName = 712,
  kObjectViewBox = 713,
  kObjectOverflow = 714,
  // kToggleGroup = 715,
  // kToggleRoot = 716,
  // kToggleTrigger = 717,
  // kToggle = 718,
  kAnchorName = 719,
  kPositionFallback = 720,
  // kAnchorScroll = 721,
  kPopoverShowDelay = 722,
  kPopoverHideDelay = 723,
  kHyphenateCharacter = 724,
  kScrollTimeline = 725,
  kScrollTimelineName = 726,
  kScrollTimelineAxis = 727,
  kViewTimeline = 728,
  kViewTimelineAxis = 729,
  kViewTimelineInset = 730,
  kViewTimelineName = 731,
  // kToggleVisibility = 732,
  kInitialLetter = 733,
  kHyphenateLimitChars = 734,
  kAnimationDelayStart = 735,
  kAnimationDelayEnd = 736,
  kFontVariantPosition = 737,
  kFontVariantAlternates = 738,
  kBaselineSource = 739,
  kAnimationRange = 740,
  kAnimationRangeStart = 741,
  kAnimationRangeEnd = 742,
  kAnimationComposition = 743,
  kTopLayer = 744,
  // kAnchorDefault = 745,
  kTextWrap = 746,
  kTextBoxTrim = 747,
  kOverlay = 748,
  kWhiteSpaceCollapse = 749,
  kScrollTimelineAttachment = 750,
  kViewTimelineAttachment = 751,
  kScrollStartBlock = 752,
  kScrollStartInline = 753,
  kScrollStartX = 754,
  kScrollStartY = 755,
  kScrollStart = 756,
  kScrollStartTargetBlock = 757,
  kScrollStartTargetInline = 758,
  kScrollStartTargetX = 759,
  kScrollStartTargetY = 760,
  kScrollStartTarget = 761,
  kTimelineScope = 762,
  kScrollbarColor = 763,
  // kWordBoundaryDetection = 764,
  kPositionFallbackBounds = 765,
  kTransitionBehavior = 766,
  kTextAutospace = 767,
  kNavigation = 768,
  kDynamicRangeLimit = 769,
  kFieldSizing = 770,
  kTextSpacingTrim = 771,
  kMaskImage = 772,
  kMaskClip = 773,
  kMaskSize = 774,
  kMaskOrigin = 775,
  kTextSpacing = 776,
  kMaskRepeat = 777,
  kMaskComposite = 778,
  kMaskPosition = 779,
  kMaskMode = 780,
  kInsetArea = 781,
  kViewTransitionClass = 782,
  kPositionTryOrder = 783,
  kPositionTryOptions = 784,
  kPositionTry = 785,
  kTextBoxEdge = 786,
  kReadingOrderItems = 787,
  kPositionAnchor = 788,
  kPositionVisibility = 789,
  kTypes = 790,
  kLineClamp = 791,
  kFontVariantEmoji = 792,
  kScrollMarkers = 793,
  kAnchorScope = 794,
  kRubyAlign = 795,

  // 1. Add new features above this line (don't change the assigned numbers of
  //    the existing items).
  // 2. Run the src/tools/metrics/histograms/update_use_counter_css.py script
  //    to update the UMA histogram names.
};

}  // namespace webf

#endif  // WEBF_CSS_SAMPLE_ID_H