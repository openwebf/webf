// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_URL_FEATURES_H
#define WEBF_URL_FEATURES_H

namespace webf {

namespace url {

// If you add or remove a feature related to URLs, you may need to
// correspondingly update the EarlyAccess allow list in app shims
// (chrome/app_shim/app_shim_controller.mm). See https://crbug.com/1520386 for
// more details.

// BASE_DECLARE_FEATURE(kUseIDNA2008NonTransitional);
// extern constinit const base::Feature kUseIDNA2008NonTransitional;

// Returns true if Chrome is using IDNA 2008 in Non-Transitional mode.
 bool IsUsingIDNA2008NonTransitional() {
   // NOTE(xiezuobing): chromium default by enabled.
    return true;
};

// Returns true if Chrome is recording IDNA 2008 related metrics.
 bool IsRecordingIDNA2008Metrics() {
    // NOTE(xiezuobing): chromium default by enabled, but webf don`t needed this at the moment.
    return false;
 };

// Returns true if kStandardCompliantNonSpecialSchemeURLParsing feature is
// enabled. See url::kStandardCompliantNonSpecialSchemeURLParsing for details.
 bool IsUsingStandardCompliantNonSpecialSchemeURLParsing() {
     // NOTE(xiezuobing): chromium default by disabled.
     return false;
 };

// When enabled, Chrome uses standard-compliant URL parsing for non-special
// scheme URLs. See https://crbug.com/1416006 for details.

//BASE_DECLARE_FEATURE(kStandardCompliantNonSpecialSchemeURLParsing);
// extern constinit const base::Feature kStandardCompliantNonSpecialSchemeURLParsing;

}  // namespace url

}  // namespace webf

#endif  // WEBF_URL_FEATURES_H
