/*
* (C) 1999-2003 Lars Knoll (knoll@kde.org)
* Copyright (C) 2004, 2005, 2006, 2008 Apple Inc. All rights reserved.
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


#include "css_url_data.h"

#include "core/css/css_markup.h"
#include "core/dom/document.h"
#include "core/platform/url/kurl.h"

namespace webf {

CSSUrlData::CSSUrlData(std::string unresolved_url,
                       const KURL& resolved_url
                       )
    : relative_url_(std::move(unresolved_url)),
      absolute_url_(resolved_url.GetString()),
      is_local_(!unresolved_url.empty() && unresolved_url[0] == '#'),
      potentially_dangling_markup_(resolved_url.PotentiallyDanglingMarkup()) {}

CSSUrlData::CSSUrlData(const std::string& resolved_url)
    : CSSUrlData(resolved_url,
                 KURL(resolved_url)
                 ) {}

KURL CSSUrlData::ResolveUrl(const Document& document) const {
  if (!potentially_dangling_markup_) {
    return KURL(absolute_url_);
  }
  // The PotentiallyDanglingMarkup() flag is lost when storing the absolute
  // url as a string from which the KURL is constructed here. The url passed
  // into the constructor had the PotentiallyDanglingMarkup flag set. That
  // information needs to be passed on to the fetch code to block such
  // resources from loading.
  //
  // Note: the PotentiallyDanglingMarkup() state on the base url may have
  // changed if the base url for the document changed since last time the url
  // was resolved. This change in base url resolving is different from the
  // typical behavior for base url changes. CSS urls are typically not re-
  // resolved. This is mentioned in the "What “browser eccentricities”?" note
  // in https://www.w3.org/TR/css-values-3/#local-urls
  //
  // Having the more spec-compliant behavior for the dangling markup edge case
  // should be fine.
  return document.CompleteURL(relative_url_);
}

bool CSSUrlData::ReResolveUrl(const Document& document) const {
  if (relative_url_.empty()) {
    return false;
  }
  KURL url = document.CompleteURL(relative_url_);
  std::string url_string(url.GetString());
  if (url_string == absolute_url_) {
    return false;
  }
  absolute_url_ = url_string;
  return true;
}

CSSUrlData CSSUrlData::MakeAbsolute() const {
  if (relative_url_.empty()) {
    return *this;
  }
  return CSSUrlData(absolute_url_, KURL(absolute_url_)
//                    Referrer(), GetOriginClean(), is_ad_related_
                    );
}

CSSUrlData CSSUrlData::MakeResolved(const KURL& base_url) const {
  if (relative_url_.empty()) {
    return *this;
  }
  const KURL resolved_url = KURL(base_url, relative_url_);
  if (is_local_) {
    return CSSUrlData(relative_url_, resolved_url
//                      Referrer(), GetOriginClean(), is_ad_related_
                      );
  }
  return CSSUrlData(std::string(resolved_url.GetString()), resolved_url
//                    Referrer(), GetOriginClean(),  is_ad_related_
                    );
}

CSSUrlData CSSUrlData::MakeWithoutReferrer() const {
  return CSSUrlData(relative_url_, KURL(absolute_url_)
//                    Referrer(), GetOriginClean(), is_ad_related_
                    );
}

bool CSSUrlData::IsLocal(const Document& document) const {
  return is_local_ ||
         EqualIgnoringFragmentIdentifier(KURL(absolute_url_), document.Url());
}

std::string CSSUrlData::CssText() const {
  return SerializeURI(relative_url_);
}

bool CSSUrlData::operator==(const CSSUrlData& other) const {
  // If only one has the 'local url' flag set, the URLs can't match.
  if (is_local_ != other.is_local_) {
    return false;
  }
  if (is_local_) {
    return relative_url_ == other.relative_url_;
  }
  if (absolute_url_.empty() && other.absolute_url_.empty()) {
    return relative_url_ == other.relative_url_;
  }
  return absolute_url_ == other.absolute_url_;
}

};  // namespace webf