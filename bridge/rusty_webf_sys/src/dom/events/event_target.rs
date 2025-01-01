/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

pub trait RustMethods {}

#[repr(C)]
pub enum EventTargetType {
  EventTarget = 0,
  Node = 1,
  ContainerNode = 2,
  Window = 3,
  Document = 4,
  Element = 5,
  HTMLElement = 6,
  HTMLImageElement = 7,
  HTMLCanvasElement = 8,
  HTMLDivElement = 9,
  HTMLScriptElement = 10,
  DocumentFragment = 11,
  Text = 12,
  Comment = 13,
}

#[repr(C)]
pub struct EventTargetRustMethods {
  pub version: c_double,
  pub add_event_listener: extern "C" fn(
    event_target: *const OpaquePtr,
    event_name: *const c_char,
    callback_context: *const EventCallbackContext,
    options: *const AddEventListenerOptions,
    exception_state: *const OpaquePtr) -> c_void,
  pub remove_event_listener: extern "C" fn(
    event_target: *const OpaquePtr,
    event_name: *const c_char,
    callback_context: *const EventCallbackContext,
    exception_state: *const OpaquePtr) -> c_void,
  pub dispatch_event: extern "C" fn(
    event_target: *const OpaquePtr,
    event: *const OpaquePtr,
    exception_state: *const OpaquePtr) -> bool,
  pub release: extern "C" fn(event_target: *const OpaquePtr),
  pub dynamic_to: extern "C" fn(event_target: *const OpaquePtr, event_target_type: EventTargetType) -> RustValue<c_void>,
}

impl RustMethods for EventTargetRustMethods {}


pub struct EventTarget {
  pub ptr: *const OpaquePtr,
  status: *const RustValueStatus,
  context: *const ExecutingContext,
  method_pointer: *const EventTargetRustMethods,
}

impl EventTarget {
  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn add_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    options: &AddEventListenerOptions,
    exception_state: &ExceptionState,
  ) -> Result<(), String> {
    let callback_context_data = Box::new(EventCallbackContextData {
      executing_context_ptr: self.context().ptr,
      executing_context_method_pointer: self.context().method_pointer(),
      executing_context_status: self.context().status,
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_context_data);
    let callback_context = Box::new(EventCallbackContext {
      callback: invoke_event_listener_callback,
      free_ptr: release_event_listener_callback,
      ptr: callback_context_data_ptr
    });
    let callback_context_ptr = Box::into_raw(callback_context);
    let c_event_name = CString::new(event_name).unwrap();
    unsafe {
      ((*self.method_pointer).add_event_listener)(self.ptr, c_event_name.as_ptr(), callback_context_ptr, options, exception_state.ptr)
    };
    if exception_state.has_exception() {
      // Clean up the allocated memory on exception
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self.context()));
    }

    Ok(())
  }

  pub fn remove_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    exception_state: &ExceptionState,
  ) -> Result<(), String> {
    let callback_context_data = Box::new(EventCallbackContextData {
      executing_context_ptr: self.context().ptr,
      executing_context_method_pointer: self.context().method_pointer(),
      executing_context_status: self.context().status,
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_context_data);
    let callback_context = Box::new(EventCallbackContext {
      callback: invoke_event_listener_callback,
      free_ptr: release_event_listener_callback,
      ptr: callback_context_data_ptr
    });
    let callback_context_ptr = Box::into_raw(callback_context);
    let c_event_name = CString::new(event_name).unwrap();
    unsafe {
      ((*self.method_pointer).remove_event_listener)(self.ptr, c_event_name.as_ptr(), callback_context_ptr, exception_state.ptr)
    };
    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self.context()));
    }

    Ok(())
  }

  pub fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dispatch_event)(self.ptr, event.ptr, exception_state.ptr)
    }
  }

  pub fn as_node(&self) -> Result<Node, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Node)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Node type.");
    }
    Ok(Node::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const NodeRustMethods, raw_ptr.status))
  }

  pub fn as_element(&self) -> Result<Element, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Element)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Element type.");
    }
    Ok(Element::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const ElementRustMethods, raw_ptr.status))
  }

  pub fn as_container_node(&self) -> Result<ContainerNode, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::ContainerNode)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the ContainerNode type.");
    }
    Ok(ContainerNode::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const ContainerNodeRustMethods, raw_ptr.status))
  }

  pub fn as_window(&self) -> Result<Window, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Window)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Window type.");
    }
    Ok(Window::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const WindowRustMethods, raw_ptr.status))
  }

  pub fn as_document(&self) -> Result<Document, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Document)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Document type.");
    }
    Ok(Document::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const DocumentRustMethods, raw_ptr.status))
  }

  pub fn as_html_element(&self) -> Result<HTMLElement, &str> {
    let raw_ptr = unsafe {
      assert!(!(*((*self).status)).disposed, "The underline C++ impl of this ptr({:?}) had been disposed", (self.method_pointer));
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::HTMLElement)
    };
    if raw_ptr.value == std::ptr::null() {
      return Err("The type value of event_target does not belong to the HTMLElement type.");
    }
    Ok(HTMLElement::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const HTMLElementRustMethods, raw_ptr.status))
  }
}

pub trait EventTargetMethods {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized;

  fn ptr(&self) -> *const OpaquePtr;

  // fn add_event_listener(&self, event_name: &str, callback: EventListenerCallback, options: &mut AddEventListenerOptions);
  fn add_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    options: &AddEventListenerOptions,
    exception_state: &ExceptionState) -> Result<(), String>;

  fn remove_event_listener(
    &self,
    event_name: &str,
    callback: EventListenerCallback,
    exception_state: &ExceptionState) -> Result<(), String>;

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool;
}

impl Drop for EventTarget {
  // When the holding on Rust side released, should notify c++ side to release the holder.
  fn drop(&mut self) {
    unsafe {
      if (*((*self).status)).disposed {
        println!("The object {:?} has been disposed.", self.ptr);
        return;
      };
      ((*self.method_pointer).release)(self.ptr)
    };
  }
}

impl EventTargetMethods for EventTarget {
  /// Initialize the instance from cpp raw pointer.
  fn initialize<T>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> EventTarget {
    EventTarget {
      ptr,
      context,
      method_pointer: method_pointer as *const EventTargetRustMethods,
      status
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.ptr
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.dispatch_event(event, exception_state)
  }
}
