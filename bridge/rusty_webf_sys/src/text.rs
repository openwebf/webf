/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::c_double;
use crate::character_data::{CharacterData, CharacterDataRustMethods};
use crate::event_target::{AddEventListenerOptions, EventListenerCallback, EventTarget, EventTargetMethods, RustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::ExecutingContext;
use crate::node::{Node, NodeMethods, NodeRustMethods};
use crate::OpaquePtr;

#[repr(C)]
pub struct TextNodeRustMethods {
  pub version: c_double,
  pub character_data: *const CharacterDataRustMethods,
}

impl RustMethods for TextNodeRustMethods {}

pub struct Text {
  pub character_data: CharacterData,
  method_pointer: *const TextNodeRustMethods,
}

impl Text {
}

impl NodeMethods for Text {
  fn append_child<T: NodeMethods>(&self, new_node: &T, exception_state: &ExceptionState) -> Result<T, String> {
    self.character_data.node.append_child(new_node, exception_state)
  }

  fn remove_child<T: NodeMethods>(&self, target_node: &T, exception_state: &ExceptionState) -> Result<T, String> {
    self.character_data.node.remove_child(target_node, exception_state)
  }


  fn as_node(&self) -> &Node {
    &self.character_data.node
  }
}

impl EventTargetMethods for Text {
  /// Initialize the instance from cpp raw pointer.
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T) -> Self where Self: Sized {
    unsafe {
      Text {
        character_data: CharacterData::initialize(ptr, context, (method_pointer as *const TextNodeRustMethods).as_ref().unwrap().character_data),
        method_pointer: method_pointer as *const TextNodeRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.character_data.ptr()
  }

  fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions) {
    self.character_data.add_event_listener(event_name, callback, options)
  }
}