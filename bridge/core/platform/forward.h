/*
 *  Copyright (C) 2006, 2009, 2011 Apple Inc. All rights reserved.
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

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_PLATFORM_WTF_FORWARD_H_
#define WEBF_PLATFORM_WTF_FORWARD_H_

#include <stddef.h>
#include <stdint.h>


template <typename T>
class scoped_refptr;

namespace WTF {

template <typename T>
class StringBuffer;
class PartitionAllocator;
template <typename T,
          uint32_t inlineCapacity = 0,
          typename Allocator = PartitionAllocator>
class Vector;

class AtomicString;
class CaseMap;
class OrdinalNumber;
class SegmentedBuffer;
class SharedBuffer;
class StringImpl;
class StringView;
class TextOffsetMap;
class TextStream;

}  // namespace WTF

using WTF::Vector;

using WTF::AtomicString;
using WTF::CaseMap;
using WTF::SegmentedBuffer;
using WTF::SharedBuffer;
using WTF::StringBuffer;
using WTF::StringImpl;
using WTF::StringView;
using WTF::TextOffsetMap;

#endif  // WEBF_PLATFORM_WTF_FORWARD_H_
