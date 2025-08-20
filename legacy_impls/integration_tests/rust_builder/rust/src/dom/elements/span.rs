use webf_sys::{ExecutingContext, NativeValue, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{common::TestCaseMetadata, snapshot::snapshot_with_filename};

#[webf_test_async]
pub async fn test_span_should_work_with_texts(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();
  let body = document.body();

  // Create first span with text
  let span = document.create_element("span", NativeValue::new_null(), &exception_state).unwrap();
  let text = document.create_text_node("hello world", &exception_state).unwrap();
  span.append_child(&text.as_node(), &exception_state).unwrap();

  // Set style properties for first span
  let span_style = span.style();
  span_style.set_property("font-size", NativeValue::new_string("80px"), &exception_state).unwrap();
  span_style.set_property("text-decoration", NativeValue::new_string("line-through"), &exception_state).unwrap();
  span_style.set_property("font-weight", NativeValue::new_string("bold"), &exception_state).unwrap();
  span_style.set_property("font-style", NativeValue::new_string("italic"), &exception_state).unwrap();
  span_style.set_property("font-family", NativeValue::new_string("arial"), &exception_state).unwrap();

  // Append first span to body
  body.append_child(&span.as_node(), &exception_state).unwrap();

  // Create second span with text
  let span2 = document.create_element("span", NativeValue::new_null(), &exception_state).unwrap();
  let text2 = document.create_text_node("hello world", &exception_state).unwrap();
  span2.append_child(&text2.as_node(), &exception_state).unwrap();

  // Set style properties for second span
  let span2_style = span2.style();
  span2_style.set_property("font-size", NativeValue::new_string("40px"), &exception_state).unwrap();
  span2_style.set_property("text-decoration", NativeValue::new_string("underline"), &exception_state).unwrap();
  span2_style.set_property("font-weight", NativeValue::new_string("lighter"), &exception_state).unwrap();
  span2_style.set_property("font-style", NativeValue::new_string("normal"), &exception_state).unwrap();
  span2_style.set_property("font-family", NativeValue::new_string("georgia"), &exception_state).unwrap();

  // Append second span to body
  body.append_child(&span2.as_node(), &exception_state).unwrap();

  // Take snapshot
  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}
