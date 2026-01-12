/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_option_element.h"

#include "core/html/collection_type.h"
#include "core/html/html_collection.h"

namespace webf {

namespace {

static const AtomicString& SelectTagName() {
  static const AtomicString kSelect = AtomicString::CreateFromUTF8("select");
  return kSelect;
}
static const AtomicString& OptionTagName() {
  static const AtomicString kOption = AtomicString::CreateFromUTF8("option");
  return kOption;
}
static const AtomicString& MultipleAttrName() {
  static const AtomicString kMultiple = AtomicString::CreateFromUTF8("multiple");
  return kMultiple;
}
static const AtomicString& ValueAttrName() {
  static const AtomicString kValue = AtomicString::CreateFromUTF8("value");
  return kValue;
}
static const AtomicString& SelectedAttrName() {
  static const AtomicString kSelected = AtomicString::CreateFromUTF8("selected");
  return kSelected;
}
static const AtomicString& DisabledAttrName() {
  static const AtomicString kDisabled = AtomicString::CreateFromUTF8("disabled");
  return kDisabled;
}

static Element* FindSelectAncestor(Element* element) {
  for (Element* current = element ? element->parentElement() : nullptr; current; current = current->parentElement()) {
    if (current->HasTagName(SelectTagName())) {
      return current;
    }
  }
  return nullptr;
}

static bool IsMultipleSelect(Element& select, ExceptionState& exception_state) {
  return select.hasAttribute(MultipleAttrName(), exception_state);
}

static void ClearOtherSelectedOptions(Element& select, Element& selected_option, ExceptionState& exception_state) {
  auto* options = MakeGarbageCollected<HTMLCollection>(static_cast<ContainerNode&>(select), CollectionType::kSelectOptions);
  const unsigned len = options->length();
  for (unsigned i = 0; i < len; i++) {
    Element* option = options->item(i, exception_state);
    if (exception_state.HasException() || option == nullptr) {
      return;
    }
    if (!option->HasTagName(OptionTagName()) || option == &selected_option) {
      continue;
    }
    option->removeAttribute(SelectedAttrName(), exception_state);
    if (exception_state.HasException()) {
      return;
    }
  }
}

}  // namespace

HTMLOptionElement::HTMLOptionElement(Document& document) : HTMLElement(OptionTagName(), &document) {}

AtomicString HTMLOptionElement::value() {
  ExceptionState exception_state;
  const bool has_value_attr = hasAttribute(ValueAttrName(), exception_state);
  if (exception_state.HasException()) {
    return AtomicString::Empty();
  }
  if (has_value_attr) {
    return getAttribute(ValueAttrName(), exception_state);
  }
  return TextFromChildren();
}

void HTMLOptionElement::setValue(const AtomicString& value, ExceptionState& exception_state) {
  setAttribute(ValueAttrName(), value, exception_state);
}

bool HTMLOptionElement::selected() {
  ExceptionState exception_state;
  return hasAttribute(SelectedAttrName(), exception_state);
}

void HTMLOptionElement::setSelected(bool selected, ExceptionState& exception_state) {
  if (selected) {
    setAttribute(SelectedAttrName(), SelectedAttrName(), exception_state);
    if (exception_state.HasException()) {
      return;
    }
    Element* select = FindSelectAncestor(this);
    if (select == nullptr) {
      return;
    }
    if (!IsMultipleSelect(*select, exception_state)) {
      if (exception_state.HasException()) {
        return;
      }
      ClearOtherSelectedOptions(*select, *this, exception_state);
    }
    return;
  }
  removeAttribute(SelectedAttrName(), exception_state);
}

bool HTMLOptionElement::defaultSelected() {
  return selected();
}

void HTMLOptionElement::setDefaultSelected(bool selected, ExceptionState& exception_state) {
  setSelected(selected, exception_state);
}

bool HTMLOptionElement::disabled() {
  ExceptionState exception_state;
  return hasAttribute(DisabledAttrName(), exception_state);
}

void HTMLOptionElement::setDisabled(bool disabled, ExceptionState& exception_state) {
  if (disabled) {
    setAttribute(DisabledAttrName(), DisabledAttrName(), exception_state);
    return;
  }
  removeAttribute(DisabledAttrName(), exception_state);
}

}  // namespace webf

