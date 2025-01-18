use std::ffi::c_void;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, RustValue};

#[no_mangle]
pub extern "C" fn init_webf_test_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  let context = initialize_webf_api(handle);
  println!("Context created");
  let exception_state = context.create_exception_state();
  let navigator = context.navigator();

  let ua_string = navigator.user_agent(&exception_state);
  println!("User Agent: {}", ua_string);

  let local_storage = context.local_storage();

  let result = local_storage.set_item("test", "test2", &exception_state);

  match result {
    Ok(_) => {
      println!("Local Storage Set Item Success");
    },
    Err(err) => {
      println!("Local Storage Set Item Failed: {:?}", err);
    }
  }

  println!("Local Storage value for \"a\": {:?}", local_storage.get_item("a", &exception_state));
  println!("Local Storage Keys: {:?}", local_storage.get_all_keys(&exception_state));
  println!("Local Storage Length: {:?}", local_storage.length(&exception_state));
  println!("Local Storage value for \"test\": {:?}", local_storage.get_item("test", &exception_state));

  local_storage.clear(&exception_state);
  std::ptr::null_mut()
}
