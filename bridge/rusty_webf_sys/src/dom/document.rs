/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct ElementCreationOptions {
  pub is: *const c_char,
}

#[repr(C)]
pub struct DocumentRustMethods {
  pub version: c_double,
  pub container_node: ContainerNodeRustMethods,
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
  pub create_event: extern "C" fn(document: *const OpaquePtr, event_type: *const c_char, exception_state: *const OpaquePtr) -> RustValue<EventRustMethods>,
  pub query_selector: extern "C" fn(document: *const OpaquePtr, selectors: *const c_char, exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub get_element_by_id: extern "C" fn(document: *const OpaquePtr, element_id: *const c_char, exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub element_from_point: extern "C" fn(document: *const OpaquePtr, x: c_double, y: c_double, exception_state: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub document_element: extern "C" fn(document: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub head: extern "C" fn(document: *const OpaquePtr) -> RustValue<ElementRustMethods>,
  pub body: extern "C" fn(document: *const OpaquePtr) -> RustValue<ElementRustMethods>,
}

impl RustMethods for DocumentRustMethods {}

pub struct Document {
  pub container_node: ContainerNode,
  method_pointer: *const DocumentRustMethods,
}

impl Document {
  /// Behavior as same as `document.createElement()` in JavaScript.
  /// the createElement() method creates the HTML element specified by tagName, or an HTMLUnknownElement if tagName isn't recognized.
  pub fn create_element(&self, name: &str, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let name_c_string = CString::new(name).unwrap();
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element)(event_target.ptr, name_c_string.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context(), new_element_value.method_pointer, new_element_value.status));
  }

  pub fn create_element_with_element_creation_options(&self, name: &str, options: &mut ElementCreationOptions, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let name_c_string = CString::new(name).unwrap();
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element_with_element_creation_options)(event_target.ptr, name_c_string.as_ptr(), options, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context(), new_element_value.method_pointer, new_element_value.status));
  }

  pub fn create_element_with_str(&self, name: &str, str_options: &CString, exception_state: &ExceptionState) -> Result<Element, String> {
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
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context(), new_element_value.method_pointer, new_element_value.status));
  }

  pub fn create_element_ns_with_element_creation_options(&self, uri: &str, name: &str, options: &mut ElementCreationOptions, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let uri_c_string = CString::new(uri).unwrap();
    let name_c_string = CString::new(name).unwrap();
    let new_element_value = unsafe {
      ((*self.method_pointer).create_element_ns_with_element_creation_options)(event_target.ptr, uri_c_string.as_ptr(), name_c_string.as_ptr(), options, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Element::initialize(new_element_value.value, event_target.context(), new_element_value.method_pointer, new_element_value.status));
  }

  pub fn create_element_ns_with_str(&self, uri: &str, name: &str, str_options: &CString, exception_state: &ExceptionState) -> Result<Element, String> {
    let options = &mut ElementCreationOptions {
      is: str_options.as_ptr(),
    };
    return self.create_element_ns_with_element_creation_options(uri, name, options, exception_state);
  }

  /// Behavior as same as `document.createTextNode()` in JavaScript.
  /// Creates a new Text node. This method can be used to escape HTML characters.
  pub fn create_text_node(&self, data: &str, exception_state: &ExceptionState) -> Result<Text, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let data_c_string = CString::new(data).unwrap();
    let new_text_node = unsafe {
      ((*self.method_pointer).create_text_node)(event_target.ptr, data_c_string.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Text::initialize(new_text_node.value, event_target.context(), new_text_node.method_pointer, new_text_node.status));
  }

  /// Behavior as same as `document.createDocumentFragment()` in JavaScript.
  /// Creates a new DocumentFragment.
  pub fn create_document_fragment(&self, exception_state: &ExceptionState) -> Result<DocumentFragment, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let new_document_fragment = unsafe {
      ((*self.method_pointer).create_document_fragment)(event_target.ptr, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(DocumentFragment::initialize(new_document_fragment.value, event_target.context(), new_document_fragment.method_pointer, new_document_fragment.status));
  }

  /// Behavior as same as `document.createComment()` in JavaScript.
  /// Creates a new Comment node with the given data.
  pub fn create_comment(&self, data: &str, exception_state: &ExceptionState) -> Result<Comment, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let data_c_string = CString::new(data).unwrap();
    let new_comment = unsafe {
      ((*self.method_pointer).create_comment)(event_target.ptr, data_c_string.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Comment::initialize(new_comment.value, event_target.context(), new_comment.method_pointer, new_comment.status));
  }

  /// Behavior as same as `document.createEvent()` in JavaScript.
  /// Creates a new event of the type specified.
  pub fn create_event(&self, event_type: &str, exception_state: &ExceptionState) -> Result<Event, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let event_type_c_string = CString::new(event_type).unwrap();
    let new_event = unsafe {
      ((*self.method_pointer).create_event)(event_target.ptr, event_type_c_string.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Event::initialize(new_event.value, event_target.context(), new_event.method_pointer, new_event.status));
  }

  /// Behavior as same as `document.querySelector()` in JavaScript.
  /// Returns the first element that is a descendant of the element on which it is invoked that matches the specified group of selectors.
  pub fn query_selector(&self, selectors: &str, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let selectoc_string = CString::new(selectors).unwrap();
    let element_value = unsafe {
      ((*self.method_pointer).query_selector)(event_target.ptr, selectoc_string.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Element::initialize(element_value.value, event_target.context(), element_value.method_pointer, element_value.status));
  }

  /// Behavior as same as `document.getElementById()` in JavaScript.
  /// Returns a reference to the element by its ID.
  pub fn get_element_by_id(&self, element_id: &str, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let id_c_string = CString::new(element_id).unwrap();
    let element_value = unsafe {
      ((*self.method_pointer).get_element_by_id)(event_target.ptr, id_c_string.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Element::initialize(element_value.value, event_target.context(), element_value.method_pointer, element_value.status));
  }

  /// Behavior as same as `document.elementFromPoint()` in JavaScript.
  /// Returns the element from the document whose elementFromPoint() method is being called which is the topmost element which lies under the given point.
  pub fn element_from_point(&self, x: f64, y: f64, exception_state: &ExceptionState) -> Result<Element, String> {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let element_value = unsafe {
      ((*self.method_pointer).element_from_point)(event_target.ptr, x, y, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(event_target.context()));
    }

    return Ok(Element::initialize(element_value.value, event_target.context(), element_value.method_pointer, element_value.status));
  }

  /// Document.documentElement returns the Element that is the root element of the document
  /// (for example, the <html> element for HTML documents).
  pub fn document_element(&self) -> HTMLElement {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let html_element_value = unsafe {
      ((*self.method_pointer).document_element)(event_target.ptr)
    };

    return HTMLElement::initialize(html_element_value.value, event_target.context(), html_element_value.method_pointer, html_element_value.status);
  }

  /// The Document.head property represents the <head> or of the current document,
  /// or null if no such element exists.
  pub fn head(&self) -> HTMLElement {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let head_element_value = unsafe {
      ((*self.method_pointer).head)(event_target.ptr)
    };
    return HTMLElement::initialize(head_element_value.value, event_target.context(), head_element_value.method_pointer, head_element_value.status);
  }


  /// The Document.body property represents the <body> or of the current document,
  /// or null if no such element exists.
  pub fn body(&self) -> HTMLElement {
    let event_target: &EventTarget = &self.container_node.node.event_target;
    let body_element_value = unsafe {
      ((*self.method_pointer).body)(event_target.ptr)
    };
    return HTMLElement::initialize(body_element_value.value, event_target.context(), body_element_value.method_pointer, body_element_value.status);
  }
}

trait DocumentMethods: ContainerNodeMethods {}

impl NodeMethods for Document {
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

impl EventTargetMethods for Document {
  /// Initialize the document instance from cpp raw pointer.
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      Document {
        container_node: ContainerNode::initialize(
          ptr,
          context,
          &(method_pointer as *const DocumentRustMethods).as_ref().unwrap().container_node,
          status,
        ),
        method_pointer: method_pointer as *const DocumentRustMethods,
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
    self.container_node.node.event_target.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.container_node.node.event_target.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.container_node.node.event_target.dispatch_event(event, exception_state)
  }
}

impl ContainerNodeMethods for Document {}

impl DocumentMethods for Document {}
