/*
 * Copyright (C) 2012 Nokia Corporation and/or its subsidiary(-ies)
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

#include "core/css/css_border_image.h"

namespace webf {

std::shared_ptr<const CSSValueList> CreateBorderImageValue(const std::shared_ptr<const CSSValue>& image,
                                                           const std::shared_ptr<const CSSValue>& image_slice,
                                                           const std::shared_ptr<const CSSValue>& border_slice,
                                                           const std::shared_ptr<const CSSValue>& outset,
                                                           const std::shared_ptr<const CSSValue>& repeat) {
  std::shared_ptr<CSSValueList> list = CSSValueList::CreateSpaceSeparated();
  if (image) {
    list->Append(image);
  }

  if (border_slice || outset) {
    std::shared_ptr<CSSValueList> list_slash = CSSValueList::CreateSlashSeparated();
    if (image_slice) {
      list_slash->Append(image_slice);
    }

    if (border_slice) {
      list_slash->Append(border_slice);
    }

    if (outset) {
      list_slash->Append(outset);
    }

    list->Append(list_slash);
  } else if (image_slice) {
    list->Append(image_slice);
  }
  if (repeat) {
    list->Append(repeat);
  }
  return list;
}

}  // namespace webf