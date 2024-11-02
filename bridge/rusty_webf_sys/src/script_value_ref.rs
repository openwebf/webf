/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct ScriptValueRefRustMethods {
  pub to_string: extern "C" fn(script_value_ref: *const OpaquePtr, exception_state: *const OpaquePtr) -> *const c_char,
  pub set_as_string: extern "C" fn(script_value_ref: *const OpaquePtr, value: *const c_char, exception_state: *const OpaquePtr),
  pub release: extern "C" fn(script_value_ref: *const OpaquePtr) -> c_void,
}

pub struct ScriptValueRef {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  pub method_pointer: *const ScriptValueRefRustMethods,
}

impl ScriptValueRef {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const ScriptValueRefRustMethods) -> ScriptValueRef {
    ScriptValueRef {
      ptr,
      context,
      method_pointer
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn to_string(&self, exception_state: &ExceptionState) -> Result<String, String> {
    unsafe {
      let c_string = ((*self.method_pointer).to_string)(self.ptr, exception_state.ptr);

      if exception_state.has_exception() {
        return Err(exception_state.stringify(self.context()));
      }

      let c_str = CStr::from_ptr(c_string);
      let str_slice = c_str.to_str().unwrap();
      Ok(str_slice.to_string())
    }
  }

  pub fn set_as_string(&self, value: &str, exception_state: &ExceptionState) -> Result<(), String> {
    unsafe {
      let c_string = CString::new(value).unwrap();
      ((*self.method_pointer).set_as_string)(self.ptr, c_string.as_ptr(), exception_state.ptr);

      if exception_state.has_exception() {
        return Err(exception_state.stringify(self.context()));
      }

      Ok(())
    }
  }
}

impl Drop for ScriptValueRef {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr)
    };
  }
}
