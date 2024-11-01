/*
 * Copyright (C) 2007, 2010 Apple Inc. All rights reserved.
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

#include "core/base/memory/values_equivalent.h"
#include "css_font_face_src_value.h"
#include "core/base/strings/string_util.h"
#include "core/css/css_uri_value.h"
#include "core/platform/url/kurl.h"
#include "core/css/css_markup.h"
#include "foundation/string_builder.h"

namespace webf {

bool CSSFontFaceSrcValue::IsSupportedFormat() const {
  // format() syntax is already checked at parse time, see
  // AtRuleDescriptorParser.
  if (!format_.empty()) {
    return true;
  }

  // Normally we would just check the format, but in order to avoid conflicts
  // with the old WinIE style of font-face, we will also check to see if the URL
  // ends with .eot.  If so, we'll go ahead and assume that we shouldn't load
  // it.
  const std::string& resolved_url_string = src_value_->UrlData().ResolvedUrl();
  return ProtocolIs(resolved_url_string, "data") || !base::EndsWith(resolved_url_string, ".eot");
}

std::string CSSFontFaceSrcValue::CustomCSSText() const {
  StringBuilder result;
  if (IsLocal()) {
    result.Append("local(");
    result.Append(SerializeString(LocalResource()));
    result.Append(')');
  } else {
    result.Append(src_value_->CssText());
  }

  if (!format_.empty()) {
    result.Append(" format(");
    // Format should be serialized as strings:
    // https://github.com/w3c/csswg-drafts/issues/6328#issuecomment-971823790
    result.Append(SerializeString(format_));
    result.Append(')');
  }

  return result.ReleaseString();
}

bool CSSFontFaceSrcValue::Equals(const CSSFontFaceSrcValue& other) const {
  return format_ == other.format_ && webf::ValuesEquivalent(src_value_, other.src_value_) &&
         local_resource_ == other.local_resource_;
}

void CSSFontFaceSrcValue::TraceAfterDispatch(GCVisitor* visitor) const {
  CSSValue::TraceAfterDispatch(visitor);
}

}  // namespace webf
