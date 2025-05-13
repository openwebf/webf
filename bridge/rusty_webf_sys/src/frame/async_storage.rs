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

  pub fn get_item(&self, key: &str, exception_state: &ExceptionState) -> WebFNativeFuture<String> {
    let key_string = NativeValue::new_list(vec![
      NativeValue::new_string(key)
    ]);
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
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "getItem", &key_string, general_callback, exception_state).unwrap();
    future_for_return
  }

  pub fn set_item(&self, key: &str, value: &str, exception_state: &ExceptionState) -> WebFNativeFuture<String> {
    let key_string = NativeValue::new_string(key);
    let value_string = NativeValue::new_string(value);
    let future_for_return = WebFNativeFuture::<String>::new();
    let future_in_callback = future_for_return.clone();
    let params_vec = vec![key_string, value_string];
    let params = NativeValue::new_list(params_vec);
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let result = unsafe { (*argv.wrapping_add(1)).clone() };
        let result = result.to_string();
        future_in_callback.set_result(Ok(Some(result)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "setItem", &params, general_callback, exception_state).unwrap();
    future_for_return
  }

  pub fn remove_item(&self, key: &str, exception_state: &ExceptionState) -> WebFNativeFuture<bool> {
    let key_string = NativeValue::new_list(vec![
      NativeValue::new_string(key)
    ]);
    let future_for_return = WebFNativeFuture::<bool>::new();
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
        let item_string = item_string.to_string();
        future_in_callback.set_result(Ok(Some(item_string == "true")));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "removeItem", &key_string, general_callback, exception_state).unwrap();
    future_for_return
  }

  pub fn clear(&self, exception_state: &ExceptionState) -> WebFNativeFuture<bool> {
    let params = NativeValue::new_list(vec![]);
    let future_for_return = WebFNativeFuture::<bool>::new();
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
        let item_string = item_string.to_string();
        future_in_callback.set_result(Ok(Some(item_string == "true")));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "clear", &params, general_callback, exception_state).unwrap();
    future_for_return
  }

  pub fn get_all_keys(&self, exception_state: &ExceptionState) -> WebFNativeFuture<Vec<String>> {
    let params = NativeValue::new_list(vec![]);
    let future_for_return = WebFNativeFuture::<Vec<String>>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let item_keys = unsafe { (*argv.wrapping_add(1)).clone() };
        let item_keys = item_keys.to_list().iter().map(|x| x.to_string()).collect::<Vec<_>>();
        future_in_callback.set_result(Ok(Some(item_keys)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "getAllKeys", &params, general_callback, exception_state).unwrap();
    future_for_return
  }

  pub fn length(&self, exception_state: &ExceptionState) -> WebFNativeFuture<i64> {
    let params = NativeValue::new_list(vec![]);
    let future_for_return = WebFNativeFuture::<i64>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let length_value = unsafe { (*argv.wrapping_add(1)).clone() };
        let length_value = length_value.to_int64();
        future_in_callback.set_result(Ok(Some(length_value)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });
    self.context().webf_invoke_module_with_params_and_callback("AsyncStorage", "length", &params, general_callback, exception_state).unwrap();
    future_for_return
  }
}
