use webf_sys::executing_context::ExecutingContext;
use crate::test_runner::TestRunner;

pub mod nodes;

pub const DESCRIPTION: &str = "Collections of Rust DOM APIs";

const TESTS: [(crate::test_runner::TestRunnerFunction, & 'static str); 1] = [
  (nodes::exec_test, nodes::DESCRIPTION)
];

pub fn exec_test(context: &ExecutingContext) {
  for (i, test) in TESTS.iter().enumerate() {
    let (func, description) = test;
    println!("Running: {description}: ");
    func(context);
  }
}