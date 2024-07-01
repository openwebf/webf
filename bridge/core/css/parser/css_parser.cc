//
// Created by 谢作兵 on 12/06/24.
//

#include "css_parser.h"
#include "css_parser_impl.h"

namespace webf {

ParseSheetResult CSSParser::ParseSheet(
    std::shared_ptr<const CSSParserContext> context,
    std::shared_ptr<StyleSheetContents> style_sheet,
    const AtomicString& text,
    CSSDeferPropertyParsing defer_property_parsing,
    bool allow_import_rules) {
  return CSSParserImpl::ParseStyleSheet(
      text, std::move(context), std::move(style_sheet), defer_property_parsing, allow_import_rules);
}

}  // namespace webf