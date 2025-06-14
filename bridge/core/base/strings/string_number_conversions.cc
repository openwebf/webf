// Copyright 2012 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "string_number_conversions.h"

#include <cassert>
#include <charconv>
#include <iterator>
#include <sstream>
#include <string>
#include <string_view>

#include "foundation/macros.h"

#include "core/base/strings/string_number_conversions_internal.h"

namespace base {

std::string NumberToString(int value) {
  return internal::IntToStringT<std::string>(value);
}

std::u16string NumberToString16(int value) {
  return internal::IntToStringT<std::u16string>(value);
}

std::string NumberToString(unsigned value) {
  return internal::IntToStringT<std::string>(value);
}

std::u16string NumberToString16(unsigned value) {
  return internal::IntToStringT<std::u16string>(value);
}

std::string NumberToString(long value) {
  return internal::IntToStringT<std::string>(value);
}

std::u16string NumberToString16(long value) {
  return internal::IntToStringT<std::u16string>(value);
}

std::string NumberToString(unsigned long value) {
  return internal::IntToStringT<std::string>(value);
}

std::u16string NumberToString16(unsigned long value) {
  return internal::IntToStringT<std::u16string>(value);
}

std::string NumberToString(long long value) {
  return internal::IntToStringT<std::string>(value);
}

std::u16string NumberToString16(long long value) {
  return internal::IntToStringT<std::u16string>(value);
}

std::string NumberToString(unsigned long long value) {
  return internal::IntToStringT<std::string>(value);
}

std::u16string NumberToString16(unsigned long long value) {
  return internal::IntToStringT<std::u16string>(value);
}

std::string NumberToString(double value) {
  return internal::DoubleToStringT<std::string>(value);
}

bool StringToInt(std::string_view input, int* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToInt(std::u16string_view input, int* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToUint(std::string_view input, unsigned* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToUint(std::u16string_view input, unsigned* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToInt64(std::string_view input, int64_t* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToInt64(std::u16string_view input, int64_t* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToUint64(std::string_view input, uint64_t* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToUint64(std::u16string_view input, uint64_t* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToSizeT(std::string_view input, size_t* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToSizeT(std::u16string_view input, size_t* output) {
  return internal::StringToIntImpl(input, *output);
}

bool StringToDouble(std::string_view input, double* output) {
  return internal::StringToDoubleImpl(input, input.data(), *output);
}

bool StringToDouble(std::u16string_view input, double* output) {
  return internal::StringToDoubleImpl(input, reinterpret_cast<const uint16_t*>(input.data()), *output);
}

std::string HexEncode(const void* bytes, size_t size) {
  return HexEncode(static_cast<const uint8_t*>(bytes), size);
}

std::string HexEncode(const uint8_t* bytes, size_t length) {
  // Each input byte creates two output hex characters.
  std::string ret;
  ret.reserve(length * 2);

  for (int i = 0; i < length; i++) {
    AppendHexEncodedByte(bytes[i], ret);
  }

  return ret;
}

std::string HexEncode(std::string_view chars) {
  return HexEncode(reinterpret_cast<const uint8_t*>(chars.data()), chars.size());
}

bool HexStringToInt(std::string_view input, int* output) {
  if (!output)
    return false;  // Handle null pointer
  auto [ptr, ec] = std::from_chars(input.data(), input.data() + input.size(), *output, 16);
  return ec == std::errc();  // Returns true if no error occurred
}

bool HexStringToUInt(std::string_view input, uint32_t* output) {
  if (!output)
    return false;  // Handle null pointer
  auto [ptr, ec] = std::from_chars(input.data(), input.data() + input.size(), *output, 16);
  return ec == std::errc();  // Returns true if no error occurred
}

bool HexStringToInt64(std::string_view input, int64_t* output) {
  if (!output)
    return false;  // Handle null pointer
  auto [ptr, ec] = std::from_chars(input.data(), input.data() + input.size(), *output, 16);
  return ec == std::errc();  // Returns true if no error occurred
}

bool HexStringToUInt64(std::string_view input, uint64_t* output) {
  if (!output)
    return false;  // Handle null pointer
  auto [ptr, ec] = std::from_chars(input.data(), input.data() + input.size(), *output, 16);
  return ec == std::errc();  // Returns true if no error occurred
}

bool HexStringToBytes(std::string_view input, std::vector<uint8_t>* output) {
  DCHECK(output->empty());
  return internal::HexStringToByteContainer<uint8_t>(input, std::back_inserter(*output));
}

bool HexStringToString(std::string_view input, std::string* output) {
  DCHECK(output->empty());
  return internal::HexStringToByteContainer<char>(input, std::back_inserter(*output));
}

// bool HexStringToSpan(std::string_view input, tcb::span<uint8_t> output) {
//  if (input.size() / 2 != output.size())
//    return false;
//
//  return internal::HexStringToByteContainer<uint8_t>(input, output.begin());
//}

}  // namespace base