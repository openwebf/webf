// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_URI_VALUE_H
#define WEBF_CSS_URI_VALUE_H

#include "core/css/css_url_data.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"

namespace webf {

class Document;
class KURL;
class SVGResource; // TODO(xiezuobing): SVGResource还未迁移

namespace cssvalue {

class CSSURIValue : public CSSValue {
 public:
  explicit CSSURIValue(CSSUrlData url_data);
  ~CSSURIValue();

  SVGResource* EnsureResourceReference() const;
  void ReResolveUrl(const Document&) const;

  const std::string& ValueForSerialization() const {
    return url_data_.ValueForSerialization();
  }

  std::string CustomCSSText() const;

  const CSSUrlData& UrlData() const { return url_data_; }
  bool IsLocal(const Document&) const;
  std::string FragmentIdentifier() const;

  // Fragment identifier with trailing spaces removed and URL
  // escape sequences decoded. This is cached, because it can take
  // a surprisingly long time to normalize the URL into an absolute
  // value if we have lots of SVG elements that need to re-run this
  // over and over again.
  const std::string& NormalizedFragmentIdentifier() const;

  bool Equals(const CSSURIValue&) const;

  std::shared_ptr<const CSSURIValue> ComputedCSSValue(const KURL& base_url) const;

  void TraceAfterDispatch(GCVisitor*) const;

 private:
  KURL AbsoluteUrl() const;

  CSSUrlData url_data_;

  mutable std::string normalized_fragment_identifier_cache_;
  mutable std::shared_ptr<const SVGResource> resource_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSURIValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsURIValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_URI_VALUE_H
