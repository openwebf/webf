use std::ffi::c_void;
use webf_sys::event::Event;
use webf_sys::executing_context::ExecutingContextRustMethods;
use webf_sys::{initialize_webf_api, performance, AddEventListenerOptions, EventTargetMethods, NativeLibraryMetaData, NativeValue, PerformanceMarkOptions, RustValue};
use webf_sys::element::Element;
use webf_sys::node::NodeMethods;

#[no_mangle]
pub extern "C" fn init_webf_app(handle: RustValue<ExecutingContextRustMethods>, meta_data: *const NativeLibraryMetaData) -> *mut c_void {
  let context = initialize_webf_api(handle, meta_data);
  println!("Context created");
  let exception_state = context.create_exception_state();
  let document = context.document();
  let click_event = document.create_event("custom_click", &exception_state).unwrap();
  document.dispatch_event(&click_event, &exception_state);

  let div_element = document.create_element("div", &exception_state).unwrap();

  let performance = context.performance();
  let exception_state = context.create_exception_state();
  let now = performance.now(&exception_state).unwrap();
  let options = PerformanceMarkOptions {
    detail: NativeValue::new_null(),
    start_time: now as f64,
  };

  performance.mark("abc", &options, &exception_state).unwrap();
  performance.mark("efg", &options, &exception_state).unwrap();

  let entries = performance.get_entries(&exception_state).unwrap();
  let has_abc = entries.iter().any(|entry| entry.name() == "abc");
  let has_efg = entries.iter().any(|entry| entry.name() == "efg");
  assert!(has_abc);
  assert!(has_efg);

  let event_listener_options = AddEventListenerOptions {
    passive: 0,
    once: 0,
    capture: 0,
  };

  let event_handler = Box::new(|event: &Event| {
    let context = event.context();
    let exception_state = context.create_exception_state();
    let document = context.document();
    let div = document.create_element("div", &exception_state).unwrap();
    let value = NativeValue::new_string("red");
    div.style().set_property("color", value, &exception_state).unwrap();
    let text_node = document.create_text_node("Created By Event Handler", &exception_state).unwrap();
    div.append_child(&text_node.as_node(), &exception_state).unwrap();
    document.body().append_child(&div.as_node(), &exception_state).unwrap();
  });

  div_element.add_event_listener("custom_click", event_handler.clone(), &event_listener_options, &exception_state).unwrap();

  let real_click_handler = Box::new(move |event: &Event| {
    match event.as_mouse_event() {
      Ok(mouse_event) => {
        let x = mouse_event.offset_x();
        let y = mouse_event.offset_y();
        let document = context.document();
        let exception_state = context.create_exception_state();
        let div = document.create_element("div", &exception_state).unwrap();
        let text_node = document.create_text_node(format!("Mouse Clicked at x: {}, y: {}", x, y).as_str(), &exception_state).unwrap();
        div.append_child(&text_node.as_node(), &exception_state).unwrap();
        document.body().append_child(&div.as_node(), &exception_state).unwrap();
      },
      Err(_) => {
        println!("Not a mouse event");
      }
    }

    let context = event.context();
    let exception_state = context.create_exception_state();
    let document = context.document();
    let custom_click_event = document.create_event("custom_click", &exception_state);

    match custom_click_event {
      Ok(custom_click_event) => {
        let event_target = event.target();
        let element: Element = event_target.as_element().unwrap();
        let _ = element.dispatch_event(&custom_click_event, &exception_state);
      },
      Err(err) => {
        println!("{err}");
      }
    }
  });

  div_element.add_event_listener("click", real_click_handler, &event_listener_options, &exception_state).unwrap();

  let text_node = document.create_text_node("From Rust", &exception_state).unwrap();

  div_element.append_child(&text_node.as_node(), &exception_state).expect("append Node Failed");

  document.body().append_child(&div_element.as_node(), &exception_state).unwrap();

  let event_cleaner_element = document.create_element("button", &exception_state).unwrap();

  let event_cleaner_text_node = document.create_text_node("Remove Event", &exception_state).unwrap();

  event_cleaner_element.append_child(&event_cleaner_text_node.as_node(), &exception_state).unwrap();

  let event_cleaner_handler = Box::new(move |event: &Event| {
    let context = event.context();
    let exception_state = context.create_exception_state();

    let _ = div_element.remove_event_listener("custom_click", event_handler.clone(), &exception_state);
  });

  event_cleaner_element.add_event_listener("click", event_cleaner_handler, &event_listener_options, &exception_state).unwrap();

  document.body().append_child(&event_cleaner_element.as_node(), &exception_state).unwrap();

  std::ptr::null_mut()
}
