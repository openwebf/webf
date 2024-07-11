use webf_sys::executing_context::ExecutingContext;
use webf_sys::node::NodeMethods;

pub type TestRunnerFunction = fn(&ExecutingContext) -> ();

pub struct TestRunner;

impl TestRunner {
  pub const TESTS: [(TestRunnerFunction, & 'static str); 2] = [
    (crate::dom::exec_test, crate::dom::DESCRIPTION),
    (crate::window::exec_test, crate::window::DESCRIPTION)
  ];
  pub fn resetDocumentElement(context: &ExecutingContext) {
    // let document = context.document();
    // let exception_state = context.create_exception_state();
    // let document_element = document.document_element();
    // document.remove_child(&document_element, &exception_state).unwrap();
    //
    // let html = document.create_element("html", &exception_state).unwrap();
    // document.append_child(&html, &exception_state).unwrap();
    //
    // let head = document.create_element("head", &exception_state).unwrap();
    // document.append_child(&head, &exception_state).unwrap();
    //
    // let body = document.create_element("body", &exception_state).unwrap();
    // document.append_child(&body, &exception_state).unwrap();
  }

  pub fn exec_test(context: &ExecutingContext) {
    for (i, test) in Self::TESTS.iter().enumerate() {
      let (func, description) = test;
      println!("Running: {description}: ");
      func(context);
    }
  }
}