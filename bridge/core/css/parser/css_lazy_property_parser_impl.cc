// Copyright 2016 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_lazy_property_parser_impl.h"
#include "core/css/parser/css_parser_impl.h"
#include "core/css/parser/css_lazy_parsing_state.h"

namespace webf {

CSSLazyPropertyParserImpl::CSSLazyPropertyParserImpl(uint32_t offset,
                                                     std::shared_ptr<CSSLazyParsingState> state)
    : CSSLazyPropertyParser(), offset_(offset), lazy_state_(state) {}

std::shared_ptr<const CSSPropertyValueSet> CSSLazyPropertyParserImpl::ParseProperties() {
  return CSSParserImpl::ParseDeclarationListForLazyStyle(
      lazy_state_->SheetText(), offset_, lazy_state_->Context());
}

}  // namespace webf
