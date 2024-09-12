/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::c_double;
use crate::container_node::{ContainerNode, ContainerNodeMethods};
use crate::element::{Element, ElementMethods, ElementRustMethods};
use crate::event::Event;
use crate::event_target::{AddEventListenerOptions, EventListenerCallback, EventTargetMethods, RustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::ExecutingContext;
use crate::node::{Node, NodeMethods};
use crate::OpaquePtr;

#[repr(C)]
pub struct HTMLElementRustMethods {
  pub version: c_double,
  pub element: ElementRustMethods,
}

pub struct HTMLElement {
  element: Element,
  method_pointer: *const HTMLElementRustMethods,
}

pub trait HTMLElementMethods: ElementMethods {}

impl ElementMethods for HTMLElement {}

impl ContainerNodeMethods for HTMLElement {}

impl NodeMethods for HTMLElement {
  fn append_child(&self, new_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.element.append_child(new_node, exception_state)
  }

  fn remove_child(&self, target_node: &Node, exception_state: &ExceptionState) -> Result<Node, String> {
    self.element.remove_child(target_node, exception_state)
  }

  fn as_node(&self) -> &Node {
    self.element.as_node()
  }
}

impl EventTargetMethods for HTMLElement {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T) -> Self where Self: Sized {
    unsafe {
      HTMLElement {
        element: Element::initialize(
          ptr,
          context,
          &(method_pointer as *const HTMLElementRustMethods).as_ref().unwrap().element,
        ),
        method_pointer: method_pointer as *const HTMLElementRustMethods,
      }
    }
  }

  fn ptr(&self) -> *const OpaquePtr {
    self.element.ptr()
  }

  fn add_event_listener(&self,
                        event_name: &str,
                        callback: EventListenerCallback,
                        options: &AddEventListenerOptions,
                        exception_state: &ExceptionState) -> Result<(), String> {
    self.element.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.element.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.element.dispatch_event(event, exception_state)
  }
}

impl HTMLElementMethods for HTMLElement {}
