use std::{future::Future, pin::Pin, sync::{Arc, Mutex}};
use md5::{Md5, Digest};
use webf_sys::{ExecutingContext, WebFNativeFuture};
use std::sync::LazyLock;
use crate::common::{spec_done, TestCaseMetadata};

type TestDoneSetter = Box<dyn Fn()>;
pub type TestDone = (WebFNativeFuture<()>, TestDoneSetter);
type TestFn = Arc<Box<dyn Fn(TestCaseMetadata, ExecutingContext, TestDone) -> Pin<Box<dyn Future<Output = ()>>> + 'static + Sync + Send>>;

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

    let mut hasher = Md5::new();
    let hash_string = format!("{}::{}", mod_path, test_case.test_name);
    hasher.update(hash_string.as_bytes());
    let test_hash = format!("{:x}", hasher.finalize()).chars().take(8).collect::<String>();

    let filepath = test_case.source_file.split("/")
      .skip(1)
      .collect::<Vec<_>>()
      .join("/");
    let snapshot_path = format!("snapshots/{}.{}", filepath, test_hash);

    let metadata = TestCaseMetadata {
      mod_path: mod_path.clone(),
      source_file: test_case.source_file.clone(),
      test_name: test_case.test_name.clone(),
      snapshot_filename: snapshot_path,
    };

    let done_future = WebFNativeFuture::<()>::new();
    let done_future_in_callback = done_future.clone();
    let set_done: TestDoneSetter = Box::new(move || {
      let done_future = done_future_in_callback.clone();
      done_future.set_result(Ok(Some(())));
    });
    let done = (done_future, set_done);

    (test_case.test_fn)(metadata, context.clone(), done).await;
    println!("\x1b[32mPASS: \x1b[0m{}::{} ", mod_path, test_case.test_name);
    spec_done(context.clone());
  }
}
