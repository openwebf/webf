use std::ffi::{c_void, CString};
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, RustValue};
use webf_sys::node::NodeMethods;

#[no_mangle]
pub extern "C" fn init_webf_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  let context = initialize_webf_api(handle);
  let exception_state = context.create_exception_state();
  let window = context.window();
  let document = context.document();

  let div_tag_name = CString::new("div").unwrap();
  let div_element = document.create_element(&div_tag_name, &exception_state).unwrap();

  let text_node_data = CString::new("From Rust").unwrap();
  let text_node = document.create_text_node(&text_node_data, &exception_state).unwrap();

  div_element.append_child(&text_node, &exception_state).expect("append Node Failed");

  document.body().append_child(&div_element, &exception_state).unwrap();

  std::ptr::null_mut()
}
