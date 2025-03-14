/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct WindowRustMethods {
  pub version: c_double,
  pub event_target: EventTargetRustMethods,
  pub scroll_to_with_x_and_y: extern "C" fn(*const OpaquePtr, c_double, c_double, *const OpaquePtr),
  pub request_animation_frame: extern "C" fn(*const OpaquePtr, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_double,
}

pub type RequestAnimationFrameCallback = Box<dyn Fn(f64)>;

impl RustMethods for WindowRustMethods {}

pub struct Window {
  pub event_target: EventTarget,
  method_pointer: *const WindowRustMethods,
}

impl Window {
  pub fn scroll_to_with_x_and_y(&self, x: f64, y: f64, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).scroll_to_with_x_and_y)(self.ptr(), x, y, exception_state.ptr)
    }
  }

  pub fn request_animation_frame(&self, callback: RequestAnimationFrameCallback, exception_state: &ExceptionState) -> Result<f64, String> {
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc != 1 {
        println!("Invalid argument count for timeout callback");
        return NativeValue::new_null();
      }
      let time_stamp = unsafe { (*argv).clone() };
      callback(time_stamp.to_float64());
      NativeValue::new_null()
    });

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let result = unsafe {
      ((*self.method_pointer).request_animation_frame)(self.ptr(), callback_context_ptr, exception_state.ptr)
    };

    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self.event_target.context()));
    }

    Ok(result)

  }
}

impl EventTargetMethods for Window {
  /// Initialize the instance from cpp raw pointer.
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      Window {
        event_target: EventTarget::initialize(
          ptr,
          context,
          &(method_pointer as *const WindowRustMethods).as_ref().unwrap().event_target,
          status,
        ),
        method_pointer: method_pointer as *const WindowRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.event_target.ptr
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.event_target.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.event_target.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self,
                    event: &Event,
                    exception_state: &ExceptionState) -> bool{
    self.event_target.dispatch_event(event, exception_state)
  }

  fn as_event_target(&self) -> &EventTarget {
    &self.event_target
  }
}
