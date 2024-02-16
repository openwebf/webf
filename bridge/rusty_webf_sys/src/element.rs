/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void};
use crate::container_node::{ContainerNode, ContainerNodeMethods, ContainerNodeRustMethods};
use crate::document::Document;
use crate::event_target::{AddEventListenerOptions, EventListenerCallback, EventTargetMethods, EventTargetRustMethods, RustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::{ExecutingContext};
use crate::node::{Node, NodeMethods};
use crate::OpaquePtr;

#[repr(C)]
pub struct ElementRustMethods {
  pub version: c_double,
  pub container_node: *const ContainerNodeRustMethods,
}

impl RustMethods for ElementRustMethods {}

pub struct Element {
  container_node: ContainerNode,
  method_pointer: *const ElementRustMethods,
}

impl Element {
}

pub trait ElementMethods: ContainerNodeMethods {}

impl ContainerNodeMethods for Element {}

impl NodeMethods for Element {
  fn append_child<T: NodeMethods>(&self, new_node: &T, exception_state: &ExceptionState) -> Result<T, String> {
    self.container_node.node.append_child(new_node, exception_state)
  }

  fn as_node(&self) -> &Node {
    &self.container_node.node
  }
}

impl EventTargetMethods for Element {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T) -> Self where Self: Sized {
    unsafe {
      Element {
        container_node: ContainerNode::initialize(
          ptr,
          context,
          (method_pointer as *const ElementRustMethods).as_ref().unwrap().container_node
        ),
        method_pointer: method_pointer as *const ElementRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.container_node.ptr()
  }

  fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions) {
    self.container_node.add_event_listener(event_name, callback, options)
  }
}

impl ElementMethods for Element {}