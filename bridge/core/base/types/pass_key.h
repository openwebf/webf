// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PASS_KEY_H
#define WEBF_PASS_KEY_H

namespace webf {

template <typename T>
class PassKey {
  friend T;
  PassKey() = default;
};

}  // namespace webf

#endif  // WEBF_PASS_KEY_H
