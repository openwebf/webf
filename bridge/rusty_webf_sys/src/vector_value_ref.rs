/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
use std::ffi::*;
use crate::*;

#[repr(C)]
pub struct VectorValueRef<T> {
    pub size: i64,
    pub data: *const RustValue<T>
}
