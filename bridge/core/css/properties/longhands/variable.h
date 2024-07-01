//
// Created by 谢作兵 on 21/06/24.
//

#ifndef WEBF_VARIABLE_H
#define WEBF_VARIABLE_H

#include "core/css/properties/longhand.h"
#include "core/executing_context.h"

namespace webf {


// TODO(https://crbug.com/980160): Remove this class when the static Variable
// instance (as returned by GetCSSPropertyVariable()) has been removed.
class Variable : public Longhand {
 public:
  constexpr Variable() : Variable(true) {}

  bool IsAffectedByAll() const override { return false; }
  CSSPropertyName GetCSSPropertyName() const override {
    assert_m(false, "NOTREACHED_IN_MIGRATION");
    return CSSPropertyName(built_in_string::kempty_string);
  }
  const char* GetPropertyName() const override { return "variable"; }
  const AtomicString& GetPropertyNameAtomicString() const override {
    // TODO(xiezuobing):
    ExecutingContext* context;
    static const AtomicString name = AtomicString(context->ctx(), "variable");
    return name;
  }

  static bool IsStaticInstance(const CSSProperty&);

 protected:
  explicit constexpr Variable(CSSProperty::Flags flags)
      : Longhand(CSSPropertyID::kVariable,
                 kProperty | kValidForFirstLetter | kValidForFirstLine |
                     kValidForMarker | kValidForHighlightLegacy |
                     kValidForHighlight | flags,
                 '\0') {}
};

}  // namespace webf

#endif  // WEBF_VARIABLE_H
