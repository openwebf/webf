//
// Created by 谢作兵 on 07/06/24.
//

#include "css_parser_context.h"
#include "core/dom/document.h"
#include "core/css/style_sheet_contents.h"

namespace webf {


CSSParserContext::CSSParserContext(
    const Document& document,
    const AtomicString& base_url_override,
//    bool origin_clean,
//    const Referrer& referrer,
    const AtomicString& charset)
    : CSSParserContext(
          base_url_override,
          charset,
          kHTMLStandardMode,
          &document) {}

CSSParserContext::CSSParserContext(const AtomicString& base_url,
                                   //                   bool origin_clean,
                                   const AtomicString& charset,
                                   CSSParserMode mode,
                                   //                   const Referrer& referrer,
                                   //                   bool is_html_document,
                                   //                   SecureContextMode,
                                   //                   const DOMWrapperWorld* world,
                                   const Document* use_counter_document
                                   //                   ResourceFetchRestriction resource_fetch_restriction
):base_url_(base_url), charset_(charset), mode_(mode), document_(use_counter_document) {}


CSSParserContext::CSSParserContext(
    const CSSParserContext* other,
    const StyleSheetContents* style_sheet_contents)
    : CSSParserContext(
          other,
          StyleSheetContents::SingleOwnerDocument(style_sheet_contents)) {}


CSSParserContext::CSSParserContext(const CSSParserContext* other,
                                   const Document* use_counter_document)
    : CSSParserContext(other->base_url_,
                       other->charset_,
                       other->mode_,
                       use_counter_document) {
}


CSSParserContext::CSSParserContext(CSSParserMode mode,
                                   SecureContextMode secure_context_mode,
                                   const Document* use_counter_document)
    : CSSParserContext(AtomicString(),
                       AtomicString(),
                       mode,
                       use_counter_document) {}


ExecutingContext* CSSParserContext::GetExecutingContext() const {
  return (document_.Get()) ? document_.Get()->GetExecutingContext() : nullptr;
}

const Document* CSSParserContext::GetDocument() const {
  return document_.Get();
}

bool CSSParserContext::IsForMarkupSanitization() const {
  return document_ && document_->IsForMarkupSanitization();
}

// TODO(xiezuobing): secure_context_mode其中这个参数没什么用
std::shared_ptr<const CSSParserContext> StrictCSSParserContext(
    SecureContextMode secure_context_mode) {
  //
  static std::shared_ptr<CSSParserContext> strict_context_pool;

  if(!strict_context_pool) {
    strict_context_pool = std::make_shared<CSSParserContext>(kHTMLStandardMode, secure_context_mode);
  }

  return strict_context_pool;
}

}  // namespace webf