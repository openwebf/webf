#ifndef BRIDGE_CORE_HTML_HTML_COLLECTION_H_
#define BRIDGE_CORE_HTML_HTML_COLLECTION_H_

#include "bindings/qjs/heap_hashmap.h"
#include "bindings/qjs/heap_vector.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/dom/collection_items_cache.h"
#include "core/dom/live_node_list_base.h"

namespace webf {

class HTMLCollection : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  HTMLCollection(ContainerNode* base, CollectionType);

  // DOM API
  unsigned length() const;
  Element* item(unsigned offset, ExceptionState& exception_state) const;
  bool NamedPropertyQuery(const AtomicString&, ExceptionState&);
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&);

  void Trace(GCVisitor*) const override;

 private:
  Member<ContainerNode> base_;
  std::vector<Element*> nodes_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_HTML_COLLECTION_H_
