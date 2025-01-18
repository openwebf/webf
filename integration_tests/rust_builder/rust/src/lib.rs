use std::ffi::c_void;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, ExecutingContext, RustValue};

fn test_user_agent(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let ua_string = navigator.user_agent(&exception_state);

  assert!(ua_string.contains("WebF"));
}

fn test_hardware_concurrency(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let hardware_concurrency = navigator.hardware_concurrency(&exception_state);

  assert!(hardware_concurrency > 0);
}

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
    &test_user_agent,
    &test_hardware_concurrency,
  ];

  webf_test_runner(tests, context);

  std::ptr::null_mut()
}
