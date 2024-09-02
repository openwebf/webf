/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void, CString};
use libc::{boolean_t, c_char};
use crate::event::Event;
use crate::exception_state::ExceptionState;
use crate::executing_context::{ExecutingContext, ExecutingContextRustMethods};
use crate::{executing_context, OpaquePtr};

#[repr(C)]
struct EventCallbackContext {
  pub callback: extern "C" fn(event_callback_context: *const OpaquePtr, event: *const OpaquePtr, exception_state: *const OpaquePtr) -> *const c_void,
  pub free_ptr: extern "C" fn(event_callback_context_ptr: *const OpaquePtr) -> *const c_void,
  pub ptr: *const EventCallbackContextData,
}

struct EventCallbackContextData {
  event_target_ptr: *const OpaquePtr,
  event_target_method_pointer: *const EventTargetRustMethods,
  executing_context_ptr: *const OpaquePtr,
  executing_context_method_pointer: *const ExecutingContextRustMethods,
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
  pub remove_event_listener: extern "C" fn(
    event_target: *const OpaquePtr,
    event_name: *const c_char,
    callback_context: *const EventCallbackContext,
    exception_state: *const OpaquePtr) -> c_void,
  pub dispatch_event: extern "C" fn(
    event_target: *const OpaquePtr,
    event: *const OpaquePtr,
    exception_state: *const OpaquePtr) -> bool,
  pub release: extern "C" fn(event_target: *const OpaquePtr),
}

impl RustMethods for EventTargetRustMethods {}


pub struct EventTarget {
  pub ptr: *const OpaquePtr,
  context: *const ExecutingContext,
  method_pointer: *const EventTargetRustMethods,
}

pub type EventListenerCallback = Box<dyn Fn(&EventTarget)>;

// Define the callback function
extern "C" fn handle_event_listener_callback(
  event_callback_context_ptr: *const OpaquePtr,
  event: *const OpaquePtr,
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
    let executing_context = ExecutingContext::initialize(callback_data.executing_context_ptr, callback_data.executing_context_method_pointer);
    let event_target = EventTarget::initialize(callback_data.event_target_ptr, &executing_context, callback_data.event_target_method_pointer);
    func(&event_target);
  }

  std::ptr::null()
}

extern "C" fn handle_callback_data_free(event_callback_context_ptr: *const OpaquePtr) -> *const c_void {
  unsafe {
    let event_callback_context = &(*(event_callback_context_ptr as *mut EventCallbackContext));
    let _ = Box::from_raw(event_callback_context.ptr as *mut EventCallbackContextData);
  }
  std::ptr::null()
}

impl EventTarget {
  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn add_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    options: &AddEventListenerOptions,
    exception_state: &ExceptionState,
  ) -> Result<(), String> {
    let callback_context_data = Box::new(EventCallbackContextData {
      event_target_ptr: self.ptr(),
      event_target_method_pointer: self.method_pointer,
      executing_context_ptr: self.context().ptr,
      executing_context_method_pointer: self.context().method_pointer(),
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_context_data);
    let callback_context = Box::new(EventCallbackContext { callback: handle_event_listener_callback, free_ptr: handle_callback_data_free, ptr: callback_context_data_ptr});
    let callback_context_ptr = Box::into_raw(callback_context);
    let c_event_name = CString::new(event_name).unwrap();
    unsafe {
      ((*self.method_pointer).add_event_listener)(self.ptr, c_event_name.as_ptr(), callback_context_ptr, options, exception_state.ptr)
    };
    if exception_state.has_exception() {
      // Clean up the allocated memory on exception
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self.context()));
    }

    Ok(())
  }

  pub fn remove_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    exception_state: &ExceptionState,
  ) -> Result<(), String> {
    let callback_context_data = Box::new(EventCallbackContextData {
      event_target_ptr: self.ptr(),
      event_target_method_pointer: self.method_pointer,
      executing_context_ptr: self.context().ptr,
      executing_context_method_pointer: self.context().method_pointer(),
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_context_data);
    let callback_context = Box::new(EventCallbackContext { callback: handle_event_listener_callback, free_ptr: handle_callback_data_free, ptr: callback_context_data_ptr});
    let callback_context_ptr = Box::into_raw(callback_context);
    let c_event_name = CString::new(event_name).unwrap();
    unsafe {
      ((*self.method_pointer).remove_event_listener)(self.ptr, c_event_name.as_ptr(), callback_context_ptr, exception_state.ptr)
    };
    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self.context()));
    }

    Ok(())
  }

  pub fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    unsafe {
      ((*self.method_pointer).dispatch_event)(self.ptr, event.ptr, exception_state.ptr)
    }
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

  fn remove_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    exception_state: &ExceptionState) -> Result<(), String>;

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool;
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

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.dispatch_event(event, exception_state)
  }
}
