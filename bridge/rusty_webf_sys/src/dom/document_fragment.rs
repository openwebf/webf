/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct DocumentFragmentRustMethods {
  pub version: c_double,
  pub container_node: ContainerNodeRustMethods,
}

impl RustMethods for DocumentFragmentRustMethods {}

pub struct DocumentFragment {
  container_node: ContainerNode,
  method_pointer: *const DocumentFragmentRustMethods,
}

impl DocumentFragment {}

pub trait DocumentFragmentMethods: ContainerNodeMethods {}

impl ContainerNodeMethods for DocumentFragment {}

impl NodeMethods for DocumentFragment {
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

impl EventTargetMethods for DocumentFragment {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      DocumentFragment {
        container_node: ContainerNode::initialize(
          ptr,
          context,
          &(method_pointer as *const DocumentFragmentRustMethods).as_ref().unwrap().container_node,
          status,
        ),
        method_pointer: method_pointer as *const DocumentFragmentRustMethods,
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

  fn as_event_target(&self) -> &EventTarget {
    self.container_node.as_event_target()
  }
}

impl DocumentFragmentMethods for DocumentFragment {}
