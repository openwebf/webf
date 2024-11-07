/*
* Copyright (C) 2010 Apple Inc. All Rights Reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions
* are met:
* 1. Redistributions of source code must retain the above copyright
*    notice, this list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright
*    notice, this list of conditions and the following disclaimer in the
*    documentation and/or other materials provided with the distribution.
*
* THIS SOFTWARE IS PROVIDED BY APPLE INC. ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE INC. OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include "string_statics.h"

namespace webf {

DEFINE_GLOBAL(AtomicString, g_null_atom);
DEFINE_GLOBAL(AtomicString, g_empty_atom);
DEFINE_GLOBAL(AtomicString, g_star_atom);
DEFINE_GLOBAL(AtomicString, g_xml_atom);
DEFINE_GLOBAL(AtomicString, g_xmlns_atom);
DEFINE_GLOBAL(AtomicString, g_xlink_atom);
DEFINE_GLOBAL(AtomicString, g_http_atom);
DEFINE_GLOBAL(AtomicString, g_https_atom);

// This is not an AtomicString because it is unlikely to be used as an
// event/element/attribute name, so it shouldn't pollute the AtomicString hash
// table.

DEFINE_GLOBAL(std::string, g_empty_string);

void StringStatics::Init() {
  new ((void*)&g_empty_string) std::string();
  new ((void*)&g_star_atom) AtomicString("*");
  new ((void*)&g_xml_atom) AtomicString("xml");
  new ((void*)&g_xmlns_atom) AtomicString("xmlns");
  new ((void*)&g_xlink_atom) AtomicString("xlink");
  new ((void*)&g_http_atom) AtomicString("http");
  new ((void*)&g_https_atom) AtomicString("https");
}

}