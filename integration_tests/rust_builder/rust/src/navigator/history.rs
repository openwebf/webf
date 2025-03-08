use webf_sys::{AddEventListenerOptions, Event, EventTargetMethods, ExecutingContext, WebFNativeFuture};
use webf_test_macros::{webf_test, webf_test_async};

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

#[webf_test_async]
pub async fn test_pop_state_event_will_trigger_when_navigate_back(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let location = context.location();
  let pathname = location.pathname(&exception_state);
  assert_eq!(pathname, "/public/core.build.js");

  let history = context.history();
  let json_str = r#"{"name": 2}"#;
  history.push_state_with_url(json_str, "", "/sample2", &exception_state);

  let done_future = WebFNativeFuture::<()>::new();
  let done_future_in_callback = done_future.clone();

  let on_pop_state_change = Box::new(move |event: &Event| {
    let context = event.context();
    let exception_state = context.create_exception_state();
    let event = event.as_pop_state_event().unwrap();
    let state = event.state();
    assert_eq!(state.is_null(), true);

    let location = context.location();
    let pathname = location.pathname(&exception_state);
    assert_eq!(pathname, "/public/core.build.js");

    done_future_in_callback.set_result(Ok(Some(())));
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
