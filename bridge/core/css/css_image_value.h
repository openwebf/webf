/*
* (C) 1999-2003 Lars Knoll (knoll@kde.org)
* Copyright (C) 2004, 2005, 2006, 2008, 2012 Apple Inc. All rights reserved.
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

#ifndef WEBF_CORE_CSS_CSS_IMAGE_VALUE_H_
#define WEBF_CORE_CSS_CSS_IMAGE_VALUE_H_

#include "core/css/css_value.h"
#include "core/css/css_url_data.h"

namespace webf {

class Document;
class StyleImage;
class SVGResource;

class CSSImageValue : public CSSValue {
 public:
  CSSImageValue(CSSUrlData url_data,
                StyleImage* image = nullptr);
  ~CSSImageValue();

//  bool IsCachePending() const { return !cached_image_; }
//  StyleImage* CachedImage() const {
//    DCHECK(!IsCachePending());
//    return cached_image_.Get();
//  }
//  FetchParameters PrepareFetch(const Document&,
//                               FetchParameters::ImageRequestBehavior,
//                               CrossOriginAttributeValue) const;
//  StyleImage* CacheImage(
//      const Document&,
//      FetchParameters::ImageRequestBehavior,
//      CrossOriginAttributeValue = kCrossOriginAttributeNotSet,
//      const float override_image_resolution = 0.0f);

//  const std::string& RelativeUrl() const { return url_data_.UnresolvedUrl(); }
//  bool IsLocal(const Document&) const;
//  AtomicString NormalizedFragmentIdentifier() const;
//
//  void ReResolveURL(const Document&) const;
//
  std::string CustomCSSText() const;
//
//  bool HasFailedOrCanceledSubresources() const;
//
//  bool Equals(const CSSImageValue&) const;

//  std::shared_ptr<const CSSImageValue> ComputedCSSValue() const {
//    return std::make_shared<CSSImageValue>(url_data_.MakeAbsolute(),
//                                               cached_image_.Get());
//  }
//  CSSImageValue* ComputedCSSValueMaybeLocal() const;
//
//  std::shared_ptr<const CSSImageValue> Clone() const {
//    return std::make_shared<CSSImageValue>(url_data_.MakeWithoutReferrer(),
//                                               cached_image_.Get());
//  }
//
//  void SetInitiator(const AtomicString& name) { initiator_name_ = name; }

//  void TraceAfterDispatch(GCVisitor*) const;
//  void RestoreCachedResourceIfNeeded(const Document&) const;
//  SVGResource* EnsureSVGResource() const;

 private:
//  CSSUrlData url_data_;
//  AtomicString initiator_name_;

  // Cached image data.
//  mutable std::shared_ptr<StyleImage> cached_image_;
//  mutable Member<SVGResource> svg_resource_;
};

template <>
struct DowncastTraits<CSSImageValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsImageValue(); }
};

}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_IMAGE_VALUE_H_
