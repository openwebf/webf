use std::ffi::c_void;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, RustValue};

#[no_mangle]
pub extern "C" fn init_webf_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  println!("helloworld");
  std::ptr::null_mut()
}
