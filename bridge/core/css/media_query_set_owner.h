// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_CSS_MEDIA_QUERY_SET_OWNER_H_
#define WEBF_CORE_CSS_MEDIA_QUERY_SET_OWNER_H_

namespace webf {

class MediaQuerySet;

// MediaQuerySet objects are immutable, for caching purposes. However,
// CSSOM (MediaList) offers an API to mutate the underlying media queries,
// so we fulfill that API by instead replacing the entire MediaQuerySet
// upon mutation. Since MediaList does not own the MediaQuerySet it is mutating
// (replacing), MediaList instead holds a reference to the object that does
// (a MediaQuerySetOwner). This way the MediaQuerySet can be replaced at the
// source.
class MediaQuerySetOwner {
 public:
  virtual std::shared_ptr<const MediaQuerySet> MediaQueries() const = 0;
  virtual void SetMediaQueries(std::shared_ptr<const MediaQuerySet>) = 0;
};

}  // namespace webf

#endif  // WEBF_CORE_CSS_MEDIA_QUERY_SET_OWNER_H_
