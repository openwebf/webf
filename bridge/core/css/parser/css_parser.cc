// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_fast_path.h"
#include "core/base/memory/shared_ptr.h"
#include "core/css/parser/css_parser_token_stream.h"
#include "core/css/parser/css_property_parser.h"
#include "core/css/parser/css_selector_parser.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/css/parser/css_tokenizer.h"
#include "core/css/parser/css_supports_parser.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/style_sheet_contents.h"
#include "css_parser_impl.h"

namespace webf {

bool CSSParser::ParseDeclarationList(std::shared_ptr<CSSParserContext> context,
                                     MutableCSSPropertyValueSet* property_set,
                                     const std::string& declaration) {
  return CSSParserImpl::ParseDeclarationList(property_set, declaration, context);
}

void CSSParser::ParseDeclarationListForInspector(std::shared_ptr<CSSParserContext> context,
                                                 const std::string& declaration,
                                                 CSSParserObserver& observer) {
}

tcb::span<CSSSelector> CSSParser::ParseSelector(std::shared_ptr<const CSSParserContext> context,
                                                CSSNestingType nesting_type,
                                                std::shared_ptr<const StyleRule> parent_rule_for_nesting,
                                                bool is_within_scope,
                                                std::shared_ptr<StyleSheetContents> style_sheet_contents,
                                                const std::string& selector,
                                                std::vector<CSSSelector>& arena) {
  CSSTokenizer tokenizer(selector);
  CSSParserTokenStream stream(tokenizer);
  return CSSSelectorParser::ParseSelector(
      stream, std::move(context), nesting_type, std::move(parent_rule_for_nesting), is_within_scope,
      /* semicolon_aborts_nested_selector */ false, std::move(style_sheet_contents), arena);
}

std::shared_ptr<const CSSSelectorList> CSSParser::ParsePageSelector(
    std::shared_ptr<const CSSParserContext> context,
    std::shared_ptr<StyleSheetContents> style_sheet_contents,
    const std::string& selector) {
  CSSTokenizer tokenizer(selector);
  const auto tokens = tokenizer.TokenizeToEOF();
  return CSSParserImpl::ParsePageSelector(CSSParserTokenRange(tokens), style_sheet_contents, context);
}

std::shared_ptr<StyleRuleBase> CSSParser::ParseMarginRule(std::shared_ptr<const CSSParserContext> context,
                                                          std::shared_ptr<StyleSheetContents> style_sheet,
                                                          const std::string& rule) {
  return CSSParserImpl::ParseRule(rule, context, CSSNestingType::kNone,
                                  /*parent_rule_for_nesting=*/nullptr, style_sheet, CSSParserImpl::kPageMarginRules);
}

std::shared_ptr<StyleRuleBase> CSSParser::ParseRule(std::shared_ptr<CSSParserContext> context,
                                                    std::shared_ptr<StyleSheetContents> style_sheet,
                                                    CSSNestingType nesting_type,
                                                    std::shared_ptr<StyleRule> parent_rule_for_nesting,
                                                    const std::string& rule) {
  return CSSParserImpl::ParseRule(rule, context, nesting_type, parent_rule_for_nesting, style_sheet,
                                  CSSParserImpl::kAllowImportRules);
}

ParseSheetResult CSSParser::ParseSheet(std::shared_ptr<CSSParserContext> context,
                                       std::shared_ptr<StyleSheetContents> style_sheet,
                                       const std::string& text,
                                       CSSDeferPropertyParsing defer_property_parsing,
                                       bool allow_import_rules) {
  return CSSParserImpl::ParseStyleSheet(text, context, style_sheet, defer_property_parsing, allow_import_rules);
}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValue(MutableCSSPropertyValueSet* declaration,
                                                            CSSPropertyID unresolved_property,
                                                            const std::string& string,
                                                            bool important,
                                                            const ExecutingContext* execution_context) {
  return ParseValue(declaration, unresolved_property, string, important,
                    static_cast<std::shared_ptr<StyleSheetContents>>(nullptr), execution_context);
}

static inline std::shared_ptr<const CSSParserContext> GetParserContext(std::shared_ptr<StyleSheetContents> style_sheet,
                                                                       const ExecutingContext* execution_context,
                                                                       CSSParserMode parser_mode) {
  if (style_sheet && style_sheet->ParserContext()->Mode() == parser_mode) {
    return style_sheet->ParserContext();
  } else {
    return std::make_shared<CSSParserContext>(parser_mode);
  }
}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValue(MutableCSSPropertyValueSet* declaration,
                                                            CSSPropertyID unresolved_property,
                                                            const std::string& string,
                                                            bool important,
                                                            std::shared_ptr<const CSSParserContext> context) {
  return CSSParserImpl::ParseValue(declaration, unresolved_property, string, important, context);
}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValue(MutableCSSPropertyValueSet* declaration,
                                                            CSSPropertyID unresolved_property,
                                                            const std::string& string,
                                                            bool important,
                                                            std::shared_ptr<StyleSheetContents> style_sheet,
                                                            const ExecutingContext* execution_context) {
  if (string.empty()) {
    return MutableCSSPropertyValueSet::kParseError;
  }

  CSSPropertyID resolved_property = ResolveCSSPropertyID(unresolved_property);
  CSSParserMode parser_mode = declaration->CssParserMode();
  std::shared_ptr<const CSSParserContext> context = GetParserContext(style_sheet, execution_context, parser_mode);

  // See if this property has a specific fast-path parser.
  std::shared_ptr<const CSSValue> value = CSSParserFastPaths::MaybeParseValue(resolved_property, string, context);
  if (value) {
    return declaration->SetLonghandProperty(CSSPropertyValue(CSSPropertyName(resolved_property), value, important));
  }

  // OK, that didn't work (either the property doesn't have a fast path,
  // or the string is on some form that the fast-path parser doesn't support,
  // e.g. a parse error). See if the value we are looking for is a longhand;
  // if so, we can use a faster parsing function. In particular, we don't need
  // to set up a vector for the results, since there will be only one.
  //
  // We only allow this path in standards mode, which rules out situations
  // like @font-face parsing etc. (which have their own rules).
  const CSSProperty& property = CSSProperty::Get(resolved_property);
  if (parser_mode == kHTMLStandardMode && property.IsProperty() && !property.IsShorthand()) {
    CSSTokenizer tokenizer(string);
    CSSParserTokenStream stream(tokenizer);
    value = CSSPropertyParser::ParseSingleValue(resolved_property, stream, context);
    if (value != nullptr) {
      return declaration->SetLonghandProperty(CSSPropertyValue(CSSPropertyName(resolved_property), value, important));
    }
  }

  // OK, that didn't work either, so we'll need the full-blown parser.
  return ParseValue(declaration, unresolved_property, string, important, context);
}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValueForCustomProperty(
    MutableCSSPropertyValueSet* declaration,
    const std::string& property_name,
    const std::string& value,
    bool important,
    std::shared_ptr<StyleSheetContents> style_sheet,
    bool is_animation_tainted) {
  DCHECK(CSSVariableParser::IsValidVariableName(property_name));
  if (value.empty()) {
    return MutableCSSPropertyValueSet::kParseError;
  }
  CSSParserMode parser_mode = declaration->CssParserMode();
  std::shared_ptr<CSSParserContext> context;
  if (style_sheet) {
    context = std::make_shared<CSSParserContext>(style_sheet->ParserContext().get(), style_sheet.get());
    context->SetMode(parser_mode);
  } else {
    context = std::make_shared<CSSParserContext>(parser_mode);
  }
  return CSSParserImpl::ParseVariableValue(declaration, property_name, value, important, context, is_animation_tainted);
}

MutableCSSPropertyValueSet::SetResult CSSParser::ParseValue(MutableCSSPropertyValueSet* declaration,
                                                            CSSPropertyID unresolved_property,
                                                            const std::string& string,
                                                            bool important,
                                                            std::shared_ptr<CSSParserContext> context) {
  return CSSParserImpl::ParseValue(declaration, unresolved_property, string, important, std::move(context));
}

std::shared_ptr<const CSSValue> CSSParser::ParseSingleValue(CSSPropertyID property_id,
                                                            const std::string& string,
                                                            std::shared_ptr<CSSParserContext> context) {
  if (string.empty()) {
    return nullptr;
  }
  std::shared_ptr<const CSSValue> value = CSSParserFastPaths::MaybeParseValue(property_id, string, context);
  if (value != nullptr) {
    return value;
  }
  CSSTokenizer tokenizer(string);
  CSSParserTokenStream stream(tokenizer);
  return CSSPropertyParser::ParseSingleValue(property_id, stream, context);
}

std::shared_ptr<const ImmutableCSSPropertyValueSet> CSSParser::ParseInlineStyleDeclaration(
    const std::string& style_string,
    Element* element) {
  return CSSParserImpl::ParseInlineStyleDeclaration(style_string, element);
}

std::shared_ptr<const ImmutableCSSPropertyValueSet> CSSParser::ParseInlineStyleDeclaration(
    const std::string& style_string,
    CSSParserMode parser_mode,
    const Document* document) {
  return CSSParserImpl::ParseInlineStyleDeclaration(style_string, parser_mode, document);
}

std::unique_ptr<std::vector<KeyframeOffset>> CSSParser::ParseKeyframeKeyList(std::shared_ptr<CSSParserContext> context,
                                                                        const std::string& key_list) {
  return CSSParserImpl::ParseKeyframeKeyList(context, key_list);
}

std::shared_ptr<StyleRuleKeyframe> CSSParser::ParseKeyframeRule(std::shared_ptr<CSSParserContext> context, const std::string& rule) {
  auto keyframe =
      CSSParserImpl::ParseRule(rule, context, CSSNestingType::kNone, /*parent_rule_for_nesting=*/nullptr, nullptr,
                               CSSParserImpl::kKeyframeRules);
  return std::reinterpret_pointer_cast<StyleRuleKeyframe>(keyframe);
}

std::string CSSParser::ParseCustomPropertyName(const std::string& name_text) {
  return CSSParserImpl::ParseCustomPropertyName(name_text);
}

bool CSSParser::ParseSupportsCondition(const std::string& condition, const ExecutingContext* execution_context) {
  // window.CSS.supports requires to parse as-if it was wrapped in parenthesis.
  std::string wrapped_condition = "(" + condition + ")";
  CSSTokenizer tokenizer(wrapped_condition);
  CSSParserTokenStream stream(tokenizer);
  DCHECK(execution_context);
  // Create parser context using document so it can check for origin trial
  // enabled property/value.
  std::string str;
  std::shared_ptr<CSSParserContext> context =
      std::make_shared<CSSParserContext>(*execution_context->document(), str);
  // Override the parser mode interpreted from the document as the spec
  // https://quirks.spec.whatwg.org/#css requires quirky values and colors
  // must not be supported in CSS.supports() method.
  context->SetMode(kHTMLStandardMode);
  CSSParserImpl parser(context);
  CSSSupportsParser::Result result = CSSSupportsParser::ConsumeSupportsCondition(stream, parser);
  if (!stream.AtEnd()) {
    result = CSSSupportsParser::Result::kParseFailure;
  }

  return result == CSSSupportsParser::Result::kSupported;
}

bool CSSParser::ParseColor(Color& color, const std::string& string, bool strict) {
  if (string.empty()) {
    return false;
  }

  // The regular color parsers don't resolve named colors, so explicitly
  // handle these first.
  Color named_color;
  if (named_color.SetNamedColor(string)) {
    color = named_color;
    return true;
  }

  switch (CSSParserFastPaths::ParseColor(string, strict ? kHTMLStandardMode : kHTMLQuirksMode, color)) {
    case ParseColorResult::kFailure:
      break;
    case ParseColorResult::kKeyword:
      return false;
    case ParseColorResult::kColor:
      return true;
  }

  // TODO(timloh): Why is this always strict mode?
  // NOTE(ikilpatrick): We will always parse color value in the insecure
  // context mode. If a function/unit/etc will require a secure context check
  // in the future, plumbing will need to be added.
  std::shared_ptr<const CSSValue> value =
      ParseSingleValue(CSSPropertyID::kColor, string, std::make_shared<CSSParserContext>(kHTMLStandardMode));
  auto* color_value = DynamicTo<cssvalue::CSSColor>(value.get());
  if (!color_value) {
    return false;
  }

  color = color_value->Value();
  return true;
}

const std::shared_ptr<const CSSValue>* CSSParser::ParseFontFaceDescriptor(CSSPropertyID property_id,
                                                                   const std::string& property_value,
                                                                   std::shared_ptr<CSSParserContext> context) {
  auto style = std::make_shared<MutableCSSPropertyValueSet>(kCSSFontFaceRuleMode);
  CSSParser::ParseValue(style.get(), property_id, property_value, true, context);
  const std::shared_ptr<const CSSValue>* value = style->GetPropertyCSSValue(property_id);

  return value;
}

std::shared_ptr<const CSSPrimitiveValue> CSSParser::ParseLengthPercentage(const std::string& string,
                                                    std::shared_ptr<CSSParserContext> context,
                                                    CSSPrimitiveValue::ValueRange value_range) {
  if (string.empty() || !context) {
    return nullptr;
  }
  CSSTokenizer tokenizer(string);
  const auto tokens = tokenizer.TokenizeToEOF();
  CSSParserTokenRange range(tokens);
  // Trim whitespace from the string. It's only necessary to consume leading
  // whitespaces, since ConsumeLengthOrPercent always consumes trailing ones.
  range.ConsumeWhitespace();
  auto parsed_value = css_parsing_utils::ConsumeLengthOrPercent(range, context, value_range);
  return range.AtEnd() ? parsed_value : nullptr;
}

std::shared_ptr<MutableCSSPropertyValueSet> CSSParser::ParseFont(const std::string& string, const ExecutingContext* execution_context) {
  auto set = std::make_shared<MutableCSSPropertyValueSet>(kHTMLStandardMode);
  ParseValue(set.get(), CSSPropertyID::kFont, string, true /* important */, execution_context);
  if (set->IsEmpty()) {
    return nullptr;
  }
  const std::shared_ptr<const CSSValue>* font_size = set->GetPropertyCSSValue(CSSPropertyID::kFontSize);
  if (!font_size || font_size->get()->IsCSSWideKeyword()) {
    return nullptr;
  }
  if (font_size->get()->IsPendingSubstitutionValue()) {
    return nullptr;
  }
  return set;
}

}  // namespace webf
