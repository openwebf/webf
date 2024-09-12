/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::{c_char, c_double, c_void};
use crate::{element::Element, event_target::{EventTarget, EventTargetMethods, EventTargetRustMethods}, exception_state::ExceptionState, executing_context::ExecutingContext, OpaquePtr, RustValue};

#[repr(C)]
pub struct EventRustMethods {
  pub version: c_double,
  pub bubbles: extern "C" fn(ptr: *const OpaquePtr) -> bool,
  pub cancelable: extern "C" fn(ptr: *const OpaquePtr) -> bool,
  pub current_target: extern "C" fn(ptr: *const OpaquePtr) -> RustValue<EventTargetRustMethods>,
  pub default_prevented: extern "C" fn(ptr: *const OpaquePtr) -> bool,
  pub src_element: extern "C" fn(ptr: *const OpaquePtr) -> RustValue<EventTargetRustMethods>,
  pub target: extern "C" fn(ptr: *const OpaquePtr) -> RustValue<EventTargetRustMethods>,
  pub is_trusted: extern "C" fn(ptr: *const OpaquePtr) -> bool,
  pub time_stamp: extern "C" fn(ptr: *const OpaquePtr) -> c_double,
  pub type_: extern "C" fn(ptr: *const OpaquePtr) -> *const c_char,
  pub prevent_default: extern "C" fn(ptr: *const OpaquePtr, exception_state: *const OpaquePtr) -> c_void,
  pub stop_immediate_propagation: extern "C" fn(ptr: *const OpaquePtr, exception_state: *const OpaquePtr) -> c_void,
  pub stop_propagation: extern "C" fn(ptr: *const OpaquePtr, exception_state: *const OpaquePtr) -> c_void,
  pub release: extern "C" fn(ptr: *const OpaquePtr) -> c_void,
}

pub struct Event {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const EventRustMethods,
}

impl Event {
  /// Initialize the element instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const EventRustMethods) -> Event {
    Event {
      ptr,
      context,
      method_pointer,
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn bubbles(&self) -> bool {
    let value = unsafe {
      ((*self.method_pointer).bubbles)(self.ptr)
    };
    value
  }

  pub fn cancelable(&self) -> bool {
    let value = unsafe {
      ((*self.method_pointer).cancelable)(self.ptr)
    };
    value
  }

  pub fn current_target(&self) -> EventTarget {
    let value = unsafe {
      ((*self.method_pointer).current_target)(self.ptr)
    };
    EventTarget::initialize(value.value, self.context, value.method_pointer)
  }

  pub fn default_prevented(&self) -> bool {
    let value = unsafe {
      ((*self.method_pointer).default_prevented)(self.ptr)
    };
    value
  }

  pub fn src_element(&self) -> EventTarget {
    let value = unsafe {
      ((*self.method_pointer).src_element)(self.ptr)
    };
    EventTarget::initialize(value.value, self.context, value.method_pointer)
  }

  pub fn target(&self) -> EventTarget {
    let value = unsafe {
      ((*self.method_pointer).target)(self.ptr)
    };
    EventTarget::initialize(value.value, self.context, value.method_pointer)
  }

  pub fn is_trusted(&self) -> bool {
    let value = unsafe {
      ((*self.method_pointer).is_trusted)(self.ptr)
    };
    value
  }

  pub fn time_stamp(&self) -> f64 {
    let value = unsafe {
      ((*self.method_pointer).time_stamp)(self.ptr)
    };
    value
  }

  pub fn type_(&self) -> String {
    let value = unsafe {
      ((*self.method_pointer).type_)(self.ptr)
    };
    let value = unsafe { std::ffi::CStr::from_ptr(value) };
    let value = value.to_str().unwrap();
    value.to_string()
  }

  pub fn prevent_default(&self, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).prevent_default)(self.ptr, exception_state.ptr);
    }
  }

  pub fn stop_immediate_propagation(&self, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).stop_immediate_propagation)(self.ptr, exception_state.ptr);
    }
  }

  pub fn stop_propagation(&self, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).stop_propagation)(self.ptr, exception_state.ptr);
    }
  }
}

impl Drop for Event {
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr);
    }
  }
}
