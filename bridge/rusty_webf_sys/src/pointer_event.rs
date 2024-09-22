/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
#[repr(C)]
pub struct PointerEventRustMethods {
  pub version: c_double,
  pub height: extern "C" fn(ptr: *const OpaquePtr) -> f64,
  pub is_primary: extern "C" fn(ptr: *const OpaquePtr) -> bool,
  pub pointer_id: extern "C" fn(ptr: *const OpaquePtr) -> f64,
  pub pointer_type: extern "C" fn(ptr: *const OpaquePtr) -> *const c_char,
  pub pressure: extern "C" fn(ptr: *const OpaquePtr) -> f64,
  pub tangential_pressure: extern "C" fn(ptr: *const OpaquePtr) -> f64,
  pub tilt_x: extern "C" fn(ptr: *const OpaquePtr) -> f64,
  pub tilt_y: extern "C" fn(ptr: *const OpaquePtr) -> f64,
  pub twist: extern "C" fn(ptr: *const OpaquePtr) -> f64,
  pub width: extern "C" fn(ptr: *const OpaquePtr) -> f64,
}
pub struct PointerEvent {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const PointerEventRustMethods,
}
impl PointerEvent {
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const PointerEventRustMethods) -> PointerEvent {
    PointerEvent {
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
  pub fn height(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).height)(self.ptr)
    };
    value
  }
  pub fn is_primary(&self) -> bool {
    let value = unsafe {
      ((*self.method_pointer).is_primary)(self.ptr)
    };
    value
  }
  pub fn pointer_id(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).pointer_id)(self.ptr)
    };
    value
  }
  pub fn pointer_type(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).pointer_type)(self.ptr)
    };
    let value = unsafe { std::ffi::CStr::from_ptr(value) };
    let value = value.to_str().unwrap();
    value.to_string()
  }
  pub fn pressure(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).pressure)(self.ptr)
    };
    value
  }
  pub fn tangential_pressure(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).tangential_pressure)(self.ptr)
    };
    value
  }
  pub fn tilt_x(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).tilt_x)(self.ptr)
    };
    value
  }
  pub fn tilt_y(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).tilt_y)(self.ptr)
    };
    value
  }
  pub fn twist(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).twist)(self.ptr)
    };
    value
  }
  pub fn width(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).width)(self.ptr)
    };
    value
  }
}