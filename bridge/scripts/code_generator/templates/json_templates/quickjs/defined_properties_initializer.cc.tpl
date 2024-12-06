// Generated from template:
//   code_generator/src/json/templates/defined_properties_initializer.cc.tpl
// and input files:
//   <%= template_path %>

#include "defined_properties_initializer.h"

<% data.filenames.forEach(filename => { %>
#include "<%= filename %>.h"
<% }) %>

namespace webf {

void DefinedPropertiesInitializer::Init() {
  <% data.interfaces.forEach(interfaceName => { %>
    <%= interfaceName %>::InitAttributeMap();
  <% }) %>
}

void DefinedPropertiesInitializer::Dispose() {
  <% data.interfaces.forEach(interfaceName => { %>
    <%= interfaceName %>::DisposeAttributeMap();
  <% }) %>
}


}