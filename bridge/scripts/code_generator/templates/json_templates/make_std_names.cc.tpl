// Generated from template:
//   code_generator/src/json/templates/make_std_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_STD_H_
#define <%= _.snakeCase(name).toUpperCase() %>_STD_H_

#include "bindings/qjs/atomic_string.h"

namespace webf {


namespace <%= name %>_stdstring {

<% _.forEach(data, function(name, index) { %>
  <% if (_.isArray(name)) { %>
    const std::string& k<%= options.camelcase ? upperCamelCase(name[0]) : name[0] %> = "<%= name[1] %>";
  <% } else if (_.isObject(name)) { %>
    const std::string& k<%= options.camelcase ? upperCamelCase(name.name) : name.name %> = "<%= name.name %>";
  <% } else { %>
     const std::string& k<%= options.camelcase ? upperCamelCase(name) : name %> = "<%= name %>";
  <% } %>
<% }) %>
}

} // webf

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>_STD
