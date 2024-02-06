/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::c_double;
use crate::event_target::EventTargetRustMethods;
use crate::OpaquePtr;

#[repr(C)]
pub struct WindowRustMethods {
  pub version: c_double,
  pub event_target: *const EventTargetRustMethods,
}

pub struct Window {
  ptr: *const OpaquePtr,
  method_pointer: *const WindowRustMethods
}


impl Window {
  pub fn initialize(ptr: *const OpaquePtr, method_pointer: *const WindowRustMethods) -> Window {
    Window {
      ptr,
      method_pointer
    }
  }
}