/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_HTML_ALL_COLLECTION_H_
#define BRIDGE_CORE_HTML_HTML_ALL_COLLECTION_H_

#include "html_collection.h"

namespace webf {

class ContainerNode;

class HTMLAllCollection : public HTMLCollection {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLAllCollection*;
  HTMLAllCollection(ContainerNode* base, CollectionType);

 private:
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_ALL_COLLECTION_H_
