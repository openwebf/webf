/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_all_collection.h"

namespace webf {

HTMLAllCollection::HTMLAllCollection(ContainerNode* base, CollectionType type) : HTMLCollection(*base, type) {}

}  // namespace webf