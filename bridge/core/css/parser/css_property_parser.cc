// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_property_parser.h"
#include "core/css/hash_tools.h"
#include "core/css/properties/css_bitset.h"
#include "core/css/property_bitsets.h"

namespace webf {

CSSPropertyParser::CSSPropertyParser(CSSParserTokenStream& stream,
                                     const CSSParserContext* context,
                                     std::vector<CSSPropertyValue>* parsed_properties)
    : stream_(stream), context_(context), parsed_properties_(parsed_properties) {
  // Strip initial whitespace/comments from stream_.
  stream_.ConsumeWhitespace();
}

bool CSSPropertyParser::ParseValueStart(webf::CSSPropertyID unresolved_property,
                                        bool allow_important_annotation,
                                        StyleRule::RuleType rule_type) {
  return false;
}

bool CSSPropertyParser::ParseValue(CSSPropertyID unresolved_property,
                                   bool allow_important_annotation,
                                   CSSParserTokenStream& stream,
                                   const CSSParserContext* context,
                                   std::vector<CSSPropertyValue>& parsed_properties,
                                   StyleRule::RuleType rule_type) {
  CSSPropertyParser parser(stream, context, &parsed_properties);
  CSSPropertyID resolved_property = ResolveCSSPropertyID(unresolved_property);

  bool parse_success;
  //  if (rule_type == StyleRule::kFontFace) {
  //    parse_success = parser.ParseFontFaceDescriptor(resolved_property);
  //  } else {
  //    parse_success = parser.ParseValueStart(unresolved_property, allow_important_annotation, rule_type);
  //  }
  parse_success = parser.ParseValueStart(unresolved_property, allow_important_annotation, rule_type);

  return parse_success;
}

const CSSValue* CSSPropertyParser::ParseSingleValue(CSSPropertyID property,
                                                    CSSParserTokenStream& stream,
                                                    const CSSParserContext* context) {
  assert(context);
  stream.ConsumeWhitespace();

  //  const CSSValue* value = css_parsing_utils::ConsumeCSSWideKeyword(stream);
  //  if (!value) {
  //    value = ParseLonghand(property, CSSPropertyID::kInvalid, *context, stream);
  //  }
  //  if (!value || !stream.AtEnd()) {
  //    return nullptr;
  //  }
  //  return value;
  return nullptr;
}

// Take the given string, lowercase it (with possible caveats;
// see comments on the LChar version), convert it to ASCII and store it into
// the buffer together with a zero terminator. The string and zero terminator
// is assumed to fit.
//
// Returns false if the string is outside the allowed range of ASCII, so that
// it could never match any CSS properties or values.
static inline bool QuasiLowercaseIntoBuffer(const char* src, unsigned length, char* dst) {
  for (unsigned i = 0; i < length; ++i) {
    unsigned char c = src[i];
    if (c == 0 || c >= 0x7F) {  // illegal character
      return false;
    }
    dst[i] = ToASCIILower(c);
  }
  dst[length] = '\0';
  return true;
}

static inline bool IsExposedInMode(const ExecutingContext* execution_context,
                                   const CSSUnresolvedProperty& property,
                                   CSSParserMode mode) {
  return mode == kUASheetMode ? property.IsUAExposed(execution_context) : property.IsWebExposed(execution_context);
}

static CSSPropertyID ExposedProperty(CSSPropertyID property_id,
                                     const ExecutingContext* execution_context,
                                     CSSParserMode mode) {
  const CSSUnresolvedProperty& property = CSSUnresolvedProperty::Get(property_id);
  CSSPropertyID alternative_id = property.GetAlternative();
  if (alternative_id != CSSPropertyID::kInvalid) {
    if (CSSPropertyID exposed_id = ExposedProperty(alternative_id, execution_context, mode);
        exposed_id != CSSPropertyID::kInvalid) {
      return exposed_id;
    }
  }
  return IsExposedInMode(execution_context, property, mode) ? property_id : CSSPropertyID::kInvalid;
}

static CSSPropertyID UnresolvedCSSPropertyID(const ExecutingContext* execution_context,
                                             const char* property_name,
                                             unsigned length,
                                             CSSParserMode mode) {
  if (length == 0) {
    return CSSPropertyID::kInvalid;
  }
  if (length >= 3 && property_name[0] == '-' && property_name[1] == '-') {
    return CSSPropertyID::kVariable;
  }
  if (length > kMaxCSSPropertyNameLength) {
    return CSSPropertyID::kInvalid;
  }

  char buffer[kMaxCSSPropertyNameLength + 1];  // 1 for null character
  if (!QuasiLowercaseIntoBuffer(property_name, length, buffer)) {
    return CSSPropertyID::kInvalid;
  }

  const char* name = buffer;
  const Property* hash_table_entry = FindProperty(name, length);
  // #if DCHECK_IS_ON()
  //   // Verify that we get the same answer with standard lowercasing.
  //   for (unsigned i = 0; i < length; ++i) {
  //     buffer[i] = ToASCIILower(property_name[i]);
  //   }
  //   DCHECK_EQ(hash_table_entry, FindProperty(buffer, length));
  // #endif
  if (!hash_table_entry) {
    return CSSPropertyID::kInvalid;
  }

  CSSPropertyID property_id = static_cast<CSSPropertyID>(hash_table_entry->id);
  if (kKnownExposedProperties.Has(property_id)) {
    assert(property_id == ExposedProperty(property_id, execution_context, mode));
    return property_id;
  }

  // The property is behind a runtime flag, so we need to go ahead
  // and actually do the resolution to see if that flag is on or not.
  // This should happen only occasionally.
  return ExposedProperty(property_id, execution_context, mode);
}

CSSPropertyID UnresolvedCSSPropertyID(const ExecutingContext* context, const std::string& string, CSSParserMode mode) {
  return UnresolvedCSSPropertyID(context, string.c_str(), string.length(), mode);
}

CSSValueID CssValueKeywordID(const std::string& string) {
  unsigned length = string.length();
  if (!length) {
    return CSSValueID::kInvalid;
  }
  if (length > maxCSSValueKeywordLength) {
    return CSSValueID::kInvalid;
  }

  char buffer[maxCSSValueKeywordLength + 1];  // 1 for null character
  if (!QuasiLowercaseIntoBuffer(string.c_str(), length, buffer)) {
    return CSSValueID::kInvalid;
  }

  const Value* hash_table_entry = FindValue(buffer, length);
#if DDEBUG
  // Verify that we get the same answer with standard lowercasing.
  for (unsigned i = 0; i < length; ++i) {
    buffer[i] = ToASCIILower(string.c_str()[i]);
  }
  assert(hash_table_entry == FindValue(buffer, length));
#endif
  return hash_table_entry ? static_cast<CSSValueID>(hash_table_entry->id) : CSSValueID::kInvalid;
}

}  // namespace webf
