/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_optgroup_element.h"

namespace webf {

namespace {

static const AtomicString& OptGroupTagName() {
  static const AtomicString kOptGroup = AtomicString::CreateFromUTF8("optgroup");
  return kOptGroup;
}

static const AtomicString& DisabledAttrName() {
  static const AtomicString kDisabled = AtomicString::CreateFromUTF8("disabled");
  return kDisabled;
}

}  // namespace

HTMLOptgroupElement::HTMLOptgroupElement(Document& document) : HTMLElement(OptGroupTagName(), &document) {}

bool HTMLOptgroupElement::disabled() const {
  ExceptionState exception_state;
  return hasAttribute(DisabledAttrName(), exception_state);
}

void HTMLOptgroupElement::setDisabled(bool disabled, ExceptionState& exception_state) {
  if (disabled) {
    setAttribute(DisabledAttrName(), DisabledAttrName(), exception_state);
    return;
  }
  removeAttribute(DisabledAttrName(), exception_state);
}

}  // namespace webf
