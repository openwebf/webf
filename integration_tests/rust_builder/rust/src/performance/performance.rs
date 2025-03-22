use webf_sys::{ExecutingContext, NativeValue, PerformanceMarkOptions, TimeoutCallback};
use webf_test_macros::{webf_test_callback, webf_test};
use webf_test_utils::{callback_runner::TestDone, common::TestCaseMetadata};

#[webf_test]
pub fn test_time_origin(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let performance = context.performance();
  let time_origin = performance.time_origin();
  assert!(time_origin > 0);
}

#[webf_test_callback]
pub async fn test_now(_metadata: TestCaseMetadata, context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let context_clone = context.clone();
  let performance = context.performance();
  let exception_state = context.create_exception_state();

  let now = performance.now(&exception_state).unwrap();

  let callback: TimeoutCallback = Box::new(move || {
    let exception_state = context_clone.create_exception_state();
    let current = performance.now(&exception_state).unwrap();
    assert!(current - now >= 300);
    set_done();
  });

  context.set_timeout_with_callback_and_timeout(callback, 300, &exception_state).unwrap();

  done_future.await.unwrap();
}

#[webf_test]
pub fn test_clear_marks(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let performance = context.performance();
  let exception_state = context.create_exception_state();
  let now = performance.now(&exception_state).unwrap();
  let options = PerformanceMarkOptions {
    detail: NativeValue::new_null(),
    start_time: now as f64,
  };

  performance.mark("abc", &options, &exception_state).unwrap();
  performance.mark("efg", &options, &exception_state).unwrap();

  let entries = performance.get_entries(&exception_state).unwrap();
  let has_abc = entries.iter().any(|entry| entry.name() == "abc");
  let has_efg = entries.iter().any(|entry| entry.name() == "efg");
  assert!(has_abc);
  assert!(has_efg);

  performance.clear_marks("abc", &exception_state).unwrap();

  let entries = performance.get_entries(&exception_state).unwrap();
  let has_abc = entries.iter().any(|entry| entry.name() == "abc");
  let has_efg = entries.iter().any(|entry| entry.name() == "efg");
  assert!(!has_abc);
  assert!(has_efg);

  performance.clear_marks("efg", &exception_state).unwrap();
}
