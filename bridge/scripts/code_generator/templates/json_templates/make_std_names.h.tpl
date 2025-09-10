// Generated from template:
//   code_generator/src/json/templates/make_std_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_STD_H_
#define <%= _.snakeCase(name).toUpperCase() %>_STD_H_

#include <string>
#include "foundation/string/atomic_string.h"

namespace webf {


namespace <%= name %>_atomicstring {

<% _.forEach(data, function(name, index) { %>
  <% if (_.isArray(name)) { %>
    extern thread_local const AtomicString k<%= options.camelcase ? upperCamelCase(name[0]) : name[0] %>;
  <% } else if (_.isObject(name)) { %>
    extern thread_local const AtomicString k<%= options.camelcase ? upperCamelCase(name.name) : name.name %>;
  <% } else { %>
     extern thread_local const AtomicString k<%= options.camelcase ? upperCamelCase(name) : name %>;
  <% } %>
<% }) %>
}

} // webf

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>_STD
