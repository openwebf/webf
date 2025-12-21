// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_variable_data.h"

#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_tokenizer.h"
#include "foundation/string/string_types.h"

namespace webf {

static bool IsFontUnitToken(CSSParserToken token) {
  if (token.GetType() != kDimensionToken) {
    return false;
  }
  switch (token.GetUnitType()) {
    case CSSPrimitiveValue::UnitType::kEms:
    case CSSPrimitiveValue::UnitType::kChs:
    case CSSPrimitiveValue::UnitType::kExs:
    case CSSPrimitiveValue::UnitType::kIcs:
    case CSSPrimitiveValue::UnitType::kCaps:
      return true;
    default:
      return false;
  }
}

static bool IsRootFontUnitToken(CSSParserToken token) {
  if (token.GetType() != kDimensionToken) {
    return false;
  }
  switch (token.GetUnitType()) {
    case CSSPrimitiveValue::UnitType::kRems:
    case CSSPrimitiveValue::UnitType::kRexs:
    case CSSPrimitiveValue::UnitType::kRchs:
    case CSSPrimitiveValue::UnitType::kRics:
    case CSSPrimitiveValue::UnitType::kRlhs:
    case CSSPrimitiveValue::UnitType::kRcaps:
      return true;
    default:
      return false;
  }
}

static bool IsLineHeightUnitToken(CSSParserToken token) {
  return token.GetType() == kDimensionToken && token.GetUnitType() == CSSPrimitiveValue::UnitType::kLhs;
}

void CSSVariableData::ExtractFeatures(const CSSParserToken& token,
                                      bool& has_font_units,
                                      bool& has_root_font_units,
                                      bool& has_line_height_units) {
  has_font_units |= IsFontUnitToken(token);
  has_root_font_units |= IsRootFontUnitToken(token);
  has_line_height_units |= IsLineHeightUnitToken(token);
}

std::shared_ptr<CSSVariableData> CSSVariableData::Create(CSSTokenizedValue value,
                                                         bool is_animation_tainted,
                                                         bool needs_variable_resolution) {
  bool has_font_units = false;
  bool has_root_font_units = false;
  bool has_line_height_units = false;
  while (!value.range.AtEnd()) {
    ExtractFeatures(value.range.Consume(), has_font_units, has_root_font_units, has_line_height_units);
  }
  return Create(value.text, is_animation_tainted, needs_variable_resolution, has_font_units, has_root_font_units,
                has_line_height_units);
}

std::shared_ptr<CSSVariableData> CSSVariableData::Create(const String& original_text,
                                                         bool is_animation_tainted,
                                                         bool needs_variable_resolution) {
  bool has_font_units = false;
  bool has_root_font_units = false;
  bool has_line_height_units = false;
  CSSTokenizer tokenizer{StringView(original_text)};
  CSSParserTokenStream stream(tokenizer);
  while (!stream.AtEnd()) {
    ExtractFeatures(stream.ConsumeRaw(), has_font_units, has_root_font_units, has_line_height_units);
  }
  return Create(StringView(original_text), is_animation_tainted, needs_variable_resolution, has_font_units, has_root_font_units,
                has_line_height_units);
}

String CSSVariableData::Serialize() const {
  StringView text = OriginalText();
  if (length_ > 0 && text[length_ - 1] == '\\') {
    // https://drafts.csswg.org/css-syntax/#consume-escaped-code-point
    // '\' followed by EOF is consumed as U+FFFD.
    // https://drafts.csswg.org/css-syntax/#consume-string-token
    // '\' followed by EOF in a string token is ignored.
    //
    // The tokenizer handles both of these cases when returning tokens, but
    // since we're working with the original string, we need to deal with them
    // ourselves.
    String serialized_text = String(text);
    //    serialized_text.Resize(serialized_text.length() - 1);

    CSSTokenizer tokenizer{text};
    CSSParserTokenStream stream(tokenizer);
    CSSParserTokenType last_token_type = kEOFToken;
    for (;;) {
      CSSParserTokenType token_type = stream.ConsumeRaw().GetType();
      if (token_type == kEOFToken) {
        break;
      }
      last_token_type = token_type;
    }

    char16_t kReplacementCharacter = 0xFFFD;

    if (last_token_type != kStringToken) {
      // Append replacement character
      UChar replacement[] = { kReplacementCharacter };
      serialized_text = serialized_text + String(replacement, 1);
    }

    // Certain token types implicitly include terminators when serialized.
    // https://drafts.csswg.org/cssom/#common-serializing-idioms
    if (last_token_type == kStringToken) {
      serialized_text = serialized_text + String::FromUTF8("\"");
    }
    if (last_token_type == kUrlToken) {
      serialized_text = serialized_text + String::FromUTF8(")");
    }

    return serialized_text;
  }

  return String(OriginalText());
}

bool CSSVariableData::operator==(const CSSVariableData& other) const {
  return OriginalText() == other.OriginalText();
}

CSSVariableData::CSSVariableData(PassKey,
                                 StringView original_text,
                                 bool is_animation_tainted,
                                 bool needs_variable_resolution,
                                 bool has_font_units,
                                 bool has_root_font_units,
                                 bool has_line_height_units)
    : length_(original_text.length()),
      is_animation_tainted_(is_animation_tainted),
      needs_variable_resolution_(needs_variable_resolution),
      is_8bit_(original_text.Is8Bit()),
      has_font_units_(has_font_units),
      has_root_font_units_(has_root_font_units),
      has_line_height_units_(has_line_height_units),
      unused_(0) {
  // Copy the string data after the object, preserving the original encoding
  if (original_text.Is8Bit()) {
    std::memcpy(reinterpret_cast<LChar*>(this + 1), original_text.Characters8(), original_text.length());
  } else {
    std::memcpy(reinterpret_cast<UChar*>(this + 1), original_text.Characters16(), original_text.length() * sizeof(UChar));
  }
}

}  // namespace webf
