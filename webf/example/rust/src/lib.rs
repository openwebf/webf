use std::ffi::{c_void, CString};
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, RustValue};
use webf_sys::event_target::{AddEventListenerOptions, EventTarget, EventTargetMethods};
use webf_sys::node::NodeMethods;

#[no_mangle]
pub extern "C" fn init_webf_app(handle: RustValue<ExecutingContextRustMethods>) -> *mut c_void {
  let context = initialize_webf_api(handle);
  let exception_state = context.create_exception_state();
  let document = context.document();

  let div_element = document.create_element("div", &exception_state).unwrap();

  let event_listener_options = AddEventListenerOptions {
    passive: 0,
    once: 0,
    capture: 0,
  };

  let event_handler = Box::new(|event_target: &EventTarget| {
    let context = event_target.context();
    let exception_state = context.create_exception_state();
    let document = context.document();
    let div = document.create_element("div", &exception_state).unwrap();
    let text_node = document.create_text_node("Created By Event Handler", &exception_state).unwrap();
    div.append_child(&text_node, &exception_state).unwrap();
    document.body().append_child(&div, &exception_state).unwrap();
  });

  div_element.add_event_listener("custom_click", event_handler.clone(), &event_listener_options, &exception_state).unwrap();

  let event = document.create_event("custom_click", &exception_state).unwrap();

  let real_click_handler = Box::new(move |event_target: &EventTarget| {
    let context = event_target.context();
    let exception_state = context.create_exception_state();
    let _ = event_target.dispatch_event(&event, &exception_state);
  });

  div_element.add_event_listener("click", real_click_handler, &event_listener_options, &exception_state).unwrap();

  let text_node = document.create_text_node("From Rust", &exception_state).unwrap();

  div_element.append_child(&text_node, &exception_state).expect("append Node Failed");

  document.body().append_child(&div_element, &exception_state).unwrap();

  let event_cleaner_element = document.create_element("button", &exception_state).unwrap();

  let event_cleaner_text_node = document.create_text_node("Remove Event", &exception_state).unwrap();

  event_cleaner_element.append_child(&event_cleaner_text_node, &exception_state).unwrap();

  let event_cleaner_handler = Box::new(move |event_target: &EventTarget| {
    let context = event_target.context();
    let exception_state = context.create_exception_state();

    let _ = div_element.remove_event_listener("custom_click", event_handler.clone(), &exception_state);
  });

  event_cleaner_element.add_event_listener("click", event_cleaner_handler, &event_listener_options, &exception_state).unwrap();

  document.body().append_child(&event_cleaner_element, &exception_state).unwrap();

  std::ptr::null_mut()
}
