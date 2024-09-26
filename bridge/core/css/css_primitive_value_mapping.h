/*
* Copyright (C) 2007 Alexey Proskuryakov <ap@nypop.com>.
* Copyright (C) 2008, 2009, 2010, 2011 Apple Inc. All rights reserved.
* Copyright (C) 2009 Torch Mobile Inc. All rights reserved.
* (http://www.torchmobile.com/)
* Copyright (C) 2009 Jeff Schiller <codedread@gmail.com>
* Copyright (C) Research In Motion Limited 2010. All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
*
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
* OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
* INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
* DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
* THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
* THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#ifndef THIRD_PARTY_BLINK_RENDERER_CORE_CSS_CSS_PRIMITIVE_VALUE_MAPPINGS_H_
#define THIRD_PARTY_BLINK_RENDERER_CORE_CSS_CSS_PRIMITIVE_VALUE_MAPPINGS_H_

#include "core/css/css_identifier_value.h"

namespace webf {

template <>
inline TimelineOffset::NamedRange CSSIdentifierValue::ConvertTo() const {
  switch (GetValueID()) {
    case CSSValueID::kCover:
      return TimelineOffset::NamedRange::kCover;
    case CSSValueID::kContain:
      return TimelineOffset::NamedRange::kContain;
    case CSSValueID::kEntry:
      return TimelineOffset::NamedRange::kEntry;
    case CSSValueID::kEntryCrossing:
      return TimelineOffset::NamedRange::kEntryCrossing;
    case CSSValueID::kExit:
      return TimelineOffset::NamedRange::kExit;
    case CSSValueID::kExitCrossing:
      return TimelineOffset::NamedRange::kExitCrossing;
    default:
      break;
  }
  NOTREACHED_IN_MIGRATION();
  return TimelineOffset::NamedRange::kCover;
}


}


#endif  // THIRD_PARTY_BLINK_RENDERER_CORE_CSS_CSS_PRIMITIVE_VALUE_MAPPINGS_H_