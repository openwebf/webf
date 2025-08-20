/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;
use crate::memory_utils::safe_free_cpp_ptr;

#[repr(C)]
pub struct VectorValueRef<T> {
    pub size: i64,
    pub data: *const RustValue<T>
}

impl<T> Drop for VectorValueRef<T> {
  fn drop(&mut self) {
    safe_free_cpp_ptr::<T>(self.data as *const T)
  }
}
