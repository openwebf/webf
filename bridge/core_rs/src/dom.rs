/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::{c_void, CString};
use libc::labs;
use webf::document::Document;
use webf::executing_context::ExecutingContext;

pub fn init_webf_dom(context: &ExecutingContext) {
  let document = context.document();
  let exception_state = context.create_exception_state();

  let head_tag_name = CString::new("head");
  let head_element = document.create_element(&head_tag_name.unwrap(), &exception_state);

  let body_tag_name = CString::new("这是23");
  let body_element = document.create_element(&body_tag_name.unwrap(), &exception_state);

  println!("!");

  // let exception_state = unsafe {
  //   ExceptionState {
  //     ptr: webf__create_exception_state()
  //   }
  // };
  // document.createElement("1234", &exception_state);

  // return document;
}

