use webf_sys::ExecutingContext;
use webf_test_macros::{webf_test, webf_test_async};

#[webf_test]
pub fn test_hardware_concurrency(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let hardware_concurrency = navigator.hardware_concurrency(&exception_state);

  assert!(hardware_concurrency > 0);
}

#[webf_test]
pub fn test_platform(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let platform = navigator.platform(&exception_state);

  assert!(platform.len() > 0);
}

#[webf_test]
pub fn test_app_name(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let app_name = navigator.app_name(&exception_state);

  assert_eq!(app_name, "WebF");
}

#[webf_test]
pub fn test_app_version(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let app_version = navigator.app_version(&exception_state);

  assert!(app_version.len() > 0);
}

#[webf_test]
pub fn test_language(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let language = navigator.language(&exception_state);

  assert!(language.len() > 0);
}

#[webf_test]
pub fn test_languages(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let languages = navigator.languages(&exception_state);

  assert!(languages.len() > 0);
  assert!(languages[0].len() > 0);
}

#[webf_test]
pub fn test_user_agent(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let ua_string = navigator.user_agent(&exception_state);

  assert!(ua_string.contains("WebF"));
}

#[webf_test_async]
pub async fn test_clipboard(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let clipboard = navigator.clipboard();

  let text = "Hello, World!";
  clipboard.write_text(text, &exception_state).await.unwrap();
  let result = clipboard.read_text(&exception_state).await.unwrap().unwrap();

  assert_eq!(result, text);
}
