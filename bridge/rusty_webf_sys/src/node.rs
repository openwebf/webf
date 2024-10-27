/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

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
  pub event_target: EventTargetRustMethods,
  pub append_child: extern "C" fn(self_node: *const OpaquePtr, new_node: *const OpaquePtr, exception_state: *const OpaquePtr) -> RustValue<NodeRustMethods>,
  pub remove_node: extern "C" fn(self_node: *const OpaquePtr, target_node: *const OpaquePtr, exception_state: *const OpaquePtr) -> RustValue<NodeRustMethods>,
}

impl RustMethods for NodeRustMethods {}

pub struct Node {
  pub event_target: EventTarget,
  method_pointer: *const NodeRustMethods,
}

impl Node {
  /// The appendChild() method of the Node interface adds a node to the end of the list of children of a specified parent node.
  pub fn append_child(&self, new_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    let event_target: &EventTarget = &self.event_target;
    let returned_result = unsafe {
      ((*self.method_pointer).append_child)(event_target.ptr, new_node.ptr(), exception_state.ptr)
    };
    if (exception_state.has_exception()) {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Node::initialize(returned_result.value, event_target.context(), returned_result.method_pointer, returned_result.status));
  }

  /// The removeChild() method of the Node interface removes a child node from the DOM and returns the removed node.
  pub fn remove_child(&self, target_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    let event_target: &EventTarget = &self.event_target;
    let returned_result = unsafe {
      ((*self.method_pointer).remove_node)(event_target.ptr, target_node.ptr(), exception_state.ptr)
    };
    if (exception_state.has_exception()) {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Node::initialize(returned_result.value, event_target.context(), returned_result.method_pointer, returned_result.status));
  }
}

pub trait NodeMethods: EventTargetMethods {
  fn append_child(&self, new_node: &Node, exception_state: &ExceptionState) -> Result<Node, String>;
  fn remove_child(&self, target_node: &Node, exception_state: &ExceptionState) -> Result<Node, String>;

  fn as_node(&self) -> &Node;
}

impl EventTargetMethods for Node {
  /// Initialize the instance from cpp raw pointer.
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      Node {
        event_target: EventTarget::initialize(
          ptr,
          context,
          &(method_pointer as *const NodeRustMethods).as_ref().unwrap().event_target,
          status,
        ),
        method_pointer: method_pointer as *const NodeRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.event_target.ptr
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.event_target.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.event_target.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self,
                    event: &Event,
                    exception_state: &ExceptionState) -> bool{
    self.event_target.dispatch_event(event, exception_state)
  }
}

impl NodeMethods for Node {
  fn append_child(&self, new_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.append_child(new_node, exception_state)
  }

  fn remove_child(&self, target_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.remove_child(target_node, exception_state)
  }

  fn as_node(&self) -> &Node {
    self
  }
}
