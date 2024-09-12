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
  return std::to_string(value);
}

std::string NumberToString(unsigned value) {
  return std::to_string(value);
}

std::string NumberToString(long value) {
  return std::to_string(value);
}

std::string NumberToString(unsigned long value) {
  return std::to_string(value);
}

std::string NumberToString(long long value) {
  return std::to_string(value);
}

std::string NumberToString(unsigned long long value) {
  return std::to_string(value);
}

std::string NumberToString(double value) {
  return std::to_string(value);
}

bool StringToInt(std::string_view input, int* output) {
  int result = std::stoi(input.data());
  *output = result;
  return true;
}

bool StringToUint(std::string_view input, unsigned* output) {
  unsigned result = std::stoul(input.data());
  *output = result;
  return true;
}

bool StringToInt64(std::string_view input, int64_t* output) {
  int64_t result = std::stoll(input.data());
  *output = result;
  return true;
}

bool StringToUint64(std::string_view input, uint64_t* output) {
  uint64_t result = std::stoull(input.data());
  *output = result;
  return true;
}

bool StringToSizeT(std::string_view input, size_t* output) {
  size_t result = std::stoull(input.data());
  *output = result;
  return true;
}

// TODO(xiezuobing): internal::StringToDoubleImpl -> std::istringstream
// It`s unsupported '- 12.32'
// ' -1223.212' -> double type '-1223.212'
bool StringToDouble(std::string_view input, double* output) {
  *output = std::stod(std::string(input));
  return true;
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

//bool HexStringToSpan(std::string_view input, tcb::span<uint8_t> output) {
//  if (input.size() / 2 != output.size())
//    return false;
//
//  return internal::HexStringToByteContainer<uint8_t>(input, output.begin());
//}

}  // namespace base