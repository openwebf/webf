/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void, CString, c_char};
use crate::add_event_listener_options::AddEventListenerOptions;
use crate::element::{Element, ElementRustMethods};
use crate::event::{Event, EventRustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::{ExecutingContext, ExecutingContextRustMethods};
use crate::{executing_context, OpaquePtr, RustValue, RustValueStatus};
use crate::container_node::{ContainerNode, ContainerNodeRustMethods};
use crate::document::{Document, DocumentRustMethods};
use crate::html_element::{HTMLElement, HTMLElementRustMethods};
use crate::node::{Node, NodeRustMethods};
use crate::window::{Window, WindowRustMethods};

#[repr(C)]
struct EventCallbackContext {
  pub callback: extern "C" fn(event_callback_context: *const OpaquePtr,
                              event: *const OpaquePtr,
                              event_method_pointer: *const EventRustMethods,
                              status: *const RustValueStatus,
                              exception_state: *const OpaquePtr) -> *const c_void,
  pub free_ptr: extern "C" fn(event_callback_context_ptr: *const OpaquePtr) -> *const c_void,
  pub ptr: *const EventCallbackContextData,
}

struct EventCallbackContextData {
  executing_context_ptr: *const OpaquePtr,
  executing_context_method_pointer: *const ExecutingContextRustMethods,
  func: EventListenerCallback,
}

impl Drop for EventCallbackContextData {
  fn drop(&mut self) {
    println!("Drop event callback context data");
  }
}

pub trait RustMethods {}


enum EventTargetType {
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

pub type EventListenerCallback = Box<dyn Fn(&Event)>;

// Define the callback function
extern "C" fn handle_event_listener_callback(
  event_callback_context_ptr: *const OpaquePtr,
  event_ptr: *const OpaquePtr,
  event_method_pointer: *const EventRustMethods,
  status: *const RustValueStatus,
  exception_state: *const OpaquePtr,
) -> *const c_void {
  // Reconstruct the Box and drop it to free the memory
  let event_callback_context = unsafe {
    &(*(event_callback_context_ptr as *mut EventCallbackContext))
  };
  let callback_context_data = unsafe {
    &(*(event_callback_context.ptr as *mut EventCallbackContextData))
  };

  unsafe {
    let func = &(*callback_context_data).func;
    let callback_data = &(*callback_context_data);
    let executing_context = ExecutingContext::initialize(callback_data.executing_context_ptr, callback_data.executing_context_method_pointer);
    let event = Event::initialize(event_ptr, &executing_context, event_method_pointer, status);
    func(&event);
  }

  std::ptr::null()
}

extern "C" fn handle_callback_data_free(event_callback_context_ptr: *const OpaquePtr) -> *const c_void {
  unsafe {
    let event_callback_context = &(*(event_callback_context_ptr as *mut EventCallbackContext));
    let _ = Box::from_raw(event_callback_context.ptr as *mut EventCallbackContextData);
  }
  std::ptr::null()
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
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_context_data);
    let callback_context = Box::new(EventCallbackContext { callback: handle_event_listener_callback, free_ptr: handle_callback_data_free, ptr: callback_context_data_ptr });
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
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_context_data);
    let callback_context = Box::new(EventCallbackContext { callback: handle_event_listener_callback, free_ptr: handle_callback_data_free, ptr: callback_context_data_ptr });
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
      ((*self.method_pointer).dispatch_event)(self.ptr, event.ptr, exception_state.ptr)
    }
  }

  pub fn as_node(&self) -> Result<Node, &str> {
    let raw_ptr = unsafe {
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Node)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Node type.");
    }
    Ok(Node::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const NodeRustMethods, raw_ptr.status))
  }

  pub fn as_element(&self) -> Result<Element, &str> {
    let raw_ptr = unsafe {
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Element)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Element type.");
    }
    Ok(Element::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const ElementRustMethods, raw_ptr.status))
  }

  pub fn as_container_node(&self) -> Result<ContainerNode, &str> {
    let raw_ptr = unsafe {
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::ContainerNode)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the ContainerNode type.");
    }
    Ok(ContainerNode::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const ContainerNodeRustMethods, raw_ptr.status))
  }

  pub fn as_window(&self) -> Result<Window, &str> {
    let raw_ptr = unsafe {
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Window)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Window type.");
    }
    Ok(Window::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const WindowRustMethods, raw_ptr.status))
  }

  pub fn as_document(&self) -> Result<Document, &str> {
    let raw_ptr = unsafe {
      ((*self.method_pointer).dynamic_to)(self.ptr, EventTargetType::Document)
    };
    if (raw_ptr.value == std::ptr::null()) {
      return Err("The type value of event_target does not belong to the Document type.");
    }
    Ok(Document::initialize(raw_ptr.value, self.context, raw_ptr.method_pointer as *const DocumentRustMethods, raw_ptr.status))
  }

  pub fn as_html_element(&self) -> Result<HTMLElement, &str> {
    let raw_ptr = unsafe {
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