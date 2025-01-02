/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use crate::*;

pub struct Storage {
  context: *const ExecutingContext,
  module_name: String,
}

impl Storage {
  pub fn initialize(context: *const ExecutingContext, module_name: &str) -> Storage {
    Storage {
      context,
      module_name: module_name.to_string(),
    }
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn get_item(&self, key: &str, exception_state: &ExceptionState) -> Result<Option<String>, String> {
    let key_string = NativeValue::new_string(key);
    let item_string = self.context().webf_invoke_module_with_params(&self.module_name, "getItem", &key_string, exception_state).unwrap();

    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }

    if item_string.is_null() {
      return Ok(None);
    }
    Ok(Some(item_string.to_string()))
  }

  pub fn set_item(&self, key: &str, value: &str, exception_state: &ExceptionState) -> Result<(), String> {
    let key_string = NativeValue::new_string(key);
    let value_string = NativeValue::new_string(value);
    let params_vec = vec![key_string, value_string];
    let params = NativeValue::new_list(params_vec);

    self.context().webf_invoke_module_with_params(&self.module_name, "setItem", &params, exception_state);

    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }

    Ok(())
  }

  pub fn remove_item(&self, key: &str, exception_state: &ExceptionState) -> Result<(), String> {
    let key_string = NativeValue::new_string(key);
    let result = self.context().webf_invoke_module_with_params(&self.module_name, "removeItem", &key_string, exception_state);

    if exception_state.has_exception() {
      return Err(exception_state.stringify(self.context()));
    }
    match result {
      Ok(result) => Ok(()),
      Err(err) => Err(err),
    }
  }

  pub fn clear(&self, exception_state: &ExceptionState) {
    self.context().webf_invoke_module(&self.module_name, "clear", exception_state);
  }

  pub fn key(&self, index: u32, exception_state: &ExceptionState) -> String {
    let index_string = NativeValue::new_int64(index.into());
    let key_string = self.context().webf_invoke_module_with_params(&self.module_name, "key", &index_string, exception_state).unwrap();
    key_string.to_string()
  }

  pub fn get_all_keys(&self, exception_state: &ExceptionState) -> Vec<String> {
    let result = self.context().webf_invoke_module(&self.module_name, "_getAllKeys", exception_state).unwrap();
    let result = result.to_list().iter().map(|item| item.to_string()).collect::<Vec<_>>();
    result
  }

  pub fn length(&self, exception_state: &ExceptionState) -> i64 {
    let length = self.context().webf_invoke_module(&self.module_name, "length", exception_state).unwrap();
    length.to_int64()
  }
}
