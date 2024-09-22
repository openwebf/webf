#[repr(C)]
pub struct <%= className %>RustMethods {
  pub version: c_double,
  <% _.forEach(object.props, function(prop, index) { %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
  pub <%= propName %>: extern "C" fn(ptr: *const OpaquePtr) -> <%= generatePublicReturnTypeValue(prop.type) %>,
    <% if (!prop.readonly) { %>
  pub set_<%= _.snakeCase(prop.name) %>: extern "C" fn(ptr: *const OpaquePtr, value: <%= generatePublicReturnTypeValue(prop.type) %>, exception_state: *const OpaquePtr) -> bool,
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var methodName = generateValidRustIdentifier(_.snakeCase(method.name)); %>
  pub <%= methodName %>: extern "C" fn(ptr: *const OpaquePtr, <%= generatePublicParametersType(method.args) %>exception_state: *const OpaquePtr) -> <%= generatePublicReturnTypeValue(method.returnType) %>,
  <% }); %>

  <% if (!object.parent) { %>
  pub release: extern "C" fn(ptr: *const OpaquePtr) -> c_void,
  <% } %>
}

pub struct <%= className %> {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const <%= className %>RustMethods,
}

impl <%= className %> {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const <%= className %>RustMethods) -> <%= className %> {
    <%= className %> {
      ptr,
      context,
      method_pointer,
    }
  }

  pub fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  <% _.forEach(object.props, function(prop, index) { %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
    <% if (isVoidType(prop.type)) { %>
  pub fn <%= propName %>(&self) {
    unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr);
    };
  }
    <% } else if (isStringType(prop.type)) { %>
  pub fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %> {
    let value = unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr)
    };
    let value = unsafe { std::ffi::CStr::from_ptr(value) };
    let value = value.to_str().unwrap();
    value.to_string()
  }
    <% } else if (isPointerType(prop.type)) { %>
  pub fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %> {
    let value = unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr)
    };
    <%= generateMethodReturnType(prop.type) %>::initialize(value.value, self.context, value.method_pointer)
  }
    <% } else { %>
  pub fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %> {
    let value = unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr)
    };
    value
  }
    <% } %>

    <% if (!prop.readonly) { %>
  pub fn set_<%= _.snakeCase(prop.name) %>(&self, value: <%= generateMethodReturnType(prop.type) %>, exception_state: &ExceptionState) -> Result<(), String> {
    let result = unsafe {
      ((*self.method_pointer).set_<%= _.snakeCase(prop.name) %>)(self.ptr, value, exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(())
  }
    <% } %>
  <% }); %>

  <% _.forEach(object.methods, function(method, index) { %>
    <% var methodName = generateValidRustIdentifier(_.snakeCase(method.name)); %>
    <% if (isVoidType(method.returnType)) { %>
  pub fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<(), String> {
    unsafe {
      ((*self.method_pointer).<%= methodName %>)(self.ptr, <%= generateMethodParametersName(method.args) %>exception_state.ptr);
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(())
  }
    <% } else if (isStringType(method.returnType)) { %>
  pub fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String> {
    let value = unsafe {
      ((*self.method_pointer).<%= methodName %>)(self.ptr, <%= generateMethodParametersName(method.args) %>exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    let value = unsafe { std::ffi::CStr::from_ptr(value) };
    let value = value.to_str().unwrap();
    Ok(value.to_string())
  }
    <% } else if (isPointerType(method.returnType)) { %>
  pub fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String> {
    let value = unsafe {
      ((*self.method_pointer).<%= methodName %>)(self.ptr, <%= generateMethodParametersName(method.args) %>exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(<%= generateMethodReturnType(method.returnType) %>::initialize(value.value, self.context, value.method_pointer))
  }
    <% } else { %>
  pub fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String> {
    let value = unsafe {
      ((*self.method_pointer).<%= methodName %>)(self.ptr, <%= generateMethodParametersName(method.args) %>exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    Ok(value)
  }
    <% } %>
  <% }); %>
}

<% if (!object.parent) { %>

impl Drop for <%= className %> {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr);
    }
  }
}

<% } %>
