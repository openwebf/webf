mod dom;
mod test_runner;
mod window;

use std::ffi::{c_void};
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, RustValue};
use crate::test_runner::TestRunner;

#[no_mangle]
pub extern "C" fn init_webf_test_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  let context = initialize_webf_api(handle);

  TestRunner::exec_test(&context);

  std::ptr::null_mut()
}