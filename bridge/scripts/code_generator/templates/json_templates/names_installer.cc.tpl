// Generated from template:
//   code_generator/src/json/templates/names_installer.cc.tmpl

<% names.forEach(function(k) { %>
#include "<%= k %>.h"
<% }); %>

namespace webf {
namespace <%= name %> {

void Init() {
<% names.forEach(function(k) { %>
  <%= k %>::Init();
<% }); %>
}

void Dispose() {
<% names.forEach(function(k) { %>
  <%= k %>::Dispose();
<% }); %>
}

}

} // webf