/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;

pub type EventListenerCallback = Box<dyn Fn(&Event)>;

pub struct EventCallbackContextData {
  pub executing_context_ptr: *const OpaquePtr,
  pub executing_context_method_pointer: *const ExecutingContextRustMethods,
  pub executing_context_status: *const RustValueStatus,
  pub func: EventListenerCallback,
}

impl Drop for EventCallbackContextData {
  fn drop(&mut self) {
    println!("Drop webf event callback context data");
  }
}

#[repr(C)]
pub struct EventCallbackContext {
  pub callback: extern "C" fn(event_callback_context: *const OpaquePtr,
                              event: *const OpaquePtr,
                              event_method_pointer: *const EventRustMethods,
                              status: *const RustValueStatus,
                              exception_state: *const OpaquePtr) -> *const c_void,
  pub free_ptr: extern "C" fn(event_callback_context_ptr: *const OpaquePtr) -> *const c_void,
  pub ptr: *const EventCallbackContextData,
}

// Define the callback function
pub extern "C" fn invoke_event_listener_callback(
  event_callback_context_ptr: *const OpaquePtr,
  event_ptr: *const OpaquePtr,
  event_method_pointer: *const EventRustMethods,
  status: *const RustValueStatus,
  exception_state: *const OpaquePtr,
) -> *const c_void {
  // Reconstruct the Box and drop it to free the memory
  let event_callback_context = unsafe {
    &(*(event_callback_context_ptr as *mut EventCallbackContext))
  };
  let callback_context_data = unsafe {
    &(*(event_callback_context.ptr as *mut EventCallbackContextData))
  };

  unsafe {
    let func = &(*callback_context_data).func;
    let callback_data = &(*callback_context_data);
    let executing_context = ExecutingContext::initialize(callback_data.executing_context_ptr, callback_data.executing_context_method_pointer, callback_data.executing_context_status);
    let event = Event::initialize(event_ptr, &executing_context, event_method_pointer, status);
    func(&event);
  }

  std::ptr::null()
}

pub extern "C" fn release_event_listener_callback(event_callback_context_ptr: *const OpaquePtr) -> *const c_void {
  unsafe {
    let event_callback_context = &(*(event_callback_context_ptr as *mut EventCallbackContext));
    let _ = Box::from_raw(event_callback_context.ptr as *mut EventCallbackContextData);
  }
  std::ptr::null()
}
