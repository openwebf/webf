use webf_sys::{ExecutingContext, NativeValue, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{common::TestCaseMetadata, snapshot::snapshot_with_filename};

#[webf_test_async]
pub async fn test_should_work_with_set_property(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div = document.create_element("div", &exception_state).unwrap();
  let div_style = div.style();
  div_style.set_property("width", NativeValue::new_string("100px"), &exception_state).unwrap();
  div_style.set_property("height", NativeValue::new_string("100px"), &exception_state).unwrap();
  div_style.set_property("background", NativeValue::new_string("red"), &exception_state).unwrap();

  assert_eq!(div_style.get_property_value("width", &exception_state).unwrap(), "100px");
  assert_eq!(div_style.get_property_value("height", &exception_state).unwrap(), "100px");

  let body = document.body();
  body.append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context.clone(), metadata.snapshot_filename).await.unwrap();
}

#[webf_test_async]
pub async fn test_should_work_with_remove_property(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div = document.create_element("div", &exception_state).unwrap();
  let div_style = div.style();
  div_style.set_property("width", NativeValue::new_string("100px"), &exception_state).unwrap();
  div_style.set_property("height", NativeValue::new_string("100px"), &exception_state).unwrap();
  div_style.set_property("background", NativeValue::new_string("red"), &exception_state).unwrap();

  let body = document.body();
  body.append_child(&div.as_node(), &exception_state).unwrap();

  let snapshot1 = metadata.snapshot_filename.clone() + "1";
  snapshot_with_filename(context.clone(), snapshot1).await.unwrap();

  assert_eq!(div_style.get_property_value("width", &exception_state).unwrap(), "100px");
  assert_eq!(div_style.get_property_value("height", &exception_state).unwrap(), "100px");

  div_style.remove_property("width", &exception_state).unwrap();
  div_style.remove_property("height", &exception_state).unwrap();

  assert_eq!(div_style.get_property_value("width", &exception_state).unwrap(), "");
  assert_eq!(div_style.get_property_value("height", &exception_state).unwrap(), "");

  let text_node = document.create_text_node("1234", &exception_state).unwrap();
  div.append_child(&text_node.as_node(), &exception_state).unwrap();

  let snapshot2 = metadata.snapshot_filename + "2";
  snapshot_with_filename(context.clone(), snapshot2).await.unwrap();
}
