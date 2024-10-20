/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_double, c_void};
use crate::container_node::{ContainerNode, ContainerNodeMethods, ContainerNodeRustMethods};
use crate::document::Document;
use crate::event::Event;
use crate::event_target::{AddEventListenerOptions, EventListenerCallback, EventTargetMethods, EventTargetRustMethods, RustMethods};
use crate::exception_state::ExceptionState;
use crate::executing_context::{ExecutingContext};
use crate::node::{Node, NodeMethods};
use crate::{OpaquePtr, RustValueStatus};

#[repr(C)]
pub struct ElementRustMethods {
  pub version: c_double,
  pub container_node: ContainerNodeRustMethods,
}

impl RustMethods for ElementRustMethods {}

enum ElementType {
  kHTMLDIVElement,
  kHTMLAnchorElement,
  kHTMLHeadElement,
  kHTMLBodyElement,
  kHTMLHTMLElement,
  kHTMLImageElement,
  kHTMLLinkElement,
  kHTMLScriptElement,
  kHTMLTemplateElement,
  kHTMLUnknownElement,
  kHTMLCanvasElement,
  kHTMLWidgetElement,
  kHTMLButtonElement,
  kHTMLFormElement,
  kHTMLInputElement,
  kHTMLTextAreaElement
}

pub struct Element {
  container_node: ContainerNode,
  method_pointer: *const ElementRustMethods,
}

impl Element {}

pub trait ElementMethods: ContainerNodeMethods {}

impl ContainerNodeMethods for Element {}

impl NodeMethods for Element {
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

impl EventTargetMethods for Element {
  fn initialize<T: RustMethods>(ptr: *const OpaquePtr, context: *const ExecutingContext, method_pointer: *const T, status: *const RustValueStatus) -> Self where Self: Sized {
    unsafe {
      Element {
        container_node: ContainerNode::initialize(
          ptr,
          context,
          &(method_pointer as *const ElementRustMethods).as_ref().unwrap().container_node,
          status
        ),
        method_pointer: method_pointer as *const ElementRustMethods,
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
    self.container_node.add_event_listener(event_name, callback, options, exception_state)
  }

  fn remove_event_listener(&self,
                           event_name: &str,
                           callback: EventListenerCallback,
                           exception_state: &ExceptionState) -> Result<(), String> {
    self.container_node.remove_event_listener(event_name, callback, exception_state)
  }

  fn dispatch_event(&self, event: &Event, exception_state: &ExceptionState) -> bool {
    self.container_node.dispatch_event(event, exception_state)
  }
}

impl ElementMethods for Element {}
