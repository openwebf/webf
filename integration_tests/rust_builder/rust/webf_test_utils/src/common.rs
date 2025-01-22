use webf_sys::{ExecutingContext, NodeMethods};

fn clear_all_timer(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let callback = Box::new(|| {});
  let end_timer = context.set_timeout_with_callback(callback, &exception_state).unwrap();

  for timer in 1..=end_timer {
    context.clear_timeout(timer, &exception_state);
  }
}

fn reset_document_element(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let document = context.document();
  let document_element = document.document_element();
  document.remove_child(document_element.as_node(), &exception_state).unwrap();

  let html = document.create_element("html", &exception_state).unwrap();
  document.append_child(html.as_node(), &exception_state).unwrap();

  let document_element = document.document_element();
  let head = document.create_element("head", &exception_state).unwrap();
  document_element.append_child(head.as_node(), &exception_state).unwrap();
  let body = document.create_element("body", &exception_state).unwrap();
  document_element.append_child(body.as_node(), &exception_state).unwrap();

  let window = context.window();
  window.scroll_to_with_x_and_y(0.0, 0.0, &exception_state);

  // @TODO: Set the background color to white
  // document.documentElement.style.backgroundColor = 'white';
}

// @TODO: Implement this
// webf.methodChannel.clearMethodCallHandler();

fn clear_cookies(context: ExecutingContext) {
  let exception_state = context.create_exception_state();
  let document = context.document();
  document.___clear_cookies__(&exception_state);
}

pub fn spec_done(context: ExecutingContext) {
  clear_all_timer(context.clone());
  reset_document_element(context.clone());
  clear_cookies(context.clone());
  context.__webf_sync_buffer__();
}
