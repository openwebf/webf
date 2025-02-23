use webf_sys::{ExecutingContext, NativeValue, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::snapshot::snapshot_with_filename;

#[webf_test_async]
pub async fn test_tag_p_basic(context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let p = document.create_element("p", &exception_state).unwrap();
  let p_style = p.style();
  p_style.set_property("width", NativeValue::new_string("300px"), &exception_state).unwrap();
  p_style.set_property("height", NativeValue::new_string("300px"), &exception_state).unwrap();
  p_style.set_property("background-color", NativeValue::new_string("grey"), &exception_state).unwrap();

  let text = document.create_text_node("This is a paragraph.", &exception_state).unwrap();
  p.append_child(&text.as_node(), &exception_state).unwrap();

  let body = document.body();
  body.append_child(&p.as_node(), &exception_state).unwrap();

  snapshot_with_filename(context.clone(), "snapshots/dom/elements/p.rs.1f1e162c1").await.unwrap();
}
