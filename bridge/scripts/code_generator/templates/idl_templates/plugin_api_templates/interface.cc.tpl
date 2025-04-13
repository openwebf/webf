<% if (className.endsWith('Event')) { %>
#include "plugin_api_gen/<%= _.snakeCase(className) %>_init.h"
<% }%>
namespace webf {

<% _.forEach(object.props, function(prop, index) { %>
<% var id = `${object.name}.${prop.name}`; %>
<% if (skipList.includes(id)) return; %>
<%= generatePublicReturnTypeValue(prop.type, true, prop.typeMode) %> <%= className %>PublicMethods::<%= _.startCase(prop.name).replace(/ /g, '') %>(<%= className %>* <%= _.snakeCase(className) %><%= isAnyType(prop.type) || prop.typeMode.dartImpl ? ", SharedExceptionState* shared_exception_state": "" %>) {
  MemberMutationScope member_mutation_scope{<%= _.snakeCase(className) %>->GetExecutingContext()};
  <% if (prop.typeMode.dartImpl) { %>
  return <%= _.snakeCase(className) %>->GetBindingProperty(binding_call_methods::k<%= _.camelCase(prop.name) %>, FlushUICommandReason::kDependentsOnElement<%= prop.typeMode.layoutDependent ? ' | FlushUICommandReason::kDependentsOnLayout' : '' %>, shared_exception_state->exception_state);
  <% } else if (isPointerType(prop.type)) { %>
  auto* result = <%= _.snakeCase(className) %>-><%= prop.name %>();
  WebFValueStatus* status_block = result->KeepAlive();
  return <%= generatePublicReturnTypeValue(prop.type, true) %>(result, result-><%= _.camelCase(getPointerType(prop.type)) %>PublicMethods(), status_block);
  <% } else if (isAnyType(prop.type)) { %>
  auto value = <%= _.snakeCase(className) %>-><%= prop.name %>();
  auto native_value = value.ToNative(<%= _.snakeCase(className) %>->ctx(), shared_exception_state->exception_state, false);
  return native_value;
  <% } else if (isStringType(prop.type)) { %>
  auto value_atomic = <%= _.snakeCase(className) %>-><%= prop.name %>();
  return AtomicStringRef(value_atomic);
  <% } else if (prop.typeMode.static) { %>
  return <%= _.snakeCase(className) %>-><%= prop.name %>;
  <% } else { %>
  return <%= _.snakeCase(className) %>-><%= prop.name %>();
  <% } %>
}
  <% if (!prop.readonly) { %>
void <%= className %>PublicMethods::Set<%= _.startCase(prop.name).replace(/ /g, '') %>(<%= className %>* <%= _.snakeCase(className) %>, <%= generatePublicParameterType(prop.type, true) %> <%= prop.name %>, SharedExceptionState* shared_exception_state) {
  MemberMutationScope member_mutation_scope{<%= _.snakeCase(className) %>->GetExecutingContext()};
  <% if (prop.typeMode.dartImpl) { %>
  NativeValue <%= _.snakeCase(prop.name) %>_native = <%= generateNativeValueConverter(prop.type) %>(<%= prop.name %>);
  <%= _.snakeCase(className) %>->SetBindingProperty(binding_call_methods::k<%= _.camelCase(prop.name) %>, <%= _.snakeCase(prop.name) %>_native, shared_exception_state->exception_state);
  <% } else { %>
    <% if (isStringType(prop.type)) { %>
  webf::AtomicString <%= prop.name %>Atomic = webf::AtomicString(<%= _.snakeCase(className) %>->ctx(), <%= prop.name %>);
    <% } %>
  <%= _.snakeCase(className) %>->set<%= _.startCase(prop.name).replace(/ /g, '') %>(<%= prop.name %><% if (isStringType(prop.type)) { %>Atomic<% } %>, shared_exception_state->exception_state);
  <% } %>
}
  <% } %>
<% }); %>

<% _.forEach(methodsWithoutOverload, function(method, index) { %>
<% var id = `${object.name}.${method.name}`; %>
<% if (skipList.includes(id)) return; %>
<% if (id === 'Element.toBlob') { %>
void ElementPublicMethods::ToBlob(Element* element,
                                  WebFNativeFunctionContext* callback_context,
                                  SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  return element->toBlob(callback_impl, shared_exception_state->exception_state);
}
void ElementPublicMethods::ToBlobWithDevicePixelRatio(Element* element,
                                                      double device_pixel_ratio,
                                                      WebFNativeFunctionContext* callback_context,
                                                      SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  return element->toBlob(device_pixel_ratio, callback_impl, shared_exception_state->exception_state);
}
<% } else if (id === 'Window.requestAnimationFrame') { %>
double WindowPublicMethods::RequestAnimationFrame(Window* window,
                                                  WebFNativeFunctionContext* callback_context,
                                                  SharedExceptionState* shared_exception_state) {
  auto callback_impl = WebFNativeFunction::Create(callback_context, shared_exception_state);
  return window->requestAnimationFrame(callback_impl, shared_exception_state->exception_state);
}
<% } else { %>
<%= generatePublicReturnTypeValue(method.returnType, true) %> <%= className %>PublicMethods::<%= _.startCase(method.rustName || method.name).replace(/ /g, '') %>(<%= className %>* <%= _.snakeCase(className) %>, <%= generatePublicParametersTypeWithName(method.args, true) %>SharedExceptionState* shared_exception_state) {
  MemberMutationScope member_mutation_scope{<%= _.snakeCase(className) %>->GetExecutingContext()};
  <% if (method.returnTypeMode?.dartImpl) { %>
    <% if (method.args.length != 0) { %>
  NativeValue args[] = {
    <% _.forEach(method.args, function(arg, index) { %>
    <%= generateNativeValueConverter(arg.type) %>(<%= _.snakeCase(arg.name) %>),
    <% }) %>
  };
    <% } %>
  <%= _.snakeCase(className) %>->InvokeBindingMethod(binding_call_methods::kaddColorStop, <%= method.args.length %>, <%= method.args.length == 0 ? 'NULL' : 'args' %>, FlushUICommandReason::kDependentsOnElement<% if(method.returnTypeMode?.layoutDependent){ %> | FlushUICommandReason::kDependentsOnLayout <% } %>, shared_exception_state->exception_state);

  <% } else { %>

  <% _.forEach(method.args, function(arg, index) { %>
    <% if (isStringType(arg.type)) { %>
  webf::AtomicString <%= _.snakeCase(arg.name) %>_atomic = webf::AtomicString(<%= _.snakeCase(className) %>->ctx(), <%= _.snakeCase(arg.name) %>);
    <% } %>
    <% if (isAnyType(arg.type)) { %>
  ScriptValue <%=_.snakeCase(arg.name)%>_script_value = ScriptValue(<%= _.snakeCase(className) %>->ctx(), <%=_.snakeCase(arg.name)%>);
    <% } %>
    <% if (isPointerType(arg.type)) { %>
      <% var pointerType = getPointerType(arg.type); %>
      <% if (pointerType === 'JSEventListener') { %>
  auto <%= arg.name %>_impl = WebFPublicPluginEventListener::Create(<%= arg.name %>, shared_exception_state);
      <% } else if (pointerType.endsWith('Options') || pointerType.endsWith('Init')) { %>
  std::shared_ptr<<%= pointerType %>> <%= arg.name %>_p = <%= pointerType %>::Create();
        <% _.forEach([...(dependentClasses[getPointerType(arg.type)]?.props ?? []), ...(dependentClasses[getPointerType(arg.type)]?.inheritedProps ?? [])], function (prop) { %>
          <% if(isStringType(prop.type)) { %>
  auto <%=_.snakeCase(prop.name)%>_atomic = AtomicString(<%= _.snakeCase(className) %>->ctx(), <%= arg.name %>-><%=_.snakeCase(prop.name)%>);
  <%= arg.name %>_p->set<%=_.upperFirst(prop.name)%>(<%=_.snakeCase(prop.name)%>_atomic);
          <% } else if (isAnyType(prop.type)) { %>
  NativeValue <%=_.snakeCase(prop.name)%> = <%= arg.name %>-><%=_.snakeCase(prop.name)%>;
  ScriptValue <%=_.snakeCase(prop.name)%>_script_value = ScriptValue(<%= _.snakeCase(className) %>->ctx(), <%=_.snakeCase(prop.name)%>);
  <%= arg.name %>_p->set<%=_.upperFirst(prop.name)%>(<%=_.snakeCase(prop.name)%>_script_value);
          <% } else { %>
  <%= arg.name %>_p->set<%=_.upperFirst(prop.name)%>(<%= arg.name %>-><%=_.snakeCase(prop.name)%>);
          <% } %>
        <% }) %>
      <% } %>
    <% } %>
  <% }); %>
  <% if (isStringType(method.returnType)) { %>
  auto value_atomic = <%= _.snakeCase(className) %>-><%= method.name %>(<%= generatePublicParametersName(method.args) %>shared_exception_state->exception_state);
  return AtomicStringRef(value_atomic);
  <% } else if (isVoidType(method.returnType)) { %>
  <%= _.snakeCase(className) %>-><%= method.name %>(<%= generatePublicParametersName(method.args) %>shared_exception_state->exception_state);
  <% } else if (isAnyType(method.returnType)) { %>
  auto return_value = <%= _.snakeCase(className) %>-><%= method.name %>(<%= generatePublicParametersName(method.args) %>shared_exception_state->exception_state);
  auto return_native_value = return_value.ToNative(<%= _.snakeCase(className) %>->ctx(), shared_exception_state->exception_state, false);
  return return_native_value;
  <% } else if (isVectorType(method.returnType)) { %>
  auto vector_value = <%= _.snakeCase(className) %>-><%= method.name %>(<%= generatePublicParametersName(method.args) %>shared_exception_state->exception_state);
  auto vector_size = vector_value.size();
  WebFValue<<%= getPointerType(method.returnType.value) %>, WebFPublicMethods>* return_elements = (WebFValue<<%= getPointerType(method.returnType.value) %>, WebFPublicMethods>*)dart_malloc(sizeof(WebFValue<<%= getPointerType(method.returnType.value) %>, WebFPublicMethods>) * vector_size);
  for (int i = 0; i < vector_size; i++) {
    <%= getPointerType(method.returnType.value) %>* entry = vector_value[i];
    WebFValueStatus* status_block = entry->KeepAlive();
    return_elements[i].value = entry;
    return_elements[i].method_pointer = entry-><%= _.lowerFirst(getPointerType(method.returnType.value)) %>PublicMethods();
    return_elements[i].status = status_block;
  }
  auto result = VectorValueRef(return_elements, vector_size);
  return result;
  <% } else if (isPointerType(method.returnType)) { %>
  auto* result = <%= _.snakeCase(className) %>-><%= method.name %>(<%= generatePublicParametersName(method.args) %>shared_exception_state->exception_state);
  WebFValueStatus* status_block = result->KeepAlive();
  return <%= generatePublicReturnTypeValue(method.returnType, true) %>(result, result-><%= _.camelCase(getPointerType(method.returnType)) %>PublicMethods(), status_block);
  <% } else { %>
  return <%= _.snakeCase(className) %>-><%= method.name %>(<%= generatePublicParametersName(method.args) %>shared_exception_state->exception_state);
  <% } %>
  <% } %>
}
<% } %>
<% }); %>

<% if (!object.parent) { %>
void <%= className %>PublicMethods::Release(<%= className %>* <%= _.snakeCase(className) %>) {
  <%= _.snakeCase(className) %>->ReleaseAlive();
}

WebFValue<<%= className %>, WebFPublicMethods> <%= className %>PublicMethods::DynamicTo(webf::<%= className %>* <%= _.snakeCase(className) %>, webf::<%= className %>Type <%= _.snakeCase(className) %>_type) {
  switch (<%= _.snakeCase(className) %>_type) {
    case <%= className %>Type::k<%= className %>: {
      WebFValueStatus* status_block = <%= _.snakeCase(className) %>->KeepAlive();
      return WebFValue<<%= className %>, WebFPublicMethods>(<%= _.snakeCase(className) %>, <%= _.snakeCase(className) %>-><%= _.camelCase(className) %>PublicMethods(), status_block);
    }
  <% _.forEach(subClasses, function (subClass, index) { %>
    case <%= className %>Type::k<%= subClass %>: {
      auto* <%= _.snakeCase(subClass) %> = webf::DynamicTo<<%= subClass %>>(<%= _.snakeCase(className) %>);
      if (<%= _.snakeCase(subClass) %> == nullptr) {
        return WebFValue<<%= className %>, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = <%= _.snakeCase(subClass) %>->KeepAlive();
      return WebFValue<<%= className %>, WebFPublicMethods>(<%= _.snakeCase(subClass) %>, <%= _.snakeCase(subClass) %>-><%= _.camelCase(subClass) %>PublicMethods(), status_block);
    }
  <% }); %>
    default:
      assert_m(false, ("Unknown <%= className %>Type " + std::to_string(static_cast<int32_t>(<%= _.snakeCase(className) %>_type))).c_str());
      return WebFValue<<%= className %>, WebFPublicMethods>::Null();
  }
}
<% } %>
<% if (object.construct && !isVoidType(object.construct.returnType)) { %>
  <% if (object.construct.args.length === 0) { %>
WebFValue<<%= className %>, <%= className %>PublicMethods> ExecutingContextWebFMethods::Create<%= className %>(ExecutingContext* context, ExceptionState& exception_state) {
  MemberMutationScope member_mutation_scope{context};
  <%= className %>* obj = <%= className %>::Create(context, exception_state);
  WebFValueStatus* status_block = obj->KeepAlive();

  return WebFValue<<%= className %>, <%= className %>PublicMethods>(obj, obj-><%= _.camelCase(className) %>PublicMethods(), status_block);
};
  <% } %>

  <% if (object.construct.args.length >= 1 && object.construct.args.some(arg => arg.name === 'type')) { %>
WebFValue<<%= className %>, <%= className %>PublicMethods> ExecutingContextWebFMethods::Create<%= className %>(ExecutingContext* context, const char* type, ExceptionState& exception_state) {
  MemberMutationScope member_mutation_scope{context};
  AtomicString type_atomic = AtomicString(context->ctx(), type);
  <%= className %>* event = <%= className %>::Create(context, type_atomic, exception_state);

  WebFValueStatus* status_block = event->KeepAlive();
  return WebFValue<<%= className %>, <%= className %>PublicMethods>(event, event-><%= _.camelCase(className) %>PublicMethods(), status_block);
};
  <% } %>

  <% if (object.construct.args.length > 1) { %>
WebFValue<<%= className %>, <%= className %>PublicMethods> ExecutingContextWebFMethods::Create<%= className %>WithOptions(ExecutingContext* context, <%= generatePublicParametersTypeWithName(object.construct.args, true) %> ExceptionState& exception_state) {
  MemberMutationScope member_mutation_scope{context};
  <% if (object.construct.args.some(arg => arg.name === 'type')) { %>
  AtomicString type_atomic = AtomicString(context->ctx(), type);
  <% } %>
  std::shared_ptr<<%= className %>Init> init_class = <%= className %>Init::Create();
  <% if(dependentClasses[className + 'Init']){ %>
  <% _.forEach([...dependentClasses[className + 'Init'].props, ...dependentClasses[className + 'Init'].inheritedProps], function (prop) { %>
  <% if(isStringType(prop.type)) { %>
  AtomicString <%=_.snakeCase(prop.name)%>_atomic = AtomicString(context->ctx(), init-><%=_.snakeCase(prop.name)%>);
  init_class->set<%=_.upperFirst(prop.name)%>(<%=_.snakeCase(prop.name)%>_atomic);
  <% } else if (isPointerType(prop.type)) { %>
  init_class->set<%=_.upperFirst(prop.name)%>(init-><%=_.snakeCase(prop.name)%>.value);
  <% } else if (isAnyType(prop.type)) { %>
  NativeValue <%=_.snakeCase(prop.name)%> = init-><%=_.snakeCase(prop.name)%>;
  ScriptValue <%=_.snakeCase(prop.name)%>_script_value = ScriptValue(context->ctx(), <%=_.snakeCase(prop.name)%>);
  init_class->set<%=_.upperFirst(prop.name)%>(<%=_.snakeCase(prop.name)%>_script_value);
  <% } else { %>
  init_class->set<%=_.upperFirst(prop.name)%>(init-><%=_.snakeCase(prop.name)%>);
  <% } %>
  <% }) %>
  <% } %>

  <%= className %>* event = <%= className %>::Create(context, <% if (object.construct.args.some(arg => arg.name === 'type')) { %>type_atomic<% } %>, init_class, exception_state);

  WebFValueStatus* status_block = event->KeepAlive();
  return WebFValue<<%= className %>, <%= className %>PublicMethods>(event, event-><%= _.camelCase(className) %>PublicMethods(), status_block);
};
<% } %>
<% } %>
}  // namespace webf
