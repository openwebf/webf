//
// Created by 谢作兵 on 06/06/24.
//

#ifndef WEBF_STYLE_ENGINE_H
#define WEBF_STYLE_ENGINE_H

#include "core/dom/element.h"
#include <unordered_map>
#include "pending_sheet_type.h"
#include "core/platform/text/text_position.h"


namespace webf {

class StyleSheetContents;
class CSSStyleSheet;
class Document;

class StyleEngine final  {
 public:
  explicit StyleEngine(Document& document);
  CSSStyleSheet* CreateSheet(Element&,
                             const AtomicString& text,
                             TextPosition start_position);
  Document& GetDocument() const;
  void Trace(GCVisitor * visitor);
  CSSStyleSheet* ParseSheet(Element&,
                            const AtomicString& text,
                            TextPosition start_position);

  void AddPendingBlockingSheet(Node& style_sheet_candidate_node,
                               PendingSheetType type);

 private:
  Member<Document> document_;
  std::unordered_map<AtomicString, std::shared_ptr<StyleSheetContents>, AtomicString::KeyHasher> text_to_sheet_cache_;
  AtomicString preferred_stylesheet_set_name_;

  // Tracks the number of currently loading top-level stylesheets. Sheets loaded
  // using the @import directive are not included in this count. We use this
  // count of pending sheets to detect when it is safe to execute scripts
  // (parser-inserted scripts may not run until all pending stylesheets have
  // loaded). See:
  // https://html.spec.whatwg.org/multipage/semantics.html#interactions-of-styling-and-scripting
  int pending_script_blocking_stylesheets_{0};
};

}  // namespace webf

#endif  // WEBF_STYLE_ENGINE_H
