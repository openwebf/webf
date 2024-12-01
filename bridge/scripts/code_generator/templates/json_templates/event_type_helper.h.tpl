 // Generated from template:
 //   code_generator/src/json/templates/event_type_helper.h.tpl
 // and input files:
 //   <%= template_path %>

#ifndef BRIDGE_CORE_EVENT_TYPE_HELPER_H_
#define BRIDGE_CORE_EVENT_TYPE_HELPER_H_

#include "core/dom/events/event.h"
#include "event_type_names.h"

<% _.forEach(data, (item, index) => { %>
 <% if (_.isString(item)) { %>
#include "core/events/<%= item %>_event.h"
 <% } else if (_.isObject(item)) { %>
#include "core/events/<%= _.snakeCase(item.class) %>.h"
 <% } %>
<% }); %>

namespace webf {

<% function generateTypeHelperTemplate(name) {
  return `
  class ${_.upperFirst(_.camelCase(name))};
  template <>
  inline bool IsEventOfType<const ${_.upperFirst(_.camelCase(name))}>(const Event& event) {
    return IsA<${_.upperFirst(_.camelCase(name))}>(event);
  }
  template <>
  struct DowncastTraits<${_.upperFirst(_.camelCase(name))}> {
    static bool AllowFrom(const Event& event) {
      return event.Is${_.upperFirst(_.camelCase(name))}();
    }
  };
  `;
} %>

 <% _.forEach(data, (item, index) => { %>
 <% if (_.isString(item)) { %>
    <%= generateTypeHelperTemplate(item + 'Event') %>
 <% } else if (_.isObject(item)) { %>
    <%= generateTypeHelperTemplate(item.class) %>
 <% } %>
 <% }) %>


}


#endif
