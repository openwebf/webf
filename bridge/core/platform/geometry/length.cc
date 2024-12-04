/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 *           (C) 2001 Dirk Mueller ( mueller@kde.org )
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008 Apple Inc. All rights
 * reserved.
 * Copyright (C) 2006 Andrew Wellington (proton@wiretapped.net)
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 *
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "length.h"
#include <unordered_map>
#include "core/platform/geometry/blend.h"
#include "core/platform/geometry/calculation_value.h"
#include "core/platform/static_constructors.h"
#include "foundation/macros.h"

namespace webf {

DEFINE_GLOBAL(Length, g_auto_length);
DEFINE_GLOBAL(Length, g_fill_available_length);
DEFINE_GLOBAL(Length, g_fit_content_length);
DEFINE_GLOBAL(Length, g_max_content_length);
DEFINE_GLOBAL(Length, g_min_content_length);
DEFINE_GLOBAL(Length, g_min_intrinsic_length);

void Length::Initialize() {
  new ((void*)&g_auto_length) Length(kAuto);
  new ((void*)&g_fill_available_length) Length(kFillAvailable);
  new ((void*)&g_fit_content_length) Length(kFitContent);
  new ((void*)&g_max_content_length) Length(kMaxContent);
  new ((void*)&g_min_content_length) Length(kMinContent);
  new ((void*)&g_min_intrinsic_length) Length(kMinIntrinsic);
}

PixelsAndPercent Length::GetPixelsAndPercent() const {
  switch (GetType()) {
    case kFixed:
      return PixelsAndPercent(Value());
    case kPercent:
      return {0.0f, Value(), /*has_explicit_pixels=*/false,
              /*has_explicit_percent=*/true};
    case kCalculated:
      return GetCalculationValue()->GetPixelsAndPercent();
    default:
      assert(false);
      return PixelsAndPercent(0.0f, 0.0f, false, false);
  }
}

Length::Length(std::shared_ptr<const CalculationValue> calc)
    : quirk_(false), type_(kCalculated), calc_value_(std::move(calc)) {}

bool Length::HasAuto() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasAuto();
  }
  return GetType() == kAuto;
}

bool Length::HasContentOrIntrinsic() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasContentOrIntrinsicSize();
  }
  return GetType() == kMinContent || GetType() == kMaxContent || GetType() == kFitContent ||
         GetType() == kMinIntrinsic || GetType() == kContent;
}

bool Length::HasAutoOrContentOrIntrinsic() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasAutoOrContentOrIntrinsicSize();
  }
  return GetType() == kAuto || HasContentOrIntrinsic();
}

bool Length::HasPercent() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasPercent();
  }
  return GetType() == kPercent;
}

bool Length::HasPercentOrStretch() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasPercentOrStretch();
  }
  return GetType() == kPercent || GetType() == kFillAvailable;
}

bool Length::HasStretch() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasStretch();
  }
  return GetType() == kFillAvailable;
}

bool Length::HasMinContent() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasMinContent();
  }
  return GetType() == kMinContent;
}

bool Length::HasMaxContent() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasMaxContent();
  }
  return GetType() == kMaxContent;
}

bool Length::HasFitContent() const {
  if (GetType() == kCalculated) {
    return GetCalculationValue()->HasFitContent();
  }
  return GetType() == kFitContent;
}

bool Length::IsCalculatedEqual(const Length& o) const {
  return IsCalculated() && (GetCalculationValue().get() == o.GetCalculationValue().get() ||
                            GetCalculationValue() == o.GetCalculationValue());
}

Length Length::SubtractFromOneHundredPercent() const {
  if (IsPercent())
    return Length::Percent(100 - Value());
  assert(IsSpecified());
  return Length(AsCalculationValue()->SubtractFromOneHundredPercent());
}

std::shared_ptr<const CalculationValue> Length::GetCalculationValue() const {
  DCHECK(IsCalculated());
  return calc_value_;
}

std::shared_ptr<const CalculationValue> Length::AsCalculationValue() const {
  if (IsCalculated())
    return GetCalculationValue();
  return CalculationValue::Create(GetPixelsAndPercent(), ValueRange::kAll);
}

Length Length::Add(const webf::Length& other) const {
  CHECK(IsSpecified());
  if (IsFixed() && other.IsFixed()) {
    return Length::Fixed(Pixels() + other.Pixels());
  }
  if (IsPercent() && other.IsPercent()) {
    return Length::Percent(Percent() + other.Percent());
  }
  return Length(AsCalculationValue()->Add(*other.AsCalculationValue()));
}

float Length::NonNanCalculatedValue(float max_value, const EvaluationInput& input) const {
  DCHECK(IsCalculated());
  float result = GetCalculationValue()->Evaluate(max_value, input);
  if (std::isnan(result))
    return 0;
  return result;
}

Length Length::Zoom(double factor) const {
  switch (GetType()) {
    case kFixed:
      return Length::Fixed(GetFloatValue() * factor);
    case kCalculated:
      return Length(GetCalculationValue()->Zoom(factor));
    default:
      return *this;
  }
}

Length Length::BlendMixedTypes(const Length& from, double progress, ValueRange range) const {
  assert(from.IsSpecified());
  assert(IsSpecified());
  return Length(AsCalculationValue()->Blend(*from.AsCalculationValue(), progress, range));
}

Length Length::BlendSameTypes(const Length& from, double progress, ValueRange range) const {
  Length::Type result_type = GetType();
  if (IsZero())
    result_type = from.GetType();

  float blended_value = webf::Blend(from.Value(), Value(), progress);
  if (range == ValueRange::kNonNegative)
    blended_value = ClampTo<float>(blended_value, 0);
  return Length(blended_value, result_type);
}

std::string Length::ToString() const {
  std::string builder;
  builder.append("Length(");
  static const char* const kTypeNames[] = {"Auto",         "Percent",       "Fixed",        "MinContent", "MaxContent",
                                           "MinIntrinsic", "FillAvailable", "FitContent",   "Calculated", "Flex",
                                           "ExtendToZoom", "DeviceWidth",   "DeviceHeight", "None",       "Content"};
  if (type_ < std::size(kTypeNames))
    builder.append(kTypeNames[type_]);
  else
    builder.append("?");
  builder.append(", ");
  if (IsCalculated()) {
    builder.append(std::to_string((uint64_t)calc_value_.get()));
  } else {
    builder.append(std::to_string(value_));
  }
  if (quirk_)
    builder.append(", Quirk");
  builder.append(")");
  return builder;
}

std::ostream& operator<<(std::ostream& ostream, const Length& value) {
  return ostream << value.ToString();
}

}  // namespace webf
