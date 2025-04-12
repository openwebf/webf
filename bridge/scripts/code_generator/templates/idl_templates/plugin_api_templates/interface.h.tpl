#include "rust_readable.h"
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
typedef struct NativeValue NativeValue;
typedef struct AtomicStringRef AtomicStringRef;
class <%= className %>;

<% if (!object.parent) { %>
enum class <%= className %>Type {
  k<%= className %> = 0,
  <% _.forEach(subClasses, function (subClass, index) { %>
  k<%= subClass %> = <%= index + 1 %>,
  <% }) %>
};
<% } %>

<% _.forEach(object.props, function(prop, index) { %>
  <% if (prop.async_type) { return; } %>
  <% var propName = _.startCase(prop.name).replace(/ /g, ''); %>
using Public<%= className %>Get<%= propName %> = <%= generatePublicReturnTypeValue(prop.type, true) %> (*)(<%= className %>*<%= isAnyType(prop.type)? ", SharedExceptionState* shared_exception_state": "" %>);
  <% if (!prop.readonly) { %>
using Public<%= className %>Set<%= propName %> = void (*)(<%= className %>*, <%= generatePublicParameterType(prop.type, true) %>, SharedExceptionState*);
  <% } %>
<% }); %>

<% _.forEach(object.methods, function(method, index) { %>
  <% if (method.async_type) { return; } %>
  <% var methodName = _.startCase(method.name).replace(/ /g, ''); %>
using Public<%= className %><%= methodName %> = <%= generatePublicReturnTypeValue(method.returnType, true) %> (*)(<%= className %>*, <%= generatePublicParametersType(method.args, true) %>SharedExceptionState*);
<% }); %>

<% if (!object.parent) { %>
using Public<%= className %>Release = void (*)(<%= className %>*);
using Public<%= className %>DynamicTo = WebFValue<<%= className %>, WebFPublicMethods> (*)(<%= className %>*, <%= className %>Type);
<% } %>

struct <%= className %>PublicMethods : public WebFPublicMethods {

  <% _.forEach(object.props, function(prop, index) { %>
    <% if (prop.async_type) { return; } %>
    <% var propName = _.startCase(prop.name).replace(/ /g, ''); %>
  static <%= generatePublicReturnTypeValue(prop.type, true) %> <%= propName %>(<%= className %>* <%= _.snakeCase(className) %><%= isAnyType(prop.type)? ", SharedExceptionState* shared_exception_state": "" %>);
    <% if (!prop.readonly) { %>
  static void Set<%= propName %>(<%= className %>* <%= _.snakeCase(className) %>, <%= generatePublicParameterType(prop.type, true) %> <%= prop.name %>, SharedExceptionState* shared_exception_state);
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% if (method.async_type || method.async_returnType) { return; } %>
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
    <% if (prop.async_type) { return; } %>
    <% var propName = _.startCase(prop.name).replace(/ /g, ''); %>
  Public<%= className %>Get<%= propName %> <%= _.snakeCase(className) %>_get_<%= _.snakeCase(prop.name) %>{<%= propName %>};
    <% if (!prop.readonly) { %>
  Public<%= className %>Set<%= propName %> <%= _.snakeCase(className) %>_set_<%= _.snakeCase(prop.name) %>{Set<%= propName %>};
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% if (method.async_type || method.async_returnType) { return; } %>
    <% var methodName = _.startCase(method.name).replace(/ /g, ''); %>
  Public<%= className %><%= methodName %> <%= _.snakeCase(className) %>_<%= _.snakeCase(method.name) %>{<%= methodName %>};
  <% }); %>

  <% if (!object.parent) { %>
  Public<%= className %>Release <%= _.snakeCase(className) %>_release{Release};
  Public<%= className %>DynamicTo <%= _.snakeCase(className) %>_dynamic_to{DynamicTo};
  <% } %>
};

}  // namespace webf
