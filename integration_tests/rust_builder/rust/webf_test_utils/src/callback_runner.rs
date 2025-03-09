use std::{future::Future, pin::Pin, sync::{Arc, Mutex}};
use webf_sys::{ExecutingContext, WebFNativeFuture};
use std::sync::LazyLock;
use crate::common::spec_done;

type TestDoneSetter = Box<dyn Fn()>;
pub type TestDone = (WebFNativeFuture<()>, TestDoneSetter);
type TestFn = Arc<Box<dyn Fn(ExecutingContext, TestDone) -> Pin<Box<dyn Future<Output = ()>>> + 'static + Sync + Send>>;

struct TestCase {
  mod_path: String,
  source_file: String,
  test_name: String,
  test_fn: TestFn,
}

static TEST_CASES: LazyLock<Arc<Mutex<Vec<TestCase>>>> = LazyLock::new(|| Arc::new(Mutex::new(Vec::new())));

pub fn register_test_case(
  mod_path: String,
  source_file: String,
  test_name: String,
  test_fn: TestFn
) {
  let mut test_cases = TEST_CASES.lock().unwrap();
  test_cases.push(TestCase {
    mod_path,
    source_file,
    test_name,
    test_fn,
  });
}

pub async fn run_tests(context: ExecutingContext) {
  let test_cases = TEST_CASES.lock().unwrap();
  for test_case in test_cases.iter() {
    let mod_path = test_case.mod_path.split("::")
      // Skip the crate name
      .skip(1)
      .collect::<Vec<_>>()
      .join("::");
    let done_future = WebFNativeFuture::<()>::new();
    let done_future_in_callback = done_future.clone();
    let set_done: TestDoneSetter = Box::new(move || {
      let done_future = done_future_in_callback.clone();
      done_future.set_result(Ok(Some(())));
    });
    let done = (done_future, set_done);
    (test_case.test_fn)(context.clone(), done).await;
    println!("\x1b[32mPASS: \x1b[0m{}::{} ", mod_path, test_case.test_name);
    spec_done(context.clone());
  }
}
