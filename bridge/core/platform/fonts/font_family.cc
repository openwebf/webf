/*
* Copyright (C) 2003, 2006, 2008 Apple Inc. All rights reserved.
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
* THIS SOFTWARE IS PROVIDED BY APPLE COMPUTER, INC. ``AS IS'' AND ANY
* EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
* IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
* PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL APPLE COMPUTER, INC. OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
* EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
* OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
* OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#include "font_family.h"
#include "font_family_names.h"
//#include "core/platform/fonts/font_cache.h"

namespace webf {

bool operator==(const FontFamily& a, const FontFamily& b) {
  if (a.FamilyIsGeneric() != b.FamilyIsGeneric() ||
      a.FamilyName() != b.FamilyName())
    return false;
  const FontFamily* ap;
  const FontFamily* bp;
  for (ap = a.Next(), bp = b.Next(); ap != bp;
       ap = ap->Next(), bp = bp->Next()) {
    if (!ap || !bp)
      return false;
    if (ap->FamilyIsGeneric() != bp->FamilyIsGeneric() ||
        ap->FamilyName() != bp->FamilyName())
      return false;
  }
  return true;
}

std::string FontFamily::ToString() const {
  std::string builder;
  builder+=family_name_;
  const FontFamily* current = Next();
  while (current) {
    builder+=", ";
    builder+=current->FamilyName();
    current = current->Next();
  }
  return builder;
}

/*static*/ FontFamily::Type FontFamily::InferredTypeFor(
    const std::string& family_name) {
  return (family_name == font_family_names_stdstring::kcursive ||
          family_name == font_family_names_stdstring::kfantasy ||
          family_name == font_family_names_stdstring::kmonospace ||
          family_name == font_family_names_stdstring::ksansSerif ||
          family_name == font_family_names_stdstring::kserif ||
          family_name == font_family_names_stdstring::kSystemUI ||
          family_name == font_family_names_stdstring::kmath)
             ? Type::kGenericFamily
             : Type::kFamilyName;
}

}  // namespace webf