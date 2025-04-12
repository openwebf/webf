<% if (!object.parent) { %>
#[repr(C)]
enum <%= className %>Type {
  <%= className %> = 0,
  <% _.forEach(subClasses, function (subClass, index) { %>
  <%= subClass %> = <%= index + 1 %>,
  <% }); %>
}
<% } %>

<% if (object.name === 'Window') { %>
pub type RequestAnimationFrameCallback = Box<dyn Fn(f64)>;
<% } %>

#[repr(C)]
pub struct <%= className %>RustMethods {
  pub version: c_double,
  <% if (object.parent) { %>
  pub <%= _.snakeCase(object.parent) %>: <%= object.parent %>RustMethods,
  <% } %>

  <% _.forEach(object.props, function(prop, index) { %>
    <% var id = `${object.name}.${prop.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
  pub <%= propName %>: extern "C" fn(*const OpaquePtr<%= isAnyType(prop.type) || prop.typeMode.dartImpl ? ", *const OpaquePtr": "" %>) -> <%= generatePublicReturnTypeValue(prop.type, prop.typeMode) %>,
    <% if (!prop.readonly) { %>
  pub set_<%= _.snakeCase(prop.name) %>: extern "C" fn(*const OpaquePtr, value: <%= generatePublicParameterType(prop.type) %>, *const OpaquePtr) -> bool,
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var id = `${object.name}.${method.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var methodName = generateValidRustIdentifier(_.snakeCase(method.name)); %>
    <% if (id === 'Element.toBlob') { %>
  pub to_blob: extern "C" fn(*const OpaquePtr, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_void,
  pub to_blob_with_device_pixel_ratio: extern "C" fn(*const OpaquePtr, c_double, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_void,
    <% } else if (id === 'Window.requestAnimationFrame') { %>
  pub request_animation_frame: extern "C" fn(*const OpaquePtr, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_double,
    <% } else { %>
  pub <%= methodName %>: extern "C" fn(*const OpaquePtr, <%= generatePublicParametersType(method.args, method.returnType) %>*const OpaquePtr) -> <%= generatePublicReturnTypeValue(method.returnType) %>,
    <% } %>
  <% }); %>

  <% if (!object.parent) { %>
  pub release: extern "C" fn(*const OpaquePtr) -> c_void,
  pub dynamic_to: extern "C" fn(*const OpaquePtr, type_: <%= className %>Type) -> RustValue<c_void>,
  <% } %>
}

<% if (object.parent) { %>
pub struct <%= className %> {
  pub <%= _.snakeCase(object.parent) %>: <%= object.parent %>,
  method_pointer: *const <%= className %>RustMethods,
}
<% } else { %>
pub struct <%= className %> {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const <%= className %>RustMethods,
  status: *const RustValueStatus
}
<% } %>

impl <%= className %> {
  <% if (object.parent) { %>
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const <%= className %>RustMethods, status: *const RustValueStatus) -> <%= className %> {
    unsafe {
      <%= className %> {
        <%= _.snakeCase(object.parent) %>: <%= object.parent %>::initialize(
          ptr,
          context,
          &(method_pointer).as_ref().unwrap().<%= _.snakeCase(object.parent) %>,
          status,
        ),
        method_pointer,
      }
    }
  }

  pub fn ptr(&self) -> *const OpaquePtr {
    self.<%= _.snakeCase(object.parent) %>.ptr()
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    self.<%= _.snakeCase(object.parent) %>.context()
  }

  <% } else { %>
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const <%= className %>RustMethods, status: *const RustValueStatus) -> <%= className %> {
    <%= className %> {
      ptr,
      context,
      method_pointer,
      status
    }
  }

  pub fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  <% } %>

  <% _.forEach(object.props, function(prop, index) { %>
    <% var id = `${object.name}.${prop.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
    <% if (isVoidType(prop.type)) { %>
  pub fn <%= propName %>(&self) {
    unsafe {
      ((*self.method_pointer).<%= propName %>)(self(.ptr()));
    };
  }
    <% } else if (isAnyType(prop.type) || prop.typeMode.dartImpl) { %>
  pub fn <%= propName %>(&self, exception_state: &ExceptionState) -> <%= generateMethodReturnType(prop.type) %> {
    let value = unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr(), exception_state.ptr)
    };
    <%= generatePropReturnStatements(prop.type, prop.typeMode) %>
  }
    <% } else { %>
  pub fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %> {
    let value = unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr())
    };
    <%= generatePropReturnStatements(prop.type) %>
  }
    <% } %>

    <% if (!prop.readonly) { %>
  pub fn set_<%= _.snakeCase(prop.name) %>(&self, value: <%= generateMethodParameterType(prop.type) %>, exception_state: &ExceptionState) -> Result<(), String> {
    unsafe {
      ((*self.method_pointer).set_<%= _.snakeCase(prop.name) %>)(self.ptr(), <%= generateMethodParametersName([{name: 'value', type: prop.type}]) %>exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(())
  }
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var id = `${object.name}.${method.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var methodName = generateValidRustIdentifier(_.snakeCase(method.name)); %>
    <% if (id === 'Element.toBlob') { %>
  pub fn to_blob(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    let event_target: &EventTarget = &self.node.event_target;
    let future_for_return = WebFNativeFuture::<Vec<u8>>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let result = unsafe { (*argv.wrapping_add(1)).clone() };
        let value = result.to_u8_bytes();
        future_in_callback.set_result(Ok(Some(value)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);
    unsafe {
      (((*self.method_pointer).to_blob))(event_target.ptr, callback_context_ptr, exception_state.ptr);
    }
    future_for_return
  }

  pub fn to_blob_with_device_pixel_ratio(&self, device_pixel_ratio: f64, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    let event_target: &EventTarget = &self.node.event_target;
    let future_for_return = WebFNativeFuture::<Vec<u8>>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let result = unsafe { (*argv.wrapping_add(1)).clone() };
        let value = result.to_u8_bytes();
        future_in_callback.set_result(Ok(Some(value)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);
    unsafe {
      (((*self.method_pointer).to_blob_with_device_pixel_ratio))(event_target.ptr, device_pixel_ratio, callback_context_ptr, exception_state.ptr);
    }
    future_for_return
  }
    <% } else if (id === 'Window.requestAnimationFrame') { %>
  pub fn request_animation_frame(&self, callback: RequestAnimationFrameCallback, exception_state: &ExceptionState) -> Result<f64, String> {
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc != 1 {
        println!("Invalid argument count for timeout callback");
        return NativeValue::new_null();
      }
      let time_stamp = unsafe { (*argv).clone() };
      callback(time_stamp.to_float64());
      NativeValue::new_null()
    });

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let result = unsafe {
      ((*self.method_pointer).request_animation_frame)(self.ptr(), callback_context_ptr, exception_state.ptr)
    };

    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self.event_target.context()));
    }

    Ok(result)

  }
    <% } else if (isVoidType(method.returnType)) { %>
  pub fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<(), String> {
      <% _.forEach(method.args, function(arg, index) { %>
        <% if (isPointerType(arg.type)) { %>
          <% var pointerType = getPointerType(arg.type); %>
          <% if (pointerType === 'JSEventListener') { %>
    let <%= arg.name %>_context_data = Box::new(EventCallbackContextData {
      executing_context_ptr: self.context().ptr,
      executing_context_method_pointer: self.context().method_pointer(),
      executing_context_meta_data: self.context().meta_data,
      executing_context_status: self.context().status,
      func: <%= arg.name %>,
    });
    let <%= arg.name %>_context_data_ptr = Box::into_raw(<%= arg.name %>_context_data);
    let <%= arg.name %>_context = Box::new(EventCallbackContext {
      callback: invoke_event_listener_callback,
      free_ptr: release_event_listener_callback,
      ptr: <%= arg.name %>_context_data_ptr
    });
    let <%= arg.name %>_context_ptr = Box::into_raw(<%= arg.name %>_context);
          <% } %>
        <% } %>
      <% }); %>
    unsafe {
      ((*self.method_pointer).<%= methodName %>)(self.ptr(), <%= generateMethodParametersName(method.args) %>exception_state.ptr);
    };
    if exception_state.has_exception() {
      <% _.forEach(method.args, function(arg, index) { %>
        <% if (isPointerType(arg.type)) { %>
          <% var pointerType = getPointerType(arg.type); %>
          <% if (pointerType === 'JSEventListener') { %>
      unsafe {
        let _ = Box::from_raw(<%= arg.name %>_context_ptr);
        let _ = Box::from_raw(<%= arg.name %>_context_data_ptr);
      }
          <% } %>
        <% } %>
      <% }); %>
      return Err(exception_state.stringify(self.context()));
    }
    Ok(())
  }
    <% } else { %>
  pub fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String> {
    <% _.forEach(method.args, function(arg, index) { %>
      <% if (isPointerType(arg.type)) { %>
        <% var pointerType = getPointerType(arg.type); %>
        <% if (pointerType === 'JSEventListener') { %>
    let <%= arg.name %>_context_data = Box::new(EventCallbackContextData {
      executing_context_ptr: self.context().ptr,
      executing_context_method_pointer: self.context().method_pointer(),
      executing_context_meta_data: self.context().meta_data,
      executing_context_status: self.context().status,
      func: <%= arg.name %>,
    });
    let <%= arg.name %>_context_data_ptr = Box::into_raw(<%= arg.name %>_context_data);
    let <%= arg.name %>_context = Box::new(EventCallbackContext {
      callback: invoke_event_listener_callback,
      free_ptr: release_event_listener_callback,
      ptr: <%= arg.name %>_context_data_ptr
    });
    let <%= arg.name %>_context_ptr = Box::into_raw(<%= arg.name %>_context);
        <% } %>
      <% } %>
    <% }); %>
    let value = unsafe {
      ((*self.method_pointer).<%= methodName %>)(self.ptr(), <%= generateMethodParametersName(method.args) %>exception_state.ptr)
    };
    if exception_state.has_exception() {
      <% _.forEach(method.args, function(arg, index) { %>
        <% if (isPointerType(arg.type)) { %>
          <% var pointerType = getPointerType(arg.type); %>
          <% if (pointerType === 'JSEventListener') { %>
      unsafe {
        let _ = Box::from_raw(<%= arg.name %>_context_ptr);
        let _ = Box::from_raw(<%= arg.name %>_context_data_ptr);
      }
          <% } %>
        <% } %>
      <% }); %>
      return Err(exception_state.stringify(self.context()));
    }
    <% if (isVectorType(method.returnType)) { %>
    let size = value.size as usize;
    let mut result = Vec::with_capacity(size);
    for i in 0..size {
      let value = unsafe { &*value.data.add(i) };
      let value = <%= getPointerType(method.returnType.value) %>::initialize(value.value, self.context(), value.method_pointer, value.status);
      result.push(value);
    }
    <% } %>
    <%= generateMethodReturnStatements(method.returnType) %>
  }
    <% } %>
  <% }); %>

  <% if (!object.parent) { %>

    <% _.forEach(subClasses, function (subClass, index) { %>

  pub fn as_<%= _.snakeCase(subClass) %>(&self) -> Result<<%= subClass %>, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, <%= className %>Type::<%= subClass %>)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of <%= className %> does not belong to the <%= subClass %> type.");
    }
    Ok(<%= subClass %>::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const <%= subClass %>RustMethods, raw_ptr.status))
  }
    <% }); %>
  <% } %>
}

<% if (!object.parent) { %>
impl Drop for <%= className %> {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr());
    }
  }
}
<% } %>

<% var parentMethodsSuperTrait = object.parent ? `: ${object.parent}Methods` : ''; %>
pub trait <%= className %>Methods<%= parentMethodsSuperTrait %> {
  <% _.forEach(object.props, function(prop, index) { %>
    <% var id = `${object.name}.${prop.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
    <% if (isVoidType(prop.type)) { %>
  fn <%= propName %>(&self);
    <% } else if (isAnyType(prop.type) || prop.typeMode.dartImpl) { %>
  fn <%= propName %>(&self, exception_state: &ExceptionState) -> <%= generateMethodReturnType(prop.type) %>;
    <% } else { %>
  fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %>;
    <% } %>

    <% if (!prop.readonly) { %>
  fn set_<%= _.snakeCase(prop.name) %>(&self, value: <%= generateMethodParameterType(prop.type) %>, exception_state: &ExceptionState) -> Result<(), String>;
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var id = `${object.name}.${method.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var methodName = generateValidRustIdentifier(_.snakeCase(method.name)); %>
    <% if (id === 'Element.toBlob') { %>
  fn to_blob(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>>;
  fn to_blob_with_device_pixel_ratio(&self, device_pixel_ratio: f64, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>>;
    <% } else if (id === 'Window.requestAnimationFrame') { %>
  fn request_animation_frame(&self, callback: RequestAnimationFrameCallback, exception_state: &ExceptionState) -> Result<f64, String>;
    <% } else if (isVoidType(method.returnType)) { %>
  fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<(), String>;
    <% } else { %>
  fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String>;
    <% } %>
  <% }); %>
  fn as_<%= _.snakeCase(className) %>(&self) -> &<%= className %>;
}

impl <%= className %>Methods for <%= className %> {
  <% _.forEach(object.props, function(prop, index) { %>
    <% var id = `${object.name}.${prop.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
    <% if (isVoidType(prop.type)) { %>
  fn <%= propName %>(&self) {
    self.<%= propName %>()
  }
    <% } else if (isAnyType(prop.type) || prop.typeMode.dartImpl) { %>
  fn <%= propName %>(&self, exception_state: &ExceptionState) -> <%= generateMethodReturnType(prop.type) %> {
    self.<%= propName %>(exception_state)
  }
    <% } else { %>
  fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %> {
    self.<%= propName %>()
  }
    <% } %>

    <% if (!prop.readonly) { %>
  fn set_<%= _.snakeCase(prop.name) %>(&self, value: <%= generateMethodParameterType(prop.type) %>, exception_state: &ExceptionState) -> Result<(), String> {
    self.set_<%= _.snakeCase(prop.name) %>(value, exception_state)
  }
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var id = `${object.name}.${method.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var methodName = generateValidRustIdentifier(_.snakeCase(method.name)); %>
    <% if (id === 'Element.toBlob') { %>
  fn to_blob(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    self.to_blob(exception_state)
  }
  fn to_blob_with_device_pixel_ratio(&self, device_pixel_ratio: f64, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    self.to_blob_with_device_pixel_ratio(device_pixel_ratio, exception_state)
  }
    <% } else if (id === 'Window.requestAnimationFrame') { %>
  fn request_animation_frame(&self, callback: RequestAnimationFrameCallback, exception_state: &ExceptionState) -> Result<f64, String> {
    self.request_animation_frame(callback, exception_state)
  }
    <% } else if (isVoidType(method.returnType)) { %>
  fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<(), String> {
    self.<%= methodName %>(<%= generateParentMethodParametersName(method.args) %>exception_state)
  }
    <% } else { %>
  fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String> {
    self.<%= methodName %>(<%= generateParentMethodParametersName(method.args) %>exception_state)
  }
    <% } %>
  <% }); %>
  fn as_<%= _.snakeCase(className) %>(&self) -> &<%= className %> {
    self
  }
}

<% var parentKey = ''; %>
<% _.forEach(inheritedObjects, function (parentObject) { %>
  <% parentKey = parentKey === '' ? _.snakeCase(parentObject.name) : `${parentKey}.${_.snakeCase(parentObject.name)}`; %>
impl <%= parentObject.name %>Methods for <%= className %> {
  <% _.forEach(parentObject.props, function(prop, index) { %>
    <% var id = `${parentObject.name}.${prop.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
    <% if (isVoidType(prop.type)) { %>
  fn <%= propName %>(&self) {
    self.<%= parentKey %>.<%= propName %>()
  }
    <% } else if (isAnyType(prop.type) || prop.typeMode.dartImpl) { %>
  fn <%= propName %>(&self, exception_state: &ExceptionState) -> <%= generateMethodReturnType(prop.type) %> {
    self.<%= parentKey %>.<%= propName %>(exception_state)
  }
    <% } else { %>
  fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %> {
    self.<%= parentKey %>.<%= propName %>()
  }
    <% } %>

    <% if (!prop.readonly) { %>
  fn set_<%= _.snakeCase(prop.name) %>(&self, value: <%= generateMethodParameterType(prop.type) %>, exception_state: &ExceptionState) -> Result<(), String> {
    self.<%= parentKey %>.set_<%= _.snakeCase(prop.name) %>(value, exception_state)
  }
    <% } %>
  <% }); %>

  <% _.forEach(parentObject.methods, function(method, index) { %>
    <% var id = `${parentObject.name}.${method.name}`; %>
    <% if (skipList.includes(id)) return; %>
    <% var methodName = generateValidRustIdentifier(_.snakeCase(method.name)); %>
    <% if (id === 'Element.toBlob') { %>
  fn to_blob(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    self.<%= parentKey %>.to_blob(exception_state)
  }
  fn to_blob_with_device_pixel_ratio(&self, device_pixel_ratio: f64, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    self.<%= parentKey %>.to_blob_with_device_pixel_ratio(device_pixel_ratio, exception_state)
  }
    <% } else if (id === 'Window.requestAnimationFrame') { %>
  fn request_animation_frame(&self, callback: RequestAnimationFrameCallback, exception_state: &ExceptionState) -> Result<f64, String> {
    self.<%= parentKey %>.request_animation_frame(callback, exception_state)
  }
    <% } else if (isVoidType(method.returnType)) { %>
  fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<(), String> {
    self.<%= parentKey %>.<%= methodName %>(<%= generateParentMethodParametersName(method.args) %>exception_state)
  }
    <% } else { %>
  fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String> {
    self.<%= parentKey %>.<%= methodName %>(<%= generateParentMethodParametersName(method.args) %>exception_state)
  }
    <% } %>
  <% }); %>
  fn as_<%= _.snakeCase(parentObject.name) %>(&self) -> &<%= parentObject.name %> {
    &self.<%= parentKey %>
  }
}
<% }); %>

<% if (object.construct && !isVoidType(object.construct.returnType)) { %>
impl ExecutingContext {

  <% if (object.construct.args.length === 0) { %>
  pub fn create_<%= _.snakeCase(className) %>(&self, exception_state: &ExceptionState) -> Result<<%= className %>, String> {
    let new_obj = unsafe {
      ((*self.method_pointer()).create_<%= _.snakeCase(className) %>)(self.ptr, exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }
    return Ok(<%= className %>::initialize(new_obj.value, self, new_obj.method_pointer, new_obj.status));
  }
  <% } %>

  <% if (object.construct.args.length >= 1 && object.construct.args.some(arg => arg.name === 'type')) { %>
  pub fn create_<%= _.snakeCase(className) %>(&self, event_type: &str, exception_state: &ExceptionState) -> Result<<%= className %>, String> {
    let event_type_c_string = CString::new(event_type).unwrap();
    let new_event = unsafe {
      ((*self.method_pointer()).create_<%= _.snakeCase(className) %>)(self.ptr, event_type_c_string.as_ptr(), exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }
    return Ok(<%= className %>::initialize(new_event.value, self, new_event.method_pointer, new_event.status));
  }
  <% } %>

  <% if (object.construct.args.length > 1) { %>
  pub fn create_<%= _.snakeCase(className) %>_with_options(&self, event_type: &str, options: &<%= className %>Init,  exception_state: &ExceptionState) -> Result<<%= className %>, String> {
    <% if (object.construct.args.some(arg => arg.name === 'type')) { %>
    let event_type_c_string = CString::new(event_type).unwrap();
    <% } %>
    let new_event = unsafe {
      ((*self.method_pointer()).create_<%= _.snakeCase(className) %>_with_options)(self.ptr,<% if (object.construct.args.some(arg => arg.name === 'type')) { %> event_type_c_string.as_ptr(),<% } %> options, exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }
    return Ok(<%= className %>::initialize(new_event.value, self, new_event.method_pointer, new_event.status));
  }
  <% } %>
}
<% } %>
