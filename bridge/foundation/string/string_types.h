/*
 * Copyright (C) 2025-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_TYPE_H
#define WEBF_TYPE_H

#include <string>
#include <string_view>

namespace webf {

// Latin1 chars
typedef unsigned char LChar;
// UTF16 units
typedef char16_t UChar;
// UTF8 units
typedef char UTF8Char;
// Unicode
typedef uint32_t UCharCodePoint;

// We want to explicit about the string types.
typedef std::basic_string<LChar> Latin1String;
typedef std::basic_string<UChar> UTF16String;
typedef std::basic_string<UTF8Char> UTF8String;

// We want to explicit about the string view types.
typedef std::basic_string_view<LChar> Latin1StringView;
typedef std::basic_string_view<UChar> UTF16StringView;
typedef std::basic_string_view<UTF8Char> UTF8StringView;

}

#endif  // WEBF_TYPE_H
