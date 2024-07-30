/*
    Copyright (C) 1999 Lars Knoll (knoll@kde.org)
    Copyright (C) 2006, 2008 Apple Inc. All rights reserved.
    Copyright (C) 2011 Rik Cabanier (cabanier@adobe.com)
    Copyright (C) 2011 Adobe Systems Incorporated. All rights reserved.
    Copyright (C) 2012 Motorola Mobility, Inc. All rights reserved.

    This library is free software; you can redistribute it and/or
    modify it under the terms of the GNU Library General Public
    License as published by the Free Software Foundation; either
    version 2 of the License, or (at your option) any later version.

    This library is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    Library General Public License for more details.

    You should have received a copy of the GNU Library General Public License
    along with this library; see the file COPYING.LIB.  If not, write to
    the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
    Boston, MA 02110-1301, USA.
*/

/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_GEOMETRY_LENGTH_FUNCTIONS_H_
#define WEBF_CORE_GEOMETRY_LENGTH_FUNCTIONS_H_

#include "core/geometry/layout_unit.h"
#include "core/geometry/length.h"

namespace gfx {
class PointF;
class SizeF;
}

namespace webf {

class Length;
class LengthSize;

struct LengthPoint;

int IntValueForLength(const Length&, int maximum_value);
float FloatValueForLength(const Length&,
                                          float maximum_value,
                                          const Length::EvaluationInput& = {});
LayoutUnit MinimumValueForLengthInternal(const Length&,
                              LayoutUnit maximum_value,
                              const Length::EvaluationInput&);

inline LayoutUnit MinimumValueForLength(
    const Length& length,
    LayoutUnit maximum_value,
    const Length::EvaluationInput& input = {}) {
  if (LIKELY(length.IsFixed()))
    return LayoutUnit(length.Value());

  return MinimumValueForLengthInternal(length, maximum_value, input);
}

LayoutUnit ValueForLength(const Length&,
               LayoutUnit maximum_value,
               const Length::EvaluationInput& input = {});
gfx::SizeF SizeForLengthSize(const LengthSize&,
                                             const gfx::SizeF& box_size);
gfx::PointF PointForLengthPoint(const LengthPoint&,
                                                const gfx::SizeF& box_size);

}  // namespace webf

#endif  // WEBF_CORE_GEOMETRY_LENGTH_FUNCTIONS_H_
