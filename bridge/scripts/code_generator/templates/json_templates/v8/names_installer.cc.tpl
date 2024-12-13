// Generated from template:
//   code_generator/src/json/templates/names_installer.cc.tmpl

//<% names.forEach(function(k) { %>
//#include "<%= k %>.h"
//<% }); %>

#include "<%= name %>.h"

namespace webf {
namespace <%= name %> {

void Init(v8::Isolate* ctx) {
//<% names.forEach(function(k) { %>
//  <%= k %>::Init(ctx);
//<% }); %>
}

void Dispose() {
//<% names.forEach(function(k) { %>
//  <%= k %>::Dispose();
//<% }); %>
}

}

} // webf