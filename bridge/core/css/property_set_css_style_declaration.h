//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_PROPERTY_SET_CSS_STYLE_DECLARATION_H
#define WEBF_PROPERTY_SET_CSS_STYLE_DECLARATION_H

#include "core/css/abstract_property_set_css_style_declaration.h"
#include "core/executing_context.h"
#include "core/css/css_property_value_set.h"

namespace webf {

class MutableCSSPropertyValueSet;

class PropertySetCSSStyleDeclaration
    : public AbstractPropertySetCSSStyleDeclaration {
 public:
  PropertySetCSSStyleDeclaration(ExecutingContext* execution_context,
                                 std::shared_ptr<MutableCSSPropertyValueSet> property_set)
      : AbstractPropertySetCSSStyleDeclaration(execution_context),
        property_set_(std::move(property_set)) {}

  bool IsPropertyValid(CSSPropertyID) const override { return true; }
  void Trace(GCVisitor*) const override;

 protected:
  MutableCSSPropertyValueSet& PropertySet() const final {
    assert(property_set_);
    return *property_set_;
  }

  std::shared_ptr<MutableCSSPropertyValueSet> property_set_;  // Cannot be null
};


}  // namespace webf

#endif  // WEBF_PROPERTY_SET_CSS_STYLE_DECLARATION_H
