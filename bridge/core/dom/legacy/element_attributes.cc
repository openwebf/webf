/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "element_attributes.h"
#include "bindings/qjs/exception_state.h"
#include "built_in_string.h"
#include "core/dom/element.h"

namespace webf {

static inline bool IsNumberIndex(const StringView& name) {
  if (name.Empty())
    return false;
  char f = name.Characters8()[0];
  return f >= '0' && f <= '9';
}

ElementAttributes::ElementAttributes(Element* element)
    : ScriptWrappable(element->ctx()), owner_event_target_id_(element->eventTargetId()) {}

AtomicString ElementAttributes::GetAttribute(const AtomicString& name) {
  bool numberIndex = IsNumberIndex(name.ToStringView());

  if (numberIndex) {
    return AtomicString::Empty();
  }

  return attributes_[name];
}

bool ElementAttributes::setAttribute(const AtomicString& name,
                                     const AtomicString& value,
                                     ExceptionState& exception_state) {
  bool numberIndex = IsNumberIndex(name.ToStringView());

  if (numberIndex) {
    exception_state.ThrowException(
        ctx(), ErrorType::TypeError,
        "Failed to execute 'kSetAttribute' on 'Element': '" + name.ToStdString() + "' is not a valid attribute name.");
    return false;
  }

  attributes_[name] = value;

  std::unique_ptr<NativeString> args_01 = name.ToNativeString();
  std::unique_ptr<NativeString> args_02 = value.ToNativeString();

  GetExecutingContext()->uiCommandBuffer()->addCommand(owner_event_target_id_, UICommand::kSetAttribute,
                                                       std::move(args_01), std::move(args_02), nullptr);

  return true;
}

bool ElementAttributes::hasAttribute(const AtomicString& name, ExceptionState& exception_state) {
  bool numberIndex = IsNumberIndex(name.ToStringView());

  if (numberIndex) {
    return false;
  }

  return attributes_.count(name) > 0;
}

void ElementAttributes::removeAttribute(const AtomicString& name, ExceptionState& exception_state) {
  attributes_.erase(name);

  std::unique_ptr<NativeString> args_01 = name.ToNativeString();
  GetExecutingContext()->uiCommandBuffer()->addCommand(owner_event_target_id_, UICommand::kRemoveAttribute,
                                                       std::move(args_01), nullptr);
}

void ElementAttributes::CopyWith(ElementAttributes* attributes) {
  for (auto& attr : attributes->attributes_) {
    attributes_[attr.first] = attr.second;
  }
}

std::string ElementAttributes::ToString() {
  std::string s;

  for (auto& attr : attributes_) {
    s += attr.first.ToStdString() + "=";
    s += "\"" + attr.second.ToStdString() + "\"";
  }

  return s;
}

bool ElementAttributes::IsEquivalent(const ElementAttributes& other) const {
  if (attributes_.size() != other.attributes_.size())
    return false;
  for (auto& entry : attributes_) {
    auto it = other.attributes_.find(entry.first);
    if (it == other.attributes_.end()) {
      return false;
    }
  }
  return true;
}

void ElementAttributes::Trace(GCVisitor* visitor) const {
}

}  // namespace webf
