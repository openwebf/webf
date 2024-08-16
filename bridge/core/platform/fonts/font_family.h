/*
* Copyright (C) 2004, 2008 Apple Inc. All rights reserved.
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

#ifndef WEBF_FONT_FAMILY_H
#define WEBF_FONT_FAMILY_H

#include <cstdint>
#include <iostream>
#include "foundation/macros.h"
#include "bindings/qjs/atomic_string.h"

namespace webf {

class SharedFontFamily;

class FontFamily {
  WEBF_DISALLOW_NEW();

 public:
  // https://drafts.csswg.org/css-fonts/#font-family-prop
  enum class Type : uint8_t { kFamilyName, kGenericFamily };

  FontFamily(const std::string& family_name,
             Type family_type,
             std::shared_ptr<SharedFontFamily> next = nullptr)
      : family_name_(family_name),
        next_(std::move(next)),
        family_type_(family_type) {}
  FontFamily() = default;
  ~FontFamily();

  // Return this font family's name. Note that it is never quoted nor escaped.
  // For web-exposed serialization, please rely instead on the functions
  // ComputedStyleUtils::ValueForFontFamily(const FontFamily&) and
  // CSSValue::CssText() in order to match formatting rules from the CSSOM
  // specification.
  const std::string& FamilyName() const { return family_name_; }
  bool FamilyIsGeneric() const { return family_type_ == Type::kGenericFamily; }

  const FontFamily* Next() const;

  std::shared_ptr<SharedFontFamily> ReleaseNext();

  bool IsPrewarmed() const { return is_prewarmed_; }
  void SetIsPrewarmed() const { is_prewarmed_ = true; }

  // Returns this font family's name followed by all subsequent linked
  // families separated ", " (comma and space). Font family names are never
  // quoted nor escaped. For web-exposed serialization, please rely instead on
  // the functions ComputedStyleUtils::ValueForFontFamily(const FontFamily&) and
  // CSSValue::CssText() in order to match formatting rules from the CSSOM
  // specification.
  std::string ToString() const;

  // Return kGenericFamily if family_name is equal to one of the supported
  // <generic-family> keyword from the CSS fonts module spec and kFamilyName
  // otherwise.
  static Type InferredTypeFor(const AtomicString& family_name);

 private:
  std::string family_name_;
  std::shared_ptr<SharedFontFamily> next_;
  Type family_type_ = Type::kFamilyName;
  mutable bool is_prewarmed_ = false;
};

class SharedFontFamily : public FontFamily {
  USING_FAST_MALLOC(SharedFontFamily);
 public:
  SharedFontFamily(const SharedFontFamily&) = delete;
  SharedFontFamily& operator=(const SharedFontFamily&) = delete;

  static std::shared_ptr<SharedFontFamily> Create(
      const std::string& family_name,
      Type family_type,
      std::shared_ptr<SharedFontFamily> next = nullptr) {
    return std::make_shared<SharedFontFamily>(family_name, family_type, std::move(next));
  }

  SharedFontFamily(const std::string& family_name,
                   Type family_type,
                   std::shared_ptr<SharedFontFamily> next)
      : FontFamily(family_name, family_type, std::move(next)) {}


};

bool operator==(const FontFamily&, const FontFamily&);
inline bool operator!=(const FontFamily& a, const FontFamily& b) {
  return !(a == b);
}

inline FontFamily::~FontFamily() {
//  std::shared_ptr<SharedFontFamily> reaper = std::move(next_);
//  while (reaper && reaper->HasOneRef()) {
//    // implicitly protects reaper->next, then derefs reaper
//    reaper = reaper->ReleaseNext();
//  }
}

inline const FontFamily* FontFamily::Next() const {
  return next_.get();
}

inline std::shared_ptr<SharedFontFamily> FontFamily::ReleaseNext() {
  return std::move(next_);
}


}  // namespace webf

#endif  // WEBF_FONT_FAMILY_H
