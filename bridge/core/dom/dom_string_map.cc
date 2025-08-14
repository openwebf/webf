/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dom_string_map.h"
#include "../../foundation/string/string_view.h"
#include "core/dom/element.h"
#include "string/string_builder.h"

namespace webf {

bool startsWith(const char* str, size_t str_len, const char* prefix) {
  size_t len_prefix = strlen(prefix);
  if (str_len < len_prefix)
    return false;
  return strncmp(str, prefix, len_prefix) == 0;
}

static bool IsValidAttributeName(const AtomicString& name) {
  // Check if name starts with "data-"
  if (name.length() < 5)
    return false;
    
  if (name.Is8Bit()) {
    if (!startsWith((const char*)name.Characters8(), name.length(), "data-"))
      return false;
      
    const int64_t length = name.length();
    for (unsigned i = 5; i < length; ++i) {
      if (IsASCIIUpper(name.Characters8()[i]))
        return false;
    }
  } else {
    // For 16-bit strings, check prefix manually
    const char16_t* chars = name.Characters16();
    if (chars[0] != 'd' || chars[1] != 'a' || chars[2] != 't' || chars[3] != 'a' || chars[4] != '-')
      return false;
      
    const int64_t length = name.length();
    for (unsigned i = 5; i < length; ++i) {
      if (IsASCIIUpper(chars[i]))
        return false;
    }
  }

  return true;
}

static bool IsValidPropertyName(const AtomicString& name) {
  const int64_t length = name.length();
  if (name.Is8Bit()) {
    const LChar* chars = name.Characters8();
    for (unsigned i = 0; i < length; ++i) {
      if (chars[i] == '-' && (i + 1 < length) && IsASCIILower(chars[i + 1]))
        return false;
    }
  } else {
    const char16_t* chars = name.Characters16();
    for (unsigned i = 0; i < length; ++i) {
      if (chars[i] == '-' && (i + 1 < length) && IsASCIILower(chars[i + 1]))
        return false;
    }
  }
  return true;
}

static bool PropertyNameMatchesAttributeName(const AtomicString& property_name,
                                             const AtomicString& attribute_name,
                                             unsigned property_length,
                                             unsigned attribute_length) {
  unsigned a = 5;
  unsigned p = 0;
  bool word_boundary = false;
  
  // Helper lambda to get character at index for both 8-bit and 16-bit strings
  auto getChar = [](const AtomicString& str, unsigned index) -> char16_t {
    if (str.Is8Bit()) {
      return static_cast<unsigned char>(str.Characters8()[index]);
    } else {
      return str.Characters16()[index];
    }
  };
  
  while (a < attribute_length && p < property_length) {
    char16_t attr_char = getChar(attribute_name, a);
    char16_t prop_char = getChar(property_name, p);
    
    if (attr_char == '-' && a + 1 < attribute_length &&
        IsASCIILower(getChar(attribute_name, a + 1))) {
      word_boundary = true;
    } else {
      char16_t expected_char = word_boundary ? ToASCIIUpper(attr_char) : std::tolower(attr_char);
      if (expected_char != prop_char)
        return false;
      p++;
      word_boundary = false;
    }
    a++;
  }

  return (a == attribute_length && p == property_length);
}

// This returns an AtomicString because attribute names are always stored
// as AtomicString types in Element (see setAttribute()).
static AtomicString ConvertPropertyNameToAttributeName(const AtomicString& name) {
  if (name.Is8Bit()) {
    StringBuilder result;
    result.Append("data-"_s);
    const LChar* chars = name.Characters8();
    unsigned length = name.length();
    for (unsigned i = 0; i < length; ++i) {
      unsigned char character = chars[i];
      if (std::isupper(character)) {
        result.Append('-');
        result.Append(static_cast<LChar>(std::tolower(character)));
      } else {
        result.Append(character);
      }
    }
    return result.ToAtomicString();
  } else {
    std::u16string result;
    result.reserve(name.length() * 2 + 5);  // Reserve extra space for potential dashes
    result.append(u"data-");
    // Handle 16-bit strings by converting to UTF-8
    const auto* chars = name.Characters16();
    unsigned length = name.length();
    for (unsigned i = 0; i < length; ++i) {
      auto character = chars[i];
      if (std::isupper(character)) {
        result.push_back('-');
        result.push_back(std::tolower(character));
      } else {
        result.push_back(character);
      }
    }
    return {result};
  }
}

std::string ConvertAttributeNameToPropertyName(const std::string& name) {
  std::string result;

  unsigned length = name.length();
  for (unsigned i = 5; i < length; ++i) {
    char character = name[i];
    if (character != '-') {
      result.push_back(character);
    } else {
      if ((i + 1 < length) && std::islower(name[i + 1])) {
        result.push_back(std::toupper(name[i + 1]));
        ++i;
      } else {
        result.push_back(character);
      }
    }
  }

  return result;
}

DOMStringMap::DOMStringMap(webf::Element* owner_element)
    : owner_element_(owner_element), ScriptWrappable(owner_element->ctx()) {}

void DOMStringMap::NamedPropertyEnumerator(std::vector<AtomicString>& props, webf::ExceptionState& exception_state) {
  auto attributes = owner_element_->attributes();
  for (auto& attribute : *attributes) {
    auto key = attribute.first;
    if (IsValidAttributeName(key)) {
      auto v = AtomicString(ConvertAttributeNameToPropertyName(key.ToUTF8String()));
      props.emplace_back(v);
    }
  }
}

bool DOMStringMap::NamedPropertyQuery(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  for (auto& attribute : *owner_element_->attributes()) {
    if (PropertyNameMatchesAttributeName(key, attribute.first, key.length(), attribute.first.length())) {
      return true;
    }
  }
  return false;
}

AtomicString DOMStringMap::item(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  for (auto& attribute : *owner_element_->attributes()) {
    if (PropertyNameMatchesAttributeName(key, attribute.first, key.length(), attribute.first.length())) {
      return attribute.second;
    }
  }

  return AtomicString::Empty();
}

bool DOMStringMap::SetItem(const webf::AtomicString& key,
                           const webf::AtomicString& value,
                           webf::ExceptionState& exception_state) {
  if (!IsValidPropertyName(key)) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "'" + key.ToUTF8String() + "' is not a valid property name.");
    return false;
  }

  auto attribute_name = ConvertPropertyNameToAttributeName(key);
  return owner_element_->attributes()->setAttribute(attribute_name, value, exception_state);
}

bool DOMStringMap::DeleteItem(const webf::AtomicString& key, webf::ExceptionState& exception_state) {
  if (IsValidPropertyName(key)) {
    auto attribute_name = ConvertPropertyNameToAttributeName(key);
    owner_element_->attributes()->removeAttribute(attribute_name, exception_state);
    return true;
  }
  return false;
}

void DOMStringMap::Trace(webf::GCVisitor* visitor) const {
  visitor->TraceMember(owner_element_);
}

const DOMStringMapPublicMethods* DOMStringMap::domStringMapPublicMethods() {
  static DOMStringMapPublicMethods dom_string_map_declaration_public_methods;
  return &dom_string_map_declaration_public_methods;
}

}  // namespace webf
