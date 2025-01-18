use webf_sys::ExecutingContext;

pub fn test_hardware_concurrency(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let hardware_concurrency = navigator.hardware_concurrency(&exception_state);

  assert!(hardware_concurrency > 0);
}

pub fn test_user_agent(context: ExecutingContext) {
  let navigator = context.navigator();
  let exception_state = context.create_exception_state();
  let ua_string = navigator.user_agent(&exception_state);

  assert!(ua_string.contains("WebF"));
}
