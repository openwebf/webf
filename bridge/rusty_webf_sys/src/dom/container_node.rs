/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct ContainerNodeRustMethods {
  pub version: c_double,
  pub node: NodeRustMethods,
}

impl RustMethods for ContainerNodeRustMethods {}

pub struct ContainerNode {
  pub node: Node,
  method_pointer: *const ContainerNodeRustMethods,
}

impl ContainerNode {

}

pub trait ContainerNodeMethods : NodeMethods {
}

impl NodeMethods for ContainerNode {
  fn append_child(&self, new_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.node.append_child(new_node, exception_state)
  }

  fn remove_child(&self, target_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.node.remove_child(target_node, exception_state)
  }

  fn as_node(&self) -> &Node {
    &self.node
  }
}

impl EventTargetMethods for ContainerNode {
  /// Initialize the instance from cpp raw pointer.
  fn initialize<T>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      ContainerNode {
        node: Node::initialize(ptr, context, &(method_pointer as *const ContainerNodeRustMethods).as_ref().unwrap().node, status),
        method_pointer: method_pointer as *const ContainerNodeRustMethods
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

impl ContainerNodeMethods for ContainerNode {}
