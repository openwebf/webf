 // Generated from template:
 //   code_generator/src/json/templates/element_type_helper.h.tpl
 // and input files:
 //   <%= template_path %>

#ifndef BRIDGE_CORE_HTML_TYPE_HELPER_H_
#define BRIDGE_CORE_HTML_TYPE_HELPER_H_


#include "core/dom/element.h"
#include "html_names.h"

<% _.forEach(data, (item, index) => { %>
  <% if (_.isString(item)) { %>
#include "core/html/html_<%= item %>_element.h"
  <% } else if (_.isObject(item)) { %>
    <% if (item.interfaceHeaderDir) { %>
#include "<%= item.interfaceHeaderDir %>/<%= item.filename ? item.filename : 'html_' + item.name + '_element' %>.h"
    <% } else if (item.interfaceName != 'HTMLElement'){ %>
#include "core/html/<%= item.filename ? item.filename : `html_${item.name}_element` %>.h"
    <% } %>
  <% } %>
<% }); %>

namespace webf {


<% function generateTypeHelperTemplate(name, htmlName) {
  return `
class ${name};
template <>
inline bool IsElementOfType<const ${name}>(const Node& node) {
 return IsA<${name}>(node);
}
template <>
inline bool IsElementOfType<const ${name}>(const HTMLElement& element) {
 return IsA<${name}>(element);
}
template <>
struct DowncastTraits<${name}> {
 static bool AllowFrom(const Element& element) {
   return element.HasTagName(html_names::k${upperCamelCase(htmlName)});
 }
 static bool AllowFrom(const Node& node) {
   return node.IsElementNode() && IsA<${name}>(To<Element>(node));
 }
 static bool AllowFrom(const EventTarget& event_target) {
    return event_target.IsNode() && To<Node>(event_target).IsElementNode() &&
            To<Element>(event_target).HasTagName(html_names::k${upperCamelCase(htmlName)});
 }
 static bool AllowFrom(const BindingObject& binding_object) {
    return binding_object.IsEventTarget() && To<EventTarget>(binding_object).IsNode() && To<Node>(binding_object).IsElementNode() &&
   To<HTMLElement>(binding_object).HasTagName(html_names::k${upperCamelCase(htmlName)});
 }
};
`;
} %>

<% _.forEach(data, (item, index) => { %>
  <% if (_.isString(item)) { %>
    <%= generateTypeHelperTemplate(`HTML${_.upperFirst(item)}Element`, item) %>
  <% } else if (_.isObject(item)) { %>
    <%= generateTypeHelperTemplate(item.interfaceName || `HTML${_.upperFirst(item.name)}Element`, item.name) %>
  <% } %>
<% }) %>

}


#endif
