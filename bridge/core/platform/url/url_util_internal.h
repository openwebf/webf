/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Copyright 2013 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef WEBF_URL_UTIL_INTERNAL_H
#define WEBF_URL_UTIL_INTERNAL_H

#include "url_parse.h"

namespace webf {

namespace url {

// Given a string and a range inside the string, compares it to the given
// lower-case |compare_to| buffer.
bool CompareSchemeComponent(const char* spec, const Component& component, const char* compare_to);

}  // namespace url

}  // namespace webf

#endif  // WEBF_URL_UTIL_INTERNAL_H
