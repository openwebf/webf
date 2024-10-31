// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "at_rule_descriptor_parser.h"
#include "core/base/strings/string_util.h"
#include "core/css/css_font_face_src_value.h"
#include "core/css/css_unparsed_declaration_value.h"
#include "core/css/css_value_list.h"
#include "core/css/parser/css_parser_token_range.h"
#include "core/css/parser/css_tokenized_value.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/css_value_pair.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/properties/css_parsing_utils.h"

namespace webf {

namespace {

std::shared_ptr<const CSSValue> ConsumeFontVariantList(CSSParserTokenRange& range) {
  std::shared_ptr<CSSValueList> values = CSSValueList::CreateCommaSeparated();
  do {
    if (range.Peek().Id() == CSSValueID::kAll) {
      // FIXME: CSSPropertyParser::ParseFontVariant() implements
      // the old css3 draft:
      // http://www.w3.org/TR/2002/WD-css3-webfonts-20020802/#font-variant
      // 'all' is only allowed in @font-face and with no other values.
      if (values->length()) {
        return nullptr;
      }
      return css_parsing_utils::ConsumeIdent(range);
    }
    std::shared_ptr<const CSSIdentifierValue> font_variant = css_parsing_utils::ConsumeFontVariantCSS21(range);
    if (font_variant) {
      values->Append(font_variant);
    }
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(range));

  if (values->length()) {
    return values;
  }

  return nullptr;
}

std::shared_ptr<const CSSIdentifierValue> ConsumeFontDisplay(CSSParserTokenRange& range) {
  return css_parsing_utils::ConsumeIdent<CSSValueID::kAuto, CSSValueID::kBlock, CSSValueID::kSwap,
                                         CSSValueID::kFallback, CSSValueID::kOptional>(range);
}

bool IsSupportedFontFormat(std::string font_format) {
  return css_parsing_utils::IsSupportedKeywordFormat(css_parsing_utils::FontFormatToId(font_format));
}

CSSFontFaceSrcValue::FontTechnology ValueIDToTechnology(CSSValueID valueID) {
  switch (valueID) {
    case CSSValueID::kFeaturesAat:
      return CSSFontFaceSrcValue::FontTechnology::kTechnologyFeaturesAAT;
    case CSSValueID::kFeaturesOpentype:
      return CSSFontFaceSrcValue::FontTechnology::kTechnologyFeaturesOT;
    case CSSValueID::kVariations:
      return CSSFontFaceSrcValue::FontTechnology::kTechnologyVariations;
    case CSSValueID::kPalettes:
      return CSSFontFaceSrcValue::FontTechnology::kTechnologyPalettes;
    case CSSValueID::kColorSbix:
      return CSSFontFaceSrcValue::FontTechnology::kTechnologySBIX;
    default:
      NOTREACHED_IN_MIGRATION();
      return CSSFontFaceSrcValue::FontTechnology::kTechnologyUnknown;
  }
}

std::shared_ptr<const CSSValue> ConsumeFontFaceSrcURI(CSSParserTokenRange& range,
                                                      std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const cssvalue::CSSURIValue> src_value = css_parsing_utils::ConsumeUrl(range, context);
  if (!src_value) {
    return nullptr;
  }
  auto uri_value = CSSFontFaceSrcValue::Create(src_value);

  // After the url() it's either the end of the src: line, or a comma
  // for the next url() or format().
  if (!range.AtEnd() && range.Peek().GetType() != CSSParserTokenType::kCommaToken &&
      (range.Peek().GetType() != CSSParserTokenType::kFunctionToken ||
       (range.Peek().FunctionId() != CSSValueID::kFormat && range.Peek().FunctionId() != CSSValueID::kTech))) {
    return nullptr;
  }

  if (range.Peek().FunctionId() == CSSValueID::kFormat) {
    CSSParserTokenRange format_args = css_parsing_utils::ConsumeFunction(range);
    CSSParserTokenType peek_type = format_args.Peek().GetType();
    if (peek_type != kIdentToken && peek_type != kStringToken) {
      return nullptr;
    }

    std::string sanitized_format;

    if (peek_type == kIdentToken) {
      std::shared_ptr<const CSSIdentifierValue> font_format = css_parsing_utils::ConsumeFontFormatIdent(format_args);
      if (!font_format) {
        return nullptr;
      }
      sanitized_format = font_format->CssText();
    }

    if (peek_type == kStringToken) {
      sanitized_format = css_parsing_utils::ConsumeString(format_args)->Value();
    }

    if (IsSupportedFontFormat(sanitized_format)) {
      uri_value->SetFormat(sanitized_format);
    } else {
      return nullptr;
    }

    format_args.ConsumeWhitespace();

    // After one argument to the format function, there shouldn't be anything
    // else, for example not a comma.
    if (!format_args.AtEnd()) {
      return nullptr;
    }
  }

  if (range.Peek().FunctionId() == CSSValueID::kTech) {
    CSSParserTokenRange tech_args = css_parsing_utils::ConsumeFunction(range);

    // One or more tech args expected.
    if (tech_args.AtEnd()) {
      return nullptr;
    }
  }

  return uri_value;
}

std::shared_ptr<const CSSValue> ConsumeFontFaceSrcLocal(CSSParserTokenRange& range,
                                                        std::shared_ptr<const CSSParserContext> context) {
  CSSParserTokenRange args = css_parsing_utils::ConsumeFunction(range);
  if (args.Peek().GetType() == kStringToken) {
    const CSSParserToken& arg = args.ConsumeIncludingWhitespace();
    if (!args.AtEnd()) {
      return nullptr;
    }
    return CSSFontFaceSrcValue::CreateLocal(std::string(arg.Value()));
  }
  if (args.Peek().GetType() == kIdentToken) {
    std::string family_name = css_parsing_utils::ConcatenateFamilyName(args);
    if (!args.AtEnd()) {
      return nullptr;
    }
    if (family_name.empty()) {
      return nullptr;
    }
    return CSSFontFaceSrcValue::CreateLocal(family_name);
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeFontFaceSrcSkipToComma(
    std::shared_ptr<const CSSValue> parse_function(CSSParserTokenRange&,
                                                   std::shared_ptr<const CSSParserContext> context),
    CSSParserTokenRange& range,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parse_result = parse_function(range, std::move(context));
  range.ConsumeWhitespace();
  if (parse_result && (range.AtEnd() || range.Peek().GetType() == CSSParserTokenType::kCommaToken)) {
    return parse_result;
  }

  while (!range.AtEnd() && range.Peek().GetType() != CSSParserTokenType::kCommaToken) {
    range.Consume();
  }
  return nullptr;
}

std::shared_ptr<const CSSValueList> ConsumeFontFaceSrc(CSSParserTokenRange& range,
                                                       std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<CSSValueList> values = CSSValueList::CreateCommaSeparated();

  range.ConsumeWhitespace();
  do {
    const CSSParserToken& token = range.Peek();
    std::shared_ptr<CSSValue> parsed_value = nullptr;
    if (token.FunctionId() == CSSValueID::kLocal) {
      parsed_value =
          std::const_pointer_cast<CSSValue>(ConsumeFontFaceSrcSkipToComma(ConsumeFontFaceSrcLocal, range, context));
    } else {
      parsed_value =
          std::const_pointer_cast<CSSValue>(ConsumeFontFaceSrcSkipToComma(ConsumeFontFaceSrcURI, range, context));
    }
    if (parsed_value) {
      values->Append(parsed_value);
    }
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(range));

  return values->length() ? values : nullptr;
}

std::shared_ptr<const CSSValue> ConsumeDescriptor(StyleRule::RuleType rule_type,
                                                  AtRuleDescriptorID id,
                                                  const CSSTokenizedValue& tokenized_value,
                                                  std::shared_ptr<const CSSParserContext> context) {
  using Parser = AtRuleDescriptorParser;
  CSSParserTokenRange range = tokenized_value.range;

  switch (rule_type) {
    case StyleRule::kFontFace:
      return Parser::ParseFontFaceDescriptor(id, tokenized_value, context);
    case StyleRule::kFontPaletteValues:
      return Parser::ParseAtFontPaletteValuesDescriptor(id, range, context);
    case StyleRule::kProperty:
      return Parser::ParseAtPropertyDescriptor(id, tokenized_value, context);
    case StyleRule::kViewTransition:
      return Parser::ParseAtViewTransitionDescriptor(id, range, context);
    case StyleRule::kCharset:
    case StyleRule::kContainer:
    case StyleRule::kStyle:
    case StyleRule::kImport:
    case StyleRule::kMedia:
    case StyleRule::kPage:
    case StyleRule::kPageMargin:
    case StyleRule::kKeyframes:
    case StyleRule::kKeyframe:
    case StyleRule::kFontFeatureValues:
    case StyleRule::kFontFeature:
    case StyleRule::kLayerBlock:
    case StyleRule::kLayerStatement:
    case StyleRule::kNamespace:
    case StyleRule::kScope:
    case StyleRule::kSupports:
    case StyleRule::kStartingStyle:
    case StyleRule::kFunction:
    case StyleRule::kPositionTry:
    default:
      // TODO(andruud): Handle other descriptor types here.
      NOTREACHED_IN_MIGRATION();
      return nullptr;
  }
}

std::shared_ptr<const CSSValue> ConsumeFontMetricOverride(CSSParserTokenRange& range,
                                                          std::shared_ptr<const CSSParserContext> context) {
  if (auto normal = css_parsing_utils::ConsumeIdent<CSSValueID::kNormal>(range)) {
    return normal;
  }
  return css_parsing_utils::ConsumePercent(range, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}

}  // namespace

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDescriptor(
    AtRuleDescriptorID id,
    CSSParserTokenRange& range,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  range.ConsumeWhitespace();
  switch (id) {
    case AtRuleDescriptorID::FontFamily:
      // In order to avoid confusion, <family-name> does not accept unquoted
      // <generic-family> keywords and general CSS keywords.
      // ConsumeGenericFamily will take care of excluding the former while the
      // ConsumeFamilyName will take care of excluding the latter.
      // See https://drafts.csswg.org/css-fonts/#family-name-syntax,
      if (css_parsing_utils::ConsumeGenericFamily(range)) {
        return nullptr;
      }
      parsed_value = css_parsing_utils::ConsumeFamilyName(range);
      break;
    case AtRuleDescriptorID::Src:  // This is a list of urls or local
                                   // references.
      parsed_value = ConsumeFontFaceSrc(range, context);
      break;
    case AtRuleDescriptorID::FontDisplay:
      parsed_value = ConsumeFontDisplay(range);
      break;
    case AtRuleDescriptorID::FontStretch: {
      CSSParserContext::ParserModeOverridingScope scope(*context, kCSSFontFaceRuleMode);
      parsed_value = css_parsing_utils::ConsumeFontStretch(range, context);
      break;
    }
    case AtRuleDescriptorID::FontStyle: {
      CSSParserContext::ParserModeOverridingScope scope(*context, kCSSFontFaceRuleMode);
      parsed_value = css_parsing_utils::ConsumeFontStyle(range, context);
      break;
    }
    case AtRuleDescriptorID::FontVariant:
      parsed_value = ConsumeFontVariantList(range);
      break;
    case AtRuleDescriptorID::FontWeight: {
      CSSParserContext::ParserModeOverridingScope scope(*context, kCSSFontFaceRuleMode);
      parsed_value = css_parsing_utils::ConsumeFontWeight(range, context);
      break;
    }
    case AtRuleDescriptorID::FontFeatureSettings:
      parsed_value = css_parsing_utils::ConsumeFontFeatureSettings(range, context);
      break;
    case AtRuleDescriptorID::AscentOverride:
    case AtRuleDescriptorID::DescentOverride:
    case AtRuleDescriptorID::LineGapOverride:
      parsed_value = ConsumeFontMetricOverride(range, context);
      break;
    case AtRuleDescriptorID::SizeAdjust:
      parsed_value = css_parsing_utils::ConsumePercent(range, context, CSSPrimitiveValue::ValueRange::kNonNegative);
      break;
    default:
      break;
  }

  if (!parsed_value || !range.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDescriptor(
    AtRuleDescriptorID id,
    const std::string& string,
    std::shared_ptr<const CSSParserContext> context) {
  CSSTokenizer tokenizer(string);
  std::vector<CSSParserToken> tokens;
  tokens.reserve(32);

  tokens = tokenizer.TokenizeToEOF();
  CSSParserTokenRange range = CSSParserTokenRange(tokens);
  return ParseFontFaceDescriptor(id, range, context);
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDescriptor(
    AtRuleDescriptorID id,
    const CSSTokenizedValue& tokenized_value,
    std::shared_ptr<const CSSParserContext> context) {
  CSSParserTokenRange range = tokenized_value.range;
  return ParseFontFaceDescriptor(id, range, context);
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDeclaration(
    CSSParserTokenRange& range,
    std::shared_ptr<const CSSParserContext> context) {
  DCHECK_EQ(range.Peek().GetType(), kIdentToken);
  const CSSParserToken& token = range.ConsumeIncludingWhitespace();
  AtRuleDescriptorID id = token.ParseAsAtRuleDescriptorID();

  if (range.Consume().GetType() != kColonToken) {
    return nullptr;  // Parse error
  }

  return ParseFontFaceDescriptor(id, range, context);
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseAtPropertyDescriptor(
    AtRuleDescriptorID id,
    const CSSTokenizedValue& tokenized_value,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  CSSParserTokenRange range = tokenized_value.range;
  switch (id) {
    case AtRuleDescriptorID::Syntax:
      range.ConsumeWhitespace();
      parsed_value = css_parsing_utils::ConsumeString(range);
      break;
    case AtRuleDescriptorID::InitialValue: {
      // Note that we must retain leading whitespace here.
      return CSSVariableParser::ParseDeclarationValue(tokenized_value, false /* is_animation_tainted */, context);
    }
    case AtRuleDescriptorID::Inherits:
      range.ConsumeWhitespace();
      parsed_value = css_parsing_utils::ConsumeIdent<CSSValueID::kTrue, CSSValueID::kFalse>(range);
      break;
    default:
      break;
  }

  if (!parsed_value || !range.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseAtViewTransitionDescriptor(
    AtRuleDescriptorID id,
    CSSParserTokenRange& range,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  switch (id) {
    case AtRuleDescriptorID::Navigation:
      range.ConsumeWhitespace();
      parsed_value = css_parsing_utils::ConsumeIdent<CSSValueID::kAuto, CSSValueID::kNone>(range);
      break;
    case AtRuleDescriptorID::Types: {
      std::shared_ptr<CSSValueList> types = CSSValueList::CreateSpaceSeparated();
      parsed_value = types;
      while (!range.AtEnd()) {
        range.ConsumeWhitespace();
        if (range.Peek().Id() == CSSValueID::kNone) {
          return nullptr;
        }
        std::shared_ptr<const CSSCustomIdentValue> ident = css_parsing_utils::ConsumeCustomIdent(range, context);
        if (!ident || base::StartsWith(ident->Value(), "-ua-")) {
          return nullptr;
        }
        types->Append(ident);
      }
      break;
    }
    default:
      break;
  }

  if (!parsed_value || !range.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

bool AtRuleDescriptorParser::ParseAtRule(StyleRule::RuleType rule_type,
                                         AtRuleDescriptorID id,
                                         const CSSTokenizedValue& tokenized_value,
                                         std::shared_ptr<const CSSParserContext> context,
                                         std::vector<CSSPropertyValue>& parsed_descriptors) {
  std::shared_ptr<const CSSValue> result = ConsumeDescriptor(rule_type, id, tokenized_value, std::move(context));

  if (!result) {
    return false;
  }
  // Convert to CSSPropertyID for legacy compatibility,
  // TODO(crbug.com/752745): Refactor CSSParserImpl to avoid using
  // the CSSPropertyID.
  CSSPropertyID equivalent_property_id = AtRuleDescriptorIDAsCSSPropertyID(id);
  parsed_descriptors.push_back(CSSPropertyValue(CSSPropertyName(equivalent_property_id), result));
  return true;
}

std::shared_ptr<const CSSValue> ConsumeFontFamily(CSSParserTokenRange& range,
                                                  std::shared_ptr<const CSSParserContext> context) {
  return css_parsing_utils::ConsumeNonGenericFamilyNameList(range);
}

std::shared_ptr<const CSSValue> ConsumeBasePalette(CSSParserTokenRange& range,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (auto ident = css_parsing_utils::ConsumeIdent<CSSValueID::kLight, CSSValueID::kDark>(range)) {
    return ident;
  }

  return css_parsing_utils::ConsumeInteger(range, context, 0);
}

std::shared_ptr<const CSSValue> ConsumeColorOverride(CSSParserTokenRange& range,
                               std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  do {
    auto color_index =
        css_parsing_utils::ConsumeInteger(range, context, 0);
    if (!color_index) {
      return nullptr;
    }
    range.ConsumeWhitespace();
    auto color = css_parsing_utils::ConsumeAbsoluteColor(range, context);
    if (!color) {
      return nullptr;
    }
    auto color_identifier = DynamicTo<CSSIdentifierValue>(color.get());
    if (color_identifier &&
        color_identifier->GetValueID() == CSSValueID::kCurrentcolor) {
      return nullptr;
    }
    list->Append(std::make_shared<CSSValuePair>(
        color_index, color, CSSValuePair::kKeepIdenticalValues));
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(range));
  if (!range.AtEnd() || !list->length()) {
    return nullptr;
  }

  return list;
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseAtFontPaletteValuesDescriptor(
    AtRuleDescriptorID id,
    CSSParserTokenRange& range,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;

  switch (id) {
    case AtRuleDescriptorID::FontFamily:
      range.ConsumeWhitespace();
      parsed_value = ConsumeFontFamily(range, context);
      break;
    case AtRuleDescriptorID::BasePalette:
      range.ConsumeWhitespace();
      parsed_value = ConsumeBasePalette(range, context);
      break;
    case AtRuleDescriptorID::OverrideColors:
      range.ConsumeWhitespace();
      parsed_value = ConsumeColorOverride(range, context);
      break;
    default:
      break;
  }

  if (!parsed_value || !range.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

}  // namespace webf
