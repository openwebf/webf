use std::cell::RefCell;
use std::ffi::c_void;
use std::rc::Rc;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, ExecutingContext, FutureRuntime, RustValue};

pub mod async_storage;
pub mod navigator;
pub mod storage;

#[no_mangle]
pub extern "C" fn init_webf_test_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  let context: ExecutingContext = initialize_webf_api(handle);
  let context_async = context.clone();

  webf_test_utils::sync_runner::run_tests(context);

  let runtime = Rc::new(RefCell::new(FutureRuntime::new()));

  let context_async_runtime = context_async.clone();
  runtime.borrow_mut().spawn(async move {
    webf_test_utils::async_runner::run_tests(context_async_runtime).await;
  });

  let runtime_run_task_callback = Box::new(move || {
    runtime.borrow_mut().run();
  });

  let exception_state = context_async.create_exception_state();
  context_async.set_run_rust_future_tasks(runtime_run_task_callback, &exception_state).unwrap();

  std::ptr::null_mut()
}
