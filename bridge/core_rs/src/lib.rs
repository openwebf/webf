use std::ffi::c_void;
use libc::{c_char, c_uint};
use webf_sys::RustValue;
use webf::{initialize_webf_api};
use webf::executing_context::{ExecutingContextRustMethods};
use crate::dom::init_webf_dom;

mod dom;
#[no_mangle]
pub extern "C" fn init_webf_polyfill(handle: RustValue<ExecutingContextRustMethods>) {
  let context = initialize_webf_api(handle);
  init_webf_dom(&context);
}