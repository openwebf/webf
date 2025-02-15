/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct CSSStyleDeclarationRustMethods {
  pub version: c_double,
  pub set_property: extern "C" fn(*const OpaquePtr, *const c_char, NativeValue, *const OpaquePtr) -> c_void,
}

impl RustMethods for CSSStyleDeclarationRustMethods {}

pub struct CSSStyleDeclaration {
  pub ptr: *const OpaquePtr,
  status: *const RustValueStatus,
  context: *const ExecutingContext,
  method_pointer: *const CSSStyleDeclarationRustMethods,
}

impl CSSStyleDeclaration {
  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const CSSStyleDeclarationRustMethods, status: *const RustValueStatus) -> CSSStyleDeclaration {
    CSSStyleDeclaration {
      ptr,
      status,
      context,
      method_pointer,
    }
  }

  pub fn set_property(&self, property: &str, value: NativeValue, exception_state: &ExceptionState) -> Result<(), String> {
    let c_property = CString::new(property).unwrap();
    unsafe {
      ((*self.method_pointer).set_property)(self.ptr(), c_property.as_ptr(), value, exception_state.ptr);
    }

    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }

    Ok(())
  }
}
