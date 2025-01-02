/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct ElementRustMethods {
  pub version: c_double,
  pub container_node: ContainerNodeRustMethods,
  pub to_blob: extern "C" fn(*const OpaquePtr, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_void,
  pub to_blob_with_device_pixel_ratio: extern "C" fn(*const OpaquePtr, c_double, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_void,
}

impl RustMethods for ElementRustMethods {}

pub struct Element {
  container_node: ContainerNode,
  method_pointer: *const ElementRustMethods,
}

impl Element {
  pub fn to_blob(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    let event_target: &EventTarget = &self.container_node.node.event_target;

    let future_for_return = WebFNativeFuture::<Vec<u8>>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let result = unsafe { (*argv.wrapping_add(1)).clone() };
        let value = result.to_u8_bytes();
        future_in_callback.set_result(Ok(Some(value)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
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
    unsafe {
      (((*self.method_pointer).to_blob))(event_target.ptr, callback_context_ptr, exception_state.ptr);
    }
    future_for_return
  }

  pub fn to_blob_with_device_pixel_ratio(&self, device_pixel_ratio: f64, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    let event_target: &EventTarget = &self.container_node.node.event_target;

    let future_for_return = WebFNativeFuture::<Vec<u8>>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let result = unsafe { (*argv.wrapping_add(1)).clone() };
        let value = result.to_u8_bytes();
        future_in_callback.set_result(Ok(Some(value)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
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
    unsafe {
      (((*self.method_pointer).to_blob_with_device_pixel_ratio))(event_target.ptr, device_pixel_ratio, callback_context_ptr, exception_state.ptr);
    }
    future_for_return
  }
}

pub trait ElementMethods: ContainerNodeMethods {
  fn to_blob(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>>;
  fn to_blob_with_device_pixel_ratio(&self, device_pixel_ratio: f64, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>>;
}

impl ContainerNodeMethods for Element {}

impl NodeMethods for Element {
  fn append_child(&self, new_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.container_node.node.append_child(new_node, exception_state)
  }

  fn remove_child(&self, target_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.container_node.node.remove_child(target_node, exception_state)
  }

  fn as_node(&self) -> &Node {
    &self.container_node.node
  }
}

impl EventTargetMethods for Element {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      Element {
        container_node: ContainerNode::initialize(
          ptr,
          context,
          &(method_pointer as *const ElementRustMethods).as_ref().unwrap().container_node,
          status
        ),
        method_pointer: method_pointer as *const ElementRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.container_node.ptr()
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.container_node.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.container_node.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.container_node.dispatch_event(event, exception_state)
  }
}

impl ElementMethods for Element {
  fn to_blob(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    self.to_blob(exception_state)
  }
  fn to_blob_with_device_pixel_ratio(&self, device_pixel_ratio: f64, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<u8>> {
    self.to_blob_with_device_pixel_ratio(device_pixel_ratio, exception_state)
  }
}
