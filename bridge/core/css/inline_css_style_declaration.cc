/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "inline_css_style_declaration.h"
#include <vector>
#include "core/dom/element.h"
#include "core/executing_context.h"
#include "css_property_list.h"

namespace webf {

template <typename CharacterType>
inline bool isASCIILower(CharacterType character) {
  return character >= 'a' && character <= 'z';
}

template <typename CharacterType>
inline CharacterType toASCIIUpper(CharacterType character) {
  return character & ~(isASCIILower(character) << 5);
}

static std::string parseJavaScriptCSSPropertyName(std::string& propertyName) {
  static std::unordered_map<std::string, std::string> propertyCache{};

  if (propertyCache.count(propertyName) > 0) {
    return propertyCache[propertyName];
  }

  std::vector<char> buffer(propertyName.size() + 1);

  if (propertyName.size() > 2 && propertyName[0] == '-' && propertyName[1] == '-') {
    propertyCache[propertyName] = propertyName;
    return propertyName;
  }

  size_t hyphen = 0;
  bool toCamelCase = false;
  for (size_t i = 0; i < propertyName.size(); ++i) {
    char c = propertyName[i];
    if (!c)
      break;
    if (c == '-' && (i > 0 && propertyName[i - 1] != '-')) {
      toCamelCase = true;
      hyphen++;
      continue;
    }
    if (toCamelCase) {
      buffer[i - hyphen] = toASCIIUpper(c);
      toCamelCase = false;
    } else {
      buffer[i - hyphen] = c;
    }
  }

  buffer.emplace_back('\0');

  std::string result = std::string(buffer.data());

  propertyCache[propertyName] = result;
  return result;
}

InlineCssStyleDeclaration* InlineCssStyleDeclaration::Create(ExecutingContext* context,
                                                             ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor.");
  return nullptr;
}

InlineCssStyleDeclaration::InlineCssStyleDeclaration(ExecutingContext* context, Element* owner_element_)
    : CSSStyleDeclaration(context->ctx()), owner_element_(owner_element_) {}

AtomicString InlineCssStyleDeclaration::item(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString(ctx());
  return InternalGetPropertyValue(propertyName);
}

bool InlineCssStyleDeclaration::SetItem(const AtomicString& key,
                                        const AtomicString& value,
                                        ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString(ctx());
  return InternalSetProperty(propertyName, value);
}

int64_t InlineCssStyleDeclaration::length() const {
  return properties_.size();
}

AtomicString InlineCssStyleDeclaration::getPropertyValue(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString(ctx());
  return InternalGetPropertyValue(propertyName);
}

void InlineCssStyleDeclaration::setProperty(const AtomicString& key,
                                            const AtomicString& value,
                                            ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString(ctx());
  InternalSetProperty(propertyName, value);
}

AtomicString InlineCssStyleDeclaration::removeProperty(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToStdString(ctx());
  return InternalRemoveProperty(propertyName);
}

void InlineCssStyleDeclaration::CopyWith(InlineCssStyleDeclaration* inline_style) {
  for (auto& attr : inline_style->properties_) {
    properties_[attr.first] = attr.second;
  }
}

void InlineCssStyleDeclaration::Trace(GCVisitor* visitor) const {
  visitor->Trace(owner_element_);
}

std::string InlineCssStyleDeclaration::ToString() const {
  if (properties_.empty())
    return "";

  std::string s;

  for (auto& attr : properties_) {
    s += attr.first + ": " + attr.second.ToStdString(ctx()) + ";";
  }

  s += "\"";
  return s;
}

bool InlineCssStyleDeclaration::NamedPropertyQuery(const AtomicString& key, ExceptionState&) {
  return cssPropertyList.count(key.ToStdString(ctx())) > 0;
}

void InlineCssStyleDeclaration::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {
  for (auto& entry : cssPropertyList) {
    names.emplace_back(AtomicString(ctx(), entry.first));
  }
}

AtomicString InlineCssStyleDeclaration::InternalGetPropertyValue(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (LIKELY(properties_.count(name) > 0)) {
    return properties_[name];
  }

  return AtomicString::Empty();
}

bool InlineCssStyleDeclaration::InternalSetProperty(std::string& name, const AtomicString& value) {
  name = parseJavaScriptCSSPropertyName(name);
  if (properties_[name] == value) {
    return true;
  }

  properties_[name] = value;

  std::unique_ptr<SharedNativeString> args_01 = stringToNativeString(name);
  GetExecutingContext()->uiCommandBuffer()->addCommand(
      UICommand::kSetStyle, std::move(args_01), owner_element_->bindingObject(), value.ToNativeString(ctx()).release());

  return true;
}

AtomicString InlineCssStyleDeclaration::InternalRemoveProperty(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (UNLIKELY(properties_.count(name) == 0)) {
    return AtomicString::Empty();
  }

  AtomicString return_value = properties_[name];
  properties_.erase(name);

  std::unique_ptr<SharedNativeString> args_01 = stringToNativeString(name);
  GetExecutingContext()->uiCommandBuffer()->addCommand(UICommand::kSetStyle, std::move(args_01),
                                                       owner_element_->bindingObject(), nullptr);

  return return_value;
}

}  // namespace webf
