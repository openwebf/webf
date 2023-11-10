#ifndef WEBF_CORE_DOM_STATIC_NODE_LIST_H_
#define WEBF_CORE_DOM_STATIC_NODE_LIST_H_

#include "bindings/qjs/cppgc/gc_visitor.h"
#include "node_list.h"

namespace webf {

class StaticNodeList final : public NodeList {
 public:
  static StaticNodeList* Adopt(JSContext* ctx, std::vector<Member<Node>>& nodes);

  explicit StaticNodeList(JSContext* ctx): NodeList(ctx) {};
  ~StaticNodeList() override;

  unsigned length() const override;
  Node* item(unsigned index, ExceptionState& exception_state) const override;

  void Trace(GCVisitor*) const override;

  bool NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) override;
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) override;

 private:
  std::vector<Member<Node>> nodes_;
};

}

#endif  // WEBF_CORE_DOM_STATIC_NODE_LIST_H_
