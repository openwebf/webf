/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use crate::executing_context::{ExecutingContext, ExecutingContextRustMethods};

pub mod executing_context;
pub mod document;
pub mod window;
pub mod element;
pub mod node;
pub mod event_target;
pub mod event;
pub mod container_node;
pub mod exception_state;
pub mod text;
pub mod character_data;
mod html_element;

#[repr(C)]
pub struct OpaquePtr;

#[repr(C)]
pub struct RustValue<T> {
  pub value: *const OpaquePtr,
  pub method_pointer: *const T,
}

pub fn initialize_webf_api(value: RustValue<ExecutingContextRustMethods>) -> ExecutingContext {
  ExecutingContext::initialize(value.value, value.method_pointer)
}

// This is the entrypoint when your rust app compiled as dynamic library and loaded & executed by WebF.
// #[no_mangle]
// pub extern "C" fn load_webf_rust_module(context: *mut c_void, method_pointer: *const c_void) {
//
// }