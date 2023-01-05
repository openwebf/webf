/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_DOCUMENT_FRAGMENT_H
#define BRIDGE_DOCUMENT_FRAGMENT_H

#include "container_node.h"

namespace webf {

class DocumentFragment : public ContainerNode {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static DocumentFragment* Create(Document& document);
  static DocumentFragment* Create(ExecutingContext* context, ExceptionState& exception_state);

  DocumentFragment(Document* document, ConstructionType type);
  ~DocumentFragment() override{};

  virtual bool IsTemplateContent() const { return false; }

  // This will catch anyone doing an unnecessary check.
  bool IsDocumentFragment() const = delete;

  AtomicString nodeValue() const override;

 protected:
  std::string nodeName() const final;

 private:
  NodeType nodeType() const final;
  Node* Clone(Document&, CloneChildrenFlag) const override;
  bool ChildTypeAllowed(NodeType) const override;
};

template <>
struct DowncastTraits<DocumentFragment> {
  static bool AllowFrom(const Node& node) { return node.IsDocumentFragment(); }
};

}  // namespace webf

#endif  // BRIDGE_DOCUMENT_FRAGMENT_H
