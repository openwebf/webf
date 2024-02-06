/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void};
use crate::{OpaquePtr, RustValue};
use crate::container_node::{ContainerNode, ContainerNodeRustMethods};
use crate::document::Document;
use crate::event_target::EventTargetRustMethods;
use crate::executing_context::{ExecutingContext};

#[repr(C)]
pub struct ElementRustMethods {
  pub version: c_double,
  pub container_node: *const ContainerNodeRustMethods,
}

pub struct Element {
  container_node: ContainerNode,
  method_pointer: *const ElementRustMethods,
}

impl Element {
  /// Initialize the element instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const ElementRustMethods) -> Element {
    unsafe {
      Element {
        container_node: ContainerNode::initialize(ptr, context, method_pointer.as_ref().unwrap().container_node),
        method_pointer
      }
    }
  }
}