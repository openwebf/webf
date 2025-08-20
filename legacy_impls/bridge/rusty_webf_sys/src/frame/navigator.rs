/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use crate::*;

pub struct Clipboard {
  context: *const ExecutingContext,
}

impl Clipboard {
  pub fn initialize(context: *const ExecutingContext) -> Clipboard {
    Clipboard {
      context
    }
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn read_text(&self, exception_state: &ExceptionState) -> WebFNativeFuture<String> {
    let params = NativeValue::new_null();
    let future_for_return = WebFNativeFuture::<String>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let item_string = unsafe { (*argv.wrapping_add(1)).clone() };
        if item_string.is_null() {
          future_in_callback.set_result(Ok(None));
          return NativeValue::new_null();
        }
        let item_string = item_string.to_string();
        future_in_callback.set_result(Ok(Some(item_string)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    self.context().webf_invoke_module_with_params_and_callback("Clipboard", "readText", &params, general_callback, exception_state).unwrap();
    future_for_return
  }

  pub fn write_text(&self, text: &str, exception_state: &ExceptionState) -> WebFNativeFuture<()> {
    let text_string = NativeValue::new_string(text);
    let future_for_return = WebFNativeFuture::<()>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        future_in_callback.set_result(Ok(None));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    self.context().webf_invoke_module_with_params_and_callback("Clipboard", "writeText", &text_string, general_callback, exception_state).unwrap();
    future_for_return
  }
}

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

  pub fn languages(&self, exception_state: &ExceptionState) -> Vec<String> {
    let languages_string = self.context().webf_invoke_module("Navigator", "getLanguages", exception_state).unwrap();
    let result = languages_string.to_json();
    let result = result.as_array().unwrap();
    let mut languages = Vec::new();
    for item in result {
      languages.push(item.to_string());
    }
    languages
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

  pub fn clipboard(&self) -> Clipboard {
    Clipboard::initialize(self.context)
  }
}
