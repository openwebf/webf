/*
 * CSS Media Query
 *
 * Copyright (C) 2006 Kimmo Kinnunen <kimmo.t.kinnunen@nokia.com>.
 * Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
 * Copyright (C) 2013 Apple Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "media_query_exp.h"
#include "media_feature_names.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_variable_parser.h"
#include "core/css/parser/css_parser_impl.h"
#include "core/css/properties/css_parsing_utils.h"
#include "core/base/strings/string_util.h"

namespace webf {

static inline bool FeatureWithValidIdent(const std::string& media_feature,
                                         CSSValueID ident) {

  if (media_feature == media_feature_names_stdstring::kVideoDynamicRange) {
    return ident == CSSValueID::kStandard || ident == CSSValueID::kHigh;
  }

  return false;
}

static inline bool FeatureWithValidLength(const std::string& media_feature, const CSSPrimitiveValue* value) {
  if (!(value->IsLength() || (value->IsNumber() && value->GetDoubleValue() == 0))) {
    return false;
  }

  return media_feature == media_feature_names_stdstring::kHeight ||
         media_feature == media_feature_names_stdstring::kMaxHeight ||
         media_feature == media_feature_names_stdstring::kMinHeight ||
         media_feature == media_feature_names_stdstring::kWidth ||
         media_feature == media_feature_names_stdstring::kMaxWidth ||
         media_feature == media_feature_names_stdstring::kMinWidth ||
         media_feature == media_feature_names_stdstring::kMaxBlockSize ||
         media_feature == media_feature_names_stdstring::kMinBlockSize ||
         media_feature == media_feature_names_stdstring::kInlineSize ||
         media_feature == media_feature_names_stdstring::kMaxInlineSize ||
         media_feature == media_feature_names_stdstring::kMinInlineSize ||
         media_feature == media_feature_names_stdstring::kDeviceHeight ||
         media_feature == media_feature_names_stdstring::kMaxDeviceHeight ||
         media_feature == media_feature_names_stdstring::kMinDeviceHeight ||
         media_feature == media_feature_names_stdstring::kDeviceWidth ||
         media_feature == media_feature_names_stdstring::kMinDeviceWidth ||
         media_feature == media_feature_names_stdstring::kMaxDeviceWidth;
}


static inline bool FeatureWithValidDensity(const std::string& media_feature,
                                           const CSSPrimitiveValue* value) {
  // NOTE: The allowed range of <resolution> values always excludes negative
  // values, in addition to any explicit ranges that might be specified.
  // https://drafts.csswg.org/css-values/#resolution
  if (!value->IsResolution() || value->GetDoubleValue() < 0) {
    return false;
  }

  return media_feature == media_feature_names_stdstring::kMinResolution ||
         media_feature == media_feature_names_stdstring::kMaxResolution;
}


static inline bool FeatureExpectingInteger(const std::string& media_feature) {
  if (media_feature == media_feature_names_stdstring::kColor ||
      media_feature == media_feature_names_stdstring::kMaxColor ||
      media_feature == media_feature_names_stdstring::kMinColor ||
      media_feature == media_feature_names_stdstring::kMaxColorIndex ||
      media_feature == media_feature_names_stdstring::kMinColorIndex) {
    return true;
  }

  return false;
}

static inline bool FeatureWithInteger(const std::string& media_feature,
                                      const CSSPrimitiveValue* value) {
  if (!value->IsInteger()) {
    return false;
  }
  return FeatureExpectingInteger(media_feature);
}

static inline bool FeatureWithNumber(const std::string& media_feature,
                                     const CSSPrimitiveValue* value) {
  if (!value->IsNumber()) {
    return false;
  }

  return false;
}

static inline bool FeatureWithZeroOrOne(const std::string& media_feature,
                                        const CSSPrimitiveValue* value) {
  if (!value->IsInteger() ||
      !(value->GetDoubleValue() == 1 || !value->GetDoubleValue())) {
    return false;
  }

  return media_feature == media_feature_names_stdstring::kGrid;
}

static inline bool FeatureWithAspectRatio(const std::string& media_feature) {
  return media_feature == media_feature_names_stdstring::kAspectRatio ||
         media_feature == media_feature_names_stdstring::kDeviceAspectRatio ||
         media_feature == media_feature_names_stdstring::kMinAspectRatio ||
         media_feature == media_feature_names_stdstring::kMaxAspectRatio ||
         media_feature == media_feature_names_stdstring::kMinDeviceAspectRatio ||
         media_feature == media_feature_names_stdstring::kMaxDeviceAspectRatio;
}

bool MediaQueryExp::IsViewportDependent() const {
  return media_feature_ == media_feature_names_stdstring::kWidth ||
         media_feature_ == media_feature_names_stdstring::kHeight ||
         media_feature_ == media_feature_names_stdstring::kMinWidth ||
         media_feature_ == media_feature_names_stdstring::kMinHeight ||
         media_feature_ == media_feature_names_stdstring::kMaxWidth ||
         media_feature_ == media_feature_names_stdstring::kMaxHeight ||
         media_feature_ == media_feature_names_stdstring::kAspectRatio ||
         media_feature_ == media_feature_names_stdstring::kMinAspectRatio ||
         media_feature_ == media_feature_names_stdstring::kMaxAspectRatio;
}

bool MediaQueryExp::IsDeviceDependent() const {
  return media_feature_ ==
             media_feature_names_stdstring::kDeviceAspectRatio ||
         media_feature_ == media_feature_names_stdstring::kDeviceWidth ||
         media_feature_ == media_feature_names_stdstring::kDeviceHeight ||
         media_feature_ == media_feature_names_stdstring::kMinDeviceWidth ||
         media_feature_ == media_feature_names_stdstring::kMinDeviceHeight ||
         media_feature_ == media_feature_names_stdstring::kMaxDeviceWidth ||
         media_feature_ == media_feature_names_stdstring::kMaxDeviceHeight ||
         media_feature_ == media_feature_names_stdstring::kVideoDynamicRange;
}

bool MediaQueryExp::IsWidthDependent() const {
  return media_feature_ == media_feature_names_stdstring::kWidth ||
         media_feature_ == media_feature_names_stdstring::kMinWidth ||
         media_feature_ == media_feature_names_stdstring::kMaxWidth ||
         media_feature_ == media_feature_names_stdstring::kAspectRatio ||
         media_feature_ == media_feature_names_stdstring::kMinAspectRatio ||
         media_feature_ == media_feature_names_stdstring::kMaxAspectRatio;
}

bool MediaQueryExp::IsHeightDependent() const {
  return media_feature_ == media_feature_names_stdstring::kHeight ||
         media_feature_ == media_feature_names_stdstring::kMinHeight ||
         media_feature_ == media_feature_names_stdstring::kMaxHeight ||
         media_feature_ == media_feature_names_stdstring::kAspectRatio ||
         media_feature_ == media_feature_names_stdstring::kMinAspectRatio ||
         media_feature_ == media_feature_names_stdstring::kMaxAspectRatio;
}

bool MediaQueryExp::IsInlineSizeDependent() const {
  return media_feature_ == media_feature_names_stdstring::kInlineSize ||
         media_feature_ == media_feature_names_stdstring::kMinInlineSize ||
         media_feature_ == media_feature_names_stdstring::kMaxInlineSize;
}

bool MediaQueryExp::IsBlockSizeDependent() const {
  return media_feature_ == media_feature_names_stdstring::kMinBlockSize ||
         media_feature_ == media_feature_names_stdstring::kMaxBlockSize;
}


MediaQueryExp::MediaQueryExp(const MediaQueryExp& other)
    : media_feature_(other.MediaFeature()), bounds_(other.bounds_) {}

MediaQueryExp::MediaQueryExp(const std::string& media_feature,
                             const MediaQueryExpValue& value)
    : MediaQueryExp(media_feature,
                    MediaQueryExpBounds(MediaQueryExpComparison(value))) {}

MediaQueryExp::MediaQueryExp(const std::string& media_feature,
                             const MediaQueryExpBounds& bounds)
    : media_feature_(media_feature), bounds_(bounds) {}

MediaQueryExp MediaQueryExp::Create(const std::string& media_feature,
                                    CSSParserTokenRange& range,
                                    const CSSParserTokenOffsets& offsets,
                                    std::shared_ptr<const CSSParserContext> context) {
  if (auto value =
          MediaQueryExpValue::Consume(media_feature, range, offsets, context)) {
    return MediaQueryExp(media_feature, *value);
  }
  return Invalid();
}


std::optional<MediaQueryExpValue> MediaQueryExpValue::Consume(
    const std::string& media_feature,
    CSSParserTokenRange& range,
    const CSSParserTokenOffsets& offsets,
    std::shared_ptr<const CSSParserContext> context) {
  CSSParserContext::ParserModeOverridingScope scope(*context, kHTMLStandardMode);

  if (CSSVariableParser::IsValidVariableName(media_feature)) {
    tcb::span span = range.RemainingSpan();
    std::string_view original_string =
        offsets.StringForTokens(span.data(), span.data() + span.size());
    CSSTokenizedValue tokenized_value{range, original_string};
    CSSParserImpl::RemoveImportantAnnotationIfPresent(tokenized_value);
    if (auto value =
            CSSVariableParser::ParseDeclarationIncludingCSSWide(
                tokenized_value, false, context)) {
      while (!range.AtEnd()) {
        range.Consume();
      }
      return MediaQueryExpValue(value);
    }
    return std::nullopt;
  }

  DCHECK_EQ(media_feature, base::ToLowerASCII(media_feature));

  std::shared_ptr<const CSSPrimitiveValue> value = css_parsing_utils::ConsumeInteger(
      range, context, -std::numeric_limits<double>::max() /* minimum_value */);
  if (!value && !FeatureExpectingInteger(media_feature)) {
    value = css_parsing_utils::ConsumeNumber(
        range, context, CSSPrimitiveValue::ValueRange::kAll);
  }
  if (!value) {
    value = css_parsing_utils::ConsumeLength(
        range, context, CSSPrimitiveValue::ValueRange::kAll);
  }
  if (!value) {
    value = css_parsing_utils::ConsumeResolution(range, context);
  }

  if (!value) {
    if (std::shared_ptr<const CSSIdentifierValue> ident = css_parsing_utils::ConsumeIdent(range)) {
      CSSValueID ident_id = ident->GetValueID();
      if (!FeatureWithValidIdent(media_feature, ident_id)) {
        return std::nullopt;
      }
      return MediaQueryExpValue(ident_id);
    }
    return std::nullopt;
  }

  // Now we have |value| as a number, length or resolution
  // Create value for media query expression that must have 1 or more values.
  if (FeatureWithAspectRatio(media_feature)) {
    if (value->GetDoubleValue() < 0) {
      return std::nullopt;
    }
    if (!css_parsing_utils::ConsumeSlashIncludingWhitespace(range)) {
      return MediaQueryExpValue(*value,
                                *CSSNumericLiteralValue::Create(
                                    1, CSSPrimitiveValue::UnitType::kNumber));
    }
    std::shared_ptr<const CSSPrimitiveValue> denominator = css_parsing_utils::ConsumeNumber(
        range, context, CSSPrimitiveValue::ValueRange::kNonNegative);
    if (!denominator) {
      return std::nullopt;
    }
    if (value->GetDoubleValue() == 0 && denominator->GetDoubleValue() == 0) {
      return MediaQueryExpValue(*CSSNumericLiteralValue::Create(
                                    1, CSSPrimitiveValue::UnitType::kNumber),
                                *CSSNumericLiteralValue::Create(
                                    0, CSSPrimitiveValue::UnitType::kNumber));
    }
    return MediaQueryExpValue(*value, *denominator);
  }

  if (FeatureWithInteger(media_feature, value.get()) ||
      FeatureWithNumber(media_feature, value.get()) ||
      FeatureWithZeroOrOne(media_feature, value.get()) ||
      FeatureWithValidLength(media_feature, value.get()) ||
      FeatureWithValidDensity(media_feature, value.get())) {
    return MediaQueryExpValue(value);
  }

  return std::nullopt;
}


namespace {

const char* MediaQueryOperatorToString(MediaQueryOperator op) {
  switch (op) {
    case MediaQueryOperator::kNone:
      return "";
    case MediaQueryOperator::kEq:
      return "=";
    case MediaQueryOperator::kLt:
      return "<";
    case MediaQueryOperator::kLe:
      return "<=";
    case MediaQueryOperator::kGt:
      return ">";
    case MediaQueryOperator::kGe:
      return ">=";
  }

  NOTREACHED_IN_MIGRATION();
  return "";
}

}


MediaQueryExp MediaQueryExp::Create(const std::string& media_feature,
                                    const MediaQueryExpBounds& bounds) {
  return MediaQueryExp(media_feature, bounds);
}

MediaQueryExp::~MediaQueryExp() = default;

void MediaQueryExp::Trace(GCVisitor* visitor) const {
}

bool MediaQueryExp::operator==(const MediaQueryExp& other) const {
  return (other.media_feature_ == media_feature_) && (bounds_ == other.bounds_);
}

std::string MediaQueryExp::Serialize() const {
  StringBuilder result;
  // <mf-boolean> e.g. (color)
  // <mf-plain>  e.g. (width: 100px)
  if (!bounds_.IsRange()) {
    result.Append(media_feature_);
    if (bounds_.right.IsValid()) {
      result.Append(": ");
      result.Append(bounds_.right.value.CssText());
    }
  } else {
    if (bounds_.left.IsValid()) {
      result.Append(bounds_.left.value.CssText());
      result.Append(" ");
      result.Append(MediaQueryOperatorToString(bounds_.left.op));
      result.Append(" ");
    }
    result.Append(media_feature_);
    if (bounds_.right.IsValid()) {
      result.Append(" ");
      result.Append(MediaQueryOperatorToString(bounds_.right.op));
      result.Append(" ");
      result.Append(bounds_.right.value.CssText());
    }
  }

  return result.ReleaseString();
}

unsigned MediaQueryExp::GetUnitFlags() const {
  unsigned unit_flags = 0;
  if (Bounds().left.IsValid()) {
    unit_flags |= Bounds().left.value.GetUnitFlags();
  }
  if (Bounds().right.IsValid()) {
    unit_flags |= Bounds().right.value.GetUnitFlags();
  }
  return unit_flags;
}

std::string MediaQueryExpValue::CssText() const {
  StringBuilder output;
  switch (type_) {
    case Type::kInvalid:
      break;
    case Type::kValue:
      output.Append(GetCSSValue().CssText());
      break;
    case Type::kRatio:
      output.Append(Numerator().CssText());
      output.Append(" / ");
      output.Append(Denominator().CssText());
      break;
    case Type::kId:
      output.Append(getValueName(Id()));
      break;
  }

  return output.ReleaseString();
}

unsigned MediaQueryExpValue::GetUnitFlags() const {
  CSSPrimitiveValue::LengthTypeFlags length_type_flags;

  if (IsValue()) {
    if (auto* primitive = DynamicTo<CSSPrimitiveValue>(GetCSSValue())) {
      primitive->AccumulateLengthUnitTypes(length_type_flags);
    }
  }

  unsigned unit_flags = 0;

  if (length_type_flags.test(CSSPrimitiveValue::kUnitTypeFontSize) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeFontXSize) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeZeroCharacterWidth) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeFontCapitalHeight) ||
      length_type_flags.test(
          CSSPrimitiveValue::kUnitTypeIdeographicFullWidth) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeLineHeight)) {
    unit_flags |= UnitFlags::kFontRelative;
  }

  if (length_type_flags.test(CSSPrimitiveValue::kUnitTypeRootFontSize) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeRootFontXSize) ||
      length_type_flags.test(
          CSSPrimitiveValue::kUnitTypeRootFontCapitalHeight) ||
      length_type_flags.test(
          CSSPrimitiveValue::kUnitTypeRootFontZeroCharacterWidth) ||
      length_type_flags.test(
          CSSPrimitiveValue::kUnitTypeRootFontIdeographicFullWidth) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeRootLineHeight)) {
    unit_flags |= UnitFlags::kRootFontRelative;
  }

  if (CSSPrimitiveValue::HasDynamicViewportUnits(length_type_flags)) {
    unit_flags |= UnitFlags::kDynamicViewport;
  }

  if (CSSPrimitiveValue::HasStaticViewportUnits(length_type_flags)) {
    unit_flags |= UnitFlags::kStaticViewport;
  }

  if (length_type_flags.test(CSSPrimitiveValue::kUnitTypeContainerWidth) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeContainerHeight) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeContainerInlineSize) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeContainerBlockSize) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeContainerMin) ||
      length_type_flags.test(CSSPrimitiveValue::kUnitTypeContainerMax)) {
    unit_flags |= UnitFlags::kContainer;
  }

  return unit_flags;
}

std::string MediaQueryExpNode::Serialize() const {
  StringBuilder builder;
  SerializeTo(builder);
  return builder.ReleaseString();
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryExpNode::Not(
    std::shared_ptr<const MediaQueryExpNode> operand) {
  if (!operand) {
    return nullptr;
  }
  return std::make_shared<MediaQueryNotExpNode>(std::move(operand));
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryExpNode::Nested(
    std::shared_ptr<const MediaQueryExpNode> operand) {
  if (!operand) {
    return nullptr;
  }
  return std::make_shared<MediaQueryNestedExpNode>(std::move(operand));
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryExpNode::Function(
    std::shared_ptr<const MediaQueryExpNode> operand,
    const std::string& name) {
  if (!operand) {
    return nullptr;
  }
  return std::make_shared<MediaQueryFunctionExpNode>(operand, name);
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryExpNode::And(
    std::shared_ptr<const MediaQueryExpNode> left,
    std::shared_ptr<const MediaQueryExpNode> right) {
  if (!left || !right) {
    return nullptr;
  }
  return std::make_shared<MediaQueryAndExpNode>(left, right);
}

std::shared_ptr<const MediaQueryExpNode> MediaQueryExpNode::Or(std::shared_ptr<const MediaQueryExpNode> left,
                                               std::shared_ptr<const MediaQueryExpNode> right) {
  if (!left || !right) {
    return nullptr;
  }
  return std::make_shared<MediaQueryOrExpNode>(left, right);
}

bool MediaQueryFeatureExpNode::IsViewportDependent() const {
  return exp_.IsViewportDependent();
}

bool MediaQueryFeatureExpNode::IsDeviceDependent() const {
  return exp_.IsDeviceDependent();
}

unsigned MediaQueryFeatureExpNode::GetUnitFlags() const {
  return exp_.GetUnitFlags();
}

bool MediaQueryFeatureExpNode::IsWidthDependent() const {
  return exp_.IsWidthDependent();
}

bool MediaQueryFeatureExpNode::IsHeightDependent() const {
  return exp_.IsHeightDependent();
}

bool MediaQueryFeatureExpNode::IsInlineSizeDependent() const {
  return exp_.IsInlineSizeDependent();
}

bool MediaQueryFeatureExpNode::IsBlockSizeDependent() const {
  return exp_.IsBlockSizeDependent();
}

void MediaQueryFeatureExpNode::SerializeTo(StringBuilder& builder) const {
  builder.Append(exp_.Serialize());
}

void MediaQueryFeatureExpNode::CollectExpressions(
    std::vector<MediaQueryExp>& result) const {
  result.push_back(exp_);
}

MediaQueryExpNode::FeatureFlags MediaQueryFeatureExpNode::CollectFeatureFlags()
    const {
  if (exp_.IsInlineSizeDependent()) {
    return kFeatureInlineSize;
  } else if (exp_.IsBlockSizeDependent()) {
    return kFeatureBlockSize;
  } else {
    FeatureFlags flags = 0;
    if (exp_.IsWidthDependent()) {
      flags |= kFeatureWidth;
    }
    if (exp_.IsHeightDependent()) {
      flags |= kFeatureHeight;
    }
    return flags;
  }
}

void MediaQueryFeatureExpNode::Trace(GCVisitor* visitor) const {
}

void MediaQueryUnaryExpNode::Trace(GCVisitor* visitor) const {
}

void MediaQueryUnaryExpNode::CollectExpressions(
    std::vector<MediaQueryExp>& result) const {
  operand_->CollectExpressions(result);
}

MediaQueryExpNode::FeatureFlags MediaQueryUnaryExpNode::CollectFeatureFlags()
    const {
  return operand_->CollectFeatureFlags();
}

void MediaQueryNestedExpNode::SerializeTo(StringBuilder& builder) const {
  builder.Append("(");
  Operand().SerializeTo(builder);
  builder.Append(")");
}

void MediaQueryFunctionExpNode::SerializeTo(StringBuilder& builder) const {
  builder.Append(name_);
  builder.Append("(");
  Operand().SerializeTo(builder);
  builder.Append(")");
}

MediaQueryExpNode::FeatureFlags MediaQueryFunctionExpNode::CollectFeatureFlags()
    const {
  FeatureFlags flags = MediaQueryUnaryExpNode::CollectFeatureFlags();
  if (name_ == "style") {
    flags |= kFeatureStyle;
  }
  return flags;
}

void MediaQueryNotExpNode::SerializeTo(StringBuilder& builder) const {
  builder.Append("not ");
  Operand().SerializeTo(builder);
}

void MediaQueryCompoundExpNode::Trace(GCVisitor* visitor) const {
}

void MediaQueryCompoundExpNode::CollectExpressions(
    std::vector<MediaQueryExp>& result) const {
  left_->CollectExpressions(result);
  right_->CollectExpressions(result);
}

MediaQueryExpNode::FeatureFlags MediaQueryCompoundExpNode::CollectFeatureFlags()
    const {
  return left_->CollectFeatureFlags() | right_->CollectFeatureFlags();
}

void MediaQueryAndExpNode::SerializeTo(StringBuilder& builder) const {
  Left().SerializeTo(builder);
  builder.Append(" and ");
  Right().SerializeTo(builder);
}

void MediaQueryOrExpNode::SerializeTo(StringBuilder& builder) const {
  Left().SerializeTo(builder);
  builder.Append(" or ");
  Right().SerializeTo(builder);
}

void MediaQueryUnknownExpNode::SerializeTo(StringBuilder& builder) const {
  builder.Append(string_);
}

void MediaQueryUnknownExpNode::CollectExpressions(
    std::vector<MediaQueryExp>&) const {}

MediaQueryExpNode::FeatureFlags MediaQueryUnknownExpNode::CollectFeatureFlags()
    const {
  return kFeatureUnknown;
}

}  // namespace webf
