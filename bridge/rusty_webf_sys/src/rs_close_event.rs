/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
pub struct CloseEventRustMethods {
  pub version: c_double,
  pub code: extern "C" fn(ptr: *const OpaquePtr) -> i64,
  pub reason: extern "C" fn(ptr: *const OpaquePtr) -> *const c_char,
  pub was_clean: extern "C" fn(ptr: *const OpaquePtr) -> bool,
}
pub struct CloseEvent {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const CloseEventRustMethods,
}
impl CloseEvent {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const CloseEventRustMethods) -> CloseEvent {
    CloseEvent {
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
  pub fn code(&self) -> i64 {
    let value = unsafe {
      ((*self.method_pointer).code)(self.ptr)
    };
    value
  }
  pub fn reason(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).reason)(self.ptr)
    };
    let value = unsafe { std::ffi::CStr::from_ptr(value) };
    let value = value.to_str().unwrap();
    value.to_string()
  }
  pub fn was_clean(&self) -> bool {
    let value = unsafe {
      ((*self.method_pointer).was_clean)(self.ptr)
    };
    value
  }
}