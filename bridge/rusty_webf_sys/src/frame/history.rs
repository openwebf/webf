/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use serde_json::Value;

use crate::*;

pub struct History {
  context: *const ExecutingContext,
}

impl History {
  pub fn initialize(context: *const ExecutingContext) -> History {
    History {
      context,
    }
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn length(&self, exception_state: &ExceptionState) -> i64 {
    let length = self.context().webf_invoke_module("History", "length", exception_state).unwrap();
    length.to_int64()
  }

  pub fn state(&self, exception_state: &ExceptionState) -> Value {
    let state_string = self.context().webf_invoke_module("History", "state", exception_state).unwrap();
    state_string.to_json()
  }

  pub fn back(&self, exception_state: &ExceptionState) {
    self.context().webf_invoke_module("History", "back", exception_state);
  }

  pub fn forward(&self, exception_state: &ExceptionState) {
    self.context().webf_invoke_module("History", "forward", exception_state);
  }

  pub fn go(&self, delta: Option<i64>, exception_state: &ExceptionState) {
    let delta_string = match delta {
      Some(delta) => NativeValue::new_int64(delta),
      None => NativeValue::new_null(),
    };
    self.context().webf_invoke_module_with_params("History", "go", &delta_string, exception_state);
  }

  pub fn push_state(&self, state: &str, title: &str, exception_state: &ExceptionState) {
    let state_value = NativeValue::new_json(state);
    let title_string = NativeValue::new_string(title);
    let params_vec = vec![state_value, title_string, NativeValue::new_null()];
    let params = NativeValue::new_list(params_vec);

    self.context().webf_invoke_module_with_params("History", "pushState", &params, exception_state);
  }

  pub fn push_state_with_url(&self, state: &str, title: &str, url: &str, exception_state: &ExceptionState) {
    let state_value = NativeValue::new_json(state);
    let title_string = NativeValue::new_string(title);
    let url_string = NativeValue::new_string(url);
    let params_vec = vec![state_value, title_string, url_string];
    let params = NativeValue::new_list(params_vec);

    self.context().webf_invoke_module_with_params("History", "pushState", &params, exception_state);
  }

  pub fn replace_state(&self, state: &str, title: &str, exception_state: &ExceptionState) {
    let state_value = NativeValue::new_json(state);
    let title_string = NativeValue::new_string(title);
    let params_vec = vec![state_value, title_string];
    let params = NativeValue::new_list(params_vec);

    self.context().webf_invoke_module_with_params("History", "replaceState", &params, exception_state);
  }

  pub fn replace_state_with_url(&self, state: &str, title: &str, url: &str, exception_state: &ExceptionState) {
    let state_value = NativeValue::new_json(state);
    let title_string = NativeValue::new_string(title);
    let url_string = NativeValue::new_string(url);
    let params_vec = vec![state_value, title_string, url_string];
    let params = NativeValue::new_list(params_vec);

    self.context().webf_invoke_module_with_params("History", "replaceState", &params, exception_state);
  }
}
