/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Copyright 2024 The WebF authors. All rights reserved.
// 
// This file contains stub implementations for CSS types that are not yet
// fully implemented in WebF but are needed for Blink compatibility.

#ifndef WEBF_CORE_STYLE_STYLE_STUBS_H_
#define WEBF_CORE_STYLE_STYLE_STUBS_H_

#include "foundation/macros.h"
#include "core/platform/geometry/length.h"

namespace webf {

// Stub implementations for CSS types not yet implemented in WebF

class StyleIntrinsicLength {
  WEBF_DISALLOW_NEW();
 public:
  StyleIntrinsicLength() = default;
  static StyleIntrinsicLength None() { return StyleIntrinsicLength(); }
  bool operator==(const StyleIntrinsicLength&) const { return true; }
  bool operator!=(const StyleIntrinsicLength&) const { return false; }
};

class GridTrackSize {
  WEBF_DISALLOW_NEW();
 public:
  GridTrackSize() = default;
  GridTrackSize(const Length& length) {}
  static GridTrackSize Auto() { return GridTrackSize(); }
  bool operator==(const GridTrackSize&) const { return true; }
  bool operator!=(const GridTrackSize&) const { return false; }
};

class NGGridTrackList {
  WEBF_DISALLOW_NEW();
 public:
  NGGridTrackList() = default;
  NGGridTrackList(const GridTrackSize& size) {}
  static NGGridTrackList CreateDefault() { return NGGridTrackList(); }
  bool operator==(const NGGridTrackList&) const { return true; }
  bool operator!=(const NGGridTrackList&) const { return false; }
};

class ComputedGridTrackList {
  WEBF_DISALLOW_NEW();
 public:
  ComputedGridTrackList() = default;
  static ComputedGridTrackList CreateDefault() { return ComputedGridTrackList(); }
  bool operator==(const ComputedGridTrackList&) const { return true; }
  bool operator!=(const ComputedGridTrackList&) const { return false; }
};

class GridPosition {
  WEBF_DISALLOW_NEW();
 public:
  GridPosition() = default;
  static GridPosition CreateAuto() { return GridPosition(); }
  bool operator==(const GridPosition&) const { return true; }
  bool operator!=(const GridPosition&) const { return false; }
};

enum class RespectImageOrientationEnum { kNone };

class StyleNameOrKeyword {
  WEBF_DISALLOW_NEW();
 public:
  StyleNameOrKeyword() = default;
  static StyleNameOrKeyword CreateKeyword() { return StyleNameOrKeyword(); }
  bool operator==(const StyleNameOrKeyword&) const { return true; }
  bool operator!=(const StyleNameOrKeyword&) const { return false; }
};

class GapLength {
  WEBF_DISALLOW_NEW();
 public:
  GapLength() = default;
  static GapLength CreateNormal() { return GapLength(); }
  bool operator==(const GapLength&) const { return true; }
  bool operator!=(const GapLength&) const { return false; }
};

class StylePath {
  WEBF_DISALLOW_NEW();
 public:
  StylePath() = default;
  static StylePath* CreateDefault() { return nullptr; }
  bool operator==(const StylePath&) const { return true; }
  bool operator!=(const StylePath&) const { return false; }
};

class ClipPathOperation {
  WEBF_DISALLOW_NEW();
 public:
  ClipPathOperation() = default;
  static ClipPathOperation* CreateDefault() { return nullptr; }
  bool operator==(const ClipPathOperation&) const { return true; }
  bool operator!=(const ClipPathOperation&) const { return false; }
};

class BasicShape {
  WEBF_DISALLOW_NEW();
 public:
  BasicShape() = default;
  static BasicShape* CreateDefault() { return nullptr; }
  bool operator==(const BasicShape&) const { return true; }
  bool operator!=(const BasicShape&) const { return false; }
};

class OffsetPathOperation {
  WEBF_DISALLOW_NEW();
 public:
  OffsetPathOperation() = default;
  static OffsetPathOperation* CreateDefault() { return nullptr; }
  bool operator==(const OffsetPathOperation&) const { return true; }
  bool operator!=(const OffsetPathOperation&) const { return false; }
};

class QuotesData {
  WEBF_DISALLOW_NEW();
 public:
  QuotesData() = default;
  static QuotesData* CreateDefault() { return nullptr; }
  bool operator==(const QuotesData&) const { return true; }
  bool operator!=(const QuotesData&) const { return false; }
};

class ShadowList {
  WEBF_DISALLOW_NEW();
 public:
  ShadowList() = default;
  static ShadowList* CreateDefault() { return nullptr; }
  bool operator==(const ShadowList&) const { return true; }
  bool operator!=(const ShadowList&) const { return false; }
};

class ComputedGridTemplateAreas {
  WEBF_DISALLOW_NEW();
 public:
  ComputedGridTemplateAreas() = default;
  static ComputedGridTemplateAreas* CreateDefault() { return nullptr; }
  bool operator==(const ComputedGridTemplateAreas&) const { return true; }
  bool operator!=(const ComputedGridTemplateAreas&) const { return false; }
};

class ContentData {
  WEBF_DISALLOW_NEW();
 public:
  ContentData() = default;
  static ContentData* CreateDefault() { return nullptr; }
  bool operator==(const ContentData&) const { return true; }
  bool operator!=(const ContentData&) const { return false; }
};

class StyleSVGResource {
  WEBF_DISALLOW_NEW();
 public:
  StyleSVGResource() = default;
  static StyleSVGResource* CreateDefault() { return nullptr; }
  bool operator==(const StyleSVGResource&) const { return true; }
  bool operator!=(const StyleSVGResource&) const { return false; }
};

// ScopedCSSNameList is defined in scoped_css_name.h

class StyleInitialLetter {
  WEBF_DISALLOW_NEW();
 public:
  StyleInitialLetter() = default;
  static StyleInitialLetter None() { return StyleInitialLetter(); }
  bool operator==(const StyleInitialLetter&) const { return true; }
  bool operator!=(const StyleInitialLetter&) const { return false; }
};

class StyleOffsetRotation {
  WEBF_DISALLOW_NEW();
 public:
  StyleOffsetRotation() = default;
  StyleOffsetRotation(float angle, OffsetRotationType type) {}
  static StyleOffsetRotation Auto() { return StyleOffsetRotation(); }
  bool operator==(const StyleOffsetRotation&) const { return true; }
  bool operator!=(const StyleOffsetRotation&) const { return false; }
};

class StyleOverflowClipMargin {
  WEBF_DISALLOW_NEW();
 public:
  StyleOverflowClipMargin() = default;
  static StyleOverflowClipMargin CreateContent() { return StyleOverflowClipMargin(); }
  bool operator==(const StyleOverflowClipMargin&) const { return true; }
  bool operator!=(const StyleOverflowClipMargin&) const { return false; }
};

class TabSize {
  WEBF_DISALLOW_NEW();
 public:
  TabSize() = default;
  TabSize(int value) {}
  static TabSize CreateSpaces(int spaces) { return TabSize(); }
  bool operator==(const TabSize&) const { return true; }
  bool operator!=(const TabSize&) const { return false; }
};

class TextBoxEdge {
  WEBF_DISALLOW_NEW();
 public:
  TextBoxEdge() = default;
  static TextBoxEdge CreateInitial() { return TextBoxEdge(); }
  bool operator==(const TextBoxEdge&) const { return true; }
  bool operator!=(const TextBoxEdge&) const { return false; }
};

class TextDecorationThickness {
  WEBF_DISALLOW_NEW();
 public:
  TextDecorationThickness() = default;
  TextDecorationThickness(const Length& length) {}
  static TextDecorationThickness CreateFromFont() { return TextDecorationThickness(); }
  bool operator==(const TextDecorationThickness&) const { return true; }
  bool operator!=(const TextDecorationThickness&) const { return false; }
};

// TouchAction is defined in core/platform/graphics/touch_action.h

class TransformOperations {
  WEBF_DISALLOW_NEW();
 public:
  TransformOperations() = default;
  static TransformOperations CreateEmpty() { return TransformOperations(); }
  bool operator==(const TransformOperations&) const { return true; }
  bool operator!=(const TransformOperations&) const { return false; }
};

class TransformOrigin {
  WEBF_DISALLOW_NEW();
 public:
  TransformOrigin() = default;
  TransformOrigin(const Length& x, const Length& y, float z) {}
  static TransformOrigin CreateInitial() { return TransformOrigin(); }
  bool operator==(const TransformOrigin&) const { return true; }
  bool operator!=(const TransformOrigin&) const { return false; }
};

enum class PageOrientation {
  kUpright,
  kRotateLeft,
  kRotateRight
};

// Helper functions for enum values
inline TransformOperations EmptyTransformOperations() {
  return TransformOperations::CreateEmpty();
}

// Constants for RespectImageOrientation  
constexpr RespectImageOrientationEnum kRespectImageOrientation = RespectImageOrientationEnum::kNone;

// Transform operation classes
class RotateTransformOperation {
  WEBF_DISALLOW_NEW();
 public:
  RotateTransformOperation() = default;
  static RotateTransformOperation* CreateDefault() { return nullptr; }
  bool operator==(const RotateTransformOperation&) const { return true; }
  bool operator!=(const RotateTransformOperation&) const { return false; }
};

class ScaleTransformOperation {
  WEBF_DISALLOW_NEW();
 public:
  ScaleTransformOperation() = default;
  static ScaleTransformOperation* CreateDefault() { return nullptr; }
  bool operator==(const ScaleTransformOperation&) const { return true; }
  bool operator!=(const ScaleTransformOperation&) const { return false; }
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_STYLE_STUBS_H_