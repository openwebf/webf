use webf_sys::{ExecutingContext, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{dom_utils::{create_element_with_style, create_element_with_style_and_child}, snapshot::snapshot_with_target_and_filename};

#[webf_test_async]
pub async fn test_set_background_color(context: ExecutingContext) {
  let style = serde_json::json!({
    "width": "200px",
    "height": "200px",
    "background-color": "blue",
  });
  let canvas = create_element_with_style(&context, "canvas", &style);
  let document = context.document();
  document.body().append_child(&canvas.as_node(), &context.create_exception_state()).unwrap();
  snapshot_with_target_and_filename(context, &canvas, "snapshots/dom/elements/canvas/canvas.rs.c6bff5e41").await.unwrap();
}

#[webf_test_async]
pub async fn test_behavior_like_inline_element(context: ExecutingContext) {
  let wrapper_style = serde_json::json!({
    "width": "200px",
    "height": "200px",
  });
  let wrapper = create_element_with_style(&context, "div", &wrapper_style);
  let canvas_style = serde_json::json!({
    "width": "100px",
    "height": "100px",
    "background-color": "blue",
  });
  let canvas = create_element_with_style(&context, "canvas", &canvas_style);
  let exception_state = context.create_exception_state();
  let text_node = context.document().create_text_node("12345", &exception_state).unwrap();
  let text = create_element_with_style_and_child(&context, "span", &serde_json::json!({}), text_node.as_node());
  wrapper.append_child(&canvas.as_node(), &exception_state).unwrap();
  wrapper.append_child(&text.as_node(), &exception_state).unwrap();
  let document = context.document();
  document.body().append_child(&wrapper.as_node(), &exception_state).unwrap();
  snapshot_with_target_and_filename(context, &wrapper, "snapshots/dom/elements/canvas/canvas.rs.58e528bc1").await.unwrap();
}
