use webf_sys::{ExecutingContext, NodeMethods};
use webf_test_macros::webf_test_async;
use webf_test_utils::{common::TestCaseMetadata, snapshot::snapshot_with_filename};

#[webf_test_async]
pub async fn test_pre_element_basic(metadata: TestCaseMetadata, context: ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  // Create pre element
  let pre = document.create_element("pre", &exception_state).unwrap();

  // Create text node with preserved whitespace and line breaks
  let text_content = "
Text in a pre element
is displayed in a fixed-width
font, and it preserves
both      spaces and
line breaks
    ";
  let text_node = document.create_text_node(text_content, &exception_state).unwrap();

  // Append text to pre element
  pre.append_child(&text_node.as_node(), &exception_state).unwrap();

  // Append pre element to body
  let body = document.body();
  body.append_child(&pre.as_node(), &exception_state).unwrap();

  // Take snapshot
  snapshot_with_filename(context.clone(), metadata.snapshot_filename).await.unwrap();
}
