// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_COMPUTED_STYLE_BASE_CONSTANTS_H
#define WEBF_COMPUTED_STYLE_BASE_CONSTANTS_H

#include <stdint.h>
#include <iosfwd>

namespace webf {


enum class EAlignmentBaseline : uint8_t {
  kBaseline,
  kMiddle,
  kAuto,
  kAlphabetic,
  kBeforeEdge,
  kAfterEdge,
  kCentral,
  kTextBeforeEdge,
  kTextAfterEdge,
  kIdeographic,
  kHanging,
  kMathematical,
  kMaxEnumValue = kMathematical,
};

enum class EBackfaceVisibility : uint8_t {
  kHidden,
  kVisible,
  kMaxEnumValue = kVisible,
};

enum class EBaselineSource : uint8_t {
  kAuto,
  kFirst,
  kLast,
  kMaxEnumValue = kLast,
};

enum class EBorderCollapse : uint8_t {
  kCollapse,
  kSeparate,
  kMaxEnumValue = kSeparate,
};

enum class EBorderStyle : uint8_t {
  kNone,
  kHidden,
  kInset,
  kGroove,
  kOutset,
  kRidge,
  kDotted,
  kDashed,
  kSolid,
  kDouble,
  kMaxEnumValue = kDouble,
};

enum class EBoxAlignment : uint8_t {
  kBaseline,
  kCenter,
  kStretch,
  kStart,
  kEnd,
  kMaxEnumValue = kEnd,
};

enum class EBoxDecorationBreak : uint8_t {
  kClone,
  kSlice,
  kMaxEnumValue = kSlice,
};

enum class EBoxDirection : uint8_t {
  kNormal,
  kReverse,
  kMaxEnumValue = kReverse,
};

enum class EBoxOrient : uint8_t {
  kHorizontal,
  kVertical,
  kMaxEnumValue = kVertical,
};

enum class EBoxPack : uint8_t {
  kCenter,
  kJustify,
  kStart,
  kEnd,
  kMaxEnumValue = kEnd,
};

enum class EBoxSizing : uint8_t {
  kBorderBox,
  kContentBox,
  kMaxEnumValue = kContentBox,
};

enum class EBreakBetween : uint8_t {
  kLeft,
  kRight,
  kAuto,
  kAvoid,
  kColumn,
  kAvoidPage,
  kPage,
  kRecto,
  kVerso,
  kAvoidColumn,
  kMaxEnumValue = kAvoidColumn,
};

enum class EBreakInside : uint8_t {
  kAuto,
  kAvoid,
  kAvoidPage,
  kAvoidColumn,
  kMaxEnumValue = kAvoidColumn,
};

enum class EBufferedRendering : uint8_t {
  kAuto,
  kStatic,
  kDynamic,
  kMaxEnumValue = kDynamic,
};

enum class ECaptionSide : uint8_t {
  kTop,
  kBottom,
  kMaxEnumValue = kBottom,
};

enum class EClear : uint8_t {
  kNone,
  kLeft,
  kRight,
  kInlineStart,
  kInlineEnd,
  kBoth,
  kMaxEnumValue = kBoth,
};

enum class EColorInterpolation : uint8_t {
  kAuto,
  kSrgb,
  kLinearrgb,
  kMaxEnumValue = kLinearrgb,
};

enum class EColorRendering : uint8_t {
  kAuto,
  kOptimizespeed,
  kOptimizequality,
  kMaxEnumValue = kOptimizequality,
};

enum class EColumnFill : uint8_t {
  kAuto,
  kBalance,
  kMaxEnumValue = kBalance,
};

enum class EColumnSpan : uint8_t {
  kNone,
  kAll,
  kMaxEnumValue = kAll,
};

enum class EContentVisibility : uint8_t {
  kHidden,
  kAuto,
  kVisible,
  kMaxEnumValue = kVisible,
};

enum class ECursor : uint8_t {
  kNone,
  kCopy,
  kAuto,
  kCrosshair,
  kDefault,
  kPointer,
  kMove,
  kVerticalText,
  kCell,
  kContextMenu,
  kAlias,
  kProgress,
  kNoDrop,
  kNotAllowed,
  kZoomIn,
  kZoomOut,
  kEResize,
  kNeResize,
  kNwResize,
  kNResize,
  kSeResize,
  kSwResize,
  kSResize,
  kWResize,
  kEwResize,
  kNsResize,
  kNeswResize,
  kNwseResize,
  kColResize,
  kRowResize,
  kText,
  kWait,
  kHelp,
  kAllScroll,
  kGrab,
  kGrabbing,
  kMaxEnumValue = kGrabbing,
};

enum class EDisplay : uint8_t {
  kInline,
  kBlock,
  kListItem,
  kInlineBlock,
  kTable,
  kInlineTable,
  kTableRowGroup,
  kTableHeaderGroup,
  kTableFooterGroup,
  kTableRow,
  kTableColumnGroup,
  kTableColumn,
  kTableCell,
  kTableCaption,
  kWebkitBox,
  kWebkitInlineBox,
  kFlex,
  kInlineFlex,
  kGrid,
  kInlineGrid,
  kContents,
  kFlowRoot,
  kNone,
  kLayoutCustom,
  kInlineLayoutCustom,
  kMath,
  kBlockMath,
  kInlineListItem,
  kFlowRootListItem,
  kInlineFlowRootListItem,
  kRuby,
  kBlockRuby,
  kRubyText,
  kMaxEnumValue = kRubyText,
};

enum class EDominantBaseline : uint8_t {
  kMiddle,
  kAuto,
  kAlphabetic,
  kCentral,
  kTextBeforeEdge,
  kTextAfterEdge,
  kIdeographic,
  kHanging,
  kMathematical,
  kUseScript,
  kNoChange,
  kResetSize,
  kMaxEnumValue = kResetSize,
};

enum class EDraggableRegionMode : uint8_t {
  kNone,
  kDrag,
  kNoDrag,
  kMaxEnumValue = kNoDrag,
};

enum class EEmptyCells : uint8_t {
  kHide,
  kShow,
  kMaxEnumValue = kShow,
};

enum class EFieldSizing : uint8_t {
  kFixed,
  kContent,
  kMaxEnumValue = kContent,
};

enum class EFlexDirection : uint8_t {
  kRow,
  kRowReverse,
  kColumn,
  kColumnReverse,
  kMaxEnumValue = kColumnReverse,
};

enum class EFlexWrap : uint8_t {
  kNowrap,
  kWrap,
  kWrapReverse,
  kMaxEnumValue = kWrapReverse,
};

enum class EFloat : uint8_t {
  kNone,
  kLeft,
  kRight,
  kInlineStart,
  kInlineEnd,
  kMaxEnumValue = kInlineEnd,
};

enum class EForcedColorAdjust : uint8_t {
  kNone,
  kAuto,
  kPreserveParentColor,
  kMaxEnumValue = kPreserveParentColor,
};

enum class EImageRendering : uint8_t {
  kAuto,
  kOptimizespeed,
  kOptimizequality,
  kPixelated,
  kWebkitOptimizeContrast,
  kMaxEnumValue = kWebkitOptimizeContrast,
};

enum class EInlineBlockBaselineEdge : uint8_t {
  kMarginBox,
  kBorderBox,
  kContentBox,
  kMaxEnumValue = kContentBox,
};

enum class EInsideLink : uint8_t {
  kNotInsideLink,
  kInsideUnvisitedLink,
  kInsideVisitedLink,
  kMaxEnumValue = kInsideVisitedLink,
};

enum class EIsolation : uint8_t {
  kAuto,
  kIsolate,
  kMaxEnumValue = kIsolate,
};

enum class EListStylePosition : uint8_t {
  kOutside,
  kInside,
  kMaxEnumValue = kInside,
};

enum class EMaskType : uint8_t {
  kAlpha,
  kLuminance,
  kMaxEnumValue = kLuminance,
};

enum class EMathShift : uint8_t {
  kNormal,
  kCompact,
  kMaxEnumValue = kCompact,
};

enum class EMathStyle : uint8_t {
  kNormal,
  kCompact,
  kMaxEnumValue = kCompact,
};

enum class EObjectFit : uint8_t {
  kNone,
  kContain,
  kCover,
  kFill,
  kScaleDown,
  kMaxEnumValue = kScaleDown,
};

enum class EOrder : uint8_t {
  kLogical,
  kVisual,
  kMaxEnumValue = kVisual,
};

enum class EOriginTrialTestProperty : uint8_t {
  kNone,
  kNormal,
  kMaxEnumValue = kNormal,
};

enum class EOverflow : uint8_t {
  kHidden,
  kAuto,
  kVisible,
  kOverlay,
  kScroll,
  kClip,
  kMaxEnumValue = kClip,
};

enum class EOverflowAnchor : uint8_t {
  kNone,
  kAuto,
  kVisible,
  kMaxEnumValue = kVisible,
};

enum class EOverflowWrap : uint8_t {
  kNormal,
  kBreakWord,
  kAnywhere,
  kMaxEnumValue = kAnywhere,
};

enum class EOverlay : uint8_t {
  kNone,
  kAuto,
  kMaxEnumValue = kAuto,
};

enum class EOverscrollBehavior : uint8_t {
  kNone,
  kAuto,
  kContain,
  kMaxEnumValue = kContain,
};

enum class EPointerEvents : uint8_t {
  kNone,
  kAll,
  kAuto,
  kVisible,
  kVisiblepainted,
  kVisiblefill,
  kVisiblestroke,
  kPainted,
  kFill,
  kStroke,
  kBoundingBox,
  kMaxEnumValue = kBoundingBox,
};

enum class EPosition : uint8_t {
  kAbsolute,
  kFixed,
  kRelative,
  kStatic,
  kSticky,
  kMaxEnumValue = kSticky,
};

enum class EPositionTryOrder : uint8_t {
  kNormal,
  kMostWidth,
  kMostHeight,
  kMostBlockSize,
  kMostInlineSize,
  kMaxEnumValue = kMostInlineSize,
};

enum class EPrintColorAdjust : uint8_t {
  kEconomy,
  kExact,
  kMaxEnumValue = kExact,
};

enum class EReadingFlow : uint8_t {
  kNormal,
  kFlexVisual,
  kFlexFlow,
  kGridRows,
  kGridColumns,
  kGridOrder,
  kMaxEnumValue = kGridOrder,
};

enum class EResize : uint8_t {
  kNone,
  kInline,
  kBlock,
  kBoth,
  kHorizontal,
  kVertical,
  kMaxEnumValue = kVertical,
};

enum class ERubyAlign : uint8_t {
  kCenter,
  kStart,
  kSpaceBetween,
  kSpaceAround,
  kMaxEnumValue = kSpaceAround,
};

enum class EScrollMarkers : uint8_t {
  kNone,
  kAfter,
  kBefore,
  kMaxEnumValue = kBefore,
};

enum class EScrollSnapStop : uint8_t {
  kNormal,
  kAlways,
  kMaxEnumValue = kAlways,
};

enum class EScrollStartTarget : uint8_t {
  kNone,
  kAuto,
  kMaxEnumValue = kAuto,
};

enum class EScrollbarWidth : uint8_t {
  kNone,
  kAuto,
  kThin,
  kMaxEnumValue = kThin,
};

enum class EShapeRendering : uint8_t {
  kAuto,
  kOptimizespeed,
  kGeometricprecision,
  kCrispedges,
  kMaxEnumValue = kCrispedges,
};

enum class ESpeak : uint8_t {
  kNone,
  kNormal,
  kSpellOut,
  kDigits,
  kLiteralPunctuation,
  kNoPunctuation,
  kMaxEnumValue = kNoPunctuation,
};

enum class ETableLayout : uint8_t {
  kAuto,
  kFixed,
  kMaxEnumValue = kFixed,
};

enum class ETextAlign : uint8_t {
  kLeft,
  kRight,
  kCenter,
  kJustify,
  kWebkitLeft,
  kWebkitRight,
  kWebkitCenter,
  kStart,
  kEnd,
  kMaxEnumValue = kEnd,
};

enum class ETextAlignLast : uint8_t {
  kLeft,
  kRight,
  kCenter,
  kJustify,
  kAuto,
  kStart,
  kEnd,
  kMaxEnumValue = kEnd,
};

enum class ETextAnchor : uint8_t {
  kMiddle,
  kStart,
  kEnd,
  kMaxEnumValue = kEnd,
};

enum class ETextAutospace : uint8_t {
  kNormal,
  kNoAutospace,
  kMaxEnumValue = kNoAutospace,
};

enum class ETextBoxTrim : uint8_t {
  kNone,
  kBoth,
  kStart,
  kEnd,
  kMaxEnumValue = kEnd,
};

enum class ETextCombine : uint8_t {
  kNone,
  kAll,
  kMaxEnumValue = kAll,
};

enum class ETextDecorationSkipInk : uint8_t {
  kNone,
  kAuto,
  kMaxEnumValue = kAuto,
};

enum class ETextDecorationStyle : uint8_t {
  kDotted,
  kDashed,
  kSolid,
  kDouble,
  kWavy,
  kMaxEnumValue = kWavy,
};

enum class ETextOrientation : uint8_t {
  kMixed,
  kSideways,
  kUpright,
  kMaxEnumValue = kUpright,
};

enum class ETextOverflow : uint8_t {
  kClip,
  kEllipsis,
  kMaxEnumValue = kEllipsis,
};

enum class ETextSecurity : uint8_t {
  kNone,
  kDisc,
  kCircle,
  kSquare,
  kMaxEnumValue = kSquare,
};

enum class ETextTransform : uint8_t {
  kNone,
  kCapitalize,
  kUppercase,
  kLowercase,
  kMathAuto,
  kMaxEnumValue = kMathAuto,
};

enum class ETransformBox : uint8_t {
  kBorderBox,
  kContentBox,
  kFillBox,
  kViewBox,
  kStrokeBox,
  kMaxEnumValue = kStrokeBox,
};

enum class ETransformStyle3D : uint8_t {
  kFlat,
  kPreserve3D,
  kMaxEnumValue = kPreserve3D,
};

enum class EUserDrag : uint8_t {
  kNone,
  kAuto,
  kElement,
  kMaxEnumValue = kElement,
};

enum class EUserModify : uint8_t {
  kReadOnly,
  kReadWrite,
  kReadWritePlaintextOnly,
  kMaxEnumValue = kReadWritePlaintextOnly,
};

enum class EUserSelect : uint8_t {
  kNone,
  kAll,
  kAuto,
  kText,
  kContain,
  kMaxEnumValue = kContain,
};

enum class EVectorEffect : uint8_t {
  kNone,
  kNonScalingStroke,
  kMaxEnumValue = kNonScalingStroke,
};

enum class EVisibility : uint8_t {
  kHidden,
  kVisible,
  kCollapse,
  kMaxEnumValue = kCollapse,
};

enum class EWordBreak : uint8_t {
  kNormal,
  kBreakAll,
  kKeepAll,
  kAutoPhrase,
  kBreakWord,
  kMaxEnumValue = kBreakWord,
};

enum class Hyphens : uint8_t {
  kNone,
  kAuto,
  kManual,
  kMaxEnumValue = kManual,
};

enum class LineBreak : uint8_t {
  kNormal,
  kAuto,
  kLoose,
  kStrict,
  kAfterWhiteSpace,
  kAnywhere,
  kMaxEnumValue = kAnywhere,
};

enum class RubyPosition : uint8_t {
  kOver,
  kUnder,
  kMaxEnumValue = kUnder,
};

enum class TextDecorationLine : unsigned {
  kNone = 0,
  kUnderline = 1,
  kOverline = 2,
  kLineThrough = 4,
  kBlink = 8,
  kSpellingError = 16,
  kGrammarError = 32,
};

static const int kTextDecorationLineBits = 6;

inline TextDecorationLine operator|(TextDecorationLine a, TextDecorationLine b) {
  return static_cast<TextDecorationLine>(
      static_cast<unsigned>(a) | static_cast<unsigned>(b)
  );
}
inline TextDecorationLine& operator|=(TextDecorationLine& a, TextDecorationLine b) {
  return a = a | b;
}

inline TextDecorationLine operator^(TextDecorationLine a, TextDecorationLine b) {
  return static_cast<TextDecorationLine>(
      static_cast<unsigned>(a) ^ static_cast<unsigned>(b)
  );
}
inline TextDecorationLine& operator^=(TextDecorationLine& a, TextDecorationLine b) {
  return a = a ^ b;
}

inline TextDecorationLine operator&(TextDecorationLine a, TextDecorationLine b) {
  return static_cast<TextDecorationLine>(
      static_cast<unsigned>(a) & static_cast<unsigned>(b)
  );
}
inline TextDecorationLine& operator&=(TextDecorationLine& a, TextDecorationLine b) {
  return a = a & b;
}

inline TextDecorationLine operator~(TextDecorationLine x) {
  return static_cast<TextDecorationLine>(~static_cast<unsigned>(x));
}

enum class TextEmphasisFill : uint8_t {
  kFilled,
  kOpen,
  kMaxEnumValue = kOpen,
};


enum class TextEmphasisMark : uint8_t {
  kNone,
  kAuto,
  kDot,
  kCircle,
  kDoubleCircle,
  kTriangle,
  kSesame,
  kCustom,
  kMaxEnumValue = kCustom,
};


}  // namespace webf

#endif  // WEBF_COMPUTED_STYLE_BASE_CONSTANTS_H
