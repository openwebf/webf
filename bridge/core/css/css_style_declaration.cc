/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_style_declaration.h"
#include "bindings/qjs/converter_impl.h"
#include "core/css/css_value.h"
#include "core/css/parser/css_property_parser.h"
#include "foundation/string_builder.h"
#include "foundation/string_utils.h"
#include "property_bitsets.h"

namespace webf {

CSSStyleDeclaration::CSSStyleDeclaration(JSContext* ctx) : BindingObject(ctx) {}
CSSStyleDeclaration::CSSStyleDeclaration(JSContext* ctx, NativeBindingObject* native_binding_object)
    : BindingObject(ctx, native_binding_object) {}

namespace {

// Check for a CSS prefix.
// Passed prefix is all lowercase.
// First character of the prefix within the property name may be upper or
// lowercase.
// Other characters in the prefix within the property name must be lowercase.
// The prefix within the property name must be followed by a capital letter.
bool HasCSSPropertyNamePrefix(const AtomicString& property_name, const char* prefix) {
  if (ToASCIILower(property_name[0]) != prefix[0]) {
    return false;
  }

  unsigned length = property_name.length();
  for (unsigned i = 1; i < length; ++i) {
    if (!prefix[i]) {
      return IsASCIIUpper(property_name[i]);
    }
    if (property_name[i] != prefix[i]) {
      return false;
    }
  }
  return false;
}

CSSPropertyID ParseCSSPropertyID(const ExecutingContext* execution_context, const AtomicString& property_name) {
  unsigned length = property_name.length();
  if (!length) {
    return CSSPropertyID::kInvalid;
  }

  StringBuilder builder;
  builder.Reserve(length);

  unsigned i = 0;
  bool has_seen_dash = false;

  if (HasCSSPropertyNamePrefix(property_name, "webkit")) {
    builder.Append("-");
  } else if (IsASCIIUpper(property_name[0])) {
    return CSSPropertyID::kInvalid;
  }

  bool has_seen_upper = IsASCIIUpper(property_name[i]);
  builder.Append(ToASCIILower(property_name[i++]));

  for (; i < length; ++i) {
    char16_t c = property_name[i];
    if (!IsASCIIUpper(c)) {
      if (c == '-') {
        has_seen_dash = true;
      }
      builder.Append(c);
    } else {
      has_seen_upper = true;
      builder.Append('-');
      builder.Append(ToASCIILower(c));
    }
  }

  // Reject names containing both dashes and upper-case characters, such as
  // "border-rightColor".
  if (has_seen_dash && has_seen_upper) {
    return CSSPropertyID::kInvalid;
  }

  std::string prop_name = builder.ReleaseString();
  return UnresolvedCSSPropertyID(execution_context, prop_name);
}

// When getting properties on CSSStyleDeclarations, the name used from
// Javascript and the actual name of the property are not the same, so
// we have to do the following translation. The translation turns upper
// case characters into lower case characters and inserts dashes to
// separate words.
//
// Example: 'backgroundPositionY' -> 'background-position-y'
//
// Also, certain prefixes such as 'css-' are stripped.
CSSPropertyID CssPropertyInfo(const ExecutingContext* execution_context, const AtomicString& name) {
  typedef std::unordered_map<AtomicString, CSSPropertyID, AtomicString::KeyHasher> CSSPropertyIDMap;
  thread_local static CSSPropertyIDMap map = {};
  CSSPropertyIDMap::iterator iter = map.find(name);
  if (iter != map.end()) {
    return iter->second;
  }

  CSSPropertyID unresolved_property = ParseCSSPropertyID(execution_context, name);
  if (unresolved_property == CSSPropertyID::kVariable) {
    unresolved_property = CSSPropertyID::kInvalid;
  }
  // Only cache known-exposed properties (i.e. properties without any
  // associated runtime flag). This is because the web-exposure of properties
  // that are not known-exposed can change dynamically, for example when
  // different ExecutingContexts are provided with different origin trial
  // settings.
  if (kKnownExposedProperties.Has(unresolved_property)) {
    map.insert({name, unresolved_property});
  }
  assert(!IsValidCSSPropertyID(unresolved_property) ||
         CSSProperty::Get(ResolveCSSPropertyID(unresolved_property)).IsWebExposed(execution_context));
  return unresolved_property;
}

}  // namespace

void CSSStyleDeclaration::Trace(GCVisitor* visitor) const {
  webf::BindingObject::Trace(visitor);
}

CSSStyleDeclaration::CSSStyleDeclaration(ExecutingContext* context) : BindingObject(context->ctx()) {}

ScriptValue CSSStyleDeclaration::item(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  AtomicString result = AnonymousNamedGetter(key);
  return ScriptValue(ctx(), result);
}

ScriptValue CSSStyleDeclaration::item(webf::AtomicString&& key, webf::ExceptionState& exception_state) {
  AtomicString result = AnonymousNamedGetter(key);
  return ScriptValue(ctx(), result);
}

AtomicString CSSStyleDeclaration::AnonymousNamedGetter(const webf::AtomicString& name) {
  // Search the style declaration.
  CSSPropertyID unresolved_property = CssPropertyInfo(GetExecutingContext(), name);

  // Do not handle non-property names.
  if (!IsValidCSSPropertyID(unresolved_property)) {
    return AtomicString::Empty();
  }

  return GetPropertyValueInternal(ResolveCSSPropertyID(unresolved_property));
}

bool CSSStyleDeclaration::AnonymousNamedSetter(const webf::AtomicString& name, const webf::ScriptValue& value) {
  auto execution_context = GetExecutingContext();
  if (!execution_context) {
    return false;
  }
  CSSPropertyID unresolved_property = CssPropertyInfo(execution_context, name);
  if (!IsValidCSSPropertyID(unresolved_property)) {
    return false;
  }
  ExceptionState exception_state;
  if (value.IsNumber()) {
    double double_value = value.ToDouble(ctx());
    if (FastPathSetProperty(unresolved_property, double_value)) {
      return true;
    }
    // The fast path failed, e.g. because the property was a longhand,
    // so let the normal string handling deal with it.
  }

  if (value.IsString()) {
    std::string_view string = value.ToString(ctx()).ToStringView();
    if (string.length() <= 128) {
      uint8_t buffer[128];
      int len = string.length();
      SetPropertyInternal(unresolved_property, AtomicString::Empty(), StringView(buffer, len), false, exception_state);
      if (exception_state.HasException()) {
        return true;
      }
      return true;
    }
  }

  // Perform a type conversion from ES value to
  // IDL [LegacyNullToEmptyString] DOMString only after we've confirmed that
  // the property name is a valid CSS attribute name (see bug 1310062).
  auto&& string_value = value.ToLegacyDOMString(ctx());
  SetPropertyInternal(unresolved_property, AtomicString::Empty(), string_value, false, exception_state);
  if (exception_state.HasException()) {
    return true;
  }
  return true;
}

void CSSStyleDeclaration::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {
  //  typedef std::vector<std::string> PreAllocatedPropertyVector;
  //  thread_local static PreAllocatedPropertyVector property_names;
  //  property_names.reserve(kNumCSSProperties - 1);
  //
  //  const ExecutingContext* execution_context = GetExecutingContext();
  //
  //  if (property_names.empty()) {
  //    for (CSSPropertyID property_id : CSSPropertyIDList()) {
  //      const CSSProperty& property_class = CSSProperty::Get(ResolveCSSPropertyID(property_id));
  //      if (property_class.IsWebExposed(execution_context)) {
  //        property_names.emplace_back(property_class.GetJSPropertyName());
  //      }
  //    }
  //    for (CSSPropertyID property_id : kCSSPropertyAliasList) {
  //      const CSSUnresolvedProperty& property_class = *GetPropertyInternal(property_id);
  //      if (property_class.IsWebExposed(execution_context)) {
  //        property_names.emplace_back(property_class.GetJSPropertyName());
  //      }
  //    }
  //    std::sort(property_names.begin(), property_names.end(), CodeUnitCompareLessThan);
  //  }
  //  names = property_names;
}

bool CSSStyleDeclaration::NamedPropertyQuery(const AtomicString& name, ExceptionState&) {
  return IsValidCSSPropertyID(CssPropertyInfo(GetExecutingContext(), name));
}

}  // namespace webf