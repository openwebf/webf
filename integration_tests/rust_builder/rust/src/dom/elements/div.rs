use webf_sys::{ExecutingContext, NativeValue, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{common::TestCaseMetadata, snapshot::snapshot_with_filename};

#[webf_test_async]
pub async fn test_div_basic(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div = document.create_element("div", &exception_state).unwrap();
  let div_style = div.style();
  div_style.set_property("width", NativeValue::new_string("300px"), &exception_state).unwrap();
  div_style.set_property("height", NativeValue::new_string("300px"), &exception_state).unwrap();
  div_style.set_property("background-color", NativeValue::new_string("red"), &exception_state).unwrap();

  let body = document.body();
  body.append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context.clone(), metadata.snapshot_filename).await.unwrap();
}
