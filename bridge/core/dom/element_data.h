/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_ELEMENT_DATA_H_
#define WEBF_CORE_DOM_ELEMENT_DATA_H_

#include "bindings/qjs/atomic_string.h"

namespace webf {

class ElementData {
 public:
  const AtomicString& Id() const { return id_; }
  AtomicString SetId(AtomicString new_id) const { return std::exchange(id_, std::move(new_id)); }
  bool HasID() const { return !id_.IsNull(); }

  void CopyWith(ElementData* other);

 private:
  mutable AtomicString id_;
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_ELEMENT_DATA_H_
