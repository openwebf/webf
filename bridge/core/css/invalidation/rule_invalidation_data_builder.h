// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_CORE_CSS_INVALIDATION_RULE_INVALIDATION_DATA_BUILDER_H_
#define WEBF_CORE_CSS_INVALIDATION_RULE_INVALIDATION_DATA_BUILDER_H_

#include "core/css/invalidation/rule_invalidation_data_visitor.h"

namespace webf {

class RuleInvalidationDataBuilder
    : public RuleInvalidationDataVisitor<
          RuleInvalidationDataVisitorType::kBuilder> {
public:
  explicit RuleInvalidationDataBuilder(RuleInvalidationData&);

  void Merge(const RuleInvalidationData& other);

protected:
  // Adds an InvalidationSet to this RuleFeatureSet, combining with any
  // data that may already be there. (That data may come from a previous
  // call to EnsureInvalidationSet(), or from another MergeInvalidationSet().)
  //
  // Copy-on-write is used to get correct merging in face of shared
  // InvalidationSets between keys; see comments on
  // EnsureMutableInvalidationSet() for more details.
  void MergeInvalidationSet(RuleInvalidationData::InvalidationSetMap&,
                            const std::string& key,
                            std::shared_ptr<InvalidationSet>);
  void MergeInvalidationSet(RuleInvalidationData::PseudoTypeInvalidationSetMap&,
                            CSSSelector::PseudoType key,
                            std::shared_ptr<InvalidationSet>);
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_INVALIDATION_RULE_INVALIDATION_DATA_BUILDER_H_