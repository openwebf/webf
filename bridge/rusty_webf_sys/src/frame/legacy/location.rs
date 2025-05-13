/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use crate::*;

pub struct Location {
  context: *const ExecutingContext,
}

impl Location {
  pub fn initialize(context: *const ExecutingContext) -> Location {
    Location {
      context
    }
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn href(&self, exception_state: &ExceptionState) -> String {
    let href_string = self.context().webf_invoke_module("Location", "href", exception_state).unwrap();
    href_string.to_string()
  }

  pub fn set_href(&self, href: &str, exception_state: &ExceptionState) {
    let href_string_native_value = NativeValue::new_list(vec![
      NativeValue::new_string(href)
    ]);
    self.context().webf_invoke_module_with_params("Navigation", "goTo", &href_string_native_value, exception_state);
  }

  pub fn origin(&self, exception_state: &ExceptionState) -> String {
    let origin_string = self.context().webf_invoke_module("Location", "origin", exception_state).unwrap();
    origin_string.to_string()
  }

  pub fn protocol(&self, exception_state: &ExceptionState) -> String {
    let protocol_string = self.context().webf_invoke_module("Location", "protocol", exception_state).unwrap();
    protocol_string.to_string()
  }

  pub fn host(&self, exception_state: &ExceptionState) -> String {
    let host_string = self.context().webf_invoke_module("Location", "host", exception_state).unwrap();
    host_string.to_string()
  }

  pub fn hostname(&self, exception_state: &ExceptionState) -> String {
    let hostname_string = self.context().webf_invoke_module("Location", "hostname", exception_state).unwrap();
    hostname_string.to_string()
  }

  pub fn port(&self, exception_state: &ExceptionState) -> String {
    let port_string = self.context().webf_invoke_module("Location", "port", exception_state).unwrap();
    port_string.to_string()
  }

  pub fn pathname(&self, exception_state: &ExceptionState) -> String {
    let pathname_string = self.context().webf_invoke_module("Location", "pathname", exception_state).unwrap();
    pathname_string.to_string()
  }

  pub fn search(&self, exception_state: &ExceptionState) -> String {
    let search_string = self.context().webf_invoke_module("Location", "search", exception_state).unwrap();
    search_string.to_string()
  }

  pub fn hash(&self, exception_state: &ExceptionState) -> String {
    let hash_string = self.context().webf_invoke_module("Location", "hash", exception_state).unwrap();
    hash_string.to_string()
  }

  pub fn assign(&self, url: &str, exception_state: &ExceptionState) {
    let url_string_native_value = NativeValue::new_list(vec![
      NativeValue::new_string(url)
    ]);
    self.context().webf_invoke_module_with_params("Navigation", "goTo", &url_string_native_value, exception_state);
  }

  pub fn reload(&self, exception_state: &ExceptionState) {
    self.context().webf_location_reload(exception_state);
  }

  pub fn replace(&self, url: &str, exception_state: &ExceptionState) {
    let url_string_native_value = NativeValue::new_list(vec![
      NativeValue::new_string(url)
    ]);
    self.context().webf_invoke_module_with_params("Navigation", "goTo", &url_string_native_value, exception_state);
  }

}
