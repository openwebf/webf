// Copyright 2013 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_URL_FILE_H
#define WEBF_URL_FILE_H

#include "url_parse_internal.h"

namespace webf {

namespace url {

// We allow both "c:" and "c|" as drive identifiers.
inline bool IsWindowsDriveSeparator(char16_t ch) {
  return ch == ':' || ch == '|';
}
inline bool IsWindowsDriveSeparator(char ch) {
  return IsWindowsDriveSeparator(static_cast<char16_t>(ch));
}

// DoesContainWindowsDriveSpecUntil returns the least number between
// start_offset and max_offset such that the spec has a valid drive
// specification starting at that offset. Otherwise it returns -1. This function
// gracefully handles, by returning -1, start_offset values that are equal to or
// larger than the spec_len, and caps max_offset appropriately to simplify
// callers. max_offset must be at least start_offset.
template <typename CHAR>
inline int DoesContainWindowsDriveSpecUntil(const CHAR* spec,
                                            int start_offset,
                                            int max_offset,
                                            int spec_len) {
  assert(start_offset <= max_offset);
  if (start_offset > spec_len - 2)
    return -1;  // Not enough room.
  if (max_offset > spec_len - 2)
    max_offset = spec_len - 2;
  for (int offset = start_offset; offset <= max_offset; ++offset) {
    // NOTE(xiezuobing):
    if (!((spec[offset] >= 'A' && spec[offset] <= 'Z') || (spec[offset] >= 'a' && spec[offset] <= 'z')))
      continue;  // Doesn't contain a valid drive letter.
    if (!IsWindowsDriveSeparator(spec[offset + 1]))
      continue;  // Isn't followed with a drive separator.
    return offset;
  }
  return -1;
}

// Returns true if the start_offset in the given spec looks like it begins a
// drive spec, for example "c:". This function explicitly handles start_offset
// values that are equal to or larger than the spec_len to simplify callers.
//
// If this returns true, the spec is guaranteed to have a valid drive letter
// plus a drive letter separator (a colon or a pipe) starting at |start_offset|.
template <typename CHAR>
inline bool DoesBeginWindowsDriveSpec(const CHAR* spec,
                                      int start_offset,
                                      int spec_len) {
  return DoesContainWindowsDriveSpecUntil(spec, start_offset, start_offset,
                                          spec_len) == start_offset;
}

#ifdef WIN32

// Returns true if the start_offset in the given text looks like it begins a
// UNC path, for example "\\". This function explicitly handles start_offset
// values that are equal to or larger than the spec_len to simplify callers.
//
// When strict_slashes is set, this function will only accept backslashes as is
// standard for Windows. Otherwise, it will accept forward slashes as well
// which we use for a lot of URL handling.
template<typename CHAR>
inline bool DoesBeginUNCPath(const CHAR* text,
                             int start_offset,
                             int len,
                             bool strict_slashes) {
  int remaining_len = len - start_offset;
  if (remaining_len < 2)
    return false;

  if (strict_slashes)
    return text[start_offset] == '\\' && text[start_offset + 1] == '\\';
  return IsSlashOrBackslash(text[start_offset]) &&
         IsSlashOrBackslash(text[start_offset + 1]);
}

#endif  // WIN32

}  // namespace url

}  // namespace webf

#endif  // WEBF_URL_FILE_H
