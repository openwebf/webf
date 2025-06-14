#ifndef WEBF_CORE_CSS_CSS_VALUE_ID_MAPPINGS_GENERATED_H_
#define WEBF_CORE_CSS_CSS_VALUE_ID_MAPPINGS_GENERATED_H_

#include <cassert>
#include "css_value_keywords.h"
<%= include_files.join('\n') %>

namespace webf {

// Do not use these functions directly, use the non-generated versions
// in CSSValueMappings.h

namespace detail {

template <class T>
T cssValueIDToPlatformEnumGenerated(CSSValueID);

<% for (var enum_name in mappings) { %>
<% var mapping = mappings[enum_name]; %>
<% if (!('segment' in mapping)) { %>

template <>
inline <%= enum_name %> cssValueIDToPlatformEnumGenerated(CSSValueID v) {
  switch (v) {
  <% mapping['mapping'].forEach(function(value) { %>
    case CSSValueID::<%= value %>:
      return <%= enum_name %>::<%= value %>;
  <% }) %>
    default:
      NOTREACHED_IN_MIGRATION();
      return <%= mapping['default_value'] %>;
  }
}

inline CSSValueID platformEnumToCSSValueIDGenerated(<%= enum_name %> v) {
  switch (v) {
  <% mapping['mapping'].forEach(function(value) { %>
    case <%= enum_name %>::<%= value %>:
      return CSSValueID::<%= value %>;
  <% }) %>
    default:
      NOTREACHED_IN_MIGRATION();
      return CSSValueID::kNone;
  }
}

<% } else { %>


template <>
inline <%= enum_name %> cssValueIDToPlatformEnumGenerated(CSSValueID v) {
  <% if (mapping['mapping'].length > mapping.longest_segment_length) { %>
  switch (v) {
  <% mapping['mapping'].forEach(function(item) { %>
  <% var value = item[0], cs_num = item[1], css_num = item[2]; %>
  <% if (css_num < mapping.start_segment[2] || css_num > mapping.end_segment[2]) { %>
    case CSSValueID::<%= value %>:
      return <%= enum_name %>::<%= value %>;
  <% } %>
  <% }) %>
    default:
      DCHECK_GE(v, CSSValueID::<%= mapping.start_segment[0] %>);
      DCHECK_LE(v, CSSValueID::<%= mapping.end_segment[0] %>);
      return static_cast<<%= enum_name %>>(static_cast<int>(v) - static_cast<int>(CSSValueID::<%= mapping.start_segment[0] %>) + static_cast<int>(<%= enum_name %>::<%= mapping.start_segment[0] %>));
  }
  <% } else { %>
  DCHECK_GE(v, CSSValueID::<%= mapping.start_segment[0] %>);
  DCHECK_LE(v, CSSValueID::<%= mapping.end_segment[0] %>);
  return static_cast<<%= enum_name %>>(static_cast<int>(v) - static_cast<int>(CSSValueID::<%= mapping.start_segment[0] %>) + static_cast<int>(<%= enum_name %>::<%= mapping.start_segment[0] %>));
  <% } %>
}

inline CSSValueID platformEnumToCSSValueIDGenerated(<%= enum_name %> v) {
  <% if (mapping['mapping'].length > mapping.longest_segment_length) { %>
  switch (v) {
  <% mapping['mapping'].forEach(function(item) { %>
  <% var value = item[0], cs_num = item[1], css_num = item[2]; %>
  <% if (cs_num < mapping.start_segment[1] || cs_num > mapping.end_segment[1]) { %>
    case <%= enum_name %>::<%= value %>:
      return CSSValueID::<%= value %>;
  <% } %>
  <% }) %>
    default:
      DCHECK_GE(v, <%= enum_name %>::<%= mapping.start_segment[0] %>);
      DCHECK_LE(v, <%= enum_name %>::<%= mapping.end_segment[0] %>);
      return static_cast<CSSValueID>(static_cast<int>(v) - static_cast<int>(<%= enum_name %>::<%= mapping.start_segment[0] %>) + static_cast<int>(CSSValueID::<%= mapping.start_segment[0] %>));
  }
  <% } else { %>
  DCHECK_GE(v, <%= enum_name %>::<%= mapping.start_segment[0] %>);
  DCHECK_LE(v, <%= enum_name %>::<%= mapping.end_segment[0] %>);
  return static_cast<CSSValueID>(static_cast<int>(v) - static_cast<int>(<%= enum_name %>::<%= mapping.start_segment[0] %>) + static_cast<int>(CSSValueID::<%= mapping.start_segment[0] %>));
  <% } %>
}


<% } %>
<% } %>
}  // namespace detail

}  // namespace blink

#endif  // WEBF_CORE_CSS_CSS_VALUE_ID_MAPPINGS_GENERATED_H_
