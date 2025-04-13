use webf_sys::{ExecutingContext, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{common::TestCaseMetadata, dom_utils::{create_element_with_style, create_element_with_style_and_children}, snapshot::snapshot_with_filename};
use serde_json::json;

#[webf_test_async]
pub async fn test_listview_height_adjust_based_on_inner_elements(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  // Create the inner div with text "ABC"
  let div_style = json!({
    "padding": "10px"
  });
  let inner_div = create_element_with_style(&context, "div", &div_style);
  let abc_text = document.create_text_node("ABC", &exception_state).unwrap();
  inner_div.append_child(&abc_text.as_node(), &exception_state).unwrap();

  // Create the ending div with text "END"
  let end_div_style = json!({
    "border": "1px solid blue"
  });
  let end_div = create_element_with_style(&context, "div", &end_div_style);
  let end_text = document.create_text_node("END", &exception_state).unwrap();
  end_div.append_child(&end_text.as_node(), &exception_state).unwrap();

  // Create text nodes
  let text_1 = document.create_text_node("\n \n \n TEXTTEXT TEXT \n \n \n", &exception_state).unwrap();
  let text_2 = document.create_text_node("\n \n \n TEXTTEXT TEXT \n \n \n", &exception_state).unwrap();
  let text_3 = document.create_text_node("\n \n \n TEXTTEXT TEXT \n \n \n", &exception_state).unwrap();
  let text_4 = document.create_text_node("\n \n \n TEXTTEXT TEXT \n \n \n", &exception_state).unwrap();
  let text_5 = document.create_text_node("\n \n \n TEXTTEXT TEXT \n \n \n", &exception_state).unwrap();

  // Create the listview container
  let container_style = json!({
    "border": "1px solid #000"
  });

  // Collect all children nodes into a Vec
  let mut children = Vec::new();
  children.push(inner_div.as_node());
  children.push(text_1.as_node());
  children.push(text_2.as_node());
  children.push(text_3.as_node());
  children.push(text_4.as_node());
  children.push(text_5.as_node());
  children.push(end_div.as_node());

  // Create container with all children
  let container = create_element_with_style_and_children(
    &context,
    "listview",
    &container_style,
    &children
  );

  // Create text node after container
  let after_text = document.create_text_node("the TEXT AFTER CONTAINER", &exception_state).unwrap();

  // Append container and after_text to body
  let body = document.body();
  body.append_child(&container.as_node(), &exception_state).unwrap();
  body.append_child(&after_text.as_node(), &exception_state).unwrap();

  // Take snapshot
  snapshot_with_filename(context.clone(), metadata.snapshot_filename).await.unwrap();
}
