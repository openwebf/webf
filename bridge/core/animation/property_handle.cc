// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/animation/property_handle.h"

#include "core/platform/text/atomic_string_hash.h"

namespace webf {

bool PropertyHandle::operator==(const PropertyHandle& other) const {
  if (handle_type_ != other.handle_type_)
    return false;

  switch (handle_type_) {
    case kHandleCSSProperty:
    case kHandlePresentationAttribute:
      return css_property_ == other.css_property_;
    case kHandleCSSCustomProperty:
      return property_name_ == other.property_name_;
    case kHandleSVGAttribute:
      return svg_attribute_ == other.svg_attribute_;
    default:
      return true;
  }
}

unsigned PropertyHandle::GetHash() const {
  switch (handle_type_) {
    case kHandleCSSProperty:
      return static_cast<int>(css_property_->PropertyID());
    case kHandleCSSCustomProperty:
      return WTF::GetHash(property_name_);
    case kHandlePresentationAttribute:
      return -static_cast<int>(css_property_->PropertyID());
    case kHandleSVGAttribute:
      return WTF::GetHash(*svg_attribute_);
    default:
      assert_m(false, "PropertyHandle::GetHash() NOTREACHED_IN_MIGRATION");
      return 0;
  }
}

}  // namespace webf