/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;

pub type WebFNativeFunction = Box<dyn Fn(c_int, *const NativeValue) -> NativeValue>;

pub struct WebFNativeFunctionContextData {
  pub func: WebFNativeFunction,
}

impl Drop for WebFNativeFunctionContextData {
  fn drop(&mut self) {
  }
}

#[repr(C)]
pub struct WebFNativeFunctionContext {
  pub callback: extern "C" fn(callback_context: *const OpaquePtr,
                              argc: c_int,
                              argv: *const NativeValue,
                              exception_state: *const OpaquePtr) -> NativeValue,
  pub free_ptr: extern "C" fn(callback_context: *const OpaquePtr) -> *const c_void,
  pub ptr: *const WebFNativeFunctionContextData,
}

pub extern "C" fn invoke_webf_native_function(
  callback_context_ptr: *const OpaquePtr,
  argc: c_int,
  argv: *const NativeValue,
  exception_state: *const OpaquePtr,
) -> NativeValue {
  let callback_context = unsafe {
    &(*(callback_context_ptr as *mut WebFNativeFunctionContext))
  };
  let callback_context_data = unsafe {
    &(*(callback_context.ptr as *mut WebFNativeFunctionContextData))
  };

  unsafe {
    let func = &(*callback_context_data).func;
    func(argc, argv)
  }
}

pub extern "C" fn release_webf_native_function(callback_context_ptr: *const OpaquePtr) -> *const c_void {
  unsafe {
    let callback_context = &(*(callback_context_ptr as *mut WebFNativeFunctionContext));
    let _ = Box::from_raw(callback_context.ptr as *mut WebFNativeFunctionContextData);
  }
  std::ptr::null()
}
