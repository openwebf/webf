<% if (object.construct) { %>
JSValue QJS<%= className %>::ConstructorCallback(JSContext* ctx, JSValue func_obj, JSValue this_val, int argc, JSValue* argv, int flags) {
  <%= generateFunctionBody(blob, object.construct, {isConstructor: true}) %>
}
<% } %>

<% if (object.indexedProp) { %>
  bool QJS<%= className %>::PropertyCheckerCallback(JSContext* ctx, JSValueConst obj, JSAtom key) {
    auto* self = toScriptWrappable<<%= className %>>(obj);
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    bool result = self->NamedPropertyQuery(AtomicString(ctx, key), exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return false;
    }
    return result;
  }
  int QJS<%= className %>::PropertyEnumerateCallback(JSContext* ctx, JSPropertyEnum** ptab, uint32_t* plen, JSValue obj) {
    auto* self = toScriptWrappable<<%= className %>>(obj);
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    std::vector<AtomicString> props;
    self->NamedPropertyEnumerator(props, exception_state);
    auto *tabs = new JSPropertyEnum[props.size()];
    for(int i = 0; i < props.size(); i ++) {
      tabs[i].atom = JS_DupAtom(ctx, props[i].Impl());
      tabs[i].is_enumerable = true;
    }

    *plen = props.size();
    *ptab = tabs;
    return 0;
  }

  <% if (object.indexedProp.indexKeyType == 'number') { %>
  JSValue QJS<%= className %>::IndexedPropertyGetterCallback(JSContext* ctx, JSValue obj, uint32_t index) {
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    auto* self = toScriptWrappable<<%= className %>>(obj);
    if (index >= self->length()) {
      return JS_UNDEFINED;
    }
    <%= generateCoreTypeValue(object.indexedProp.type) %> result = self->item(index, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }

    return Converter<<%= generateIDLTypeConverter(object.indexedProp.type, object.indexedProp.optional) %>>::ToValue(ctx, result);
  };
  <% } else { %>
  JSValue QJS<%= className %>::StringPropertyGetterCallback(JSContext* ctx, JSValue obj, JSAtom key) {
    auto* self = toScriptWrappable<<%= className %>>(obj);
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    ${generateCoreTypeValue(object.indexedProp.type)} result = self->item(AtomicString(ctx, key), exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return exception_state.ToQuickJS();
    }
    return Converter<<%= generateIDLTypeConverter(object.indexedProp.type, object.indexedProp.optional) %>>::ToValue(ctx, result);
  };
  <% } %>
  <% if (!object.indexedProp.readonly) { %>
    <% if (object.indexedProp.indexKeyType == 'number') { %>
  bool QJS<%= className %>::IndexedPropertySetterCallback(JSContext* ctx, JSValueConst obj, uint32_t index, JSValueConst value) {
    auto* self = toScriptWrappable<<%= className %>>(obj);
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    auto&& v = Converter<<%= generateIDLTypeConverter(object.indexedProp.type, object.indexedProp.optional) %>>::FromValue(ctx, value, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return false;
    }
    bool success = self->SetItem(index, v, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return false;
    }
    return success;
  };
    <% } else { %>
  bool QJS<%= className %>::StringPropertySetterCallback(JSContext* ctx, JSValueConst obj, JSAtom key, JSValueConst value) {
    auto* self = toScriptWrappable<<%= className %>>(obj);
    ExceptionState exception_state;
    MemberMutationScope scope{ExecutingContext::From(ctx)};
    auto&& v = Converter<<%= generateIDLTypeConverter(object.indexedProp.type, object.indexedProp.optional) %>>::FromValue(ctx, value, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return false;
    }
    bool success = self->SetItem(AtomicString(ctx, key), v, exception_state);
    if (UNLIKELY(exception_state.HasException())) {
      return false;
    }
    return success;
  };
    <% } %>
  <% } %>
 <% } %>


static thread_local AttributeMap* internal_properties = nullptr;

void QJS<%= className %>::InitAttributeMap() {
  internal_properties = new AttributeMap();

  for(int i = 0; i < <%= object.props.length %>; i ++) {
  <% object.props.forEach(prop => { %>
    internal_properties->emplace(std::make_pair(defined_properties::k<%= prop.name %>, true));
  <% }) %>
  }
}

void QJS<%= className %>::DisposeAttributeMap() {
  delete internal_properties;
}

AttributeMap* QJS<%= className %>::definedAttributeMap() {
  assert(internal_properties != nullptr);
  return internal_properties;
}

bool QJS<%= className %>::IsAttributeDefinedInternal(const AtomicString& key) {
  return definedAttributeMap()->count(key) > 0;
}

<% _.forEach(filtedMethods, function(method, index) { %>

  <% if (overloadMethods[method.name] && overloadMethods[method.name].length > 1) { %>
    <% _.forEach(overloadMethods[method.name], function(overloadMethod, index) { %>
static JSValue <%= overloadMethod.name %>_overload_<%= index %>(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
        <%= generateFunctionBody(blob, overloadMethod, {isInstanceMethod: true}) %>
      }
    <% }); %>
    static JSValue <%= method.name %>(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
      <%= generateOverLoadSwitchBody(overloadMethods[method.name]) %>
    }
  <% } else { %>

  static JSValue <%= method.name %>(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
    <%= generateFunctionBody(blob, method, {isInstanceMethod: true}) %>
  }
  <% } %>

<% }) %>

<% _.forEach(object.props, function(prop, index) { %>
static JSValue <%= prop.name %>AttributeGetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* <%= blob.filename %> = toScriptWrappable<<%= className %>>(this_val);
  assert(<%= blob.filename %> != nullptr);
  MemberMutationScope scope{ExecutingContext::From(ctx)};

  <% if (prop.typeMode && prop.typeMode.dartImpl) { %>
  ExceptionState exception_state;
  auto&& native_value = <%= blob.filename %>->GetBindingProperty(binding_call_methods::k<%= prop.name %>, exception_state);
  <% if (isTypeNeedAllocate(prop.type)) { %>
  typename <%= generateNativeValueTypeConverter(prop.type) %>::ImplType v = NativeValueConverter<<%= generateNativeValueTypeConverter(prop.type) %>>::FromNativeValue(ctx, native_value);
  <% } else { %>
  typename <%= generateNativeValueTypeConverter(prop.type) %>::ImplType v = NativeValueConverter<<%= generateNativeValueTypeConverter(prop.type) %>>::FromNativeValue(native_value);
  <% } %>
  if (UNLIKELY(exception_state.HasException())) {
    return exception_state.ToQuickJS();
  }
  return Converter<<%= generateIDLTypeConverter(prop.type, prop.optional) %>>::ToValue(ctx, v);
  <% } else if (prop.typeMode && prop.typeMode.static) { %>
  return Converter<<%= generateIDLTypeConverter(prop.type, prop.optional) %>>::ToValue(ctx, <%= className %>::<%= prop.name %>);
  <% } else { %>
  return Converter<<%= generateIDLTypeConverter(prop.type, prop.optional) %>>::ToValue(ctx, <%= blob.filename %>-><%= prop.name %>());
  <% } %>
}
<% if (!prop.readonly) { %>
static JSValue <%= prop.name %>AttributeSetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
 auto* <%= blob.filename %> = toScriptWrappable<<%= className %>>(this_val);
  ExceptionState exception_state;
  auto&& v = Converter<<%= generateIDLTypeConverter(prop.type, prop.optional) %>>::FromValue(ctx, argv[0], exception_state);
  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }
  MemberMutationScope scope{ExecutingContext::From(ctx)};

  <% if (prop.typeMode && prop.typeMode.dartImpl) { %>
  <%= blob.filename %>->SetBindingProperty(binding_call_methods::k<%= prop.name %>, NativeValueConverter<<%= generateNativeValueTypeConverter(prop.type) %>>::ToNativeValue(<% if (isDOMStringType(prop.type)) { %>ctx, <% } %>v),exception_state);
  <% } else {%>
  <%= blob.filename %>->set<%= prop.name[0].toUpperCase() + prop.name.slice(1) %>(v, exception_state);
  <% } %>
  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }

  return JS_DupValue(ctx, argv[0]);
}
<% } %>
<% }); %>


<% if (mixinObjects) { %>
<% mixinObjects.forEach(function(object) { %>

<% _.forEach(object.props, function(prop, index) { %>
static JSValue <%= prop.name %>AttributeGetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
  auto* <%= blob.filename %> = toScriptWrappable<<%= className %>>(this_val);
  assert(<%= blob.filename %> != nullptr);
  MemberMutationScope scope{ExecutingContext::From(ctx)};
  return Converter<<%= generateIDLTypeConverter(prop.type, prop.optional) %>>::ToValue(ctx, <%= object.name %>::<%= prop.name %>(*<%= blob.filename %>));
}
<% if (!prop.readonly) { %>
static JSValue <%= prop.name %>AttributeSetCallback(JSContext* ctx, JSValueConst this_val, int argc, JSValueConst* argv) {
 auto* <%= blob.filename %> = toScriptWrappable<<%= className %>>(this_val);
  ExceptionState exception_state;
  auto&& v = Converter<<%= generateIDLTypeConverter(prop.type, prop.optional) %>>::FromValue(ctx, argv[0], exception_state);
  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }
  MemberMutationScope scope{ExecutingContext::From(ctx)};

  <%= object.name %>::set<%= prop.name[0].toUpperCase() + prop.name.slice(1) %>(*<%= blob.filename %>, v, exception_state);
  if (exception_state.HasException()) {
    return exception_state.ToQuickJS();
  }

  return JS_DupValue(ctx, argv[0]);
}
<% } %>
<% }); %>


<% }); %>
<% } %>
