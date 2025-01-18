use std::cell::RefCell;
use std::ffi::c_void;
use std::future::Future;
use std::pin::Pin;
use std::rc::Rc;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, ExecutingContext, FutureRuntime, RustValue};

pub mod async_storage;
pub mod navigator;
pub mod storage;

fn webf_test_runner(tests: &[&dyn Fn(ExecutingContext)], context: ExecutingContext) {
  println!("Running {} tests", tests.len());
  for test in tests {
    test(context.clone());
    println!("Test passed");
  }
}

type TestFn = Box<dyn Fn(ExecutingContext) -> Pin<Box<dyn Future<Output = ()>>>>;

async fn webf_test_runner_async(tests: &[TestFn], context: ExecutingContext) {
  println!("Running {} tests", tests.len());
  for test in tests {
    test(context.clone()).await;
    println!("Test passed");
  }
}

#[no_mangle]
pub extern "C" fn init_webf_test_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  let context: ExecutingContext = initialize_webf_api(handle);
  let context_async = context.clone();

  let tests: &[&dyn Fn(ExecutingContext)] = &[
    &navigator::navigator::test_user_agent,
    &navigator::navigator::test_hardware_concurrency,
    &storage::set::test_local_storage_method_access,
    &storage::set::test_session_storage_method_access,
  ];

  webf_test_runner(tests, context);

  let runtime = Rc::new(RefCell::new(FutureRuntime::new()));

  let context_async_runtime = context_async.clone();
  runtime.borrow_mut().spawn(async move {
    let tests: &[TestFn] = &[
      Box::new(|context| {
        Box::pin(async_storage::async_storage::test_should_work_with_set_item(context))
      }),
    ];

    webf_test_runner_async(tests, context_async_runtime).await;
  });

  let runtime_run_task_callback = Box::new(move || {
    runtime.borrow_mut().run();
  });

  let exception_state = context_async.create_exception_state();
  context_async.set_run_rust_future_tasks(runtime_run_task_callback, &exception_state).unwrap();

  std::ptr::null_mut()
}
