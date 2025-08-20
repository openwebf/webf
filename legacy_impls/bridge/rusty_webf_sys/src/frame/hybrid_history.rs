/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use serde_json::Value;

use crate::*;

pub struct HybridHistory {
  context: *const ExecutingContext,
}

impl HybridHistory {
  pub fn initialize(context: *const ExecutingContext) -> HybridHistory {
    HybridHistory {
      context,
    }
  }

  pub fn context<'a>(&self) -> &'a ExecutingContext {
    assert!(!self.context.is_null(), "Context PTR must not be null");
    unsafe { &*self.context }
  }

  pub fn state(&self, exception_state: &ExceptionState) -> Value {
    let state_string = self.context().webf_invoke_module("HybridHistory", "state", exception_state).unwrap();
    state_string.to_json()
  }

  pub fn back(&self, exception_state: &ExceptionState) {
    self.context().webf_invoke_module("HybridHistory", "back", exception_state);
  }

  pub fn push_state(&self, state: &str, name: &str, exception_state: &ExceptionState) {
    let state_value = NativeValue::new_json(state);
    let name_string = NativeValue::new_string(name);
    let params_vec = vec![state_value, name_string];
    let params = NativeValue::new_list(params_vec);

    self.context().webf_invoke_module_with_params("HybridHistory", "pushState", &params, exception_state);
  }

}
