/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::c_double;
use crate::character_data::{CharacterData, CharacterDataRustMethods};
use crate::event::Event;
use crate::event_target::{AddEventListenerOptions, EventListenerCallback, EventTarget, EventTargetMethods, RustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::ExecutingContext;
use crate::node::{Node, NodeMethods, NodeRustMethods};
use crate::{OpaquePtr, RustValueStatus};

#[repr(C)]
pub struct TextNodeRustMethods {
  pub version: c_double,
  pub character_data: CharacterDataRustMethods,
}

impl RustMethods for TextNodeRustMethods {}

pub struct Text {
  pub character_data: CharacterData,
  method_pointer: *const TextNodeRustMethods,
}

impl Text {
}

impl NodeMethods for Text {
  fn append_child(&self, new_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.character_data.node.append_child(new_node, exception_state)
  }

  fn remove_child(&self, target_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.character_data.node.remove_child(target_node, exception_state)
  }


  fn as_node(&self) -> &Node {
    &self.character_data.node
  }
}

impl EventTargetMethods for Text {
  /// Initialize the instance from cpp raw pointer.
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      Text {
        character_data: CharacterData::initialize(ptr, context, &(method_pointer as *const TextNodeRustMethods).as_ref().unwrap().character_data, status),
        method_pointer: method_pointer as *const TextNodeRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.character_data.ptr()
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.character_data.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.character_data.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.character_data.dispatch_event(event, exception_state)
  }
}
