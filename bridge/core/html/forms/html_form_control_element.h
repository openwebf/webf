/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Stub for HTMLFormControlElement - WebF doesn't have this yet
#ifndef WEBF_CORE_HTML_FORMS_HTML_FORM_CONTROL_ELEMENT_H_
#define WEBF_CORE_HTML_FORMS_HTML_FORM_CONTROL_ELEMENT_H_

#include "core/html/html_element.h"
#include "foundation/casting.h"

namespace webf {

// Stub class for form control elements
class HTMLFormControlElement : public HTMLElement {
 public:
  using HTMLElement::HTMLElement;
  
  // Stub methods for autofill
  bool IsAutofilled() const { return false; }
  bool IsPreviewed() const { return false; }
  int GetAutofillState() const { return 0; }
};

// Stub for WebAutofillState
namespace WebAutofillState {
  constexpr int kPreviewed = 1;
}

}  // namespace webf

// Downcast traits for HTMLFormControlElement
template <>
struct webf::DowncastTraits<webf::HTMLFormControlElement> {
  static bool AllowFrom(const webf::Node& node) {
    // For now, return false since we don't have actual form control elements
    return false;
  }
  static bool AllowFrom(const webf::Element& element) {
    // For now, return false since we don't have actual form control elements
    return false;
  }
};

#endif  // WEBF_CORE_HTML_FORMS_HTML_FORM_CONTROL_ELEMENT_H_