// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_CONTAINER_QUERY_H_
#define WEBF_CORE_CSS_CONTAINER_QUERY_H_

#include "core/css/container_selector.h"

namespace webf {

class ContainerQuery final {
 public:
  ContainerQuery(ContainerSelector, std::shared_ptr<const MediaQueryExpNode> query);
  ContainerQuery(const ContainerQuery&);

  const ContainerSelector& Selector() const { return selector_; }
  const ContainerQuery* Parent() const { return parent_.get(); }

  std::shared_ptr<ContainerQuery> CopyWithParent(std::shared_ptr<const ContainerQuery>) const;

  std::string ToString() const;

 private:
  friend class ContainerQueryTest;
  friend class ContainerQueryEvaluator;
  friend class CSSContainerRule;
  friend class StyleRuleContainer;

  const MediaQueryExpNode& Query() const { return *query_; }

  ContainerSelector selector_;
  std::shared_ptr<const MediaQueryExpNode> query_;
  std::shared_ptr<const ContainerQuery> parent_;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_CONTAINER_QUERY_H_
