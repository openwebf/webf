use std::ffi::c_void;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, ExecutingContext, NativeLibraryMetaData, RustValue};

pub mod async_storage;
pub mod dom;
pub mod cookie;
pub mod navigator;
pub mod storage;
pub mod timer;

#[no_mangle]
pub extern "C" fn init_webf_test_app(handle: RustValue<ExecutingContextRustMethods>, meta_data: *const NativeLibraryMetaData) -> *mut c_void {
  let context: ExecutingContext = initialize_webf_api(handle, meta_data);

  webf_test_utils::sync_runner::run_tests(context.clone());

  webf_sys::webf_future::spawn(context.clone(), async move {
    webf_test_utils::async_runner::run_tests(context.clone()).await;
    webf_test_utils::callback_runner::run_tests(context.clone()).await;
  });

  std::ptr::null_mut()
}
