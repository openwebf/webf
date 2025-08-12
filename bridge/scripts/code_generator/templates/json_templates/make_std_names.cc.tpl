// Generated from template:
//   code_generator/src/json/templates/make_std_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_STD_H_
#define <%= _.snakeCase(name).toUpperCase() %>_STD_H_

#include "foundation/string/atomic_string.h"

namespace webf {


namespace <%= name %>_atomicstring {

<% _.forEach(data, function(name, index) { %>
  <% if (_.isArray(name)) { %>
    const AtomicString k<%= options.camelcase ? upperCamelCase(name[0]) : name[0] %> = AtomicString::CreateFromUTF8("<%= name[1] %>");
  <% } else if (_.isObject(name)) { %>
    const AtomicString k<%= options.camelcase ? upperCamelCase(name.name) : name.name %> = AtomicString::CreateFromUTF8("<%= name.name %>");
  <% } else { %>
     const AtomicString k<%= options.camelcase ? upperCamelCase(name) : name %> = AtomicString::CreateFromUTF8("<%= name %>");
  <% } %>
<% }) %>
}

} // webf

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>_STD
