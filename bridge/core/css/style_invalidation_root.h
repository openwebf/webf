// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_STYLE_INVALIDATION_ROOT_H_
#define WEBF_CORE_CSS_STYLE_INVALIDATION_ROOT_H_

#include "core/css/style_traversal_root.h"

namespace webf {

class StyleInvalidationRoot : public StyleTraversalRoot {
  WEBF_DISALLOW_NEW();

 public:
  Element* RootElement() const;
  void SubtreeModified(ContainerNode& parent) final;

 private:
/*
 #if DCHECK_IS_ON()
  ContainerNode* Parent(const Node& node) const final;
  bool IsChildDirty(const Node& node) const final;
#endif  // DCHECK_IS_ON()
*/
  bool IsDirty(const Node& node) const final;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_STYLE_INVALIDATION_ROOT_H_