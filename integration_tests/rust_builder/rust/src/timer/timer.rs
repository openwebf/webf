use std::{cell::RefCell, rc::Rc, time::{SystemTime, UNIX_EPOCH}};
use webf_sys::{ExecutingContext, IntervalCallback, RequestAnimationFrameCallback, TimeoutCallback};
use webf_test_macros::webf_test_callback;
use webf_test_utils::callback_runner::TestDone;

#[webf_test_callback]
pub async fn test_resolve_after_100ms(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let start_time = SystemTime::now()
    .duration_since(UNIX_EPOCH)
    .unwrap()
    .as_millis();

  let exception_state = context.create_exception_state();
  let callback: TimeoutCallback = Box::new(move || {
    let end_time = SystemTime::now()
      .duration_since(UNIX_EPOCH)
      .unwrap()
      .as_millis();
    let elapsed = end_time - start_time;
    assert!(elapsed - 100 <= 100);
    set_done();
  });

  context.set_timeout_with_callback_and_timeout(callback, 100, &exception_state).unwrap();

  done_future.await.unwrap();
}

#[webf_test_callback]
pub async fn test_stop_before_resolved(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;

  let exception_state = context.create_exception_state();
  let callback1: TimeoutCallback = Box::new(move || {
    panic!("This should not be called");
  });
  let timeout_id = context.set_timeout_with_callback_and_timeout(callback1, 100, &exception_state).unwrap();

  let callback2: TimeoutCallback = Box::new(move || {
    set_done();
  });
  context.set_timeout_with_callback_and_timeout(callback2, 120, &exception_state).unwrap();

  let context_clone = context.clone();
  let callback3: TimeoutCallback = Box::new(move || {
    let exception_state = context_clone.create_exception_state();
    context_clone.clear_timeout(timeout_id, &exception_state);
  });
  context.set_timeout_with_callback_and_timeout(callback3, 50, &exception_state).unwrap();

  done_future.await.unwrap();
}

#[webf_test_callback]
pub async fn test_trigger_5_times_and_stop(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();

  let count = Rc::new(RefCell::new(0));

  let interval_id_ref = Rc::new(RefCell::new(0));

  let context_clone = context.clone();
  let count_clone = count.clone();
  let interval_id_clone = interval_id_ref.clone();

  let interval_callback: IntervalCallback = Box::new(move || {
    let mut count_value = count_clone.borrow_mut();
    *count_value += 1;

    if *count_value > 5 {
      // 当计数达到5次后，清除间隔定时器
      let exception_state = context_clone.create_exception_state();
      let interval_id = *interval_id_clone.borrow();
      context_clone.clear_interval(interval_id, &exception_state);
      set_done();
    }
  });

  let interval_id = context.set_interval_with_callback_and_timeout(interval_callback, 10, &exception_state).unwrap();

  *interval_id_ref.borrow_mut() = interval_id;

  let timeout_callback: TimeoutCallback = Box::new(move || {
    panic!("setInterval execute time out!");
  });
  context.set_timeout_with_callback_and_timeout(timeout_callback, 200, &exception_state).unwrap();

  done_future.await.unwrap();
}

#[webf_test_callback]
pub async fn test_request_animation_frame_with_timestamp(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();

  let callback: RequestAnimationFrameCallback = Box::new(move |timestamp| {
    assert!(timestamp > 0.0);
    set_done();
  });

  context.window().request_animation_frame(callback, &exception_state).unwrap();

  done_future.await.unwrap();
}

#[webf_test_callback]
pub async fn test_clear_timeout(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();

  let fail_callback: TimeoutCallback = Box::new(move || {
    panic!("clearTimeout not works.");
  });

  let timer_id = context.set_timeout_with_callback_and_timeout(fail_callback, 200, &exception_state).unwrap();
  context.clear_timeout(timer_id, &exception_state);

  let success_callback: TimeoutCallback = Box::new(move || {
    set_done();
  });
  context.set_timeout_with_callback_and_timeout(success_callback, 250, &exception_state).unwrap();

  done_future.await.unwrap();
}
