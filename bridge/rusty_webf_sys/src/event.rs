/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::{c_char, c_double, c_void};
use crate::OpaquePtr;

#[repr(C)]
pub struct EventRustMethods {
  pub version: c_double,
}

pub struct Event {
  pub ptr: *const OpaquePtr,
  method_pointer: *const EventRustMethods,
}

impl Event {
  /// Initialize the element instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, method_pointer: *const EventRustMethods) -> Event {
    Event {
      ptr,
      method_pointer
    }
  }
}
