/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use crate::*;

pub struct Navigator {
  context: *const ExecutingContext,
}

impl Navigator {
  pub fn initialize(context: *const ExecutingContext) -> Navigator {
    Navigator {
      context
    }
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn user_agent(&self, exception_state: &ExceptionState) -> String {
    let ua_string = self.context().webf_invoke_module("Navigator", "getUserAgent", exception_state).unwrap();
    ua_string.to_string()
  }

  pub fn platform(&self, exception_state: &ExceptionState) -> String {
    let platform_string = self.context().webf_invoke_module("Navigator", "getPlatform", exception_state).unwrap();
    platform_string.to_string()
  }

  pub fn language(&self, exception_state: &ExceptionState) -> String {
    let language_string = self.context().webf_invoke_module("Navigator", "getLanguage", exception_state).unwrap();
    language_string.to_string()
  }

  pub fn languages(&self, exception_state: &ExceptionState) -> String {
    let languages_string = self.context().webf_invoke_module("Navigator", "getLanguages", exception_state).unwrap();
    languages_string.to_string()
  }

  pub fn app_name(&self, exception_state: &ExceptionState) -> String {
    let app_name_string = self.context().webf_invoke_module("Navigator", "getAppName", exception_state).unwrap();
    app_name_string.to_string()
  }

  pub fn app_version(&self, exception_state: &ExceptionState) -> String {
    let app_version_string = self.context().webf_invoke_module("Navigator", "getAppVersion", exception_state).unwrap();
    app_version_string.to_string()
  }

  pub fn hardware_concurrency(&self, exception_state: &ExceptionState) -> i32 {
    let hardware_concurrency = self.context().webf_invoke_module("Navigator", "getHardwareConcurrency", exception_state).unwrap();
    let concurrency_string = hardware_concurrency.to_string();
    i32::from_str_radix(&concurrency_string, 10).unwrap()
  }
}
