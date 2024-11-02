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
class <%= dependentType %>;
typedef struct <%= dependentType %>PublicMethods <%= dependentType %>PublicMethods;
  <% } %>
<% }); %>
class SharedExceptionState;
class ExecutingContext;
class <%= className %>;
typedef struct ScriptValueRef ScriptValueRef;

<% if (!object.parent) { %>
enum class <%= className %>Type {
  k<%= className %> = 0,
  <% _.forEach(subClasses, function (subClass, index) { %>
  k<%= subClass %> = <%= index + 1 %>,
  <% }) %>
};
<% } %>

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
using Public<%= className %>DynamicTo = WebFValue<<%= className %>, WebFPublicMethods> (*)(<%= className %>*, <%= className %>Type);
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
  static WebFValue<<%= className %>, WebFPublicMethods> DynamicTo(<%= className %>* <%= _.snakeCase(className) %>, <%= className %>Type <%= _.snakeCase(className) %>_type);
  <% } %>
  double version{1.0};

  <% if (object.parent) { %>
  <%= object.parent %>PublicMethods <%= _.snakeCase(object.parent) %>;
  <% } %>

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
  Public<%= className %>DynamicTo <%= _.snakeCase(className) %>_dynamic_to{DynamicTo};
  <% } %>
};

}  // namespace webf
