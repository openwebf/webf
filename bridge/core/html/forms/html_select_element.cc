/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_select_element.h"
#include "core/html/html_collection.h"

namespace webf {

namespace {

static const AtomicString& SelectTagName() {
  static const AtomicString kSelect = AtomicString::CreateFromUTF8("select");
  return kSelect;
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

static AtomicString GetOptionValue(Element& option, ExceptionState& exception_state) {
  const bool has_value_attr = option.hasAttribute(ValueAttrName(), exception_state);
  if (exception_state.HasException()) {
    return AtomicString::Null();
  }
  if (has_value_attr) {
    return option.getAttribute(ValueAttrName(), exception_state);
  }
  return option.TextFromChildren();
}

static bool IsOptionDisabled(Element& option, ExceptionState& exception_state) {
  return option.hasAttribute(DisabledAttrName(), exception_state);
}

static void SetOptionSelected(Element& option, bool selected, ExceptionState& exception_state) {
  if (selected) {
    option.setAttribute(SelectedAttrName(), SelectedAttrName());
  } else {
    option.removeAttribute(SelectedAttrName(), exception_state);
  }
}

static Element* FirstSelectedOption(Element& select, ExceptionState& exception_state) {
  auto* options = MakeGarbageCollected<HTMLCollection>(static_cast<ContainerNode&>(select), CollectionType::kSelectOptions);
  const unsigned len = options->length();
  for (unsigned i = 0; i < len; i++) {
    Element* option = options->item(i, exception_state);
    if (exception_state.HasException()) {
      return nullptr;
    }
    if (option == nullptr) {
      continue;
    }
    if (option->hasAttribute(SelectedAttrName(), exception_state)) {
      if (exception_state.HasException()) {
        return nullptr;
      }
      return option;
    }
  }
  return nullptr;
}

static Element* FirstEnabledOption(Element& select, ExceptionState& exception_state) {
  auto* options = MakeGarbageCollected<HTMLCollection>(static_cast<ContainerNode&>(select), CollectionType::kSelectOptions);
  const unsigned len = options->length();
  for (unsigned i = 0; i < len; i++) {
    Element* option = options->item(i, exception_state);
    if (exception_state.HasException()) {
      return nullptr;
    }
    if (option == nullptr) {
      continue;
    }
    if (!IsOptionDisabled(*option, exception_state)) {
      if (exception_state.HasException()) {
        return nullptr;
      }
      return option;
    }
  }
  return nullptr;
}

}  // namespace

HTMLSelectElement::HTMLSelectElement(Document& document) : HTMLElement(SelectTagName(), &document) {}

HTMLCollection* HTMLSelectElement::options() const {
  return MakeGarbageCollected<HTMLCollection>(const_cast<HTMLSelectElement&>(*this), CollectionType::kSelectOptions);
}

AtomicString HTMLSelectElement::value() const {
  ExceptionState exception_state;
  Element* selected = FirstSelectedOption(const_cast<HTMLSelectElement&>(*this), exception_state);
  if (exception_state.HasException() || selected == nullptr) {
    Element* first_enabled = FirstEnabledOption(const_cast<HTMLSelectElement&>(*this), exception_state);
    if (exception_state.HasException() || first_enabled == nullptr) {
      return AtomicString::Empty();
    }
    return GetOptionValue(*first_enabled, exception_state);
  }
  return GetOptionValue(*selected, exception_state);
}

void HTMLSelectElement::setValue(const AtomicString& value, ExceptionState& exception_state) {
  const bool is_multiple = multiple();
  auto* options = MakeGarbageCollected<HTMLCollection>(*this, CollectionType::kSelectOptions);
  const unsigned len = options->length();

  bool matched = false;
  for (unsigned i = 0; i < len; i++) {
    Element* option = options->item(i, exception_state);
    if (exception_state.HasException()) {
      return;
    }
    if (option == nullptr) {
      continue;
    }

    const AtomicString option_value = GetOptionValue(*option, exception_state);
    if (exception_state.HasException()) {
      return;
    }

    const bool should_select = option_value == value;
    matched = matched || should_select;

    if (!is_multiple) {
      SetOptionSelected(*option, should_select, exception_state);
    } else if (should_select) {
      SetOptionSelected(*option, true, exception_state);
    }

    if (exception_state.HasException()) {
      return;
    }
  }

  if (!matched && !is_multiple && len > 0) {
    Element* first = options->item(0, exception_state);
    if (exception_state.HasException()) {
      return;
    }
    if (first != nullptr) {
      SetOptionSelected(*first, true, exception_state);
    }
  }
}

double HTMLSelectElement::selectedIndex() const {
  ExceptionState exception_state;
  auto* options = MakeGarbageCollected<HTMLCollection>(const_cast<HTMLSelectElement&>(*this), CollectionType::kSelectOptions);
  const unsigned len = options->length();
  for (unsigned i = 0; i < len; i++) {
    Element* option = options->item(i, exception_state);
    if (exception_state.HasException()) {
      return -1;
    }
    if (option == nullptr) {
      continue;
    }
    if (option->hasAttribute(SelectedAttrName(), exception_state)) {
      if (exception_state.HasException()) {
        return -1;
      }
      return static_cast<double>(i);
    }
  }
  return -1;
}

void HTMLSelectElement::setSelectedIndex(double index, ExceptionState& exception_state) {
  const bool is_multiple = multiple();
  auto* options = MakeGarbageCollected<HTMLCollection>(*this, CollectionType::kSelectOptions);
  const unsigned len = options->length();

  const int32_t target = static_cast<int32_t>(index);
  if (target < 0 || static_cast<unsigned>(target) >= len) {
    if (!is_multiple) {
      for (unsigned i = 0; i < len; i++) {
        Element* option = options->item(i, exception_state);
        if (exception_state.HasException()) {
          return;
        }
        if (option != nullptr) {
          SetOptionSelected(*option, false, exception_state);
          if (exception_state.HasException()) {
            return;
          }
        }
      }
    }
    return;
  }

  for (unsigned i = 0; i < len; i++) {
    Element* option = options->item(i, exception_state);
    if (exception_state.HasException()) {
      return;
    }
    if (option == nullptr) {
      continue;
    }

    const bool should_select = static_cast<int32_t>(i) == target;
    if (!is_multiple) {
      SetOptionSelected(*option, should_select, exception_state);
    } else if (should_select) {
      SetOptionSelected(*option, true, exception_state);
    }

    if (exception_state.HasException()) {
      return;
    }
  }
}

bool HTMLSelectElement::multiple() {
  ExceptionState exception_state;
  return hasAttribute(MultipleAttrName(), exception_state);
}

void HTMLSelectElement::setMultiple(bool multiple, ExceptionState& exception_state) {
  if (multiple) {
    setAttribute(MultipleAttrName(), MultipleAttrName(), exception_state);
    return;
  }
  removeAttribute(MultipleAttrName(), exception_state);
}

}  // namespace webf
