/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void};
use libc::{boolean_t, c_char};
use crate::{OpaquePtr};
use crate::executing_context::{ExecutingContext};

#[repr(C)]
pub struct EventListener {
  pub callback: extern "C" fn(event: *const OpaquePtr, exception_state: *const OpaquePtr) -> c_void,
}

#[repr(C)]
pub struct AddEventListenerOptions {
  pub passive: boolean_t,
  pub once: boolean_t,
  pub capture: boolean_t,
}

#[repr(C)]
pub struct EventTargetRustMethods {
  pub version: c_double,
  pub add_event_listener: extern "C" fn(
    event_target: *const OpaquePtr,
    event_name: *const c_char,
    listener: *mut EventListener,
    options: &mut AddEventListenerOptions,
    exception_state: *mut OpaquePtr) -> c_void,
  pub release: extern "C" fn(event_target: *const OpaquePtr),
}


pub struct EventTarget {
  pub ptr: *const OpaquePtr,
  pub context: *const ExecutingContext,
  method_pointer: *const EventTargetRustMethods,
}

type EventListenerCallback = fn(name: c_char) -> c_void;

impl EventTarget {
  /// Initialize the instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const EventTargetRustMethods) -> EventTarget {
    EventTarget {
      ptr,
      context,
      method_pointer,
    }
  }

  pub fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions) {}
}

pub trait EventTargetMethods {
  // fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions);
}

impl Drop for EventTarget {
  // When the holding on Rust side released, should notify c++ side to release the holder.
  fn drop(&mut self) {
    unsafe {
      ((*self.method_pointer).release)(self.ptr)
    };
  }
}

impl EventTargetMethods for EventTarget {
  // fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions) {
  //   self.add_event_listener(event_name, callback, options);
  // }
}

