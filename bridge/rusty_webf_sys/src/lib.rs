/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#[repr(C)]
pub struct OpaquePtr;

#[repr(C)]
pub struct RustValue<T> {
    pub value: *const OpaquePtr,
    pub method_pointer: *const T,
}