/*
 * Copyright (C) 2000 Lars Knoll (knoll@kde.org)
 *           (C) 2000 Antti Koivisto (koivisto@kde.org)
 *           (C) 2000 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2003, 2006, 2007, 2010, 2011 Apple Inc. All rights reserved.
 * Copyright (C) 2008 Holger Hans Peter Freyther
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

#ifndef WEBF_CORE_PLATFORM_FONTS_FONT_H_
#define WEBF_CORE_PLATFORM_FONTS_FONT_H_

#include "core/platform/fonts/font_description.h"
#include "foundation/macros.h"

namespace webf {

class GCVisitor;

class Font {
  WEBF_DISALLOW_NEW();

 public:
  Font();
  explicit Font(const FontDescription&);

  Font(const Font&) = default;
  Font(Font&&) = default;
  Font& operator=(const Font&) = default;
  Font& operator=(Font&&) = default;

  bool operator==(const Font& other) const;
  bool operator!=(const Font& other) const { return !(*this == other); }

  const FontDescription& GetFontDescription() const { return font_description_; }

 public:
  FontDescription font_description_;
};

}  // namespace webf

#endif  // WEBF_CORE_PLATFORM_FONTS_FONT_H_
