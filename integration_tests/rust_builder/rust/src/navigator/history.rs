use webf_sys::{AddEventListenerOptions, Event, EventTargetMethods, ExecutingContext, WebFNativeFuture};
use webf_test_macros::{webf_test, webf_test_async, webf_test_callback};
use webf_test_utils::callback_runner::TestDone;

#[webf_test]
pub fn test_location_should_update_when_push_state(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_str = r#"{"name": 1}"#;
  history.push_state_with_url(json_str, "", "/sample", &exception_state);
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/sample");
  let state = history.state(&exception_state);
  let expected: serde_json::Value = serde_json::from_str(json_str).unwrap();
  assert_eq!(state, expected);

  history.back(&exception_state);
}

#[webf_test_callback]
pub async fn test_pop_state_event_will_trigger_when_navigate_back(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_str = r#"{"name": 2}"#;
  history.push_state_with_url(json_str, "", "/sample2", &exception_state);

  let on_pop_state_change = Box::new(move |event: &Event| {
    let context = event.context();
    let exception_state = context.create_exception_state();
    let event = event.as_pop_state_event().unwrap();
    let state = event.state(&exception_state);
    assert_eq!(state.is_null(), true);

    let location = context.location();
    let pathname = location.pathname(&exception_state);
    assert_eq!(pathname, "/public/core.build.js");

    set_done();
  });

  let event_listener_options = AddEventListenerOptions {
    passive: 0,
    once: 1,
    capture: 0,
  };

  let window = context.window();
  window.add_event_listener("popstate", on_pop_state_change, &event_listener_options, &exception_state).unwrap();

  let context_for_animation_frame = context.clone();
  let animation_frame_callback = Box::new(move |_time_stamp| {
    let context = context_for_animation_frame.clone();
    let exception_state = context.create_exception_state();
    history.back(&exception_state);
  });

  window.request_animation_frame(animation_frame_callback, &exception_state).unwrap();
  done_future.await.unwrap();
}

#[webf_test]
pub fn test_push_state_with_no_url_will_default_to_current_url(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_str = r#"{"name": 1}"#;
  history.push_state(json_str, "", &exception_state);
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");
  let state = history.state(&exception_state);
  let expected: serde_json::Value = serde_json::from_str(json_str).unwrap();
  assert_eq!(state, expected);

  history.back(&exception_state);
}

#[webf_test_callback]
pub async fn test_replace_state_should_work(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_state_1 = r#"{"name": 0}"#;
  history.replace_state(json_state_1, "", &exception_state);
  let json_state_2 = r#"{"name": 2}"#;
  history.push_state_with_url(json_state_2, "", "/sample2", &exception_state);

  let on_pop_state_change = Box::new(move |event: &Event| {
    let context = event.context();
    let exception_state = context.create_exception_state();
    let event = event.as_pop_state_event().unwrap();
    let state = event.state(&exception_state);
    let expected: serde_json::Value = serde_json::from_str(json_state_1).unwrap();
    assert_eq!(state.to_json(), expected);

    let location = context.location();
    let pathname = location.pathname(&exception_state);
    assert_eq!(pathname, "/public/core.build.js");

    set_done();
  });

  let event_listener_options = AddEventListenerOptions {
    passive: 0,
    once: 1,
    capture: 0,
  };

  let window = context.window();
  window.add_event_listener("popstate", on_pop_state_change, &event_listener_options, &exception_state).unwrap();
  let expected: serde_json::Value = serde_json::from_str(json_state_2).unwrap();
  let state = history.state(&exception_state);
  assert_eq!(state, expected);

  let context_for_animation_frame = context.clone();
  let animation_frame_callback = Box::new(move |_time_stamp| {
    let context = context_for_animation_frame.clone();
    let exception_state = context.create_exception_state();
    history.back(&exception_state);
  });

  window.request_animation_frame(animation_frame_callback, &exception_state).unwrap();
  done_future.await.unwrap();
}

#[webf_test_callback]
pub async fn test_go_back_should_work(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_state_1 = r#"{"name": 0}"#;
  history.replace_state(json_state_1, "", &exception_state);
  let json_state_2 = r#"{"name": 2}"#;
  history.push_state_with_url(json_state_2, "", "/sample2", &exception_state);

  let on_pop_state_change = Box::new(move |event: &Event| {
    let context = event.context();
    let exception_state = context.create_exception_state();
    let event = event.as_pop_state_event().unwrap();
    let state = event.state(&exception_state);
    let expected: serde_json::Value = serde_json::from_str(json_state_1).unwrap();
    assert_eq!(state.to_json(), expected);

    let location = context.location();
    let pathname = location.pathname(&exception_state);
    assert_eq!(pathname, "/public/core.build.js");

    set_done();
  });

  let event_listener_options = AddEventListenerOptions {
    passive: 0,
    once: 1,
    capture: 0,
  };

  let window = context.window();
  window.add_event_listener("popstate", on_pop_state_change, &event_listener_options, &exception_state).unwrap();
  let expected: serde_json::Value = serde_json::from_str(json_state_2).unwrap();
  let state = history.state(&exception_state);
  assert_eq!(state, expected);

  let context_for_animation_frame = context.clone();
  let animation_frame_callback = Box::new(move |_time_stamp| {
    let context = context_for_animation_frame.clone();
    let exception_state = context.create_exception_state();
    history.go(Some(-1), &exception_state);
  });

  window.request_animation_frame(animation_frame_callback, &exception_state).unwrap();
  done_future.await.unwrap();
}

#[webf_test_callback]
pub async fn test_hash_change_should_fire_when_history_back(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_state = r#"{"name": 2}"#;
  history.push_state_with_url(json_state, "", "#/page_1", &exception_state);

  let on_hash_change = Box::new(move |event: &Event| {
    let event = event.as_hashchange_event().unwrap();

    let parser = url_parse::core::Parser::new(None);
    let old_url = event.old_url();
    let old_anchor = parser.parse(&old_url).unwrap().anchor.unwrap();
    assert_eq!(old_anchor, "/page_1");

    let new_url = event.new_url();
    let new_anchor = parser.parse(&new_url).unwrap().anchor.unwrap();
    assert_eq!(new_anchor, "hash=hashValue");

    set_done();
  });

  let event_listener_options = AddEventListenerOptions {
    passive: 0,
    once: 1,
    capture: 0,
  };

  let window = context.window();
  window.add_event_listener("hashchange", on_hash_change, &event_listener_options, &exception_state).unwrap();

  let context_for_animation_frame = context.clone();
  let animation_frame_callback = Box::new(move |_time_stamp| {
    let context = context_for_animation_frame.clone();
    let exception_state = context.create_exception_state();
    history.back(&exception_state);
  });

  window.request_animation_frame(animation_frame_callback, &exception_state).unwrap();
  done_future.await.unwrap();
}

#[webf_test_callback]
pub async fn test_hash_change_when_go_back_should_work(context: ExecutingContext, done: TestDone) {
  let (done_future, set_done) = done;
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_state_1 = r#"{"name": 0}"#;
  history.replace_state(json_state_1, "", &exception_state);
  let json_state_2 = r#"{"name": 2}"#;
  history.push_state_with_url(json_state_2, "", "#/page_1", &exception_state);

  let on_hash_change = Box::new(move |event: &Event| {
    let event = event.as_hashchange_event().unwrap();

    let parser = url_parse::core::Parser::new(None);
    let old_url = event.old_url();
    let old_anchor = parser.parse(&old_url).unwrap().anchor.unwrap();
    assert_eq!(old_anchor, "/page_1");

    let new_url = event.new_url();
    let new_anchor = parser.parse(&new_url).unwrap().anchor.unwrap();
    assert_eq!(new_anchor, "hash=hashValue");

    set_done();
  });

  let event_listener_options = AddEventListenerOptions {
    passive: 0,
    once: 1,
    capture: 0,
  };

  let window = context.window();
  window.add_event_listener("hashchange", on_hash_change, &event_listener_options, &exception_state).unwrap();

  let context_for_animation_frame = context.clone();
  let animation_frame_callback = Box::new(move |_time_stamp| {
    let context = context_for_animation_frame.clone();
    let exception_state = context.create_exception_state();
    history.go(Some(-1), &exception_state);
  });

  window.request_animation_frame(animation_frame_callback, &exception_state).unwrap();
  done_future.await.unwrap();
}
