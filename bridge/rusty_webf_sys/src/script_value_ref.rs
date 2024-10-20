/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void};
use crate::*;

#[repr(C)]
pub struct ScriptValueRefRustMethods {
  pub release: extern "C" fn(script_value_ref: *const OpaquePtr) -> c_void,
}

pub struct ScriptValueRef {
  pub ptr: *const OpaquePtr,
  pub method_pointer: *const ScriptValueRefRustMethods,
}

impl Drop for ScriptValueRef {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr)
    };
  }
}