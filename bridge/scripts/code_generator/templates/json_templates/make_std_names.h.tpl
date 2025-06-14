// Generated from template:
//   code_generator/src/json/templates/make_std_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_STD_H_
#define <%= _.snakeCase(name).toUpperCase() %>_STD_H_

#include <string>

namespace webf {


namespace <%= name %>_stdstring {

<% _.forEach(data, function(name, index) { %>
  <% if (_.isArray(name)) { %>
    extern const std::string& k<%= options.camelcase ? upperCamelCase(name[0]) : name[0] %>;
  <% } else if (_.isObject(name)) { %>
    extern const std::string& k<%= options.camelcase ? upperCamelCase(name.name) : name.name %>;
  <% } else { %>
     extern const std::string& k<%= options.camelcase ? upperCamelCase(name) : name %>;
  <% } %>
<% }) %>
}

} // webf

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>_STD
