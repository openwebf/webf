use std::{future::Future, pin::Pin, sync::{Arc, Mutex}};
use webf_sys::ExecutingContext;
use std::sync::LazyLock;
use crate::common::spec_done;

type TestFn = Arc<Box<dyn Fn(ExecutingContext) -> Pin<Box<dyn Future<Output = ()>>> + 'static + Sync + Send>>;

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
    (test_case.test_fn)(context.clone()).await;
    println!("\x1b[32mPASS: \x1b[0m{}::{} ", mod_path, test_case.test_name);
    spec_done(context.clone());
  }
}
