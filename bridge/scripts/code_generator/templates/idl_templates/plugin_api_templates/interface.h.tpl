#include "script_value_ref.h"
<% if (object.parent) { %>
#include "<%= _.snakeCase(object.parent) %>.h"
<% } else { %>
#include "webf_value.h"
<% } %>

namespace webf {

<% _.forEach(dependentTypes, function (dependentType) { %>
  <% if (dependentType.endsWith('Options') || dependentType.endsWith('Init')) { %>
typedef struct WebF<%= dependentType %> WebF<%= dependentType %>;
  <% } else if (dependentType === 'JSEventListener') { %>
typedef struct WebFEventListenerContext WebFEventListenerContext;
  <% } else { %>
typedef struct <%= dependentType %> <%= dependentType %>;
typedef struct <%= dependentType %>PublicMethods <%= dependentType %>PublicMethods;
  <% } %>
<% }); %>
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct <%= className %> <%= className %>;
typedef struct ScriptValueRef ScriptValueRef;

<% _.forEach(object.props, function(prop, index) { %>
  <% var propName = _.startCase(prop.name).replace(/ /g, ''); %>
using Public<%= className %>Get<%= propName %> = <%= generatePublicReturnTypeValue(prop.type, true) %> (*)(<%= className %>*);
  <% if (!prop.readonly) { %>
using Public<%= className %>Set<%= propName %> = void (*)(<%= className %>*, <%= generatePublicReturnTypeValue(prop.type, true) %>, SharedExceptionState*);
  <% } %>
  <% if (isStringType(prop.type)) { %>
using Public<%= className %>Dup<%= propName %> = <%= generatePublicReturnTypeValue(prop.type, true) %> (*)(<%= className %>*);
  <% } %>
<% }); %>

<% _.forEach(object.methods, function(method, index) { %>
  <% var methodName = _.startCase(method.name).replace(/ /g, ''); %>
using Public<%= className %><%= methodName %> = <%= generatePublicReturnTypeValue(method.returnType, true) %> (*)(<%= className %>*, <%= generatePublicParametersType(method.args, true) %>SharedExceptionState*);
<% }); %>

<% if (!object.parent) { %>
using Public<%= className %>Release = void (*)(<%= className %>*);
<% } %>

struct <%= className %>PublicMethods : public WebFPublicMethods {

  <% _.forEach(object.props, function(prop, index) { %>
    <% var propName = _.startCase(prop.name).replace(/ /g, ''); %>
  static <%= generatePublicReturnTypeValue(prop.type, true) %> <%= propName %>(<%= className %>* <%= _.snakeCase(className) %>);
    <% if (!prop.readonly) { %>
  static void Set<%= propName %>(<%= className %>* <%= _.snakeCase(className) %>, <%= generatePublicReturnTypeValue(prop.type, true) %> <%= prop.name %>, SharedExceptionState* shared_exception_state);
    <% } %>
    <% if (isStringType(prop.type)) { %>
  static <%= generatePublicReturnTypeValue(prop.type, true) %> Dup<%= propName %>(<%= className %>* <%= _.snakeCase(className) %>);
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var methodName = _.startCase(method.name).replace(/ /g, ''); %>
  static <%= generatePublicReturnTypeValue(method.returnType, true) %> <%= methodName %>(<%= className %>* <%= _.snakeCase(className) %>, <%= generatePublicParametersTypeWithName(method.args, true) %>SharedExceptionState* shared_exception_state);
  <% }); %>

  <% if (!object.parent) { %>
  static void Release(<%= className %>* <%= _.snakeCase(className) %>);
  <% } %>
  double version{1.0};

  <% _.forEach(object.props, function(prop, index) { %>
    <% var propName = _.startCase(prop.name).replace(/ /g, ''); %>
  Public<%= className %>Get<%= propName %> <%= _.snakeCase(className) %>_get_<%= _.snakeCase(prop.name) %>{<%= propName %>};
    <% if (!prop.readonly) { %>
  Public<%= className %>Set<%= propName %> <%= _.snakeCase(className) %>_set_<%= _.snakeCase(prop.name) %>{Set<%= propName %>};
    <% } %>
    <% if (isStringType(prop.type)) { %>
  Public<%= className %>Dup<%= propName %> <%= _.snakeCase(className) %>_dup_<%= _.snakeCase(prop.name) %>{Dup<%= propName %>};
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var methodName = _.startCase(method.name).replace(/ /g, ''); %>
  Public<%= className %><%= methodName %> <%= _.snakeCase(className) %>_<%= _.snakeCase(method.name) %>{<%= methodName %>};
  <% }); %>

  <% if (!object.parent) { %>
  Public<%= className %>Release <%= _.snakeCase(className) %>_release{Release};
  <% } %>
};

}  // namespace webf
