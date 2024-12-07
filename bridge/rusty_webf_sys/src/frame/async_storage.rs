/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use crate::*;

pub type GetItemCallback = Box<dyn Fn(Result<Option<String>, String>)>;
pub type SetItemCallback = Box<dyn Fn(Result<Option<String>, String>)>;

pub struct AsyncStorage {
  context: *const ExecutingContext,
}

impl AsyncStorage {
  pub fn initialize(context: *const ExecutingContext) -> AsyncStorage {
    AsyncStorage {
      context,
    }
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn get_item(&self, key: &str, callback: GetItemCallback, exception_state: &ExceptionState) {
    let key_string = NativeValue::new_string(key);
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { *argv };
        let error_string = error_string.to_string();
        callback(Err(error_string));
        return;
      }
      if argc == 2 {
        let item_string = unsafe { *argv.wrapping_add(1) };
        if item_string.is_null() {
          callback(Ok(None));
          return;
        }
        let item_string = item_string.to_string();
        callback(Ok(Some(item_string)));
        return;
      }
      println!("Invalid argument count for timeout callback");
    });
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "getItem", &key_string, general_callback, exception_state).unwrap();
  }

  pub fn set_item(&self, key: &str, value: &str, callback: SetItemCallback, exception_state: &ExceptionState) {
    let key_string = NativeValue::new_string(key);
    let value_string = NativeValue::new_string(value);
    let params_vec = vec![key_string, value_string];
    let params = NativeValue::new_list(params_vec);
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { *argv };
        let error_string = error_string.to_string();
        callback(Err(error_string));
        return;
      }
      if argc == 2 {
        let result = unsafe { *argv.wrapping_add(1) };
        let result = result.to_string();
        callback(Ok(Some(result)));
        return;
      }
      println!("Invalid argument count for timeout callback");
    });
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "setItem", &params, general_callback, exception_state).unwrap();
  }
}
