#include "script_value_ref.h"
<% if (object.parent) { %>
#include "<%= _.snakeCase(object.parent) %>.h"
<% } else { %>
#include "webf_value.h"
<% } %>

namespace webf {

<% _.forEach(dependentTypes, function (dependentType) { %>
typedef struct <%= dependentType %> <%= dependentType %>;
typedef struct <%= dependentType %>PublicMethods <%= dependentType %>PublicMethods;
<% }); %>
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct <%= className %> <%= className %>;
typedef struct ScriptValueRef ScriptValueRef;

<% _.forEach(object.props, function(prop, index) { %>
using Public<%= className %>Get<%= _.startCase(prop.name).replace(/ /g, '') %> = <%= generatePublicReturnTypeValue(prop.type, true) %> (*)(<%= className %>*);
  <% if (!prop.readonly) { %>
using Public<%= className %>Set<%= _.startCase(prop.name).replace(/ /g, '') %> = void (*)(<%= className %>*, <%= generatePublicReturnTypeValue(prop.type, true) %>, SharedExceptionState*);
  <% } %>
  <% if (isStringType(prop.type)) { %>
using Public<%= className %>Dup<%= _.startCase(prop.name).replace(/ /g, '') %> = <%= generatePublicReturnTypeValue(prop.type, true) %> (*)(<%= className %>*);
  <% } %>
<% }); %>

<% _.forEach(object.methods, function(method, index) { %>
using Public<%= className %><%= _.startCase(method.name).replace(/ /g, '') %> = <%= generatePublicReturnTypeValue(method.returnType, true) %> (*)(<%= className %>*, <%= generatePublicParametersType(method.args, true) %>SharedExceptionState*);
<% }); %>

<% if (!object.parent) { %>
using Public<%= className %>Release = void (*)(<%= className %>*);
<% } %>

struct <%= className %>PublicMethods : public WebFPublicMethods {

  <% _.forEach(object.props, function(prop, index) { %>
  static <%= generatePublicReturnTypeValue(prop.type, true) %> <%= _.startCase(prop.name).replace(/ /g, '') %>(<%= className %>* <%= _.camelCase(className) %>);
    <% if (!prop.readonly) { %>
  static void Set<%= _.startCase(prop.name).replace(/ /g, '') %>(<%= className %>* <%= _.camelCase(className) %>, <%= generatePublicReturnTypeValue(prop.type, true) %> <%= prop.name %>, SharedExceptionState* shared_exception_state);
    <% } %>
    <% if (isStringType(prop.type)) { %>
  static <%= generatePublicReturnTypeValue(prop.type, true) %> Dup<%= _.startCase(prop.name).replace(/ /g, '') %>(<%= className %>* <%= _.camelCase(className) %>);
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
  static <%= generatePublicReturnTypeValue(method.returnType, true) %> <%= _.startCase(method.name).replace(/ /g, '') %>(<%= className %>* <%= _.camelCase(className) %>, <%= generatePublicParametersTypeWithName(method.args, true) %>SharedExceptionState* shared_exception_state);
  <% }); %>

  <% if (!object.parent) { %>
  static void Release(<%= className %>* <%= _.camelCase(className) %>);
  <% } %>
  double version{1.0};

  <% _.forEach(object.props, function(prop, index) { %>
  Public<%= className %>Get<%= _.startCase(prop.name).replace(/ /g, '') %> <%= _.snakeCase(className) %>_get_<%= _.snakeCase(prop.name) %>{<%= _.startCase(prop.name).replace(/ /g, '') %>};
    <% if (!prop.readonly) { %>
  Public<%= className %>Set<%= _.startCase(prop.name).replace(/ /g, '') %> <%= _.snakeCase(className) %>_set_<%= _.snakeCase(prop.name) %>{Set<%= _.startCase(prop.name).replace(/ /g, '') %>};
    <% } %>
    <% if (isStringType(prop.type)) { %>
  Public<%= className %>Dup<%= _.startCase(prop.name).replace(/ /g, '') %> <%= _.snakeCase(className) %>_dup_<%= _.snakeCase(prop.name) %>{Dup<%= _.startCase(prop.name).replace(/ /g, '') %>};
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
  Public<%= className %><%= _.startCase(method.name).replace(/ /g, '') %> <%= _.snakeCase(className) %>_<%= _.snakeCase(method.name) %>{<%= _.startCase(method.name).replace(/ /g, '') %>};
  <% }); %>

  <% if (!object.parent) { %>
  Public<%= className %>Release <%= _.snakeCase(className) %>_release{Release};
  <% } %>
};

}  // namespace webf
