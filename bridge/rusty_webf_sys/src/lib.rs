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
pub mod custom_event;
pub mod add_event_listener_options;
pub mod animation_event_init;
pub mod close_event_init;
pub mod event_init;
pub mod event_listener_options;
pub mod focus_event_init;
pub mod gesture_event_init;
pub mod hashchange_event_init;
pub mod input_event_init;
pub mod intersection_change_event_init;
pub mod keyboard_event_init;
pub mod mouse_event_init;
pub mod pointer_event_init;
pub mod scroll_options;
pub mod scroll_to_options;
pub mod touch_init;
pub mod transition_event_init;
pub mod ui_event_init;
mod memory_utils;

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
pub use add_event_listener_options::*;
pub use animation_event_init::*;
pub use close_event_init::*;
pub use event_init::*;
pub use event_listener_options::*;
pub use focus_event_init::*;
pub use gesture_event_init::*;
pub use hashchange_event_init::*;
pub use input_event_init::*;
pub use intersection_change_event_init::*;
pub use keyboard_event_init::*;
pub use mouse_event_init::*;
pub use pointer_event_init::*;
pub use scroll_options::*;
pub use scroll_to_options::*;
pub use touch_init::*;
pub use transition_event_init::*;
pub use ui_event_init::*;

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
