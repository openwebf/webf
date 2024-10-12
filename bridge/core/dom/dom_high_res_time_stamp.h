// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DOM_DOM_HIGH_RES_TIME_STAMP_H_
#define WEBF_CORE_DOM_DOM_HIGH_RES_TIME_STAMP_H_

namespace webf {

typedef double DOMHighResTimeStamp;

inline double ConvertDOMHighResTimeStampToSeconds(DOMHighResTimeStamp milliseconds) {
  return milliseconds / 1000;
}

// inline DOMHighResTimeStamp ConvertTimeToDOMHighResTimeStamp(base::Time time) {
//   return static_cast<DOMHighResTimeStamp>(
//       time.InMillisecondsFSinceUnixEpochIgnoringNull());
// }

}  // namespace webf

#endif  // WEBF_CORE_DOM_DOM_HIGH_RES_TIME_STAMP_H_
