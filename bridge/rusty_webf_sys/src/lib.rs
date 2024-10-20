/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use crate::executing_context::{ExecutingContext, ExecutingContextRustMethods};

pub mod executing_context;
pub mod document;
pub mod window;
pub mod element;
pub mod document_fragment;
pub mod node;
pub mod event_target;
pub mod event;
pub mod animation_event;
pub mod close_event;
pub mod focus_event;
pub mod gesture_event;
pub mod hashchange_event;
pub mod input_event;
pub mod intersection_change_event;
pub mod mouse_event;
pub mod pointer_event;
pub mod transition_event;
pub mod ui_event;
pub mod container_node;
pub mod exception_state;
pub mod text;
pub mod comment;
pub mod character_data;
pub mod html_element;
pub mod script_value_ref;
mod custom_event;

pub use executing_context::*;
pub use document::*;
pub use window::*;
pub use element::*;
pub use document_fragment::*;
pub use node::*;
pub use event_target::*;
pub use event::*;
pub use animation_event::*;
pub use close_event::*;
pub use focus_event::*;
pub use gesture_event::*;
pub use hashchange_event::*;
pub use input_event::*;
pub use intersection_change_event::*;
pub use mouse_event::*;
pub use pointer_event::*;
pub use transition_event::*;
pub use ui_event::*;
pub use container_node::*;
pub use exception_state::*;
pub use text::*;
pub use comment::*;
pub use character_data::*;
pub use html_element::*;
pub use script_value_ref::*;

#[repr(C)]
pub struct OpaquePtr;

#[repr(C)]
pub struct RustValueStatus {
  pub disposed: bool,
}

#[repr(C)]
pub struct RustValue<T> {
  pub value: *const OpaquePtr,
  pub method_pointer: *const T,
  pub status: *const RustValueStatus,
}

pub fn initialize_webf_api(value: RustValue<ExecutingContextRustMethods>) -> ExecutingContext {
  ExecutingContext::initialize(value.value, value.method_pointer)
}

// This is the entrypoint when your rust app compiled as dynamic library and loaded & executed by WebF.
// #[no_mangle]
// pub extern "C" fn load_webf_rust_module(context: *mut c_void, method_pointer: *const c_void) {
//
// }
