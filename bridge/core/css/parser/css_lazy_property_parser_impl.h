//
// Created by 谢作兵 on 14/06/24.
//

#ifndef WEBF_CSS_LAZY_PROPERTY_PARSER_IMPL_H
#define WEBF_CSS_LAZY_PROPERTY_PARSER_IMPL_H

#include "core/css/css_property_value_set.h"

namespace webf {

class CSSLazyParsingState;

// This class is responsible for lazily parsing a single CSS declaration list.
class CSSLazyPropertyParserImpl : public CSSLazyPropertyParser {
 public:
  CSSLazyPropertyParserImpl(uint32_t offset, std::shared_ptr<CSSLazyParsingState>);

  // CSSLazyPropertyParser:
  CSSPropertyValueSet* ParseProperties() override;

  void Trace(GCVisitor* visitor) const override {
    CSSLazyPropertyParser::Trace(visitor);
  }

 private:
  uint32_t offset_;
  std::shared_ptr<CSSLazyParsingState> lazy_state_;
};

}  // namespace webf

#endif  // WEBF_CSS_LAZY_PROPERTY_PARSER_IMPL_H
