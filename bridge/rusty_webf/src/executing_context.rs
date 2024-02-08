/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_char, c_double, c_void};
use std::ptr;
use libc;
use libc::c_uint;
use webf_sys::{OpaquePtr, RustValue};
use crate::document::{Document, DocumentRustMethods};
use crate::event_target::EventTargetMethods;
use crate::exception_state::{ExceptionState, ExceptionStateRustMethods};
use crate::window::{Window, WindowRustMethods};

#[repr(C)]
pub struct ExecutingContextRustMethods {
  pub version: c_double,
  pub get_document: extern "C" fn(*const OpaquePtr) -> RustValue<DocumentRustMethods>,
  pub get_window: extern "C" fn(*const OpaquePtr) -> RustValue<WindowRustMethods>,
  pub create_exception_state: extern "C" fn() -> RustValue<ExceptionStateRustMethods>,
}

/// An environment contains all the necessary running states of a web page.
///
/// For Flutter apps, there could be many web pages running in the same Dart environment,
/// and each web page is isolated with its own DOM tree, layout state, and JavaScript running environment.
///
/// In the Rust world, Rust code plays the same role as JavaScript,
/// so the Rust running states also live in the ExecutionContext class.
///
/// Since both JavaScript and Rust run in the same environment,
/// the DOM tree and the underlying layout state are shared between Rust and JavaScript worlds.
/// it's possible to create an HTMLElement in Rust and remove it from JavaScript,
/// and even collaborate with each other to build an enormous application.
///
/// The relationship between Window, Document, and ExecutionContext is 1:1:1 at any point in time.
pub struct ExecutingContext {
  // The underlying pointer points to the actual implementation of ExecutionContext in the C++ world.
  pub ptr: *const OpaquePtr,
  // Methods available for export from the C++ world for use.
  method_pointer: *const ExecutingContextRustMethods,
}

impl ExecutingContext {
  pub fn initialize(ptr: *const OpaquePtr, method_pointer: *const ExecutingContextRustMethods) -> ExecutingContext {
    ExecutingContext {
      ptr,
      method_pointer
    }
  }

  /// Obtain the window instance from ExecutingContext.
  pub fn window(&self) -> Window {
    let result = unsafe {
      ((*self.method_pointer).get_window)(self.ptr)
    };
    return Window::initialize(result.value, result.method_pointer);
  }

  /// Obtain the document instance from ExecutingContext.
  pub fn document(&self) -> Document {
    let result = unsafe {
      ((*self.method_pointer).get_document)(self.ptr)
    };
    return Document::initialize::<DocumentRustMethods>(result.value, self, result.method_pointer);
  }

  pub fn create_exception_state(&self) -> ExceptionState {
    let result = unsafe {
      ((*self.method_pointer).create_exception_state)()
    };
    ExceptionState::initialize(result.value, result.method_pointer)
  }
}

