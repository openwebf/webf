// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// clang-format off

// NOTE: Since all the getters declared in this file are returning forward-declared
// types, you will need to include the right one of these (usually longhands.h)
// if you wish the compiler to see that they inherit from CSSProperty:
//
// #include "longhands.h"
// #include "shorthands.h"

#ifndef WEBF_CORE_CSS_PROPERTY_INSTANCES_H_
#define WEBF_CORE_CSS_PROPERTY_INSTANCES_H_

#include "css_property_names.h"

namespace webf {
<% _.each(properties, (property, index) => { %>
namespace <%= property.namespace %> { class <%= property.classname %>; }
<% }); %>
<% _.each(alias, (property, index) => { %>
namespace <%= property.namespace %> { class <%= property.classname %>; }
<% }); %>

// We predeclare the size of the union here, so that we can inline
// GetPropertyInternal() without #including every single CSSProperty
// out there (which would be nearly impossible wrt. circular includes).
// We static_assert that it's correct in the .cc file.
// See crbug.com/1450215.
static constexpr size_t kCSSPropertyUnionBytes = 16;

union alignas(kCSSPropertyUnionBytes) CSSPropertyUnion;

// Static instances of every single CSSProperty and CSSUnresolvedProperty,
// indexed by CSSPropertyID.
extern const CSSPropertyUnion kCssProperties[];

class CSSUnresolvedProperty;
inline const CSSUnresolvedProperty* GetPropertyInternal(CSSPropertyID id) {
  return reinterpret_cast<const CSSUnresolvedProperty *>(
      reinterpret_cast<const char *>(kCssProperties) +
          kCSSPropertyUnionBytes * static_cast<unsigned>(id));
}

<% _.each(properties, (property, index) => { %>
inline const <%= property.namespace %>::<%= property.classname %>&
Get<%= property.property_id %>() {
  return *reinterpret_cast<const <%= property.namespace %>::<%= property.classname%> *>(
      GetPropertyInternal(CSSPropertyID::<%= property.enum_key %>));
}
<% }); %>

}  // namespace webf

#endif  // WEBF_CORE_CSS_PROPERTY_INSTANCES_H_
