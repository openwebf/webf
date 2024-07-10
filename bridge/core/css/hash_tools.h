/*
 * Copyright (C) 2010 Andras Becsi <abecsi@inf.u-szeged.hu>, University of
 * Szeged
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

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_HASH_TOOLS_H
#define WEBF_HASH_TOOLS_H

#include "foundation/macros.h"

namespace webf {

struct Property {
  WEBF_DISALLOW_NEW();
 public:
  int name_offset;
  int id;
};

struct Value {
  WEBF_DISALLOW_NEW();
 public:
  int name_offset;
  int id;
};

const Property* FindProperty(const char* str, unsigned len);
const Value* FindValue(const char* str, unsigned len);


}  // namespace webf

#endif  // WEBF_HASH_TOOLS_H
