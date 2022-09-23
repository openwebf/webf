/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_EMPTY_NODE_LIST_H_
#define BRIDGE_CORE_DOM_EMPTY_NODE_LIST_H_

#include <vector>
#include "node_list.h"

namespace webf {

class ExceptionState;
class AtomicString;

class EmptyNodeList : public NodeList {
 public:
  explicit EmptyNodeList(Node* root_node);

  Node& OwnerNode() const { return *owner_; }
  void Trace(GCVisitor* visitor) const override;

 private:
  unsigned length() const override { return 0; }
  Node* item(unsigned, ExceptionState& exception_state) const override { return nullptr; }
  bool NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) override;
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) override;

  bool IsEmptyNodeList() const override { return true; }
  Node* VirtualOwnerNode() const override;

  Node* owner_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_EMPTY_NODE_LIST_H_
