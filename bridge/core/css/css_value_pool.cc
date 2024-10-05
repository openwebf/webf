/*
 * Copyright (C) 2011, 2012 Apple Inc. All rights reserved.
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
 * THIS SOFTWARE IS PROVIDED BY APPLE INC. AND ITS CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL APPLE INC. OR ITS CONTRIBUTORS
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_value_pool.h"

namespace webf {

CSSValuePool::CSSValuePool()
    : inherited_value_(std::make_shared<CSSInheritedValue>()),
      initial_value_(std::make_shared<CSSInitialValue>()),
      unset_value_(std::make_shared<CSSUnsetValue>(PassKey())),
      revert_value_(std::make_shared<CSSRevertValue>(PassKey())),
      revert_layer_value_(std::make_shared<CSSRevertLayerValue>(PassKey())),
      invalid_variable_value_(std::make_shared<CSSInvalidVariableValue>()),
      initial_color_value_(std::make_shared<CSSInitialColorValue>(PassKey())),
      color_transparent_(std::make_shared<cssvalue::CSSColor>(Color::kTransparent)),
      color_white_(std::make_shared<cssvalue::CSSColor>(Color::kWhite)),
      color_black_(std::make_shared<cssvalue::CSSColor>(Color::kBlack)) {
  identifier_value_cache_.resize(kMaximumCacheableIntegerValue);
  pixel_value_cache_.resize(kMaximumCacheableIntegerValue);
  percent_value_cache_.resize(kMaximumCacheableIntegerValue);
  number_value_cache_.resize(kMaximumCacheableIntegerValue);
}

CSSValuePool& CssValuePool() {
  thread_local static CSSValuePool pool;
  return pool;
}

}  // namespace webf
