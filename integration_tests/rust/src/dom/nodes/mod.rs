use webf_sys::executing_context::ExecutingContext;
use crate::dom::nodes;
use crate::test_runner::TestRunner;

pub mod append_child;

pub const DESCRIPTION: &str = "Node APIs Test";

const TESTS: [(crate::test_runner::TestRunnerFunction, &'static str); 1] = [
  (append_child::exec_test, append_child::DESCRIPTION)
];

pub fn exec_test(context: &ExecutingContext) {
  for (i, test) in TESTS.iter().enumerate() {
    let (func, description) = test;

    TestRunner::resetDocumentElement(context);

    println!("Running: {description}: ");
    func(context);
  }
}