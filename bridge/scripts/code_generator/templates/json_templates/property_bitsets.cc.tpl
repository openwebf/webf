// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/property_bitsets.h"
#include "core/css/properties/css_bitset.h"
#include <array>

namespace webf {

const CSSBitset kLogicalGroupProperties{ {
<% _.each(logical_group_properties, (property, index) => { %>
    CSSPropertyID::<%= property %>,
<% }); %>
} };

const CSSBitset kKnownExposedProperties{ {
<% _.each(known_exposed_properties, (property, index) => { %>
    CSSPropertyID::<%= property %>,
<% }); %>
} };

const CSSBitset kSurrogateProperties{ {
<% _.each(surrogate_properties, (property, index) => { %>
    CSSPropertyID::<%= property %>,
<% }); %>
} };

}  // namespace blink
