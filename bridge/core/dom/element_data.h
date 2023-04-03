/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_ELEMENT_DATA_H_
#define WEBF_CORE_DOM_ELEMENT_DATA_H_

#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "bindings/qjs/cppgc/member.h"
#include "dom_token_list.h"

namespace webf {

class ElementData {
 public:
  void CopyWith(ElementData* other);
  void Trace(GCVisitor* visitor) const;

  DOMTokenList* GetClassList() const;
  void SetClassList(DOMTokenList* dom_token_lists);

 private:
  Member<DOMTokenList> class_lists_;
  AtomicString class_;
};

}  // namespace webf

#endif  // WEBF_CORE_DOM_ELEMENT_DATA_H_
