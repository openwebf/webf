/*
 * Copyright (C) 2000 Lars Knoll (knoll@kde.org)
 *           (C) 2000 Antti Koivisto (koivisto@kde.org)
 *           (C) 2000 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008 Apple Inc. All rights
 * reserved.
 * Copyright (C) 2007 Nicholas Shanks <webkit@nickshanks.com>
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

#ifndef WEBF_CORE_PLATFORM_FONTS_FONT_DESCRIPTION_H_
#define WEBF_CORE_PLATFORM_FONTS_FONT_DESCRIPTION_H_

#include <cinttypes>
#include "core/platform/fonts/font_family.h"
#include "font_family_names.h"
#include "foundation/macros.h"

namespace webf {

typedef struct {
  uint32_t parts[1];
} FieldsAsUnsignedType;

class FontDescription {
  USING_FAST_MALLOC(FontDescription);
 public:
  enum HashCategory { kHashEmptyValue = 0, kHashDeletedValue, kHashRegularValue };

  enum GenericFamilyType : uint8_t {
    kNoFamily,
    kStandardFamily,
    kWebkitBodyFamily,
    kSerifFamily,
    kSansSerifFamily,
    kMonospaceFamily,
    kCursiveFamily,
    kFantasyFamily
  };

  FontDescription();
  FontDescription(const FontDescription&);

  FontDescription& operator=(const FontDescription&);
  bool operator==(const FontDescription&) const;
  bool operator!=(const FontDescription& other) const {
    return !(*this == other);
  }

 private:
  FontFamily family_list_;  // The list of font families to be used.
};

}  // namespace webf

#endif  // WEBF_CORE_PLATFORM_FONTS_FONT_DESCRIPTION_H_
