use webf_sys::{ExecutingContext, NativeValue, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{common::TestCaseMetadata, snapshot::snapshot_with_filename};

#[webf_test_async]
pub async fn test_headings_default_margin(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div = document.create_element("div", NativeValue::new_null(),  &exception_state).unwrap();

  let h1 = document.create_element("h1", NativeValue::new_null(), &exception_state).unwrap();
  let h2 = document.create_element("h2", NativeValue::new_null(), &exception_state).unwrap();
  let h3 = document.create_element("h3", NativeValue::new_null(), &exception_state).unwrap();
  let h4 = document.create_element("h4", NativeValue::new_null(), &exception_state).unwrap();
  let h5 = document.create_element("h5", NativeValue::new_null(), &exception_state).unwrap();
  let h6 = document.create_element("h6", NativeValue::new_null(), &exception_state).unwrap();

  let h1_text = document.create_text_node("Heading 1", &exception_state).unwrap();
  let h2_text = document.create_text_node("Heading 2", &exception_state).unwrap();
  let h3_text = document.create_text_node("Heading 3", &exception_state).unwrap();
  let h4_text = document.create_text_node("Heading 4", &exception_state).unwrap();
  let h5_text = document.create_text_node("Heading 5", &exception_state).unwrap();
  let h6_text = document.create_text_node("Heading 6", &exception_state).unwrap();

  h1.append_child(&h1_text.as_node(), &exception_state).unwrap();
  h2.append_child(&h2_text.as_node(), &exception_state).unwrap();
  h3.append_child(&h3_text.as_node(), &exception_state).unwrap();
  h4.append_child(&h4_text.as_node(), &exception_state).unwrap();
  h5.append_child(&h5_text.as_node(), &exception_state).unwrap();
  h6.append_child(&h6_text.as_node(), &exception_state).unwrap();

  div.append_child(&h1.as_node(), &exception_state).unwrap();
  div.append_child(&h2.as_node(), &exception_state).unwrap();
  div.append_child(&h3.as_node(), &exception_state).unwrap();
  div.append_child(&h4.as_node(), &exception_state).unwrap();
  div.append_child(&h5.as_node(), &exception_state).unwrap();
  div.append_child(&h6.as_node(), &exception_state).unwrap();

  document.body().append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}
