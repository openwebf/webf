use webf_sys::{ExecutingContext, NativeValue, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{common::TestCaseMetadata, dom_utils::create_element_with_style, snapshot::snapshot_with_filename};
use serde_json::json;

#[webf_test_async]
pub async fn test_br_basic(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let p = document.create_element("p", NativeValue::new_null(), &exception_state).unwrap();
  let text1 = document.create_text_node(" Hello World! ", &exception_state).unwrap();
  let br = document.create_element("br", NativeValue::new_null(), &exception_state).unwrap();
  let text2 = document.create_text_node(" 你好，世界！", &exception_state).unwrap();

  p.append_child(&text1.as_node(), &exception_state).unwrap();
  p.append_child(&br.as_node(), &exception_state).unwrap();
  p.append_child(&text2.as_node(), &exception_state).unwrap();

  document.body().append_child(&p.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}

#[webf_test_async]
pub async fn test_br_after_block_element(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div_style = json!({
    "fontSize": "24px"
  });

  let inner_div = create_element_with_style(&context, "div", &json!({}));
  let hello_text = document.create_text_node("Hello", &exception_state).unwrap();
  inner_div.append_child(&hello_text.as_node(), &exception_state).unwrap();

  let br = create_element_with_style(&context, "br", &json!({}));
  let world_text = document.create_text_node("world", &exception_state).unwrap();

  let div = create_element_with_style(&context, "div", &div_style);
  div.append_child(&inner_div.as_node(), &exception_state).unwrap();
  div.append_child(&br.as_node(), &exception_state).unwrap();
  div.append_child(&world_text.as_node(), &exception_state).unwrap();

  document.body().append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}

#[webf_test_async]
pub async fn test_br_after_text_node_in_flow_layout(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div_style = json!({
    "fontSize": "24px"
  });

  let hello_text = document.create_text_node("Hello", &exception_state).unwrap();
  let br = create_element_with_style(&context, "br", &json!({}));
  let world_text = document.create_text_node("world", &exception_state).unwrap();

  let div = create_element_with_style(&context, "div", &div_style);
  div.append_child(&hello_text.as_node(), &exception_state).unwrap();
  div.append_child(&br.as_node(), &exception_state).unwrap();
  div.append_child(&world_text.as_node(), &exception_state).unwrap();

  document.body().append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}

#[webf_test_async]
pub async fn test_br_in_flex_layout(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div_style = json!({
    "fontSize": "24px",
    "display": "flex",
    "flexDirection": "column"
  });

  let span = create_element_with_style(&context, "span", &json!({}));
  let hello_text = document.create_text_node("Hello", &exception_state).unwrap();
  span.append_child(&hello_text.as_node(), &exception_state).unwrap();

  let br = create_element_with_style(&context, "br", &json!({}));
  let world_text = document.create_text_node("world", &exception_state).unwrap();

  let div = create_element_with_style(&context, "div", &div_style);
  div.append_child(&span.as_node(), &exception_state).unwrap();
  div.append_child(&br.as_node(), &exception_state).unwrap();
  div.append_child(&world_text.as_node(), &exception_state).unwrap();

  document.body().append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}

#[webf_test_async]
pub async fn test_multiple_br_elements_after_text_node(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div_style = json!({
    "fontSize": "24px"
  });

  let hello_text = document.create_text_node("Hello", &exception_state).unwrap();
  let br1 = create_element_with_style(&context, "br", &json!({}));
  let br2 = create_element_with_style(&context, "br", &json!({}));
  let br3 = create_element_with_style(&context, "br", &json!({}));
  let br4 = create_element_with_style(&context, "br", &json!({}));
  let world_text = document.create_text_node("world", &exception_state).unwrap();

  let div = create_element_with_style(&context, "div", &div_style);
  div.append_child(&hello_text.as_node(), &exception_state).unwrap();
  div.append_child(&br1.as_node(), &exception_state).unwrap();
  div.append_child(&br2.as_node(), &exception_state).unwrap();
  div.append_child(&br3.as_node(), &exception_state).unwrap();
  div.append_child(&br4.as_node(), &exception_state).unwrap();
  div.append_child(&world_text.as_node(), &exception_state).unwrap();

  document.body().append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}

#[webf_test_async]
pub async fn test_styles_on_br_not_working(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let div_style = json!({
    "fontSize": "24px"
  });

  let br_style = json!({
    "width": "100px",
    "height": "100px",
    "margin": "100px",
    "backgroundColor": "green"
  });

  let br = create_element_with_style(&context, "br", &br_style);
  let hello_text = document.create_text_node("Hello ", &exception_state).unwrap();
  let world_text = document.create_text_node("world", &exception_state).unwrap();

  let div = create_element_with_style(&context, "div", &div_style);
  div.append_child(&br.as_node(), &exception_state).unwrap();
  div.append_child(&hello_text.as_node(), &exception_state).unwrap();
  div.append_child(&world_text.as_node(), &exception_state).unwrap();

  document.body().append_child(&div.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context, metadata.snapshot_filename).await.unwrap();
}
