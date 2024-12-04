// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_property_parser.h"
#include "core/css/css_pending_substitution_value.h"
#include "core/css/css_unparsed_declaration_value.h"
#include "core/css/hash_tools.h"
#include "core/css/parser/at_rule_descriptor_parser.h"
#include "core/css/parser/css_parser_impl.h"
#include "core/css/parser/css_tokenized_value.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/properties/css_bitset.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/css/property_bitsets.h"
#include "longhands.h"
#include "shorthands.h"

namespace webf {

namespace {

bool IsPropertyAllowedInRule(const CSSProperty& property, StyleRule::RuleType rule_type) {
  // This function should be called only when parsing a property. Shouldn't
  // reach here with a descriptor.
  DCHECK(property.IsProperty());
  switch (rule_type) {
    case StyleRule::kStyle:
      return true;
    case StyleRule::kPage:
      // TODO(sesse): Limit the allowed properties here.
      // https://www.w3.org/TR/css-page-3/#page-property-list
      // https://www.w3.org/TR/css-page-3/#margin-property-list
      return true;
    case StyleRule::kKeyframe:
      return property.IsValidForKeyframe();
    case StyleRule::kPositionTry:
      return property.IsValidForPositionTry();
    default:
      NOTREACHED_IN_MIGRATION();
      return false;
  }
}

}  // namespace

CSSPropertyParser::CSSPropertyParser(CSSParserTokenStream& stream,
                                     std::shared_ptr<const CSSParserContext> context,
                                     std::vector<CSSPropertyValue>* parsed_properties)
    : stream_(stream), context_(context), parsed_properties_(parsed_properties) {
  // Strip initial whitespace/comments from stream_.
  stream_.ConsumeWhitespace();
}

std::shared_ptr<const CSSValue> CSSPropertyParser::ConsumeCSSWideKeyword(CSSParserTokenStream& stream,
                                                                         bool allow_important_annotation,
                                                                         bool& important) {
  CSSParserTokenStream::State savepoint = stream.Save();

  auto value = css_parsing_utils::ConsumeCSSWideKeyword(stream);
  if (!value) {
    // No need to Restore(), we are at the right spot anyway.
    // (We do this instead of relying on CSSParserTokenStream's
    // Restore() optimization, as this path is so hot.)
    return nullptr;
  }

  important = css_parsing_utils::MaybeConsumeImportant(stream, allow_important_annotation);
  if (!stream.AtEnd()) {
    stream.Restore(savepoint);
    return nullptr;
  }

  return value;
}

bool CSSPropertyParser::ParseCSSWideKeyword(CSSPropertyID unresolved_property, bool allow_important_annotation) {
  bool important;
  auto value = ConsumeCSSWideKeyword(stream_, allow_important_annotation, important);
  if (!value) {
    return false;
  }

  CSSPropertyID property = ResolveCSSPropertyID(unresolved_property);
  const StylePropertyShorthand& shorthand = shorthandForProperty(property);
  if (!shorthand.length()) {
    if (!CSSProperty::Get(property).IsProperty()) {
      return false;
    }
    AddProperty(property, CSSPropertyID::kInvalid, value, important,
                css_parsing_utils::IsImplicitProperty::kNotImplicit, *parsed_properties_);
  } else {
    css_parsing_utils::AddExpandedPropertyForValue(property, value, important, *parsed_properties_);
  }
  return true;
}

bool CSSPropertyParser::ParseValueStart(webf::CSSPropertyID unresolved_property,
                                        bool allow_important_annotation,
                                        StyleRule::RuleType rule_type) {
  if (ParseCSSWideKeyword(unresolved_property, rule_type)) {
    return true;
  }

  CSSParserTokenStream::State savepoint = stream_.Save();

  CSSPropertyID property_id = ResolveCSSPropertyID(unresolved_property);
  const CSSProperty& property = CSSProperty::Get(property_id);
  // If a CSSPropertyID is only a known descriptor (@fontface, @property), not a
  // style property, it will not be a valid declaration.
  if (!property.IsProperty()) {
    return false;
  }
  if (!IsPropertyAllowedInRule(property, rule_type)) {
    return false;
  }
  int parsed_properties_size = parsed_properties_->size();

  bool is_shorthand = property.IsShorthand();
  DCHECK(context_);

  // NOTE: The first branch of the if here uses the tokenized form,
  // and the second uses the streaming parser. This is only allowed
  // since they start from the same place and we reset both below,
  // so they cannot go out of sync.
  if (is_shorthand) {
    const auto local_context = CSSParserLocalContext()
                                   .WithAliasParsing(IsPropertyAlias(unresolved_property))
                                   .WithCurrentShorthand(property_id);
    // Variable references will fail to parse here and will fall out to the
    // variable ref parser below.
    //
    // NOTE: We call ParseShorthand() with important=false, since we don't know
    // yet whether we have !important or not. We'll change the flag for all
    // added properties below (ParseShorthand() makes its own calls to
    // AddProperty(), since there may be more than one of them).
    if (To<Shorthand>(property).ParseShorthand(
            /*important=*/false, stream_, context_, local_context, *parsed_properties_)) {
      bool important = css_parsing_utils::MaybeConsumeImportant(stream_, allow_important_annotation);
      if (stream_.AtEnd()) {
        if (important) {
          for (size_t property_idx = parsed_properties_size; property_idx < parsed_properties_->size();
               ++property_idx) {
            (*parsed_properties_)[property_idx].SetImportant();
          }
        }
        return true;
      }
    }

    // Remove any properties that may have been added by ParseShorthand()
    // during a failing parse earlier.
    parsed_properties_->erase(parsed_properties_->begin(), parsed_properties_->begin() + parsed_properties_size);
    parsed_properties_->shrink_to_fit();
  } else {
    if (std::shared_ptr<const CSSValue> parsed_value =
            css_parsing_utils::ParseLonghand(unresolved_property, CSSPropertyID::kInvalid, context_, stream_)) {
      bool important = css_parsing_utils::MaybeConsumeImportant(stream_, allow_important_annotation);
      if (stream_.AtEnd()) {
        AddProperty(property_id, CSSPropertyID::kInvalid, std::move(parsed_value), important,
                    css_parsing_utils::IsImplicitProperty::kNotImplicit, *parsed_properties_);
        return true;
      }
    }
  }

  // We did not parse properly without variable substitution,
  // so rewind the stream, and see if parsing it as something
  // containing variables will help.
  //
  // Note that if so, this needs the original text, so we need to take
  // note of the original offsets so that we can see what we tokenized.
  stream_.EnsureLookAhead();
  stream_.Restore(savepoint);

  CSSTokenizedValue value = CSSParserImpl::ConsumeRestrictedPropertyValue(stream_);
  if (!stream_.AtEnd()) {
    return false;
  }

  const bool important = CSSParserImpl::RemoveImportantAnnotationIfPresent(value);
  value.text = CSSVariableParser::StripTrailingWhitespaceAndComments(value.text);

  if (CSSVariableParser::ContainsValidVariableReferences(value.range, context_->GetExecutingContext())) {
    if (value.text.length() > CSSVariableData::kMaxVariableBytes) {
      return false;
    }

    bool is_animation_tainted = false;
    auto variable = std::make_shared<CSSUnparsedDeclarationValue>(
        CSSVariableData::Create(value, is_animation_tainted, true), context_);

    if (is_shorthand) {
      std::shared_ptr<cssvalue::CSSPendingSubstitutionValue> pending_value =
          std::make_shared<cssvalue::CSSPendingSubstitutionValue>(property_id, variable);
      css_parsing_utils::AddExpandedPropertyForValue(property_id, pending_value, important, *parsed_properties_);
    } else {
      AddProperty(property_id, CSSPropertyID::kInvalid, variable, important,
                  css_parsing_utils::IsImplicitProperty::kNotImplicit, *parsed_properties_);
    }
    return true;
  }

  return false;
}

bool CSSPropertyParser::ParseValue(CSSPropertyID unresolved_property,
                                   bool allow_important_annotation,
                                   CSSParserTokenStream& stream,
                                   std::shared_ptr<const CSSParserContext> context,
                                   std::vector<CSSPropertyValue>& parsed_properties,
                                   StyleRule::RuleType rule_type) {
  CSSPropertyParser parser(stream, std::move(context), &parsed_properties);
  CSSPropertyID resolved_property = ResolveCSSPropertyID(unresolved_property);

  bool parse_success;
  if (rule_type == StyleRule::kFontFace) {
    parse_success = parser.ParseFontFaceDescriptor(resolved_property);
  } else {
    parse_success = parser.ParseValueStart(unresolved_property, allow_important_annotation, rule_type);
  }

  return parse_success;
}

std::shared_ptr<const CSSValue> CSSPropertyParser::ParseSingleValue(CSSPropertyID property,
                                                                    CSSParserTokenStream& stream,
                                                                    std::shared_ptr<const CSSParserContext> context) {
  assert(context);
  stream.ConsumeWhitespace();

  std::shared_ptr<const CSSValue> value = css_parsing_utils::ConsumeCSSWideKeyword(stream);
  if (!value) {
    value = css_parsing_utils::ParseLonghand(property, CSSPropertyID::kInvalid, std::move(context), stream);
  }
  if (!value || !stream.AtEnd()) {
    return nullptr;
  }
  return value;
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
#if DCHECK_IS_ON()
  // Verify that we get the same answer with standard lowercasing.
  for (unsigned i = 0; i < length; ++i) {
    buffer[i] = ToASCIILower(property_name[i]);
  }
  DCHECK_EQ(hash_table_entry, FindProperty(buffer, length));
#endif
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

CSSPropertyID UnresolvedCSSPropertyID(const ExecutingContext* context,
                                      const std::string_view& string,
                                      CSSParserMode mode) {
  return UnresolvedCSSPropertyID(context, string.data(), string.length(), mode);
}

CSSValueID CssValueKeywordID(const std::string_view& string) {
  unsigned length = string.length();
  if (!length) {
    return CSSValueID::kInvalid;
  }
  if (length > maxCSSValueKeywordLength) {
    return CSSValueID::kInvalid;
  }

  char buffer[maxCSSValueKeywordLength + 1];  // 1 for null character
  if (!QuasiLowercaseIntoBuffer(string.data(), length, buffer)) {
    return CSSValueID::kInvalid;
  }

  const Value* hash_table_entry = FindValue(buffer, length);
#if DDEBUG
  // Verify that we get the same answer with standard lowercasing.
  for (unsigned i = 0; i < length; ++i) {
    buffer[i] = ToASCIILower(string.data()[i]);
  }
  assert(hash_table_entry == FindValue(buffer, length));
#endif
  return hash_table_entry ? static_cast<CSSValueID>(hash_table_entry->id) : CSSValueID::kInvalid;
}

bool CSSPropertyParser::ParseFontFaceDescriptor(CSSPropertyID resolved_property) {
  // TODO(meade): This function should eventually take an AtRuleDescriptorID.
  const AtRuleDescriptorID id = CSSPropertyIDAsAtRuleDescriptor(resolved_property);
  if (id == AtRuleDescriptorID::Invalid) {
    return false;
  }

  // ParseFontFaceDescriptor() could want the original text,
  // for re-tokenization for the specific case of the “unicode-range”
  // property (which is the only property where UnicodeRange productions
  // are allowed). Thus, we need to keep track of exactly what
  // we tokenized, so that we can also send in the original text.
  //
  // This should obviously go away when everything uses
  // the streaming parser.
  size_t start_offset = stream_.LookAheadOffset();
  CSSParserTokenRange range = stream_.ConsumeUntilPeekedTypeIs();
  size_t end_offset = stream_.Offset();
  std::string_view original_text = stream_.StringRangeAt(start_offset, end_offset - start_offset);

  auto parsed_value = AtRuleDescriptorParser::ParseFontFaceDescriptor(id, {range, original_text}, context_);
  if (!parsed_value) {
    return false;
  }

  AddProperty(resolved_property, CSSPropertyID::kInvalid /* current_shorthand */, parsed_value, false /* important */,
              css_parsing_utils::IsImplicitProperty::kNotImplicit, *parsed_properties_);
  return true;
}

}  // namespace webf
