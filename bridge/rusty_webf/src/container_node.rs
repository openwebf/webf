/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::c_double;
use crate::document::{Document, DocumentRustMethods};
use crate::event_target::EventTargetRustMethods;
use crate::executing_context::ExecutingContext;
use crate::node::{Node, NodeRustMethods};
use crate::OpaquePtr;

#[repr(C)]
pub struct ContainerNodeRustMethods {
  pub version: c_double,
  pub node: *const NodeRustMethods,
}

pub struct ContainerNode {
  pub node: Node,
  method_pointer: *const ContainerNodeRustMethods,
}

impl ContainerNode {
  /// Initialize the instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const ContainerNodeRustMethods) -> ContainerNode {
    unsafe {
      ContainerNode {
        node: Node::initialize(ptr, context, method_pointer.as_ref().unwrap().node),
        method_pointer
      }
    }
  }
}