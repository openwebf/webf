/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "element_attributes.h"
#include "bindings/qjs/exception_state.h"
#include "built_in_string.h"
#include "core/dom/element.h"
#include "foundation/native_value_converter.h"

namespace webf {

static inline bool IsNumberIndex(const StringView& name) {
  if (name.Empty())
    return false;
  char f = name.Characters8()[0];
  return f >= '0' && f <= '9';
}

ElementAttributes::ElementAttributes(Element* element) : ScriptWrappable(element->ctx()), element_(element) {}

AtomicString ElementAttributes::getAttribute(const AtomicString& name, ExceptionState& exception_state) {
  bool numberIndex = IsNumberIndex(name.ToStringView());

  if (numberIndex || attributes_.count(name) == 0) {
    return AtomicString::Empty();
  }

  AtomicString value = attributes_[name];

  // Fallback to directly FFI access to dart.
  if (value.IsEmpty()) {
    NativeValue dart_result = element_->GetBindingProperty(name, exception_state);
    if (dart_result.tag == NativeTag::TAG_STRING) {
      return NativeValueConverter<NativeTypeString>::FromNativeValue(element_->ctx(), dart_result);
    }
  }

  return value;
}

bool ElementAttributes::setAttribute(const AtomicString& name,
                                     const AtomicString& value,
                                     ExceptionState& exception_state) {
  bool numberIndex = IsNumberIndex(name.ToStringView());

  if (numberIndex) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "Failed to execute 'kSetAttribute' on 'Element': '" + name.ToStdString(ctx()) +
                                       "' is not a valid attribute name.");
    return false;
  }

  attributes_[name] = value;

  std::unique_ptr<NativeString> args_01 = name.ToNativeString(ctx());
  std::unique_ptr<NativeString> args_02 = value.ToNativeString(ctx());

  GetExecutingContext()->uiCommandBuffer()->addCommand(element_->eventTargetId(), UICommand::kSetAttribute,
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

  std::unique_ptr<NativeString> args_01 = name.ToNativeString(ctx());
  GetExecutingContext()->uiCommandBuffer()->addCommand(element_->eventTargetId(), UICommand::kRemoveAttribute,
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
    s += attr.first.ToStdString(ctx()) + "=";
    s += "\"" + attr.second.ToStdString(ctx()) + "\"";
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
  visitor->Trace(element_);
}

}  // namespace webf
