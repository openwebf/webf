/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "<%= blob.filename %>.h"
#include "foundation/native_value_converter.h"
#include "binding_call_methods.h"
#include "bindings/qjs/member_installer.h"
#include "bindings/qjs/qjs_function.h"
#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "core/executing_context.h"
#include "core/dom/element.h"
#include "core/dom/text.h"
#include "core/dom/document.h"
#include "core/dom/document_fragment.h"
#include "core/dom/comment.h"
#include "core/geometry/dom_matrix.h"
#include "core/geometry/dom_point.h"
#include "core/input/touch_list.h"
#include "core/dom/static_node_list.h"
#include "core/html/html_all_collection.h"
#include "defined_properties.h"

namespace webf {

<% if (wrapperTypeInfoInit) { %>
<%= wrapperTypeInfoInit %>
<% } %>
<%= content %>

<% if (globalFunctionInstallList.length > 0 || classPropsInstallList.length > 0 || classMethodsInstallList.length > 0 || constructorInstallList.length > 0) { %>
void QJS<%= className %>::Install(ExecutingContext* context) {
  <% if (globalFunctionInstallList.length > 0) { %> InstallGlobalFunctions(context); <% } %>
  <% if(classPropsInstallList.length > 0) { %> InstallPrototypeProperties(context); <% } %>
  <% if(classMethodsInstallList.length > 0) { %> InstallPrototypeMethods(context); <% } %>
  <% if(constructorInstallList.length > 0) { %> InstallConstructor(context); <% } %>
  <% if (staticMethodsInstallList.length > 0) { %> InstallStaticMethods(context); <% } %>
}

<% } %>

<% if(globalFunctionInstallList.length > 0) { %>
void QJS<%= className %>::InstallGlobalFunctions(ExecutingContext* context) {
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    <%= globalFunctionInstallList.join(',\n') %>
  };
  MemberInstaller::InstallFunctions(context, context->Global(), functionConfig);
}
<% } %>

<% if(classPropsInstallList.length > 0) { %>
void QJS<%= className %>::InstallPrototypeProperties(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
    <%= classPropsInstallList.join(',\n') %>
  };
  MemberInstaller::InstallFunctions(context, prototype, functionConfig);
}
<% } %>

<% if(classMethodsInstallList.length > 0) { %>
void QJS<%= className %>::InstallPrototypeMethods(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue prototype = context->contextData()->prototypeForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributesConfig {
    <%= classMethodsInstallList.join(',\n') %>
  };

  MemberInstaller::InstallAttributes(context, prototype, attributesConfig);
}
<% } %>

<% if(staticMethodsInstallList.length > 0) { %>
void QJS<%= className %>::InstallStaticMethods(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue constructor = context->contextData()->constructorForType(wrapperTypeInfo);
  std::initializer_list<MemberInstaller::FunctionConfig> functionConfig {
       <%= staticMethodsInstallList.join(',\n') %>
  };
  MemberInstaller::InstallFunctions(context, constructor, functionConfig);
}
<% } %>

<% if (constructorInstallList.length > 0) { %>
void QJS<%= className %>::InstallConstructor(ExecutingContext* context) {
  const WrapperTypeInfo* wrapperTypeInfo = GetWrapperTypeInfo();
  JSValue constructor = context->contextData()->constructorForType(wrapperTypeInfo);

  std::initializer_list<MemberInstaller::AttributeConfig> attributeConfig {
    <%= constructorInstallList.join(',\n') %>
  };
  MemberInstaller::InstallAttributes(context, context->Global(), attributeConfig);
}
<% } %>

}
