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
pub mod rs_event;
pub mod rs_animation_event;
pub mod rs_close_event;
pub mod rs_focus_event;
pub mod rs_gesture_event;
pub mod rs_hashchange_event;
pub mod rs_input_event;
pub mod rs_intersection_change_event;
pub mod rs_mouse_event;
pub mod rs_pointer_event;
pub mod rs_transition_event;
pub mod rs_ui_event;
pub mod container_node;
pub mod exception_state;
pub mod text;
pub mod comment;
pub mod character_data;
pub mod html_element;

pub use executing_context::*;
pub use document::*;
pub use window::*;
pub use element::*;
pub use document_fragment::*;
pub use node::*;
pub use event_target::*;
pub use rs_event::*;
pub use rs_animation_event::*;
pub use rs_close_event::*;
pub use rs_focus_event::*;
pub use rs_gesture_event::*;
pub use rs_hashchange_event::*;
pub use rs_input_event::*;
pub use rs_intersection_change_event::*;
pub use rs_mouse_event::*;
pub use rs_pointer_event::*;
pub use rs_transition_event::*;
pub use rs_ui_event::*;
pub use container_node::*;
pub use exception_state::*;
pub use text::*;
pub use comment::*;
pub use character_data::*;
pub use html_element::*;

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
