use webf_sys::{ElementMethods, ExecutingContext, NativeValue, NodeMethods};
use std::fmt::Debug;

pub struct TestCaseMetadata {
  pub mod_path: String,
  pub source_file: String,
  pub test_name: String,
  pub snapshot_filename: String,
}

/// Checks if two values are equal without causing a panic
/// 
/// Returns true if values are equal, false otherwise.
/// On failure, prints an error message with the file, line, expected and actual values.
pub fn check_eq<T: PartialEq + Debug>(left: T, right: T, file: &str, line: u32) -> bool {
  if left != right {
    eprintln!("Assertion failed at {}:{}", file, line);
    eprintln!("Expected: {:?}", right);
    eprintln!("Got: {:?}", left);
    false
  } else {
    true
  }
}

/// Specialized version for String and &str comparison
pub fn check_eq_str(left: String, right: &str, file: &str, line: u32) -> bool {
  if left != right {
    eprintln!("Assertion failed at {}:{}", file, line);
    eprintln!("Expected: {:?}", right);
    eprintln!("Got: {:?}", left);
    false
  } else {
    true
  }
}

/// Macro wrapper for check_eq that automatically captures file and line info
// Make check_eq available at crate root to be used by the macro
#[doc(hidden)]
pub use self::check_eq as _check_eq;
#[doc(hidden)]
pub use self::check_eq_str as _check_eq_str;

#[macro_export]
macro_rules! safe_assert_eq {
  ($left:expr, $right:expr) => {
    $crate::_check_eq($left, $right, file!(), line!())
  };
}

fn clear_all_timer(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let callback = Box::new(|| {});
  let end_timer = context.set_timeout_with_callback(callback, &exception_state).unwrap();

  for timer in 1..=end_timer {
    context.clear_timeout(timer, &exception_state);
  }
}

fn reset_document_element(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let document = context.document();
  let document_element = document.document_element();
  document.remove_child(document_element.as_node(), &exception_state).unwrap();

  let html = document.create_element("html", &exception_state).unwrap();
  document.append_child(html.as_node(), &exception_state).unwrap();

  let document_element = document.document_element();
  let head = document.create_element("head", &exception_state).unwrap();
  document_element.append_child(head.as_node(), &exception_state).unwrap();
  let body = document.create_element("body", &exception_state).unwrap();
  document_element.append_child(body.as_node(), &exception_state).unwrap();

  let window = context.window();
  window.scroll_to_with_x_and_y(0.0, 0.0, &exception_state);

  document_element.style().set_property("background-color", NativeValue::new_string("white"), &exception_state).unwrap();
}

// @TODO: Implement this
// webf.methodChannel.clearMethodCallHandler();

fn clear_cookies(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let document = context.document();
  document.___clear_cookies__(&exception_state);
}

pub fn spec_done(context: ExecutingContext) {
  clear_all_timer(context.clone());
  reset_document_element(context.clone());
  clear_cookies(context.clone());
  context.__webf_sync_buffer__();
}
