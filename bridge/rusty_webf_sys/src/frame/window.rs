/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct WindowRustMethods {
  pub version: c_double,
  pub event_target: EventTargetRustMethods,
  pub scroll_to_with_x_and_y: extern "C" fn(*const OpaquePtr, c_double, c_double, *const OpaquePtr),
}

impl RustMethods for WindowRustMethods {}

pub struct Window {
  ptr: *const OpaquePtr,
  method_pointer: *const WindowRustMethods,
  status: *const RustValueStatus,
}


impl Window {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const WindowRustMethods, status: *const RustValueStatus) -> Window {
    Window {
      ptr,
      method_pointer,
      status,
    }
  }

  pub fn scroll_to_with_x_and_y(&self, x: f64, y: f64, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).scroll_to_with_x_and_y)(self.ptr, x, y, exception_state.ptr)
    }
  }

}
