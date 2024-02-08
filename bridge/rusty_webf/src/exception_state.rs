/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/


use std::ffi::{c_char, c_double, c_void};
use std::ptr;
use libc::c_uint;
use webf_sys::OpaquePtr;
use crate::executing_context::ExecutingContext;

#[repr(C)]
pub struct ExceptionStateRustMethods {
  pub version: c_double,
  pub has_exception: extern "C" fn(*const OpaquePtr) -> bool,
  pub stringify: extern "C" fn(
    executing_context: *const OpaquePtr,
    shared_exception_state: *const OpaquePtr,
    errmsg: *mut *mut c_char,
    strlen: *mut c_uint
  ) -> c_void,
}

pub struct ExceptionState {
  pub ptr: *const OpaquePtr,
  method_pointer: *const ExceptionStateRustMethods,
}

impl ExceptionState {
  /// Initialize the element instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, method_pointer: *const ExceptionStateRustMethods) -> ExceptionState {
    ExceptionState {
      ptr,
      method_pointer
    }
  }

  /// DOM operations may be failed due to other reasons.
  /// Check the if this operation was success
  pub fn has_exception(&self) -> bool {
    return unsafe {
      ((*self.method_pointer).has_exception)(self.ptr)
    };
  }

  pub fn stringify(&self, context: *const ExecutingContext) -> String {
    let mut errmsg: *mut c_char = ptr::null_mut();
    let mut strlen: c_uint = 0;

    unsafe {
      (((*self.method_pointer)).stringify)(context.as_ref().unwrap().ptr, self.ptr, &mut errmsg, &mut strlen);

      if errmsg.is_null() {
        return String::new();
      }
      let slice = std::slice::from_raw_parts(errmsg as *const u8, strlen as usize);
      let message = String::from_utf8_lossy(slice).to_string();;

      // Free the allocated C string memory
      libc::free(errmsg as *mut c_void);
      return message;
    }
  }
}

impl Drop for ExceptionState {
  fn drop(&mut self) {
    unsafe {
      libc::free(self.ptr.cast_mut() as *mut c_void);
    }
  }
}