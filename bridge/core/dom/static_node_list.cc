#include "static_node_list.h"

namespace webf {

StaticNodeList* StaticNodeList::Adopt(JSContext* ctx, std::vector<Member<Node>>& nodes) {
  auto* node_list = MakeGarbageCollected<StaticNodeList>(ctx);
  swap(node_list->nodes_, nodes);
  return node_list;
}

StaticNodeList::~StaticNodeList() = default;

unsigned StaticNodeList::length() const {
  return nodes_.size();
}

Node* StaticNodeList::item(unsigned index, ExceptionState& exception_state) const {
  if (index < nodes_.size())
    return nodes_[index].Get();
  return nullptr;
}

void StaticNodeList::Trace(GCVisitor* visitor) const {
  for(auto& entry : nodes_) {
    visitor->TraceMember(entry);
  }

  NodeList::Trace(visitor);
}

void StaticNodeList::NamedPropertyEnumerator(std::vector<AtomicString>& names, webf::ExceptionState& exception_state) {
  for (int i = 0; i < nodes_.size(); i ++) {
    names.emplace_back(AtomicString(ctx(), std::to_string(i)));
  }
}

bool StaticNodeList::NamedPropertyQuery(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  std::string str = key.ToStdString(ctx());
  int number = std::stoi(str);
  if (number >= nodes_.size()) {
    return false;
  }

  return nodes_[number];
}

}