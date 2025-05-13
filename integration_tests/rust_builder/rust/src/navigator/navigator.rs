use webf_sys::ExecutingContext;
use webf_test_macros::{webf_test, webf_test_async};
use webf_test_utils::common::{TestCaseMetadata, check_eq};
use webf_test_utils::safe_assert_eq;

#[webf_test]
pub fn test_hardware_concurrency(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let hardware_concurrency = navigator.hardware_concurrency(&exception_state);

  if hardware_concurrency <= 0 {
    eprintln!("Assertion failed at {}:{}", file!(), line!());
    eprintln!("Expected hardware_concurrency > 0, got {}", hardware_concurrency);
  }
}

#[webf_test]
pub fn test_platform(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let platform = navigator.platform(&exception_state);

  if platform.len() <= 0 {
    eprintln!("Assertion failed at {}:{}", file!(), line!());
    eprintln!("Expected platform.len() > 0, got empty string");
  }
}

#[webf_test]
pub fn test_app_name(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let app_name = navigator.app_name(&exception_state);

  safe_assert_eq!(app_name, "WebF".to_string());
}

#[webf_test]
pub fn test_app_version(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let app_version = navigator.app_version(&exception_state);

  if app_version.len() <= 0 {
    eprintln!("Assertion failed at {}:{}", file!(), line!());
    eprintln!("Expected app_version.len() > 0, got empty string");
  }
}

#[webf_test]
pub fn test_language(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let language = navigator.language(&exception_state);

  if language.len() <= 0 {
    eprintln!("Assertion failed at {}:{}", file!(), line!());
    eprintln!("Expected language.len() > 0, got empty string");
  }
}

#[webf_test]
pub fn test_languages(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let languages = navigator.languages(&exception_state);

  if languages.len() <= 0 {
    eprintln!("Assertion failed at {}:{}", file!(), line!());
    eprintln!("Expected languages.len() > 0, got empty array");
  } else if languages[0].len() <= 0 {
    eprintln!("Assertion failed at {}:{}", file!(), line!());
    eprintln!("Expected languages[0].len() > 0, got empty string");
  }
}

#[webf_test]
pub fn test_user_agent(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let ua_string = navigator.user_agent(&exception_state);

  if !ua_string.contains("WebF") {
    eprintln!("Assertion failed at {}:{}", file!(), line!());
    eprintln!("Expected ua_string to contain 'WebF', got '{}'", ua_string);
  }
}

#[webf_test_async]
pub async fn test_clipboard(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let clipboard = navigator.clipboard();

  let text = "Hello, World!";
  clipboard.write_text(text, &exception_state).await.unwrap();
  let result = clipboard.read_text(&exception_state).await.unwrap().unwrap();

  safe_assert_eq!(result, text.to_string());
}
