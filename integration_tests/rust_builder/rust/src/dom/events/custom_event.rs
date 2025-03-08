use webf_sys::{CustomEventInit, ExecutingContext, NativeValue};
use webf_test_macros::webf_test;

#[webf_test]
pub fn it_should_work_as_expected(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let detail = NativeValue::new_string("detailMessage");
  let custom_event_init = CustomEventInit {
    bubbles: 0,
    cancelable: 0,
    composed: 1,
    detail,
  };

  let custom_event = context.create_custom_event_with_options(
    "customEvent", &custom_event_init, &exception_state).unwrap();

  let detail_property = custom_event.detail(&exception_state).to_string();
  assert_eq!(detail_property, "detailMessage");
}
