// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "css_syntax_definition.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/css/css_custom_ident_value.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/css_unparsed_declaration_value.h"

namespace webf {

namespace {

std::shared_ptr<const CSSValue> ConsumeSingleType(const CSSSyntaxComponent& syntax,
                                  CSSParserTokenStream& stream,
                                  std::shared_ptr<const CSSParserContext> context) {
  switch (syntax.GetType()) {
    case CSSSyntaxType::kIdent:
      if (stream.Peek().GetType() == kIdentToken &&
          stream.Peek().Value() == syntax.GetString()) {
        stream.ConsumeIncludingWhitespace();
        return std::make_shared<CSSCustomIdentValue>(syntax.GetString());
      }
      return nullptr;
    case CSSSyntaxType::kLength: {
      CSSParserContext::ParserModeOverridingScope scope(*context,
                                                        kHTMLStandardMode);
      return css_parsing_utils::ConsumeLength(
          stream, context, CSSPrimitiveValue::ValueRange::kAll);
    }
    case CSSSyntaxType::kNumber:
      return css_parsing_utils::ConsumeNumber(
          stream, context, CSSPrimitiveValue::ValueRange::kAll);
    case CSSSyntaxType::kPercentage:
      return css_parsing_utils::ConsumePercent(
          stream, context, CSSPrimitiveValue::ValueRange::kAll);
    case CSSSyntaxType::kLengthPercentage: {
      CSSParserContext::ParserModeOverridingScope scope(*context,
                                                        kHTMLStandardMode);
      return css_parsing_utils::ConsumeLengthOrPercent(
          stream, context, CSSPrimitiveValue::ValueRange::kAll,
          css_parsing_utils::UnitlessQuirk::kForbid, kCSSAnchorQueryTypesAll);
    }
    case CSSSyntaxType::kColor: {
      CSSParserContext::ParserModeOverridingScope scope(*context,
                                                        kHTMLStandardMode);
      return css_parsing_utils::ConsumeColor(stream, context);
    }
    case CSSSyntaxType::kImage:
      return css_parsing_utils::ConsumeImage(stream, context);
    case CSSSyntaxType::kUrl:
      return css_parsing_utils::ConsumeUrl(stream, context);
    case CSSSyntaxType::kInteger:
      return css_parsing_utils::ConsumeIntegerOrNumberCalc(stream, context);
    case CSSSyntaxType::kAngle:
      return css_parsing_utils::ConsumeAngle(stream, context);
    case CSSSyntaxType::kTime:
      return css_parsing_utils::ConsumeTime(
          stream, context, CSSPrimitiveValue::ValueRange::kAll);
    case CSSSyntaxType::kResolution:
      return css_parsing_utils::ConsumeResolution(stream, context);
    case CSSSyntaxType::kTransformFunction:
      return css_parsing_utils::ConsumeTransformValue(stream, context);
    case CSSSyntaxType::kTransformList:
      return css_parsing_utils::ConsumeTransformList(stream, context);
    case CSSSyntaxType::kCustomIdent:
      return css_parsing_utils::ConsumeCustomIdent(stream, context);
    default:
      NOTREACHED_IN_MIGRATION();
      return nullptr;
  }
}

std::shared_ptr<const CSSValue> ConsumeSyntaxComponent(const CSSSyntaxComponent& syntax,
                                       CSSParserTokenStream& stream,
                                       std::shared_ptr<const CSSParserContext> context) {
  // CSS-wide keywords are already handled by the CSSPropertyParser
  if (syntax.GetRepeat() == CSSSyntaxRepeat::kSpaceSeparated) {
    auto list = CSSValueList::CreateSpaceSeparated();
    while (!stream.AtEnd()) {
      auto value = ConsumeSingleType(syntax, stream, context);
      if (!value) {
        return nullptr;
      }
      list->Append(value);
    }
    return list->length() ? list : nullptr;
  }
  if (syntax.GetRepeat() == CSSSyntaxRepeat::kCommaSeparated) {
    auto list = CSSValueList::CreateCommaSeparated();
    do {
      auto value = ConsumeSingleType(syntax, stream, context);
      if (!value) {
        return nullptr;
      }
      list->Append(value);
    } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(stream));
    return list->length() && stream.AtEnd() ? list : nullptr;
  }
  auto result = ConsumeSingleType(syntax, stream, context);
  if (!stream.AtEnd()) {
    return nullptr;
  }
  return result;
}

}  // namespace

std::shared_ptr<const CSSValue> CSSSyntaxDefinition::Parse(const std::string& text,
                                           std::shared_ptr<const CSSParserContext> context,
                                           bool is_animation_tainted) const {
  if (IsUniversal()) {
    return CSSVariableParser::ParseUniversalSyntaxValue(text, context,
                                                        is_animation_tainted);
  }
  for (const CSSSyntaxComponent& component : syntax_components_) {
    CSSTokenizer tokenizer(text);
    CSSParserTokenStream stream(tokenizer);
    stream.ConsumeWhitespace();
    if (auto result =
            ConsumeSyntaxComponent(component, stream, context)) {
      return result;
    }
  }
  return nullptr;
}

CSSSyntaxDefinition CSSSyntaxDefinition::IsolatedCopy() const {
  std::vector<CSSSyntaxComponent> syntax_components_copy;
  syntax_components_copy.reserve(syntax_components_.size());
  for (const auto& syntax_component : syntax_components_) {
    syntax_components_copy.push_back(CSSSyntaxComponent(
        syntax_component.GetType(), syntax_component.GetString(),
        syntax_component.GetRepeat()));
  }
  return CSSSyntaxDefinition(std::move(syntax_components_copy), original_text_);
}

CSSSyntaxDefinition::CSSSyntaxDefinition(std::vector<CSSSyntaxComponent> components,
                                         const std::string& original_text)
    : syntax_components_(std::move(components)), original_text_(original_text) {
  DCHECK(syntax_components_.size());
}

CSSSyntaxDefinition CSSSyntaxDefinition::CreateUniversal() {
  std::vector<CSSSyntaxComponent> components;
  components.push_back(CSSSyntaxComponent(
      CSSSyntaxType::kTokenStream, "", CSSSyntaxRepeat::kNone));
  return CSSSyntaxDefinition(std::move(components), {});
}

std::string CSSSyntaxDefinition::ToString() const {
  return IsUniversal() ? "*" : original_text_;
}


}