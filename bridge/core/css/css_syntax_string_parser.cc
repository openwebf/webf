// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_syntax_string_parser.h"
#include "core/css/parser/css_parser_idioms.h"
#include "core/css/properties/css_parsing_utils.h"

namespace webf {

namespace {

// https://drafts.css-houdini.org/css-properties-values-api-1/#supported-names
std::optional<CSSSyntaxType> ParseSyntaxType(std::string_view type) {
  if (type == "length") {
    return CSSSyntaxType::kLength;
  }
  if (type == "number") {
    return CSSSyntaxType::kNumber;
  }
  if (type == "percentage") {
    return CSSSyntaxType::kPercentage;
  }
  if (type == "length-percentage") {
    return CSSSyntaxType::kLengthPercentage;
  }
  if (type == "color") {
    return CSSSyntaxType::kColor;
  }
  if (type == "image") {
    return CSSSyntaxType::kImage;
  }
  if (type == "url") {
    return CSSSyntaxType::kUrl;
  }
  if (type == "integer") {
    return CSSSyntaxType::kInteger;
  }
  if (type == "angle") {
    return CSSSyntaxType::kAngle;
  }
  if (type == "time") {
    return CSSSyntaxType::kTime;
  }
  if (type == "resolution") {
    return CSSSyntaxType::kResolution;
  }
  if (type == "transform-function") {
    return CSSSyntaxType::kTransformFunction;
  }
  if (type == "transform-list") {
    return CSSSyntaxType::kTransformList;
  }
  if (type == "custom-ident") {
    return CSSSyntaxType::kCustomIdent;
  }
  return std::nullopt;
}

bool IsPreMultiplied(CSSSyntaxType type) {
  return type == CSSSyntaxType::kTransformList;
}

}  // namespace

// Trim from the start (left trim)
static inline std::string ltrim(std::string s) {
  s.erase(s.begin(), std::find_if(s.begin(), s.end(), [](unsigned char ch) {
            return !std::isspace(ch);
          }));
  return s;
}

// Trim from the end (right trim)
static inline std::string rtrim(std::string s) {
  s.erase(std::find_if(s.rbegin(), s.rend(), [](unsigned char ch) {
            return !std::isspace(ch);
          }).base(), s.end());
  return s;
}

// Trim from both ends (left and right trim)
static inline std::string trim(std::string s) {
  return ltrim(rtrim(s));
}

CSSSyntaxStringParser::CSSSyntaxStringParser(const std::string& string)
    : string_(trim(string)), input_(string_) {}

std::optional<CSSSyntaxDefinition> CSSSyntaxStringParser::Parse() {
  if (string_.empty()) {
    return std::nullopt;
  }
  if (string_.length() == 1 && string_[0] == '*') {
    return CSSSyntaxDefinition::CreateUniversal();
  }

  std::vector<CSSSyntaxComponent> components;

  while (true) {
    if (!ConsumeSyntaxComponent(components)) {
      return std::nullopt;
    }
    input_.AdvanceUntilNonWhitespace();
    char cc = input_.NextInputChar();
    input_.Advance();
    if (cc == '\0') {
      break;
    }
    if (cc == '|') {
      continue;
    }
    return std::nullopt;
  }

  return CSSSyntaxDefinition(std::move(components), string_);
}

bool CSSSyntaxStringParser::ConsumeSyntaxComponent(
    std::vector<CSSSyntaxComponent>& components) {
  input_.AdvanceUntilNonWhitespace();

  CSSSyntaxType type = CSSSyntaxType::kTokenStream;
  std::string ident;

  char cc = input_.NextInputChar();
  input_.Advance();

  if (cc == '<') {
    if (!ConsumeDataTypeName(type)) {
      return false;
    }
  } else if (IsNameStartCodePoint(cc) || cc == '\\') {
    if (NextCharsAreIdentifier(cc, input_)) {
      input_.PushBack(cc);
      type = CSSSyntaxType::kIdent;
      if (!ConsumeIdent(ident)) {
        return false;
      }
    }
  } else {
    return false;
  }

  DCHECK_NE(type, CSSSyntaxType::kTokenStream);

  CSSSyntaxRepeat repeat =
      IsPreMultiplied(type) ? CSSSyntaxRepeat::kNone : ConsumeRepeatIfPresent();
  components.emplace_back(type, ident, repeat);
  return true;
}

CSSSyntaxRepeat CSSSyntaxStringParser::ConsumeRepeatIfPresent() {
  char cc = input_.NextInputChar();
  if (cc == '+') {
    input_.Advance();
    return CSSSyntaxRepeat::kSpaceSeparated;
  }
  if (cc == '#') {
    input_.Advance();
    return CSSSyntaxRepeat::kCommaSeparated;
  }
  return CSSSyntaxRepeat::kNone;
}

bool CSSSyntaxStringParser::ConsumeDataTypeName(CSSSyntaxType& type) {
  for (unsigned size = 0;; ++size) {
    char cc = input_.PeekWithoutReplacement(size);
    if (IsNameCodePoint(cc)) {
      continue;
    }
    if (cc == '>') {
      unsigned start = input_.Offset();
      input_.Advance(size + 1);
      if (auto syntax_type = ParseSyntaxType(input_.RangeAt(start, size))) {
        type = *syntax_type;
        return true;
      }
      return false;
    }
    return false;
  }
}

bool CSSSyntaxStringParser::ConsumeIdent(std::string& ident) {
  ident = ConsumeName(input_);
  return !css_parsing_utils::IsCSSWideKeyword(ident) &&
         !css_parsing_utils::IsDefaultKeyword(ident);
}


}