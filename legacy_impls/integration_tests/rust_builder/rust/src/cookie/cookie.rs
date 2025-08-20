use webf_sys::ExecutingContext;
use webf_test_macros::webf_test;
use webf_test_utils::common::TestCaseMetadata;

#[webf_test]
pub fn test_works_with_cookie_getter_and_setter(_metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let cookie = document.cookie(&exception_state);
  assert_eq!(cookie, "");

  document.set_cookie("name=oeschger", &exception_state);
  document.set_cookie("favorite_food=tripe", &exception_state);

  let cookie = document.cookie(&exception_state);
  assert_eq!(cookie, "name=oeschger; favorite_food=tripe");
}
