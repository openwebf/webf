export type <%= className %>Props = {
  <% _.forEach(properties?.props, function(prop, index) { %>
    <% var propName = _.kebabCase(prop.name); %>
    <% if (prop.optional) { %>
  '<%= propName %>'?: <%= generateReturnType(prop.type) %>;
    <% } else { %>
  '<%= propName %>': <%= generateReturnType(prop.type) %>;
    <% } %>
  <% }); %>
}

export interface <%= className %>Element {
  <% _.forEach(properties?.props, function(prop, index) { %>
    <% var propName = _.camelCase(prop.name); %>
    <% if (prop.optional) { %>
  <%= propName %>?: <%= generateReturnType(prop.type) %>;
    <% } else { %>
  <%= propName %>: <%= generateReturnType(prop.type) %>;
    <% } %>
  <% }); %>
  <% _.forEach(properties?.methods, function(method, index) { %>
  <%= generateMethodDeclaration(method) %>
  <% }); %>
}

export type <%= className %>Events = {
  <% _.forEach(events?.props, function(prop, index) { %>
    <% var propName = prop.name; %>
  <%= propName %>?: <%= generateEventHandlerType(prop.type) %>;
  <% }); %>
}
