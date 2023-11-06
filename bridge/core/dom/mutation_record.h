/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_DOM_MUTATION_RECORD_H_
#define WEBF_CORE_DOM_MUTATION_RECORD_H_

#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/cppgc/member.h"

namespace webf {

class Node;
class StaticNodeList;

class MutationRecord : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();
 public:
  using ImplType = MutationRecord*;
  static MutationRecord* CreateChildList(Node* target,
                                         StaticNodeList* added,
                                         StaticNodeList* removed,
                                         Node* previous_sibling,
                                         Node* next_sibling);
  static MutationRecord* CreateAttributes(Node* target,
                                          const AtomicString& new_value,
                                          const AtomicString& old_value);
  static MutationRecord* CreateCharacterData(Node* target,
                                             const AtomicString& old_value);
  static MutationRecord* CreateWithNullOldValue(MutationRecord*);

  MutationRecord() = delete;
  MutationRecord(JSContext* ctx);

  ~MutationRecord() override;

  virtual const AtomicString& type() = 0;
  virtual Node* target() = 0;

  virtual StaticNodeList* addedNodes() = 0;
  virtual StaticNodeList* removedNodes() = 0;
  virtual Node* previousSibling() { return nullptr; }
  virtual Node* nextSibling() { return nullptr; }

  virtual const AtomicString attributeName() { return AtomicString::Null(); }
  virtual const AtomicString attributeNamespace() { return AtomicString::Null(); }

  virtual AtomicString oldValue() { return AtomicString::Empty(); }

 private:
};

}

#endif  // WEBF_CORE_DOM_MUTATION_RECORD_H_
