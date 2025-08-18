// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "at_rule_descriptor_parser.h"
#include "core/base/strings/string_util.h"
#include "core/css/css_font_face_src_value.h"
#include "core/css/css_unparsed_declaration_value.h"
#include "core/css/css_value_list.h"
#include "core/css/css_value_pair.h"
#include "core/css/parser/css_tokenized_value.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/properties/css_parsing_utils.h"

namespace webf {

namespace {


// Stream versions of helper functions
std::shared_ptr<const CSSValue> ConsumeFontVariantList(CSSParserTokenStream& stream) {
  std::shared_ptr<CSSValueList> values = CSSValueList::CreateCommaSeparated();
  do {
    if (stream.Peek().Id() == CSSValueID::kAll) {
      // FIXME: CSSPropertyParser::ParseFontVariant() implements
      // the old css3 draft:
      // http://www.w3.org/TR/2002/WD-css3-webfonts-20020802/#font-variant
      // 'all' is only allowed in @font-face and with no other values.
      if (values->length()) {
        return nullptr;
      }
      return css_parsing_utils::ConsumeIdent(stream);
    }
    std::shared_ptr<const CSSIdentifierValue> font_variant = css_parsing_utils::ConsumeFontVariantCSS21(stream);
    if (font_variant) {
      values->Append(font_variant);
    }
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(stream));

  if (values->length()) {
    return values;
  }

  return nullptr;
}

std::shared_ptr<const CSSIdentifierValue> ConsumeFontDisplay(CSSParserTokenStream& stream) {
  return css_parsing_utils::ConsumeIdent<CSSValueID::kAuto, CSSValueID::kBlock, CSSValueID::kSwap,
                                         CSSValueID::kFallback, CSSValueID::kOptional>(stream);
}

// Stream versions of helper functions for ConsumeFontFaceSrc
std::shared_ptr<const CSSValue> ConsumeFontFaceSrcURI(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeFontFaceSrcLocal(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context);

std::shared_ptr<const CSSValue> ConsumeFontFaceSrcSkipToComma(
    std::shared_ptr<const CSSValue> parse_function(CSSParserTokenStream&,
                                                   std::shared_ptr<const CSSParserContext> context),
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parse_result = parse_function(stream, std::move(context));
  stream.ConsumeWhitespace();
  if (parse_result && (stream.AtEnd() || stream.Peek().GetType() == CSSParserTokenType::kCommaToken)) {
    return parse_result;
  }

  while (!stream.AtEnd() && stream.Peek().GetType() != CSSParserTokenType::kCommaToken) {
    stream.Consume();
  }
  return nullptr;
}

std::shared_ptr<const CSSValueList> ConsumeFontFaceSrc(CSSParserTokenStream& stream,
                                                       std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<CSSValueList> values = CSSValueList::CreateCommaSeparated();

  stream.ConsumeWhitespace();
  do {
    const CSSParserToken& token = stream.Peek();
    std::shared_ptr<CSSValue> parsed_value = nullptr;
    if (token.FunctionId() == CSSValueID::kLocal) {
      parsed_value =
          std::const_pointer_cast<CSSValue>(ConsumeFontFaceSrcSkipToComma(ConsumeFontFaceSrcLocal, stream, context));
    } else {
      parsed_value =
          std::const_pointer_cast<CSSValue>(ConsumeFontFaceSrcSkipToComma(ConsumeFontFaceSrcURI, stream, context));
    }
    if (parsed_value) {
      values->Append(parsed_value);
    }
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(stream));

  return values->length() ? values : nullptr;
}

std::shared_ptr<const CSSValue> ConsumeFontMetricOverride(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context) {
  if (std::shared_ptr<const CSSIdentifierValue> normal = 
          css_parsing_utils::ConsumeIdent<CSSValueID::kNormal>(stream)) {
    return normal;
  }
  return css_parsing_utils::ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
}



bool IsSupportedFontFormat(const String& font_format) {
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
// Stream versions of ConsumeFontFaceSrcURI and ConsumeFontFaceSrcLocal
std::shared_ptr<const CSSValue> ConsumeFontFaceSrcURI(CSSParserTokenStream& stream,
                                                      std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const cssvalue::CSSURIValue> src_value = css_parsing_utils::ConsumeUrl(stream, context);
  if (!src_value) {
    return nullptr;
  }
  auto uri_value = CSSFontFaceSrcValue::Create(src_value);

  // After the url() it's either the end of the src: line, or a comma
  // for the next url() or format().
  if (!stream.AtEnd() && stream.Peek().GetType() != CSSParserTokenType::kCommaToken &&
      (stream.Peek().GetType() != CSSParserTokenType::kFunctionToken ||
       (stream.Peek().FunctionId() != CSSValueID::kFormat && stream.Peek().FunctionId() != CSSValueID::kTech))) {
    return nullptr;
  }

  if (stream.Peek().FunctionId() == CSSValueID::kFormat) {
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();
    CSSParserTokenType peek_type = stream.Peek().GetType();
    if (peek_type != kIdentToken && peek_type != kStringToken) {
      return nullptr;
    }

    String sanitized_format;

    if (peek_type == kIdentToken) {
      std::shared_ptr<const CSSIdentifierValue> font_format = css_parsing_utils::ConsumeFontFormatIdent(stream);
      if (!font_format) {
        return nullptr;
      }
      sanitized_format = font_format->CssText();
    }

    if (peek_type == kStringToken) {
      sanitized_format = css_parsing_utils::ConsumeString(stream)->Value();
    }

    if (IsSupportedFontFormat(sanitized_format)) {
      uri_value->SetFormat(sanitized_format);
    } else {
      return nullptr;
    }

    stream.ConsumeWhitespace();

    // After one argument to the format function, there shouldn't be anything
    // else, for example not a comma.
    if (!stream.AtEnd()) {
      return nullptr;
    }
  }

  if (stream.Peek().FunctionId() == CSSValueID::kTech) {
    CSSParserTokenStream::BlockGuard guard(stream);
    stream.ConsumeWhitespace();

    // One or more tech args expected.
    if (stream.AtEnd()) {
      return nullptr;
    }
  }

  return uri_value;
}

std::shared_ptr<const CSSValue> ConsumeFontFaceSrcLocal(CSSParserTokenStream& stream,
                                                        std::shared_ptr<const CSSParserContext> context) {
  CSSParserTokenStream::BlockGuard guard(stream);
  
  if (stream.Peek().GetType() == kStringToken) {
    const CSSParserToken& arg = stream.ConsumeIncludingWhitespace();
    if (!stream.AtEnd()) {
      return nullptr;
    }
    return CSSFontFaceSrcValue::CreateLocal(String(arg.Value()));
  }
  if (stream.Peek().GetType() == kIdentToken) {
    String family_name = css_parsing_utils::ConcatenateFamilyName(stream);
    if (!stream.AtEnd()) {
      return nullptr;
    }
    if (family_name.IsEmpty()) {
      return nullptr;
    }
    return CSSFontFaceSrcValue::CreateLocal(family_name);
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeDescriptor(StyleRule::RuleType rule_type,
                                                  AtRuleDescriptorID id,
                                                  const CSSTokenizedValue& tokenized_value,
                                                  std::shared_ptr<const CSSParserContext> context) {
  using Parser = AtRuleDescriptorParser;
  
  // Convert tokenized_value to a stream
  String serialized = tokenized_value.range.Serialize();
  CSSTokenizer tokenizer{serialized.ToStringView()};
  CSSParserTokenStream stream(tokenizer);

  switch (rule_type) {
    case StyleRule::kFontFace:
      return Parser::ParseFontFaceDescriptor(id, tokenized_value, context);
    case StyleRule::kFontPaletteValues:
      return Parser::ParseAtFontPaletteValuesDescriptor(id, stream, context);
    case StyleRule::kProperty:
      return Parser::ParseAtPropertyDescriptor(id, tokenized_value, context);
    case StyleRule::kViewTransition:
      return Parser::ParseAtViewTransitionDescriptor(id, stream, context);
    case StyleRule::kCounterStyle:
      return Parser::ParseAtCounterStyleDescriptor(id, stream, context);
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

}  // namespace

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDescriptor(
    AtRuleDescriptorID id,
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  stream.ConsumeWhitespace();
  switch (id) {
    case AtRuleDescriptorID::FontFamily:
      // In order to avoid confusion, <family-name> does not accept unquoted
      // <generic-family> keywords and general CSS keywords.
      // ConsumeGenericFamily will take care of excluding the former while the
      // ConsumeFamilyName will take care of excluding the latter.
      // See https://drafts.csswg.org/css-fonts/#family-name-syntax,
      if (css_parsing_utils::ConsumeGenericFamily(stream)) {
        return nullptr;
      }
      parsed_value = css_parsing_utils::ConsumeFamilyName(stream);
      break;
    case AtRuleDescriptorID::Src:  // This is a list of urls or local
                                   // references.
      parsed_value = ConsumeFontFaceSrc(stream, context);
      break;
    case AtRuleDescriptorID::FontDisplay:
      parsed_value = ConsumeFontDisplay(stream);
      break;
    case AtRuleDescriptorID::FontStretch: {
      CSSParserContext::ParserModeOverridingScope scope(*context, kCSSFontFaceRuleMode);
      parsed_value = css_parsing_utils::ConsumeFontStretch(stream, context);
      break;
    }
    case AtRuleDescriptorID::FontStyle: {
      CSSParserContext::ParserModeOverridingScope scope(*context, kCSSFontFaceRuleMode);
      parsed_value = css_parsing_utils::ConsumeFontStyle(stream, context);
      break;
    }
    case AtRuleDescriptorID::FontVariant:
      parsed_value = ConsumeFontVariantList(stream);
      break;
    case AtRuleDescriptorID::FontWeight: {
      CSSParserContext::ParserModeOverridingScope scope(*context, kCSSFontFaceRuleMode);
      parsed_value = css_parsing_utils::ConsumeFontWeight(stream, context);
      break;
    }
    case AtRuleDescriptorID::FontFeatureSettings:
      parsed_value = css_parsing_utils::ConsumeFontFeatureSettings(stream, context);
      break;
    case AtRuleDescriptorID::AscentOverride:
    case AtRuleDescriptorID::DescentOverride:
    case AtRuleDescriptorID::LineGapOverride:
      parsed_value = ConsumeFontMetricOverride(stream, context);
      break;
    case AtRuleDescriptorID::SizeAdjust:
      parsed_value = css_parsing_utils::ConsumePercent(stream, context, CSSPrimitiveValue::ValueRange::kNonNegative);
      break;
    default:
      break;
  }

  if (!parsed_value || !stream.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDescriptor(
    AtRuleDescriptorID id,
    const std::string& string,
    std::shared_ptr<const CSSParserContext> context) {
  String string_value = String::FromUTF8(string.c_str());
  CSSTokenizer tokenizer{string_value.ToStringView()};
  CSSParserTokenStream stream(tokenizer);
  return ParseFontFaceDescriptor(id, stream, context);
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDescriptor(
    AtRuleDescriptorID id,
    const CSSTokenizedValue& tokenized_value,
    std::shared_ptr<const CSSParserContext> context) {
  String serialized = tokenized_value.range.Serialize();
  CSSTokenizer tokenizer{serialized.ToStringView()};
  CSSParserTokenStream stream(tokenizer);
  return ParseFontFaceDescriptor(id, stream, context);
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseFontFaceDeclaration(
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  DCHECK_EQ(stream.Peek().GetType(), kIdentToken);
  const CSSParserToken& token = stream.ConsumeIncludingWhitespace();
  AtRuleDescriptorID id = token.ParseAsAtRuleDescriptorID();

  if (stream.Consume().GetType() != kColonToken) {
    return nullptr;  // Parse error
  }

  return ParseFontFaceDescriptor(id, stream, context);
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseAtPropertyDescriptor(
    AtRuleDescriptorID id,
    const CSSTokenizedValue& tokenized_value,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  
  // Create a stream from the tokenized value
  CSSTokenizer tokenizer{tokenized_value.text};
  CSSParserTokenStream stream(tokenizer);
  
  switch (id) {
    case AtRuleDescriptorID::Syntax:
      stream.ConsumeWhitespace();
      parsed_value = css_parsing_utils::ConsumeString(stream);
      break;
    case AtRuleDescriptorID::InitialValue: {
      // Note that we must retain leading whitespace here.
      return CSSVariableParser::ParseDeclarationValue(tokenized_value, false /* is_animation_tainted */, context);
    }
    case AtRuleDescriptorID::Inherits:
      stream.ConsumeWhitespace();
      parsed_value = css_parsing_utils::ConsumeIdent<CSSValueID::kTrue, CSSValueID::kFalse>(stream);
      break;
    default:
      break;
  }

  if (!parsed_value || !stream.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseAtViewTransitionDescriptor(
    AtRuleDescriptorID id,
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  switch (id) {
    case AtRuleDescriptorID::Navigation:
      stream.ConsumeWhitespace();
      parsed_value = css_parsing_utils::ConsumeIdent<CSSValueID::kAuto, CSSValueID::kNone>(stream);
      break;
    case AtRuleDescriptorID::Types: {
      std::shared_ptr<CSSValueList> types = CSSValueList::CreateSpaceSeparated();
      parsed_value = types;
      while (!stream.AtEnd()) {
        stream.ConsumeWhitespace();
        if (stream.Peek().Id() == CSSValueID::kNone) {
          return nullptr;
        }
        std::shared_ptr<const CSSCustomIdentValue> ident = css_parsing_utils::ConsumeCustomIdent(stream, context);
        if (!ident || ident->Value().StartsWith(AtomicString::CreateFromUTF8("-ua-"))) {
          return nullptr;
        }
        types->Append(ident);
      }
      break;
    }
    default:
      break;
  }

  if (!parsed_value || !stream.AtEnd()) {
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

// Stream versions of font palette helper functions
std::shared_ptr<const CSSValue> ConsumeFontFamily(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeBasePalette(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeColorOverride(CSSParserTokenStream& stream,
                                                    std::shared_ptr<const CSSParserContext> context);
std::shared_ptr<const CSSValue> ConsumeFontFamily(CSSParserTokenStream& stream,
                                                  std::shared_ptr<const CSSParserContext> context) {
  return css_parsing_utils::ConsumeNonGenericFamilyNameList(stream);
}
std::shared_ptr<const CSSValue> ConsumeBasePalette(CSSParserTokenStream& stream,
                                                   std::shared_ptr<const CSSParserContext> context) {
  if (auto ident = css_parsing_utils::ConsumeIdent<CSSValueID::kLight, CSSValueID::kDark>(stream)) {
    return ident;
  }

  auto palette_index = css_parsing_utils::ConsumeInteger(stream, context, 0);
  if (palette_index) {
    // TODO: Add IsElementDependent check when WebF supports it
    // Only calc() expressions that can be fully simplified at parse time are
    // valid. If not, they rely on an element context, and @font-palette-values
    // descriptors are not in an element context.
    return palette_index;
  }
  return nullptr;
}
std::shared_ptr<const CSSValue> ConsumeColorOverride(CSSParserTokenStream& stream,
                                                    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  do {
    auto color_index = css_parsing_utils::ConsumeInteger(stream, context, 0);
    if (!color_index) {
      // TODO: Add IsElementDependent check when WebF supports it
      // Only calc() expressions that can be fully simplified at parse time are
      // valid. If not, they rely on an element context, and
      // @font-palette-values descriptors are not in an element context.
      return nullptr;
    }
    stream.ConsumeWhitespace();
    auto color = css_parsing_utils::ConsumeAbsoluteColor(stream, context);
    if (!color) {
      return nullptr;
    }
    auto color_identifier = DynamicTo<CSSIdentifierValue>(color.get());
    if (color_identifier && color_identifier->GetValueID() == CSSValueID::kCurrentcolor) {
      return nullptr;
    }
    list->Append(std::make_shared<CSSValuePair>(color_index, color, CSSValuePair::kKeepIdenticalValues));
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(stream));
  if (!stream.AtEnd() || !list->length()) {
    return nullptr;
  }

  return list;
}

std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseAtFontPaletteValuesDescriptor(
    AtRuleDescriptorID id,
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  CSSParserContext::ParserModeOverridingScope scope(
      *context, kCSSFontPaletteValuesRuleMode);

  switch (id) {
    case AtRuleDescriptorID::FontFamily:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeFontFamily(stream, context);
      break;
    case AtRuleDescriptorID::BasePalette:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeBasePalette(stream, context);
      break;
    case AtRuleDescriptorID::OverrideColors:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeColorOverride(stream, context);
      break;
    default:
      break;
  }

  if (!parsed_value || !stream.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

namespace {

std::shared_ptr<const CSSValue> ConsumeCounterStyleSymbol(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context) {
  // <symbol> = <string> | <image> | <custom-ident>
  if (std::shared_ptr<const CSSValue> string = css_parsing_utils::ConsumeString(stream)) {
    return string;
  }
  // TODO: Add image support when WebF supports CSS images in counter styles
  // For now, skip the RuntimeEnabledFeatures check and image parsing
  if (std::shared_ptr<const CSSCustomIdentValue> custom_ident =
          css_parsing_utils::ConsumeCustomIdent(stream, context)) {
    return custom_ident;
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeCounterStyleSystem(CSSParserTokenStream& stream,
                                                          std::shared_ptr<const CSSParserContext> context) {
  // Syntax: cyclic | numeric | alphabetic | symbolic | additive |
  // [ fixed <integer>? ] | [ extends <counter-style-name> ]
  if (std::shared_ptr<const CSSValue> ident = css_parsing_utils::ConsumeIdent<
          CSSValueID::kCyclic, CSSValueID::kSymbolic, CSSValueID::kAlphabetic,
          CSSValueID::kNumeric, CSSValueID::kAdditive>(stream)) {
    return ident;
  }

  if (std::shared_ptr<const CSSValue> ident =
          css_parsing_utils::ConsumeIdent<CSSValueID::kFixed>(stream)) {
    std::shared_ptr<const CSSPrimitiveValue> first_symbol_value =
        css_parsing_utils::ConsumeInteger(stream, context);
    if (!first_symbol_value) {
      first_symbol_value = CSSNumericLiteralValue::Create(
          1, CSSPrimitiveValue::UnitType::kInteger);
    } else {
      // For fixed system, the integer must be positive
      if (first_symbol_value->GetFloatValue() <= 0) {
        return nullptr;
      }
    }
    // WebF doesn't have IsElementDependent yet
    return std::make_shared<CSSValuePair>(
        ident, first_symbol_value, CSSValuePair::kKeepIdenticalValues);
  }

  if (std::shared_ptr<const CSSValue> ident =
          css_parsing_utils::ConsumeIdent<CSSValueID::kExtends>(stream)) {
    std::shared_ptr<const CSSValue> extended =
        css_parsing_utils::ConsumeCounterStyleName(stream, context);
    if (!extended) {
      return nullptr;
    }
    return std::make_shared<CSSValuePair>(
        ident, extended, CSSValuePair::kKeepIdenticalValues);
  }

  // Internal keywords for predefined counter styles that use special
  // algorithms. For example, 'simp-chinese-informal'.
  if (context->Mode() == kUASheetMode) {
    if (std::shared_ptr<const CSSValue> ident = css_parsing_utils::ConsumeIdent<
            CSSValueID::kInternalHebrew,
            CSSValueID::kInternalSimpChineseInformal,
            CSSValueID::kInternalSimpChineseFormal,
            CSSValueID::kInternalTradChineseInformal,
            CSSValueID::kInternalTradChineseFormal,
            CSSValueID::kInternalKoreanHangulFormal,
            CSSValueID::kInternalKoreanHanjaInformal,
            CSSValueID::kInternalKoreanHanjaFormal,
            CSSValueID::kInternalLowerArmenian,
            CSSValueID::kInternalUpperArmenian,
            CSSValueID::kInternalEthiopicNumeric>(stream)) {
      return ident;
    }
  }

  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeCounterStyleNegative(CSSParserTokenStream& stream,
                                                            std::shared_ptr<const CSSParserContext> context) {
  // Syntax: <symbol> <symbol>?
  std::shared_ptr<const CSSValue> prepend = ConsumeCounterStyleSymbol(stream, context);
  if (!prepend) {
    return nullptr;
  }
  if (stream.AtEnd()) {
    return prepend;
  }

  std::shared_ptr<const CSSValue> append = ConsumeCounterStyleSymbol(stream, context);
  if (!append || !stream.AtEnd()) {
    return nullptr;
  }

  return std::make_shared<CSSValuePair>(prepend, append,
                                        CSSValuePair::kKeepIdenticalValues);
}

std::shared_ptr<const CSSValue> ConsumeCounterStyleRangeBound(CSSParserTokenStream& stream,
                                                              std::shared_ptr<const CSSParserContext> context) {
  if (std::shared_ptr<const CSSValue> infinite =
          css_parsing_utils::ConsumeIdent<CSSValueID::kInfinite>(stream)) {
    return infinite;
  }
  if (std::shared_ptr<const CSSPrimitiveValue> integer =
          css_parsing_utils::ConsumeInteger(stream, context)) {
    // WebF doesn't have IsElementDependent yet
    return integer;
  }
  return nullptr;
}

std::shared_ptr<const CSSValue> ConsumeCounterStyleRange(CSSParserTokenStream& stream,
                                                         std::shared_ptr<const CSSParserContext> context) {
  // Syntax: [ [ <integer> | infinite ]{2} ]# | auto
  if (std::shared_ptr<const CSSValue> auto_value =
          css_parsing_utils::ConsumeIdent<CSSValueID::kAuto>(stream)) {
    return auto_value;
  }

  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  do {
    std::shared_ptr<const CSSValue> lower_bound = ConsumeCounterStyleRangeBound(stream, context);
    if (!lower_bound) {
      return nullptr;
    }
    std::shared_ptr<const CSSValue> upper_bound = ConsumeCounterStyleRangeBound(stream, context);
    if (!upper_bound) {
      return nullptr;
    }

    // If the lower bound of any range is higher than the upper bound, the
    // entire descriptor is invalid and must be ignored.
    // TODO: Add range validation when WebF supports MediaValues
    
    list->Append(std::make_shared<CSSValuePair>(
        lower_bound, upper_bound, CSSValuePair::kKeepIdenticalValues));
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(stream));
  if (!stream.AtEnd() || !list->length()) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> ConsumeCounterStylePad(CSSParserTokenStream& stream,
                                                       std::shared_ptr<const CSSParserContext> context) {
  // Syntax: <integer [0,∞]> && <symbol>
  std::shared_ptr<const CSSPrimitiveValue> integer = nullptr;
  std::shared_ptr<const CSSValue> symbol = nullptr;
  while (!integer || !symbol) {
    if (!integer) {
      integer = css_parsing_utils::ConsumeInteger(stream, context, 0);
      if (integer) {
        // WebF doesn't have IsElementDependent yet
        continue;
      }
    }
    if (!symbol) {
      symbol = ConsumeCounterStyleSymbol(stream, context);
      if (symbol) {
        continue;
      }
    }
    return nullptr;
  }
  if (!stream.AtEnd()) {
    return nullptr;
  }

  return std::make_shared<CSSValuePair>(integer, symbol,
                                        CSSValuePair::kKeepIdenticalValues);
}

std::shared_ptr<const CSSValue> ConsumeCounterStyleSymbols(CSSParserTokenStream& stream,
                                                           std::shared_ptr<const CSSParserContext> context) {
  // Syntax: <symbol>+
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  while (!stream.AtEnd()) {
    std::shared_ptr<const CSSValue> symbol = ConsumeCounterStyleSymbol(stream, context);
    if (!symbol) {
      return nullptr;
    }
    list->Append(symbol);
  }
  if (!list->length()) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> ConsumeCounterStyleAdditiveSymbols(CSSParserTokenStream& stream,
                                                                   std::shared_ptr<const CSSParserContext> context) {
  // Syntax: [ <integer [0,∞]> && <symbol> ]#
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateCommaSeparated();
  std::shared_ptr<const CSSPrimitiveValue> last_integer = nullptr;
  do {
    std::shared_ptr<const CSSPrimitiveValue> integer = nullptr;
    std::shared_ptr<const CSSValue> symbol = nullptr;
    while (!integer || !symbol) {
      if (!integer) {
        integer = css_parsing_utils::ConsumeInteger(stream, context, 0);
        if (integer) {
          // WebF doesn't have IsElementDependent yet
          continue;
        }
      }
      if (!symbol) {
        symbol = ConsumeCounterStyleSymbol(stream, context);
        if (symbol) {
          continue;
        }
      }
      return nullptr;
    }

    if (last_integer) {
      // The additive tuples must be specified in order of strictly descending
      // weight; otherwise, the declaration is invalid and must be ignored.
      // TODO: Add weight validation when WebF supports MediaValues
    }
    last_integer = integer;

    list->Append(std::make_shared<CSSValuePair>(
        integer, symbol, CSSValuePair::kKeepIdenticalValues));
  } while (css_parsing_utils::ConsumeCommaIncludingWhitespace(stream));
  if (!stream.AtEnd() || !list->length()) {
    return nullptr;
  }
  return list;
}

std::shared_ptr<const CSSValue> ConsumeCounterStyleSpeakAs(CSSParserTokenStream& stream,
                                                           std::shared_ptr<const CSSParserContext> context) {
  // Syntax: auto | bullets | numbers | words | <counter-style-name>
  // We don't support spell-out now.
  if (std::shared_ptr<const CSSValue> ident = css_parsing_utils::ConsumeIdent<
          CSSValueID::kAuto, CSSValueID::kBullets, CSSValueID::kNumbers,
          CSSValueID::kWords>(stream)) {
    return ident;
  }
  if (std::shared_ptr<const CSSValue> name =
          css_parsing_utils::ConsumeCounterStyleName(stream, context)) {
    return name;
  }
  return nullptr;
}

}  // namespace


std::shared_ptr<const CSSValue> AtRuleDescriptorParser::ParseAtCounterStyleDescriptor(
    AtRuleDescriptorID id,
    CSSParserTokenStream& stream,
    std::shared_ptr<const CSSParserContext> context) {
  std::shared_ptr<const CSSValue> parsed_value = nullptr;
  switch (id) {
    case AtRuleDescriptorID::System:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStyleSystem(stream, context);
      break;
    case AtRuleDescriptorID::Negative:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStyleNegative(stream, context);
      break;
    case AtRuleDescriptorID::Prefix:
    case AtRuleDescriptorID::Suffix:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStyleSymbol(stream, context);
      break;
    case AtRuleDescriptorID::Range:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStyleRange(stream, context);
      break;
    case AtRuleDescriptorID::Pad:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStylePad(stream, context);
      break;
    case AtRuleDescriptorID::Fallback:
      stream.ConsumeWhitespace();
      parsed_value =
          css_parsing_utils::ConsumeCounterStyleName(stream, context);
      break;
    case AtRuleDescriptorID::Symbols:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStyleSymbols(stream, context);
      break;
    case AtRuleDescriptorID::AdditiveSymbols:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStyleAdditiveSymbols(stream, context);
      break;
    case AtRuleDescriptorID::SpeakAs:
      stream.ConsumeWhitespace();
      parsed_value = ConsumeCounterStyleSpeakAs(stream, context);
      break;
    default:
      break;
  }

  if (!parsed_value || !stream.AtEnd()) {
    return nullptr;
  }

  return parsed_value;
}

}  // namespace webf
