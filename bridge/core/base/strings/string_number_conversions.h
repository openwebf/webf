// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_STRING_NUMBER_CONVERSIONS_H
#define WEBF_STRING_NUMBER_CONVERSIONS_H

#include <stddef.h>
#include <stdint.h>
#include <span>
#include <string>
#include <string_view>
#include <vector>

// ----------------------------------------------------------------------------
// IMPORTANT MESSAGE FROM YOUR SPONSOR
//
// Please do not add "convenience" functions for converting strings to integers
// that return the value and ignore success/failure. That encourages people to
// write code that doesn't properly handle the error conditions.
//
// DO NOT use these functions in any UI unless it's NOT localized on purpose.
// Instead, use base::MessageFormatter for a complex message with numbers
// (integer, float, double) embedded or base::Format{Number,Double,Percent} to
// just format a single number/percent. Note that some languages use native
// digits instead of ASCII digits while others use a group separator or decimal
// point different from ',' and '.'. Using these functions in the UI would lead
// numbers to be formatted in a non-native way.
// ----------------------------------------------------------------------------
namespace base {

// Number -> string conversions ------------------------------------------------

// Ignores locale! see warning above.
std::string NumberToString(int value);
std::string NumberToString(unsigned int value);
std::string NumberToString(long value);
std::string NumberToString(unsigned long value);
std::string NumberToString(long long value);
std::string NumberToString(unsigned long long value);
std::string NumberToString(double value);

// String -> number conversions ------------------------------------------------

// Perform a best-effort conversion of the input string to a numeric type,
// setting |*output| to the result of the conversion.  Returns true for
// "perfect" conversions; returns false in the following cases:
//  - Overflow. |*output| will be set to the maximum value supported
//    by the data type.
//  - Underflow. |*output| will be set to the minimum value supported
//    by the data type.
//  - Trailing characters in the string after parsing the number.  |*output|
//    will be set to the value of the number that was parsed.
//  - Leading whitespace in the string before parsing the number. |*output| will
//    be set to the value of the number that was parsed.
//  - No characters parseable as a number at the beginning of the string.
//    |*output| will be set to 0.
//  - Empty string.  |*output| will be set to 0.
// WARNING: Will write to |output| even when returning false.
//          Read the comments above carefully.
bool StringToInt(std::string_view input, int* output);

bool StringToUint(std::string_view input, unsigned* output);

bool StringToInt64(std::string_view input, int64_t* output);

bool StringToUint64(std::string_view input, uint64_t* output);

bool StringToSizeT(std::string_view input, size_t* output);

// For floating-point conversions, only conversions of input strings in decimal
// form are defined to work.  Behavior with strings representing floating-point
// numbers in hexadecimal, and strings representing non-finite values (such as
// NaN and inf) is undefined.  Otherwise, these behave the same as the integral
// variants.  This expects the input string to NOT be specific to the locale.
// If your input is locale specific, use ICU to read the number.
// WARNING: Will write to |output| even when returning false.
//          Read the comments here and above StringToInt() carefully.
bool StringToDouble(std::string_view input, double* output);

// Hex encoding ----------------------------------------------------------------

// Returns a hex string representation of a binary buffer. The returned hex
// string will be in upper case. This function does not check if |size| is
// within reasonable limits since it's written with trusted data in mind.  If
// you suspect that the data you want to format might be large, the absolute
// max size for |size| should be is
//   std::numeric_limits<size_t>::max() / 2
std::string HexEncode(const uint8_t* bytes, size_t length);
std::string HexEncode(std::string_view chars);
std::string HexEncode(const void* bytes, size_t size);

// Appends a hex representation of `byte`, as two uppercase (by default)
// characters, to `output`. This is a useful primitive in larger conversion
// routines.
inline void AppendHexEncodedByte(uint8_t byte, std::string& output, bool uppercase = true) {
  static constexpr char kHexCharsUpper[] = {'0', '1', '2', '3', '4', '5', '6', '7',
                                            '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
  static constexpr char kHexCharsLower[] = {'0', '1', '2', '3', '4', '5', '6', '7',
                                            '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
  const char* const hex_chars = uppercase ? kHexCharsUpper : kHexCharsLower;
  output.append({hex_chars[byte >> 4], hex_chars[byte & 0xf]});
}

// Best effort conversion, see StringToInt above for restrictions.
// Will only successful parse hex values that will fit into |output|, i.e.
// -0x80000000 < |input| < 0x7FFFFFFF.
bool HexStringToInt(std::string_view input, int* output);

// Best effort conversion, see StringToInt above for restrictions.
// Will only successful parse hex values that will fit into |output|, i.e.
// 0x00000000 < |input| < 0xFFFFFFFF.
// The string is not required to start with 0x.
bool HexStringToUInt(std::string_view input, uint32_t* output);

// Best effort conversion, see StringToInt above for restrictions.
// Will only successful parse hex values that will fit into |output|, i.e.
// -0x8000000000000000 < |input| < 0x7FFFFFFFFFFFFFFF.
bool HexStringToInt64(std::string_view input, int64_t* output);

// Best effort conversion, see StringToInt above for restrictions.
// Will only successful parse hex values that will fit into |output|, i.e.
// 0x0000000000000000 < |input| < 0xFFFFFFFFFFFFFFFF.
// The string is not required to start with 0x.
bool HexStringToUInt64(std::string_view input, uint64_t* output);

// Similar to the previous functions, except that output is a vector of bytes.
// |*output| will contain as many bytes as were successfully parsed prior to the
// error.  There is no overflow, but input.size() must be evenly divisible by 2.
// Leading 0x or +/- are not allowed.
bool HexStringToBytes(std::string_view input, std::vector<uint8_t>* output);

// Same as HexStringToBytes, but for an std::string.
bool HexStringToString(std::string_view input, std::string* output);

// Decodes the hex string |input| into a presized |output|. The output buffer
// must be sized exactly to |input.size() / 2| or decoding will fail and no
// bytes will be written to |output|. Decoding an empty input is also
// considered a failure. When decoding fails due to encountering invalid input
// characters, |output| will have been filled with the decoded bytes up until
// the failure.
//bool HexStringToSpan(std::string_view input, tcb::span<> output);

}  // namespace base

#endif  // WEBF_STRING_NUMBER_CONVERSIONS_H