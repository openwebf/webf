/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::c_double;
use crate::event_target::{EventTargetRustMethods, RustMethods};
use crate::executing_context::ExecutingContext;
use crate::{OpaquePtr, RustValueStatus};

#[repr(C)]
pub struct WindowRustMethods {
  pub version: c_double,
  pub event_target: EventTargetRustMethods,
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
}
