use webf_sys::element::Element;
use webf_sys::executing_context::ExecutingContext;
use webf_sys::node::NodeMethods;
use crate::test_runner::TestRunner;

pub fn append_child(context: &ExecutingContext) {
  let exception_state = context.create_exception_state();
  let div = context.document().create_element("div", &exception_state);

  match div {
    Ok(element) => {
      let text_node = context.document().create_text_node("helloworld", &exception_state).unwrap();
      context.document().body().append_child(&text_node, &exception_state).unwrap();
    }
    Err(err) => {
      println!("Exception: {err}");
    }
  }
}

pub const DESCRIPTION: &str = "Node.AppendChild Test";

const TESTS: [(crate::test_runner::TestRunnerFunction, & 'static str); 1] = [
  (append_child, "will works with append nodes at the end of body")
];

pub fn exec_test(context: &ExecutingContext) {
  for (i, test) in TESTS.iter().enumerate() {
    TestRunner::resetDocumentElement(context);
    let (func, description) = test;
    println!("Running: {description}: ");
    func(context);
  }
}