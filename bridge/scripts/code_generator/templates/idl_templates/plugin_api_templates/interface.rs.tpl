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
  status: *const RustValueStatus
}

impl <%= className %> {
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

  <% _.forEach(object.props, function(prop, index) { %>
    <% var propName = generateValidRustIdentifier(_.snakeCase(prop.name)); %>
    <% if (isVoidType(prop.type)) { %>
  pub fn <%= propName %>(&self) {
    unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr);
    };
  }
    <% } else { %>
  pub fn <%= propName %>(&self) -> <%= generateMethodReturnType(prop.type) %> {
    let value = unsafe {
      ((*self.method_pointer).<%= propName %>)(self.ptr)
    };
    <%= generatePropReturnStatements(prop.type) %>
  }
    <% } %>

    <% if (!prop.readonly) { %>
  pub fn set_<%= _.snakeCase(prop.name) %>(&self, value: <%= generateMethodReturnType(prop.type) %>, exception_state: &ExceptionState) -> Result<(), String> {
    unsafe {
      ((*self.method_pointer).set_<%= _.snakeCase(prop.name) %>)(self.ptr, <%= generateMethodParametersName([{name: 'value', type: prop.type}]) %>exception_state.ptr)
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
    <% } else { %>
  pub fn <%= methodName %>(&self, <%= generateMethodParametersTypeWithName(method.args) %>exception_state: &ExceptionState) -> Result<<%= generateMethodReturnType(method.returnType) %>, String> {
    let value = unsafe {
      ((*self.method_pointer).<%= methodName %>)(self.ptr, <%= generateMethodParametersName(method.args) %>exception_state.ptr)
    };
    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    <%= generateMethodReturnStatements(method.returnType) %>
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
