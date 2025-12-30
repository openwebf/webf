/*
 * (C) 1999-2003 Lars Knoll (knoll@kde.org)
 * (C) 2002-2003 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2002, 2006, 2012 Apple Computer, Inc.
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
 */

#include "css_rule_list.h"

#include <charconv>

#include "bindings/qjs/exception_state.h"
#include "foundation/string/atomic_string.h"

namespace webf {

bool CSSRuleList::NamedPropertyQuery(const AtomicString& key, ExceptionState& exception_state) {
  if (key.IsNull()) {
    return false;
  }

  std::string str = key.ToUTF8String();
  if (str.empty()) {
    return false;
  }

  uint32_t index = 0;
  const char* begin = str.data();
  const char* end = begin + str.size();
  auto [ptr, ec] = std::from_chars(begin, end, index);
  if (ec != std::errc() || ptr != end) {
    return false;
  }

  return index < length();
}

void CSSRuleList::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState& exception_state) {
  unsigned len = length();
  names.reserve(len);
  for (unsigned i = 0; i < len; i++) {
    names.emplace_back(AtomicString(std::to_string(i)));
  }
}

}  // namespace webf
