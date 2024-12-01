/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct CharacterDataRustMethods {
  pub version: c_double,
  pub node: NodeRustMethods,
}

impl RustMethods for CharacterDataRustMethods {}

pub struct CharacterData {
  pub node: Node,
  method_pointer: *const CharacterDataRustMethods,
}

impl CharacterData {}

impl EventTargetMethods for CharacterData {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      CharacterData {
        node: Node::initialize(ptr, context, &(method_pointer as *const CharacterDataRustMethods).as_ref().unwrap().node, status),
        method_pointer: method_pointer as *const CharacterDataRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.node.ptr()
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.node.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.node.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.node.dispatch_event(event, exception_state)
  }
}
