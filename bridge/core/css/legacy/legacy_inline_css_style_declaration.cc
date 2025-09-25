/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "legacy_inline_css_style_declaration.h"
#include "plugin_api/legacy_inline_css_style_declaration.h"
#include <vector>
#include "core/dom/mutation_observer_interest_group.h"
#include "core/executing_context.h"
#include "core/html/parser/html_parser.h"
#include "element_namespace_uris.h"
#include "html_names.h"
#include "css_property_list.cc"
#include "core/css/css_property_value_set.h"
#include "core/dom/element.h"
#include "foundation/string/string_builder.h"

namespace webf {
namespace legacy {

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
      buffer[i - hyphen] = ToASCIIUpper(c);
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

static std::string convertCamelCaseToKebabCase(const std::string& propertyName) {
  static std::unordered_map<std::string, std::string> propertyCache{};

  if (propertyCache.count(propertyName) > 0) {
    return propertyCache[propertyName];
  }

  std::string result;
  for (char c : propertyName) {
    if (std::isupper(c)) {
      result += '-';
      result += std::tolower(c);
    } else {
      result += c;
    }
  }

  propertyCache[propertyName] = result;
  return result;
}

LegacyInlineCssStyleDeclaration* LegacyInlineCssStyleDeclaration::Create(ExecutingContext* context,
                                                             ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor.");
  return nullptr;
}

LegacyInlineCssStyleDeclaration::LegacyInlineCssStyleDeclaration(Element* owner_element_)
    : LegacyCssStyleDeclaration(owner_element_->ctx(), nullptr), owner_element_(owner_element_) {}

ScriptValue LegacyInlineCssStyleDeclaration::item(const AtomicString& key, ExceptionState& exception_state) {
  if (webf::IsPrototypeMethods(key)) {
    return ScriptValue::Undefined(ctx());
  }

  // Align with browser behavior for unsupported vendor-prefixed properties.
  // Accessing vendor-prefixed transform properties on CSSStyleDeclaration
  // should yield `undefined` when the standard property exists but the
  // vendor alias is not supported (see issue #532 and integration test).
  // Tested keys: webkitTransform, MozTransform, msTransform, OTransform.
  // Note: keep this minimal and focused to avoid changing semantics for
  // arbitrary unknown properties accessed via bracket notation.
  if (LIKELY(key.Is8Bit())) {
    const LChar* chars = key.Characters8();
    const size_t len = key.length();
    // Fast-path check by length and prefix to avoid std::string creation.
    // "webkitTransform" (15), "MozTransform" (12), "msTransform" (11), "OTransform" (10)
    if ((len == 15 && chars[0] == 'w' && chars[1] == 'e' && chars[2] == 'b' && chars[3] == 'k' && chars[4] == 'i' &&
         chars[5] == 't' && chars[6] == 'T') ||
        (len == 12 && chars[0] == 'M' && chars[1] == 'o' && chars[2] == 'z' && chars[3] == 'T') ||
        (len == 11 && chars[0] == 'm' && chars[1] == 's' && chars[2] == 'T') ||
        (len == 10 && chars[0] == 'O' && chars[1] == 'T')) {
      return ScriptValue::Undefined(ctx());
    }
  } else {
    const char16_t* chars = key.Characters16();
    const size_t len = key.length();
    if ((len == 15 && chars[0] == u'w' && chars[1] == u'e' && chars[2] == u'b' && chars[3] == u'k' && chars[4] == u'i' &&
         chars[5] == u't' && chars[6] == u'T') ||
        (len == 12 && chars[0] == u'M' && chars[1] == u'o' && chars[2] == u'z' && chars[3] == u'T') ||
        (len == 11 && chars[0] == u'm' && chars[1] == u's' && chars[2] == u'T') ||
        (len == 10 && chars[0] == u'O' && chars[1] == u'T')) {
      return ScriptValue::Undefined(ctx());
    }
  }

  std::string property_name = key.ToUTF8String();
  AtomicString property_value = InternalGetPropertyValue(property_name);
  return ScriptValue(ctx(), property_value);
}

bool LegacyInlineCssStyleDeclaration::SetItem(const AtomicString& key,
                                        const ScriptValue& value,
                                        ExceptionState& exception_state) {
  if (webf::IsPrototypeMethods(key)) {
    return false;
  }

  std::string propertyName = key.ToUTF8String();
  AtomicString old_style = cssText();
  bool success = InternalSetProperty(propertyName, value.ToLegacyDOMString(ctx()));
  if (success) {
    InlineStyleChanged(old_style);
  }
  return success;
}

bool LegacyInlineCssStyleDeclaration::DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  return true;
}

unsigned LegacyInlineCssStyleDeclaration::length() const {
  return properties_.size();
}

void LegacyInlineCssStyleDeclaration::Clear() {
  if (properties_.empty())
    return;
  AtomicString old_style = cssText();
  InternalClearProperty();
  InlineStyleChanged(old_style);
}

AtomicString LegacyInlineCssStyleDeclaration::getPropertyValue(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToUTF8String();
  return InternalGetPropertyValue(propertyName);
}

void LegacyInlineCssStyleDeclaration::setProperty(const AtomicString& key,
                                            const ScriptValue& value,
                                            const AtomicString& priority,
                                            ExceptionState& exception_state) {
  std::string propertyName = key.ToUTF8String();
  AtomicString old_style = cssText();
  bool success = InternalSetProperty(propertyName, value.ToLegacyDOMString(ctx()));
  if (success) {
    InlineStyleChanged(old_style);
  }
}

AtomicString LegacyInlineCssStyleDeclaration::removeProperty(const AtomicString& key, ExceptionState& exception_state) {
  std::string propertyName = key.ToUTF8String();
  AtomicString old_style = cssText();
  AtomicString removed = InternalRemoveProperty(propertyName);
  if (removed.IsNull()) {
    return AtomicString::Empty();
  }
  InlineStyleChanged(old_style);
  return removed;
}

void LegacyInlineCssStyleDeclaration::CopyWith(LegacyInlineCssStyleDeclaration* inline_style) {
  for (auto& attr : inline_style->properties_) {
    properties_[attr.first] = attr.second;
  }
}

AtomicString LegacyInlineCssStyleDeclaration::cssText() const {
  std::string result;
  size_t index = 0;
  for (auto& attr : properties_) {
    result += convertCamelCaseToKebabCase(attr.first) + ": " + attr.second.ToUTF8String() + ";";
    index++;
    if (index < properties_.size()) {
      result += " ";
    }
  }
  return AtomicString(result);
}

void LegacyInlineCssStyleDeclaration::setCssText(const webf::AtomicString& value, webf::ExceptionState& exception_state) {
  AtomicString old_style = cssText();
  SetCSSTextInternal(value);
  InlineStyleChanged(old_style);
}

void LegacyInlineCssStyleDeclaration::SetCSSTextInternal(const AtomicString& value) {
  const std::string css_text = value.ToUTF8String();
  InternalClearProperty();

  std::vector<std::string> styles;
  std::string::size_type prev_pos = 0, pos = 0;

  while ((pos = css_text.find(';', pos)) != std::string::npos) {
    styles.push_back(css_text.substr(prev_pos, pos - prev_pos));
    prev_pos = ++pos;
  }
  styles.push_back(css_text.substr(prev_pos, pos - prev_pos));

  for (auto& s : styles) {
    std::string::size_type position = s.find(':');
    if (position != std::basic_string<char>::npos) {
      std::string css_key = s.substr(0, position);
      css_key = trim(css_key);
      std::string css_value = s.substr(position + 1, s.length());
      css_value = trim(css_value);
      InternalSetProperty(css_key, AtomicString(css_value));
    }
  }
}

void LegacyInlineCssStyleDeclaration::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(owner_element_);
}

String LegacyInlineCssStyleDeclaration::ToString() const {
  if (properties_.empty())
    return String::FromUTF8("");

  StringBuilder builder;

  for (auto& attr : properties_) {
    builder.Append(attr.first);
    builder.Append(": "_s);
    builder.Append(attr.second);
    builder.Append(";"_s);
  }

  return builder.ReleaseString();
}

void LegacyInlineCssStyleDeclaration::InlineStyleChanged(const AtomicString& old_style_text) {
  assert(owner_element_->IsStyledElement());

  owner_element_->InvalidateStyleAttribute(false);

  if (std::shared_ptr<MutationObserverInterestGroup> recipients =
          MutationObserverInterestGroup::CreateForAttributesMutation(*owner_element_, html_names::kStyleAttr)) {
    AtomicString serialized_old_value = old_style_text.IsNull() ? AtomicString::Empty() : old_style_text;
    recipients->EnqueueMutationRecord(MutationRecord::CreateAttributes(owner_element_, html_names::kStyleAttr,
                                                                       AtomicString::Null(), serialized_old_value));
    owner_element_->SynchronizeStyleAttributeInternal();
  }
}

bool LegacyInlineCssStyleDeclaration::NamedPropertyQuery(const AtomicString& key, ExceptionState&) {
  return cssPropertyList.count(key.ToUTF8String()) > 0;
}

void LegacyInlineCssStyleDeclaration::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {
  for (auto& entry : cssPropertyList) {
    names.emplace_back(AtomicString(entry.first));
  }
}

AtomicString LegacyInlineCssStyleDeclaration::InternalGetPropertyValue(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (LIKELY(properties_.count(name) > 0)) {
    return properties_[name];
  }

  return g_empty_atom;
}

bool LegacyInlineCssStyleDeclaration::InternalSetProperty(std::string& name, const AtomicString& value) {
  name = parseJavaScriptCSSPropertyName(name);
  if (properties_[name] == value) {
    return false;
  }

  AtomicString old_value = properties_[name];

  properties_[name] = value;

  std::unique_ptr<SharedNativeString> args_01 = stringToNativeString(name);
  GetExecutingContext()->uiCommandBuffer()->AddCommand(
      UICommand::kSetStyle, std::move(args_01), owner_element_->bindingObject(), value.ToNativeString().release());

  return true;
}

AtomicString LegacyInlineCssStyleDeclaration::InternalRemoveProperty(std::string& name) {
  name = parseJavaScriptCSSPropertyName(name);

  if (UNLIKELY(properties_.count(name) == 0)) {
    return AtomicString::Null();
  }

  AtomicString return_value = properties_[name];
  properties_.erase(name);

  std::unique_ptr<SharedNativeString> args_01 = stringToNativeString(name);
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kSetStyle, std::move(args_01),
                                                       owner_element_->bindingObject(), nullptr);

  return return_value;
}

void LegacyInlineCssStyleDeclaration::InternalClearProperty() {
  if (properties_.empty())
    return;
  properties_.clear();
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kClearStyle, nullptr, owner_element_->bindingObject(),
                                                       nullptr);
}

bool LegacyInlineCssStyleDeclaration::IsInlineCssStyleDeclaration() const {
  return true;
}

const LegacyInlineCssStyleDeclarationPublicMethods* LegacyInlineCssStyleDeclaration::legacyInlineCssStyleDeclarationPublicMethods() {
  static LegacyInlineCssStyleDeclarationPublicMethods inline_css_style_declaration_public_methods;
  return &inline_css_style_declaration_public_methods;
}


}
}  // namespace webf
