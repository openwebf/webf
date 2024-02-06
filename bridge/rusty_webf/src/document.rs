/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_char, c_double, CString};
use std::mem;
use crate::{OpaquePtr, RustValue};
use crate::container_node::{ContainerNode, ContainerNodeRustMethods};
use crate::element::{Element, ElementRustMethods};
use crate::event_target::EventTarget;
use crate::exception_state::ExceptionState;
use crate::executing_context::ExecutingContext;

#[repr(C)]
pub struct DocumentRustMethods {
  pub version: c_double,
  pub container_node: *const ContainerNodeRustMethods,
  pub create_element: extern "C" fn(document: *const OpaquePtr, tag_name: *const c_char, exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub document_element: extern "C" fn(document: *const OpaquePtr) -> RustValue<ElementRustMethods>,
}

pub struct Document {
  pub container_node: ContainerNode,
  method_pointer: *const DocumentRustMethods,
}

impl Document {
  /// Initialize the document instance from cpp raw pointer.
  pub fn initialize(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const DocumentRustMethods) -> Document {
    unsafe {
      Document {
        container_node: ContainerNode::initialize(ptr, context, method_pointer.as_ref().unwrap().container_node),
        method_pointer,
      }
    }
  }

  // Behavior as same as `document.createElement()` in JavaScript.
  // the createElement() method creates the HTML element specified by tagName, or an HTMLUnknownElement if tagName isn't recognized.
  pub fn create_element(&self, name: &CString, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element)(event_target.ptr, name.as_ptr(), exception_state.ptr)
    };

    if (exception_state.has_exception()) {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context, new_element_value.method_pointer));
  }

  pub fn document_element(&self) -> Element {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let html_element_value = unsafe {
      ((*self.method_pointer).document_element)(event_target.ptr)
    };

    return Element::initialize(html_element_value.value, event_target.context, html_element_value.method_pointer);
  }
}