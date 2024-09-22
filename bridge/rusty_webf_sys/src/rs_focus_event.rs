/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
pub struct FocusEventRustMethods {
  pub version: c_double,
  pub related_target: extern "C" fn(ptr: *const OpaquePtr) -> RustValue<EventTargetRustMethods>,
}
pub struct FocusEvent {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const FocusEventRustMethods,
}
impl FocusEvent {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const FocusEventRustMethods) -> FocusEvent {
    FocusEvent {
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
  pub fn related_target(&self) -> EventTarget {
    let value = unsafe {
      ((*self.method_pointer).related_target)(self.ptr)
    };
    EventTarget::initialize(value.value, self.context, value.method_pointer)
  }
}