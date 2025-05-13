use webf_sys::ExecutingContext;
use webf_test_macros::webf_test;
use webf_test_utils::common::TestCaseMetadata;
use webf_test_utils::safe_assert_eq;

#[webf_test]
pub fn test_works_with_cookie_getter_and_setter(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let cookie = document.cookie(&exception_state);
  safe_assert_eq!(cookie, "".to_string());

  document.set_cookie("name=oeschger", &exception_state);
  document.set_cookie("favorite_food=tripe", &exception_state);

  let cookie = document.cookie(&exception_state);
  safe_assert_eq!(cookie, "name=oeschger; favorite_food=tripe".to_string());
}
