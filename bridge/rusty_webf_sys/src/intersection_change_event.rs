/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
pub struct IntersectionChangeEventRustMethods {
  pub version: c_double,
  pub intersection_ratio: extern "C" fn(ptr: *const OpaquePtr) -> f64,
}
pub struct IntersectionChangeEvent {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const IntersectionChangeEventRustMethods,
}
impl IntersectionChangeEvent {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const IntersectionChangeEventRustMethods) -> IntersectionChangeEvent {
    IntersectionChangeEvent {
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
  pub fn intersection_ratio(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).intersection_ratio)(self.ptr)
    };
    value
  }
}