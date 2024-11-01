// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CONTAINER_SELECTOR_H_
#define WEBF_CORE_CSS_CONTAINER_SELECTOR_H_

#include "core/layout/geometry/axis.h"
#include "core/css/media_query_exp.h"
#include "core/base/hash/hash.h"
#include "core/platform/hash_functions.h"

namespace webf {

class Element;

// Not to be confused with regular selectors. This refers to container
// selection by e.g. a given name, or by implicit container selection
// according to the queried features.
//
// https://drafts.csswg.org/css-contain-3/#container-rule
class ContainerSelector {
 public:
  ContainerSelector() = default;
  explicit ContainerSelector(PhysicalAxes physical_axes)
      : physical_axes_(physical_axes) {}
  ContainerSelector(const std::string& name,
                    PhysicalAxes physical_axes,
                    LogicalAxes logical_axes)
      : name_(std::move(name)),
        physical_axes_(physical_axes),
        logical_axes_(logical_axes) {}
  ContainerSelector(const std::string&  name, const MediaQueryExpNode&);

  bool operator==(const ContainerSelector& o) const {
    return (name_ == o.name_) && (physical_axes_ == o.physical_axes_) &&
           (logical_axes_ == o.logical_axes_) &&
           (has_style_query_ == o.has_style_query_) &&
           (has_sticky_query_ == o.has_sticky_query_) &&
           (has_snap_query_ == o.has_snap_query_);
  }
  bool operator!=(const ContainerSelector& o) const { return !(*this == o); }

  unsigned GetHash() const;

  const std::string& Name() const { return name_; }

  // Given the specified writing mode, return the EContainerTypes required
  // for this selector to match.
  unsigned Type(WritingMode) const;

  bool SelectsSizeContainers() const {
    return physical_axes_ != kPhysicalAxesNone ||
           logical_axes_ != kLogicalAxesNone;
  }

  bool SelectsStyleContainers() const { return has_style_query_; }
  bool SelectsStickyContainers() const { return has_sticky_query_; }
  bool SelectsSnapContainers() const { return has_snap_query_; }
  bool SelectsStateContainers() const {
    return SelectsStickyContainers() || SelectsSnapContainers();
  }
  bool HasUnknownFeature() const { return has_unknown_feature_; }

  PhysicalAxes GetPhysicalAxes() const { return physical_axes_; }
  LogicalAxes GetLogicalAxes() const { return logical_axes_; }

 private:
  std::string name_;
  PhysicalAxes physical_axes_{kPhysicalAxesNone};
  LogicalAxes logical_axes_{kLogicalAxesNone};
  bool has_style_query_{false};
  bool has_sticky_query_{false};
  bool has_snap_query_{false};
  bool has_unknown_feature_{false};
};


class ScopedContainerSelector {
 public:
  ScopedContainerSelector(ContainerSelector selector,
                          const TreeScope* tree_scope)
      : selector_(selector), tree_scope_(tree_scope) {}

  unsigned GetHash() const {
    unsigned hash = selector_.GetHash();
    AddIntToHash(hash, reinterpret_cast<uint64_t>(tree_scope_));
    return hash;
  }

  bool operator==(const ScopedContainerSelector& other) const {
    return selector_ == other.selector_ && tree_scope_ == other.tree_scope_;
  }

  void Trace(GCVisitor* visitor) const;

 private:
  ContainerSelector selector_;
  const TreeScope* tree_scope_;
};


}

#endif  // WEBF_CORE_CSS_CONTAINER_SELECTOR_H_
