//
// Created by 谢作兵 on 12/06/24.
//

#include "css_lazy_parsing_state.h"
#include "css_parser_context.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

CSSLazyParsingState::CSSLazyParsingState(std::shared_ptr<const CSSParserContext> context,
                                         const AtomicString& sheet_text,
                                         std::shared_ptr<StyleSheetContents> contents)
    : context_(context),
      sheet_text_(sheet_text),
      owning_contents_(contents) {}


void CSSLazyParsingState::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(document_);
}

}  // namespace webf