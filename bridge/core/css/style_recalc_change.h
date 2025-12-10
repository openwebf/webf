// Copyright 2021 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.
//
// Copyright (C) 2022-present The WebF authors. All rights reserved.
//
// This is a deliberately trimmed-down adaptation of Blink's
// StyleRecalcChange (see blink_source/renderer/core/css/style_recalc_change.h).
//
// It keeps the public API and flag semantics that StyleEngine and future
// callers rely on (e.g. ForceRecalcChildren / ForceRecalcDescendants), but
// omits container-query specific behavior and other advanced bits that
// depend on Blink-only types. Those can be filled in incrementally as we
// port more of Blink's style engine.

#ifndef WEBF_CORE_CSS_STYLE_RECALC_CHANGE_H_
#define WEBF_CORE_CSS_STYLE_RECALC_CHANGE_H_

namespace webf {

class StyleRecalcChange {
 public:
  // To what extent do we need to update style for children.
  enum Propagate {
    // No need to update style of any children.
    kNo,
    // Need to update existence and style for pseudo elements.
    kUpdatePseudoElements,
    // Need to recalculate style for children for inheritance. All changed
    // inherited properties can be propagated instead of a full rule matching.
    kIndependentInherit,
    // Need to recalculate style for children, typically for inheritance.
    kRecalcChildren,
    // Need to recalculate style for all descendants.
    kRecalcDescendants,
  };

  StyleRecalcChange() = default;
  StyleRecalcChange(const StyleRecalcChange&) = default;
  StyleRecalcChange& operator=(const StyleRecalcChange&) = default;
  explicit StyleRecalcChange(Propagate propagate) : propagate_(propagate) {}

  // Returns true when there is no requested propagation and no flags.
  bool IsEmpty() const { return !propagate_ && !flags_; }

  // Force a full subtree recalc.
  StyleRecalcChange ForceRecalcDescendants() const {
    return {kRecalcDescendants, flags_};
  }

  // Force recalc of direct children. This is weaker than ForceRecalcDescendants
  // in Blink (where container-query flags may add more work), but the basic
  // propagate semantics are preserved.
  StyleRecalcChange ForceRecalcChildren() const {
    return {kRecalcChildren, flags_};
  }

  // Force layout-tree reattachment in addition to any recalc work.
  StyleRecalcChange ForceReattachLayoutTree() const {
    return {propagate_, static_cast<Flags>(flags_ | kReattach)};
  }

  // Combine two changes by taking the stronger propagate level and OR-ing
  // all flags.
  StyleRecalcChange Combine(const StyleRecalcChange& other) const {
    return {static_cast<Propagate>(propagate_ > other.propagate_ ? propagate_
                                                                 : other.propagate_),
            static_cast<Flags>(flags_ | other.flags_)};
  }

  bool RecalcChildren() const { return propagate_ > kUpdatePseudoElements; }
  bool RecalcDescendants() const { return propagate_ == kRecalcDescendants; }

  bool UpdatePseudoElements() const { return propagate_ != kNo; }

  bool ReattachLayoutTree() const { return flags_ & kReattach; }

  // Mirrors Blink's StyleRecalcChange::SuppressRecalc() but without the
  // container-query specific behavior. We expose this so callers can request
  // that a "root" element itself is skipped while still forcing work in its
  // descendants.
  StyleRecalcChange SuppressRecalc() const {
    return {propagate_, static_cast<Flags>(flags_ | kSuppressRecalc)};
  }

  bool IsSuppressed() const { return flags_ & kSuppressRecalc; }

 private:
  enum Flag : unsigned {
    kNoFlags = 0,
    // If set, need to reattach layout tree.
    kReattach = 1 << 0,
    // If set, prevent style recalc for the node passed to
    // ShouldRecalcStyleFor (used in Blink to skip the query container
    // itself during interleaved recalc). We expose the flag so that
    // callers can still request suppression, even though we don't yet
    // implement full ShouldRecalcStyleFor().
    kSuppressRecalc = 1 << 1,
  };

  using Flags = unsigned;

  StyleRecalcChange(Propagate propagate, Flags flags)
      : propagate_(propagate), flags_(flags) {}

  Propagate propagate_ = kNo;
  Flags flags_ = kNoFlags;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_RECALC_CHANGE_H_

