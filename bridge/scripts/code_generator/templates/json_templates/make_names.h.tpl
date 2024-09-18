// Generated from template:
//   code_generator/src/json/templates/make_names.h.tmpl
// and input files:
//   <%= template_path %>


#ifndef <%= _.snakeCase(name).toUpperCase() %>_H_
#define <%= _.snakeCase(name).toUpperCase() %>_H_

#include "bindings/qjs/atomic_string.h"

namespace webf {
namespace <%= name %> {

<% _.forEach(data, function(name, index) { %>
  <% if (_.isArray(name)) { %>
    extern thread_local const AtomicString& k<%= name[0] %>;
  <% } else if (_.isObject(name)) { %>
    extern thread_local const AtomicString& k<%= name.name %>;
  <% } else { %>
  extern thread_local const AtomicString& k<%= name %>;
  <% } %>
<% }) %>

<% if (deps && deps.html_attribute_names) { %>
  constexpr unsigned kHtmlAttributeNamesCount = <%= deps.html_attribute_names.data.length %>;
  <% _.forEach(deps.html_attribute_names.data, function(name, index) { %>
    extern thread_local const AtomicString& k<%= upperCamelCase(name) %>Attr;
  <% }) %>
<% } %>

constexpr unsigned kNamesCount = <%= data.length %>;

void Init(JSContext* ctx);
void Dispose();

}

} // webf

#endif  // #define <%= _.snakeCase(name).toUpperCase() %>
