// Copyright 2013 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifdef UNSAFE_BUFFERS_BUILD
// TODO(crbug.com/350788890): Remove this and spanify to fix the errors.
#pragma allow_unsafe_buffers
#endif

#include "url_canon.h"
#include "url_canon_internal.h"

// Query canonicalization in IE
// ----------------------------
// IE is very permissive for query parameters specified in links on the page
// (in contrast to links that it constructs itself based on form data). It does
// not unescape any character. It does not reject any escape sequence (be they
// invalid like "%2y" or freaky like %00).
//
// IE only escapes spaces and nothing else. Embedded NULLs, tabs (0x09),
// LF (0x0a), and CR (0x0d) are removed (this probably happens at an earlier
// layer since they are removed from all portions of the URL). All other
// characters are passed unmodified. Invalid UTF-16 sequences are preserved as
// well, with each character in the input being converted to UTF-8. It is the
// server's job to make sense of this invalid query.
//
// Invalid multibyte sequences (for example, invalid UTF-8 on a UTF-8 page)
// are converted to the invalid character and sent as unescaped UTF-8 (0xef,
// 0xbf, 0xbd). This may not be canonicalization, the parser may generate these
// strings before the URL handler ever sees them.
//
// Our query canonicalization
// --------------------------
// We escape all non-ASCII characters and control characters, like Firefox.
// This is more conformant to the URL spec, and there do not seem to be many
// problems relating to Firefox's behavior.
//
// Like IE, we will never unescape (although the application may want to try
// unescaping to present the user with a more understandable URL). We will
// replace all invalid sequences (including invalid UTF-16 sequences, which IE
// doesn't) with the "invalid character," and we will escape it.

namespace webf {

namespace url {

namespace {

// Appends the given string to the output, escaping characters that do not
// match the given |type| in SharedCharTypes. This version will accept 8 or 16
// bit characters, but assumes that they have only 7-bit values. It also assumes
// that all UTF-8 values are correct, so doesn't bother checking
template<typename CHAR>
void AppendRaw8BitQueryString(const CHAR* source, int length,
                              CanonOutput* output) {
  for (int i = 0; i < length; i++) {
    if (!IsQueryChar(static_cast<unsigned char>(source[i])))
      AppendEscapedChar(static_cast<unsigned char>(source[i]), output);
    else  // Doesn't need escaping.
      output->push_back(static_cast<char>(source[i]));
  }
}

void DoConvertToQueryEncoding(const char* spec,
                              const Component& query,
                              CanonOutput* output) {
  // No converter, do our own UTF-8 conversion.
  AppendStringOfType(&spec[query.begin], static_cast<size_t>(query.len),
                     CHAR_QUERY, output);
}

void DoCanonicalizeQuery(const char* spec,
                         const Component& query,
                         CanonOutput* output,
                         Component* out_query) {
  if (!query.is_valid()) {
    *out_query = Component();
    return;
  }

  output->push_back('?');
  out_query->begin = output->length();

  DoConvertToQueryEncoding(spec, query, output);

  out_query->len = output->length() - out_query->begin;
}

}  // namespace

void CanonicalizeQuery(const char* spec,
                       const Component& query,
                       CanonOutput* output,
                       Component* out_query) {
  DoCanonicalizeQuery(spec, query,
                                           output, out_query);
}

}  // namespace url


}