/*
 *  Copyright (C) 2003, 2008, 2012 Apple Inc. All rights reserved.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Library General Public
 *  License as published by the Free Software Foundation; either
 *  version 2 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Library General Public License for more details.
 *
 *  You should have received a copy of the GNU Library General Public License
 *  along with this library; see the file COPYING.LIB.  If not, write to
 *  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA 02110-1301, USA.
 *
 */

#include "dtoa.h"
#include <double-conversion/double-conversion.h>
#include "foundation/macros.h"

namespace webf {

namespace {

const double_conversion::StringToDoubleConverter& GetDoubleConverter() {
  static double_conversion::StringToDoubleConverter converter(
      double_conversion::StringToDoubleConverter::ALLOW_LEADING_SPACES |
          double_conversion::StringToDoubleConverter::ALLOW_TRAILING_JUNK,
      0.0, 0, nullptr, nullptr);
  return converter;
}

}  // namespace

const char* NumberToString(double d, NumberToStringBuffer buffer) {
  double_conversion::StringBuilder builder(buffer, kNumberToStringBufferLength);
  const double_conversion::DoubleToStringConverter& converter =
      double_conversion::DoubleToStringConverter::EcmaScriptConverter();
  converter.ToShortest(d, &builder);
  return builder.Finalize();
}

static inline const char* FormatStringTruncatingTrailingZerosIfNeeded(NumberToStringBuffer buffer,
                                                                      double_conversion::StringBuilder& builder) {
  int length = builder.position();

  // If there is an exponent, stripping trailing zeros would be incorrect.
  // FIXME: Zeros should be stripped before the 'e'.
  if (memchr(buffer, 'e', length))
    return builder.Finalize();

  int decimal_point_position = 0;
  for (; decimal_point_position < length; ++decimal_point_position) {
    if (buffer[decimal_point_position] == '.')
      break;
  }

  if (decimal_point_position == length)
    return builder.Finalize();

  int truncated_length = length - 1;
  for (; truncated_length > decimal_point_position; --truncated_length) {
    if (buffer[truncated_length] != '0')
      break;
  }

  // No trailing zeros found to strip.
  if (truncated_length == length - 1)
    return builder.Finalize();

  // If we removed all trailing zeros, remove the decimal point as well.
  if (truncated_length == decimal_point_position) {
    DCHECK_GT(truncated_length, 0);
    --truncated_length;
  }

  // Truncate the StringBuilder, and return the final result.
  char* result = builder.Finalize();
  result[truncated_length + 1] = '\0';
  return result;
}

const char* NumberToFixedPrecisionString(double d, unsigned significant_figures, NumberToStringBuffer buffer) {
  // Mimic String::format("%.[precision]g", ...), but use dtoas rounding
  // facilities.
  // "g": Signed value printed in f or e format, whichever is more compact for
  // the given value and precision.
  // The e format is used only when the exponent of the value is less than -4 or
  // greater than or equal to the precision argument. Trailing zeros are
  // truncated, and the decimal point appears only if one or more digits follow
  // it.
  // "precision": The precision specifies the maximum number of significant
  // digits printed.
  double_conversion::StringBuilder builder(buffer, kNumberToStringBufferLength);
  const double_conversion::DoubleToStringConverter& converter =
      double_conversion::DoubleToStringConverter::EcmaScriptConverter();
  converter.ToPrecision(d, significant_figures, &builder);
  // FIXME: Trailing zeros should never be added in the first place. The
  // current implementation does not strip when there is an exponent, eg.
  // 1.50000e+10.
  return FormatStringTruncatingTrailingZerosIfNeeded(buffer, builder);
}

const char* NumberToFixedWidthString(double d, unsigned decimal_places, NumberToStringBuffer buffer) {
  // Mimic String::format("%.[precision]f", ...), but use dtoas rounding
  // facilities.
  // "f": Signed value having the form [ - ]dddd.dddd, where dddd is one or more
  // decimal digits.  The number of digits before the decimal point depends on
  // the magnitude of the number, and the number of digits after the decimal
  // point depends on the requested precision.
  // "precision": The precision value specifies the number of digits after the
  // decimal point.  If a decimal point appears, at least one digit appears
  // before it.  The value is rounded to the appropriate number of digits.
  double_conversion::StringBuilder builder(buffer, kNumberToStringBufferLength);
  const double_conversion::DoubleToStringConverter& converter =
      double_conversion::DoubleToStringConverter::EcmaScriptConverter();
  converter.ToFixed(d, decimal_places, &builder);
  return builder.Finalize();
}

double ParseDouble(const char* string, size_t length, size_t& parsed_length) {
  int int_parsed_length = 0;
  double d = GetDoubleConverter().StringToDouble(reinterpret_cast<const char*>(string),
                                                 base::saturated_cast<int>(length), &int_parsed_length);
  parsed_length = int_parsed_length;
  return d;
}

namespace internal {

void InitializeDoubleConverter() {
  // Force initialization of static DoubleToStringConverter converter variable
  // inside EcmaScriptConverter function while we are in single thread mode.
  double_conversion::DoubleToStringConverter::EcmaScriptConverter();

  GetDoubleConverter();
}

}  // namespace internal

}  // namespace webf
