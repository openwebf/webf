use std::ffi::c_void;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, ExecutingContext, RustValue};

pub mod navigator;
pub mod storage;

fn webf_test_runner(tests: &[&dyn Fn(ExecutingContext)], context: ExecutingContext) {
  println!("Running {} tests", tests.len());
  for test in tests {
    test(context.clone());
    println!("Test passed");
  }
}

#[no_mangle]
pub extern "C" fn init_webf_test_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  let context = initialize_webf_api(handle);

  let tests: &[&dyn Fn(ExecutingContext)] = &[
    &navigator::navigator::test_user_agent,
    &navigator::navigator::test_hardware_concurrency,
    &storage::set::test_local_storage_method_access,
    &storage::set::test_session_storage_method_access,
  ];

  webf_test_runner(tests, context);

  std::ptr::null_mut()
}
