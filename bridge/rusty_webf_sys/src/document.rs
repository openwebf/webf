/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_char, c_double, CString};
use std::mem;
use crate::container_node::{ContainerNode, ContainerNodeRustMethods};
use crate::element::{Element, ElementMethods, ElementRustMethods};
use crate::event_target::{AddEventListenerOptions, EventListenerCallback, EventTarget, EventTargetMethods, RustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::ExecutingContext;
use crate::node::{Node, NodeMethods};
use crate::{OpaquePtr, RustValue};
use crate::text::{Text, TextNodeRustMethods};

#[repr(C)]
pub struct DocumentRustMethods {
  pub version: c_double,
  pub container_node: *const ContainerNodeRustMethods,
  pub create_element: extern "C" fn(document: *const OpaquePtr, tag_name: *const c_char, exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub create_text_node: extern "C" fn(document: *const OpaquePtr, data: *const c_char, exception_state: *const OpaquePtr) -> RustValue<TextNodeRustMethods>,
  pub document_element: extern "C" fn(document: *const OpaquePtr) -> RustValue<ElementRustMethods>,
}

impl RustMethods for DocumentRustMethods {}

pub struct Document {
  pub container_node: ContainerNode,
  method_pointer: *const DocumentRustMethods,
}

impl Document {

  /// Behavior as same as `document.createElement()` in JavaScript.
  /// the createElement() method creates the HTML element specified by tagName, or an HTMLUnknownElement if tagName isn't recognized.
  pub fn create_element(&self, name: &CString, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element)(event_target.ptr, name.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context, new_element_value.method_pointer));
  }

  /// Behavior as same as `document.createTextNode()` in JavaScript.
  /// Creates a new Text node. This method can be used to escape HTML characters.
  pub fn create_text_node(&self, data: &CString, exception_state: &ExceptionState) -> Result<Text, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_text_node = unsafe {
      ((*self.method_pointer).create_text_node)(event_target.ptr, data.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(Text::initialize(new_text_node.value, event_target.context, new_text_node.method_pointer));
  }

  /// Document.documentElement returns the Element that is the root element of the document
  /// (for example, the <html> element for HTML documents).
  pub fn document_element(&self) -> Element {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let html_element_value = unsafe {
      ((*self.method_pointer).document_element)(event_target.ptr)
    };

    return Element::initialize(html_element_value.value, event_target.context, html_element_value.method_pointer);
  }
}

trait DocumentMethods : NodeMethods {}

impl NodeMethods for Document {
  fn append_child<T: NodeMethods>(&self, new_node: &T, exception_state: &ExceptionState) -> Result<T, String> {
    self.container_node.node.append_child(new_node, exception_state)
  }

  fn as_node(&self) -> &Node {
    &self.container_node.node
  }
}

impl EventTargetMethods for Document {
  /// Initialize the document instance from cpp raw pointer.
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T) -> Self where Self: Sized {
    unsafe {
      Document {
        container_node: ContainerNode::initialize(
          ptr,
          context,
          (method_pointer as *const DocumentRustMethods).as_ref().unwrap().container_node
        ),
        method_pointer: method_pointer as *const DocumentRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.container_node.ptr()
  }

  fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions) {
    self.container_node.node.event_target.add_event_listener(event_name, callback, options)
  }
}

impl DocumentMethods for Document {}