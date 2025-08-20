/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "tree_scope.h"
#include "document.h"

namespace webf {

TreeScope::TreeScope(Document& document) : root_node_(&document), document_(&document) {
  root_node_->SetTreeScope(this);
}

}  // namespace webf
