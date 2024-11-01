/*
*  Copyright (C) 2003, 2008, 2012 Apple Inc. All rights reserved.
*
*  This library is free software; you can redistribute it and/or
*  modify it under the terms of the GNU Library General Public
*  License as published by the Free Software Foundation; either
*  version 2 of the License, or (at your option) any later version.
*
*  This library is distributed in the hope that it will be useful,
*  but WITHOUT ANY WARRANTY; without even the implied warranty of
*  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
*  Library General Public License for more details.
*
*  You should have received a copy of the GNU Library General Public License
*  along with this library; see the file COPYING.LIB.  If not, write to
*  the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
*  Boston, MA 02110-1301, USA.
*
*/

#include "core/base/numerics/safe_conversions.h"

#ifndef WEBF_FOUNDATION_DTOA_H_
#define WEBF_FOUNDATION_DTOA_H_

namespace webf {

// Size = 80 for sizeof(DtoaBuffer) + some sign bits, decimal point, 'e',
// exponent digits.
const unsigned kNumberToStringBufferLength = 96;
typedef char NumberToStringBuffer[kNumberToStringBufferLength];

const char* NumberToString(double, NumberToStringBuffer);
const char* NumberToFixedPrecisionString(
    double,
    unsigned significant_figures,
    NumberToStringBuffer);
const char* NumberToFixedWidthString(double,
                                                unsigned decimal_places,
                                                NumberToStringBuffer);

double ParseDouble(const char* string,
                              size_t length,
                              size_t& parsed_length);
namespace internal {

void InitializeDoubleConverter();

}  // namespace internal

}

#endif  // WEBF_FOUNDATION_DTOA_H_
