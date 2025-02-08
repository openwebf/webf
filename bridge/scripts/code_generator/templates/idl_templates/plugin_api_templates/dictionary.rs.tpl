#[repr(C)]
pub struct <%= className %> {
<% _.forEach(parentObjects, function(parentObject, index) { %>
<% if (parentObject?.props) { %>
  <% _.forEach(parentObject.props, function(prop, index) { %>
    <% if (!object.props.map(prop => prop.name).includes(prop.name)){ %>
    <% var propName = _.snakeCase(prop.name) %>
    <% if (isStringType(prop.type)) { %>
  pub <%= propName %>: <%= generatePublicReturnTypeValue(prop.type, true) %>,
    <% } else { %>
  pub <%= propName %>: <%= generatePublicReturnTypeValue(prop.type, true) %>,
    <% } %>
    <% } %>
  <% }); %>
<% } %>
<% }); %>

<% _.forEach(object.props, function(prop, index) { %>
  <% var propName = _.snakeCase(prop.name) %>
  <% if (isStringType(prop.type)) { %>
  pub <%= propName %>: <%= generatePublicReturnTypeValue(prop.type, true) %>,
  <% } else { %>
  pub <%= propName %>: <%= generatePublicReturnTypeValue(prop.type, true) %>,
  <% } %>
<% }); %>
}
