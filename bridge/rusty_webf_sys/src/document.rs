/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_char, c_double, CString};
use std::mem;
use crate::container_node::{ContainerNode, ContainerNodeMethods, ContainerNodeRustMethods};
use crate::element::{Element, ElementMethods, ElementRustMethods};
use crate::document_fragment::{DocumentFragment, DocumentFragmentRustMethods};
use crate::event_target::{AddEventListenerOptions, EventListenerCallback, EventTarget, EventTargetMethods, RustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::ExecutingContext;
use crate::node::{Node, NodeMethods};
use crate::{OpaquePtr, RustValue};
use crate::text::{Text, TextNodeRustMethods};
use crate::comment::{Comment, CommentRustMethods};

#[repr(C)]
pub struct ElementCreationOptions {
  pub is: *const c_char,
}

#[repr(C)]
pub struct DocumentRustMethods {
  pub version: c_double,
  pub container_node: *const ContainerNodeRustMethods,
  pub create_element: extern "C" fn(document: *const OpaquePtr, tag_name: *const c_char, exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub create_element_with_element_creation_options: extern "C" fn(
    document: *const OpaquePtr,
    tag_name: *const c_char,
    options: &mut ElementCreationOptions,
    exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub create_element_ns: extern "C" fn(document: *const OpaquePtr, uri: *const c_char, tag_name: *const c_char, exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub create_element_ns_with_element_creation_options: extern "C" fn(
    document: *const OpaquePtr,
    uri: *const c_char,
    tag_name: *const c_char,
    options: &mut ElementCreationOptions,
    exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub create_text_node: extern "C" fn(document: *const OpaquePtr, data: *const c_char, exception_state: *const OpaquePtr) -> RustValue<TextNodeRustMethods>,
  pub create_document_fragment: extern "C" fn(document: *const OpaquePtr, exception_state: *const OpaquePtr) -> RustValue<DocumentFragmentRustMethods>,
  pub create_comment: extern "C" fn(document: *const OpaquePtr, data: *const c_char, exception_state: *const OpaquePtr) -> RustValue<CommentRustMethods>,
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

  pub fn create_element_with_element_creation_options(&self, name: &CString, options: &mut ElementCreationOptions, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element_with_element_creation_options)(event_target.ptr, name.as_ptr(), options, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context, new_element_value.method_pointer));
  }

  pub fn create_element_with_str(&self, name: &CString, str_options: &CString, exception_state: &ExceptionState) -> Result<Element, String> {
    let options = &mut ElementCreationOptions {
      is: str_options.as_ptr(),
    };
    return self.create_element_with_element_creation_options(name, options, exception_state);
  }

  /// Behavior as same as `document.createElementNS()` in JavaScript.
  /// Creates a new element with the given namespace URI and qualified name.
  /// The qualified name is a concatenation of the namespace prefix, a colon, and the local name.
  pub fn create_element_ns(&self, uri: &CString, name: &CString, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element_ns)(event_target.ptr, uri.as_ptr(), name.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context, new_element_value.method_pointer));
  }

  pub fn create_element_ns_with_element_creation_options(&self, uri: &CString, name: &CString, options: &mut ElementCreationOptions, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element_ns_with_element_creation_options)(event_target.ptr, uri.as_ptr(), name.as_ptr(), options, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context, new_element_value.method_pointer));
  }

  pub fn create_element_ns_with_str(&self, uri: &CString, name: &CString, str_options: &CString, exception_state: &ExceptionState) -> Result<Element, String> {
    let options = &mut ElementCreationOptions {
      is: str_options.as_ptr(),
    };
    return self.create_element_ns_with_element_creation_options(uri, name, options, exception_state);
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

  /// Behavior as same as `document.createDocumentFragment()` in JavaScript.
  /// Creates a new DocumentFragment.
  pub fn create_document_fragment(&self, exception_state: &ExceptionState) -> Result<DocumentFragment, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_document_fragment = unsafe {
      ((*self.method_pointer).create_document_fragment)(event_target.ptr, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(DocumentFragment::initialize(new_document_fragment.value, event_target.context, new_document_fragment.method_pointer));
  }

  /// Behavior as same as `document.createComment()` in JavaScript.
  /// Creates a new Comment node with the given data.
  pub fn create_comment(&self, data: &CString, exception_state: &ExceptionState) -> Result<Comment, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_comment = unsafe {
      ((*self.method_pointer).create_comment)(event_target.ptr, data.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context));
    }

    return Ok(Comment::initialize(new_comment.value, event_target.context, new_comment.method_pointer));
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

trait DocumentMethods : ContainerNodeMethods {}

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

impl ContainerNodeMethods for Document {}

impl DocumentMethods for Document {}
