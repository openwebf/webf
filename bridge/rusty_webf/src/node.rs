/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void};
use libc::c_char;
use crate::container_node::{ContainerNode, ContainerNodeRustMethods};
use crate::event_target::{EventTarget, EventTargetRustMethods};
use crate::{OpaquePtr};
use crate::executing_context::ExecutingContext;

enum NodeType {
  ElementNode,
  AttributeNode,
  TextNode,
  CommentNode,
  DocumentNode,
  DocumentTypeNode,
  DocumentFragmentNode,
}

impl NodeType {
  fn value(&self) -> i32 {
    match self {
      NodeType::ElementNode => 1,
      NodeType::AttributeNode => 2,
      NodeType::TextNode => 3,
      NodeType::CommentNode => 8,
      NodeType::DocumentNode => 9,
      NodeType::DocumentTypeNode => 10,
      NodeType::DocumentFragmentNode => 11,
    }
  }
}

#[repr(C)]
pub struct NodeRustMethods {
  pub version: c_double,
  pub event_target: *const EventTargetRustMethods,
}

pub struct Node {
  pub event_target: EventTarget,
  method_pointer: *const NodeRustMethods,
}

impl Node {
  /// Initialize the instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const NodeRustMethods) -> Node {
    unsafe {
      Node {
        event_target: EventTarget::initialize(
          ptr,
          context,
          method_pointer.as_ref().unwrap().event_target,
        ),
        method_pointer,
      }
    }
  }
}