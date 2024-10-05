/*
* Copyright (C) 2003 Lars Knoll (knoll@kde.org)
* Copyright (C) 2004, 2005, 2006, 2008, 2009, 2010 Apple Inc. All rights
* reserved.
* Copyright (C) 2008 Eric Seidel <eric@webkit.org>
* Copyright (C) 2009 - 2010  Torch Mobile (Beijing) Co. Ltd. All rights
* reserved.
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

#ifndef WEBF_CORE_CSS_CSS_MARKUP_H_
#define WEBF_CORE_CSS_CSS_MARKUP_H_

#include <string>
#include "foundation/string_builder.h"
#include "bindings/qjs/atomic_string.h"

// Helper functions for converting from CSSValues to text.

namespace webf {


// Common serializing methods. See:
// https://drafts.csswg.org/cssom/#common-serializing-idioms
void SerializeIdentifier(const std::string_view& identifier,
                         StringBuilder& append_to,
                         bool skip_start_checks = false);
void SerializeString(const std::string_view&, StringBuilder& append_to);
std::string SerializeString(const std::string&);
std::string SerializeURI(const std::string&);
std::string SerializeFontFamily(const std::string&);

}

#endif  // WEBF_CORE_CSS_CSS_MARKUP_H_
