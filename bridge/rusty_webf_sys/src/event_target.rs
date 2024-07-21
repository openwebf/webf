/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void, CString};
use libc::{boolean_t, c_char};
use crate::exception_state::ExceptionState;
use crate::executing_context::{ExecutingContext};
use crate::OpaquePtr;

#[repr(C)]
struct EventCallbackContext {
  pub callback: extern "C" fn(event_callback_context: *const OpaquePtr, event: *const OpaquePtr, exception_state: *const OpaquePtr) -> *const c_void,
  pub ptr: *const EventCallbackContextData,
}

struct EventCallbackContextData {
  event_target: *const EventTarget,
  func: EventListenerCallback,
}

#[repr(C)]
pub struct AddEventListenerOptions {
  pub passive: boolean_t,
  pub once: boolean_t,
  pub capture: boolean_t,
}

pub trait RustMethods {}

#[repr(C)]
pub struct EventTargetRustMethods {
  pub version: c_double,
  pub add_event_listener: extern "C" fn(
    event_target: *const OpaquePtr,
    event_name: *const c_char,
    callback_context: *const EventCallbackContext,
    options: *const AddEventListenerOptions,
    exception_state: *const OpaquePtr) -> c_void,
  pub release: extern "C" fn(event_target: *const OpaquePtr),
}

impl RustMethods for EventTargetRustMethods {}


pub struct EventTarget {
  pub ptr: *const OpaquePtr,
  pub context: *const ExecutingContext,
  method_pointer: *const EventTargetRustMethods,
}

pub type EventListenerCallback = Box<dyn Fn(*const EventTarget)>;

// Define the callback function
extern "C" fn handle_event_listener_callback(
  event_callback_context_ptr: *const OpaquePtr,
  event: *const OpaquePtr,
  exception_state: *const OpaquePtr,
) -> *const c_void {
  // Reconstruct the Box and drop it to free the memory
  let event_callback_context = unsafe {
    Box::from_raw(event_callback_context_ptr as *mut EventCallbackContextData)
  };

  let func = event_callback_context.func;
  func(event_callback_context.event_target);

  std::ptr::null()
}

impl EventTarget {
  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn add_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    options: &AddEventListenerOptions,
    exception_state: &ExceptionState,
  ) -> Result<(), String> {
    let callback_context_data = Box::new(EventCallbackContextData {
      event_target: self as *const EventTarget,
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_context_data);
    let c_listener = EventCallbackContext { callback: handle_event_listener_callback, ptr: callback_context_data_ptr };
    let c_event_name = CString::new(event_name).unwrap();
    unsafe {
      ((*self.method_pointer).add_event_listener)(self.ptr, c_event_name.as_ptr(), &c_listener, options, exception_state.ptr)
    };
    if exception_state.has_exception() {
      // Clean up the allocated memory on exception
      unsafe {
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self.context));
    }

    Ok(())
  }
}

pub trait EventTargetMethods {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T) -> Self where Self: Sized;

  fn ptr(&self) -> *const OpaquePtr;

  // fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions);
  fn add_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    options: &AddEventListenerOptions,
    exception_state: &ExceptionState) -> Result<(), String>;
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
  /// Initialize the instance from cpp raw pointer.
  fn initialize<T>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T) -> EventTarget {
    EventTarget {
      ptr,
      context,
      method_pointer: method_pointer as *const EventTargetRustMethods,
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.add_event_listener(event_name, callback, options, exception_state)
  }
}

