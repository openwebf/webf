// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_ANCHOR_EVALUATOR_H_
#define WEBF_CORE_CSS_ANCHOR_EVALUATOR_H_

#include <optional>

#include "foundation/macros.h"
#include "core/css/css_anchor_query_enums.h"
#include "css_property_names.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/style/inset_area.h"
#include "core/geometry/layout_unit.h"

namespace webf {

class AnchorQuery;
class AnchorScope;
class ScopedCSSName;

class AnchorEvaluator {
  WEBF_DISALLOW_NEW();

 public:
  AnchorEvaluator() = default;

  // The evaluation of anchor() and anchor-size() functions is affected
  // by the context they are used in. For example, it is not allowed to
  // do anchor() queries "cross-axis" (e.g. left:anchor(--a top)),
  // and anchor-size() queries are only valid in sizing properties.
  // Queries that violate these rules instead resolve to their fallback
  // values (or 0px if no fallback value exists).
  //
  // The default mode of AnchorEvaluator (kNone) is to return nullopt (i.e.
  // fallback) for any query. This represents a context where no anchor query
  // is valid, e.g. a property unrelated to insets or sizing.
  //
  // The values kLeft, kRight, kTop and kBottom represent the corresponding
  // inset properties, and allow anchor() queries [1] (with restrictions),
  // but not anchor-size() queries.
  //
  // The value kSize represents supported sizing properties [2], and allows
  // anchor-size(), but not anchor().
  //
  // The current mode can be set by placing an AnchorScope object on the
  // stack.
  //
  // [1] https://drafts.csswg.org/css-anchor-position-1/#anchor-valid
  // [2] https://drafts.csswg.org/css-anchor-position-1/#anchor-size-valid
  enum class Mode {
    kNone,

    // anchor()
    kLeft,
    kRight,
    kTop,
    kBottom,

    // anchor-size()
    kSize
  };

  // Evaluates an anchor() or anchor-size() query.
  // Returns |nullopt| if the query is invalid (e.g., no targets or wrong
  // axis.), in which case the fallback should be used.
  virtual std::optional<LayoutUnit> Evaluate(
      const AnchorQuery&,
      const ScopedCSSName* position_anchor,
      const std::optional<InsetAreaOffsets>&) = 0;

  virtual void Trace(GCVisitor*) const {}

 protected:
  Mode GetMode() const { return mode_; }

 private:
  friend class AnchorScope;

  // The computed position-anchor in use for the current try option.
  Mode mode_ = Mode::kNone;
};

// Temporarily sets the Mode of an AnchorEvaluator.
//
// This class behaves like base::AutoReset, except it allows `anchor_evalutor`
// to be nullptr (in which case the AnchorScope has no effect).
//
// See AnchorEvaluator::Mode for more information.
class AnchorScope {
  WEBF_STACK_ALLOCATED();

 public:
  using Mode = AnchorEvaluator::Mode;

  explicit AnchorScope(Mode mode, AnchorEvaluator* anchor_evaluator)
      : target_(anchor_evaluator ? &anchor_evaluator->mode_ : nullptr),
        original_(anchor_evaluator ? anchor_evaluator->mode_ : Mode::kNone) {
    if (target_) {
      *target_ = mode;
    }
  }
  ~AnchorScope() {
    if (target_) {
      *target_ = original_;
    }
  }

 private:

  static Mode PropertyMode(CSSPropertyID property) {
    switch (property) {
      case CSSPropertyID::kTop:
        return Mode::kTop;
      case CSSPropertyID::kRight:
        return Mode::kRight;
      case CSSPropertyID::kBottom:
        return Mode::kBottom;
      case CSSPropertyID::kLeft:
        return Mode::kLeft;
      case CSSPropertyID::kWidth:
      case CSSPropertyID::kHeight:
      case CSSPropertyID::kMinWidth:
      case CSSPropertyID::kMinHeight:
      case CSSPropertyID::kMaxWidth:
      case CSSPropertyID::kMaxHeight:
        return Mode::kSize;
      default:
        return Mode::kNone;
    }
  }

  Mode* target_;
  Mode original_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_ANCHOR_EVALUATOR_H_