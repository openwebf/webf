use webf_sys::ExecutingContext;
use webf_test_macros::webf_test;

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
