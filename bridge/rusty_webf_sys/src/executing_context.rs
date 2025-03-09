/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

use std::ffi::*;
use native_value::NativeValue;

use crate::*;

#[repr(C)]
pub struct ExecutingContextRustMethods {
  pub version: c_double,
  pub get_document: extern "C" fn(*const OpaquePtr) -> RustValue<DocumentRustMethods>,
  pub get_window: extern "C" fn(*const OpaquePtr) -> RustValue<WindowRustMethods>,
  pub create_exception_state: extern "C" fn() -> RustValue<ExceptionStateRustMethods>,
  pub finish_recording_ui_operations: extern "C" fn(*const OpaquePtr) -> c_void,
  pub webf_sync_buffer: extern "C" fn(*const OpaquePtr) -> c_void,
  pub webf_match_image_snapshot: extern "C" fn(*const OpaquePtr, *const NativeValue, *const NativeValue, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_void,
  pub webf_match_image_snapshot_bytes: extern "C" fn(*const OpaquePtr, *const NativeValue, *const NativeValue, *const WebFNativeFunctionContext, *const OpaquePtr) -> c_void,
  pub webf_invoke_module: extern "C" fn(*const OpaquePtr, *const c_char, *const c_char, *const OpaquePtr) -> NativeValue,
  pub webf_invoke_module_with_params: extern "C" fn(*const OpaquePtr, *const c_char, *const c_char, *const NativeValue, *const OpaquePtr) -> NativeValue,
  pub webf_invoke_module_with_params_and_callback: extern "C" fn(*const OpaquePtr, *const c_char, *const c_char, *const NativeValue, *const WebFNativeFunctionContext, *const OpaquePtr) -> NativeValue,
  pub webf_location_reload: extern "C" fn(*const OpaquePtr, exception_state: *const OpaquePtr) -> c_void,
  pub set_timeout: extern "C" fn(*const OpaquePtr, *const WebFNativeFunctionContext, c_int, *const OpaquePtr) -> c_int,
  pub set_interval: extern "C" fn(*const OpaquePtr, *const WebFNativeFunctionContext, c_int, *const OpaquePtr) -> c_int,
  pub clear_timeout: extern "C" fn(*const OpaquePtr, c_int, *const OpaquePtr),
  pub clear_interval: extern "C" fn(*const OpaquePtr, c_int, *const OpaquePtr),
  pub add_rust_future_task: extern "C" fn(*const OpaquePtr, *const WebFNativeFunctionContext, *const NativeLibraryMetaData, *const OpaquePtr) -> c_int,
  pub remove_rust_future_task: extern "C" fn(*const OpaquePtr, c_int, *const NativeLibraryMetaData, *const OpaquePtr) -> c_void,
  pub create_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<EventRustMethods>,
  pub create_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const EventInit, exception_state: *const OpaquePtr ) -> RustValue<EventRustMethods>,
  pub create_animation_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<AnimationEventRustMethods>,
  pub create_animation_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const AnimationEventInit, exception_state: *const OpaquePtr ) -> RustValue<AnimationEventRustMethods>,
  pub create_close_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<CloseEventRustMethods>,
  pub create_close_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const CloseEventInit, exception_state: *const OpaquePtr ) -> RustValue<CloseEventRustMethods>,
  pub create_custom_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<CustomEventRustMethods>,
  pub create_custom_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const CustomEventInit, exception_state: *const OpaquePtr ) -> RustValue<CustomEventRustMethods>,
  pub create_focus_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<FocusEventRustMethods>,
  pub create_focus_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const FocusEventInit, exception_state: *const OpaquePtr ) -> RustValue<FocusEventRustMethods>,
  pub create_gesture_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<GestureEventRustMethods>,
  pub create_gesture_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const GestureEventInit, exception_state: *const OpaquePtr ) -> RustValue<GestureEventRustMethods>,
  pub create_hashchange_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<HashchangeEventRustMethods>,
  pub create_hashchange_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const HashchangeEventInit, exception_state: *const OpaquePtr ) -> RustValue<HashchangeEventRustMethods>,
  pub create_input_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<InputEventRustMethods>,
  pub create_input_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const InputEventInit, exception_state: *const OpaquePtr ) -> RustValue<InputEventRustMethods>,
  pub create_intersection_change_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<IntersectionChangeEventRustMethods>,
  pub create_intersection_change_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const IntersectionChangeEventInit, exception_state: *const OpaquePtr ) -> RustValue<IntersectionChangeEventRustMethods>,
  pub create_pop_state_event: extern "C" fn(*const OpaquePtr, exception_state: *const OpaquePtr ) -> RustValue<PopStateEventRustMethods>,
  pub create_mouse_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<MouseEventRustMethods>,
  pub create_mouse_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const MouseEventInit, exception_state: *const OpaquePtr ) -> RustValue<MouseEventRustMethods>,
  pub create_pointer_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<PointerEventRustMethods>,
  pub create_pointer_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const PointerEventInit, exception_state: *const OpaquePtr ) -> RustValue<PointerEventRustMethods>,
  pub create_transition_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<TransitionEventRustMethods>,
  pub create_transition_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const TransitionEventInit, exception_state: *const OpaquePtr ) -> RustValue<TransitionEventRustMethods>,
  pub create_ui_event: extern "C" fn(*const OpaquePtr, *const c_char, exception_state: *const OpaquePtr ) -> RustValue<UIEventRustMethods>,
  pub create_ui_event_with_options: extern "C" fn(*const OpaquePtr, *const c_char, options: *const UIEventInit, exception_state: *const OpaquePtr ) -> RustValue<UIEventRustMethods>,
}

pub type TimeoutCallback = Box<dyn Fn()>;
pub type IntervalCallback = Box<dyn Fn()>;
pub type RunRustFutureTasksCallback = Box<dyn Fn()>;

#[repr(C)]
pub struct NativeLibraryMetaData {
  pub lib_name: *const NativeValue
}

/// An environment contains all the necessary running states of a web page.
///
/// For Flutter apps, there could be many web pages running in the same Dart environment,
/// and each web page is isolated with its own DOM tree, layout state, and JavaScript running environment.
///
/// In the Rust world, Rust code plays the same role as JavaScript,
/// so the Rust running states also live in the ExecutionContext class.
///
/// Since both JavaScript and Rust run in the same environment,
/// the DOM tree and the underlying layout state are shared between Rust and JavaScript worlds.
/// it's possible to create an HTMLElement in Rust and remove it from JavaScript,
/// and even collaborate with each other to build an enormous application.
///
/// The relationship between Window, Document, and ExecutionContext is 1:1:1 at any point in time.
pub struct ExecutingContext {
  // The underlying pointer points to the actual implementation of ExecutionContext in the C++ world.
  pub ptr: *const OpaquePtr,
  // Methods available for export from the C++ world for use.
  method_pointer: *const ExecutingContextRustMethods,
  pub meta_data: *const NativeLibraryMetaData,
  pub status: *const RustValueStatus,
}

impl ExecutingContext {
  pub fn initialize(ptr: *const OpaquePtr, method_pointer: *const ExecutingContextRustMethods, meta_data: *const NativeLibraryMetaData, status: *const RustValueStatus) -> ExecutingContext {
    ExecutingContext {
      ptr,
      method_pointer,
      meta_data,
      status
    }
  }

  pub fn method_pointer<'a>(&self) -> &'a ExecutingContextRustMethods {
    unsafe {
      &*self.method_pointer
    }
  }

  /// Obtain the window instance from ExecutingContext.
  pub fn window(&self) -> Window {
    let result = unsafe {
      ((*self.method_pointer).get_window)(self.ptr)
    };
    return Window::initialize(result.value, self, result.method_pointer, result.status);
  }

  /// Obtain the document instance from ExecutingContext.
  pub fn document(&self) -> Document {
    let result = unsafe {
      ((*self.method_pointer).get_document)(self.ptr)
    };
    return Document::initialize::<DocumentRustMethods>(result.value, self, result.method_pointer, result.status);
  }

  pub fn location(&self) -> Location {
    Location::initialize(self)
  }

  pub fn history(&self) -> History {
    History::initialize(self)
  }

  pub fn hybrid_history(&self) -> HybridHistory {
    HybridHistory::initialize(self)
  }

  pub fn navigator(&self) -> Navigator {
    Navigator::initialize(self)
  }

  pub fn async_storage(&self) -> AsyncStorage {
    AsyncStorage::initialize(self)
  }

  pub fn local_storage(&self) -> Storage {
    Storage::initialize(self, "LocalStorage")
  }

  pub fn session_storage(&self) -> Storage {
    Storage::initialize(self, "SessionStorage")
  }

  pub fn create_exception_state(&self) -> ExceptionState {
    let result = unsafe {
      ((*self.method_pointer).create_exception_state)()
    };
    ExceptionState::initialize(result.value, result.method_pointer)
  }

  pub fn __webf_sync_buffer__(&self) {
    unsafe {
      ((*self.method_pointer).webf_sync_buffer)(self.ptr);
    }
  }

  pub fn __webf_match_image_snapshot__(&self, image: Vec<u8>, snapshot_filename: &str, exception_state: &ExceptionState) -> WebFNativeFuture<bool> {
    let image_blob = NativeValue::new_u8_bytes(image);
    let snapshot_filename_value = NativeValue::new_string(snapshot_filename);
    let future_for_return = WebFNativeFuture::<bool>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let match_result = unsafe { (*argv.wrapping_add(1)).clone() };
        let match_result = match_result.to_int64();
        future_in_callback.set_result(Ok(Some(match_result != 0)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let result = unsafe {
      ((*self.method_pointer).webf_match_image_snapshot)(self.ptr, &image_blob, &snapshot_filename_value, callback_context_ptr, exception_state.ptr)
    };

    future_for_return
  }

  pub fn webf_match_image_snapshot_bytes(&self, image: Vec<u8>, snapshot: Vec<u8>, exception_state: &ExceptionState) -> WebFNativeFuture<bool> {
    let image_blob = NativeValue::new_u8_bytes(image);
    let snapshot_blob = NativeValue::new_u8_bytes(snapshot);
    let future_for_return = WebFNativeFuture::<bool>::new();
    let future_in_callback = future_for_return.clone();
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc == 1 {
        let error_string = unsafe { (*argv).clone() };
        let error_string = error_string.to_string();
        future_in_callback.set_result(Err(error_string));
        return NativeValue::new_null();
      }
      if argc == 2 {
        let match_result = unsafe { (*argv.wrapping_add(1)).clone() };
        let match_result = match_result.to_int64();
        future_in_callback.set_result(Ok(Some(match_result != 0)));
        return NativeValue::new_null();
      }
      println!("Invalid argument count for async storage callback");
      NativeValue::new_null()
    });

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let result = unsafe {
      ((*self.method_pointer).webf_match_image_snapshot)(self.ptr, &image_blob, &snapshot_blob, callback_context_ptr, exception_state.ptr)
    };

    future_for_return
  }

  pub fn webf_invoke_module(&self, module_name: &str, method: &str, exception_state: &ExceptionState) -> Result<NativeValue, String> {
    let module_name = CString::new(module_name).unwrap();
    let method = CString::new(method).unwrap();
    let result = unsafe {
      ((*self.method_pointer).webf_invoke_module)(self.ptr, module_name.as_ptr(), method.as_ptr(), exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }

    Ok(result)
  }

  pub fn webf_invoke_module_with_params(&self, module_name: &str, method: &str, params: &NativeValue, exception_state: &ExceptionState) -> Result<NativeValue, String> {
    let module_name = CString::new(module_name).unwrap();
    let method = CString::new(method).unwrap();
    let result = unsafe {
      ((*self.method_pointer).webf_invoke_module_with_params)(self.ptr, module_name.as_ptr(), method.as_ptr(), params, exception_state.ptr)
    };

    if exception_state.has_exception() {
      return Err(exception_state.stringify(self));
    }

    Ok(result)
  }

  pub fn webf_invoke_module_with_params_and_callback(&self, module_name: &str, method: &str, params: &NativeValue, callback: WebFNativeFunction, exception_state: &ExceptionState) -> Result<NativeValue, String> {
    let module_name = CString::new(module_name).unwrap();
    let method = CString::new(method).unwrap();

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let result = unsafe {
      ((*self.method_pointer).webf_invoke_module_with_params_and_callback)(self.ptr, module_name.as_ptr(), method.as_ptr(), params, callback_context_ptr, exception_state.ptr)
    };

    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self));
    }

    Ok(result)
  }

  pub fn webf_location_reload(&self, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).webf_location_reload)(self.ptr, exception_state.ptr);
    }
  }

  pub fn set_timeout_with_callback(&self, callback: TimeoutCallback, exception_state: &ExceptionState) -> Result<i32, String> {
    self.set_timeout_with_callback_and_timeout(callback, 0, exception_state)
  }

  pub fn set_timeout_with_callback_and_timeout(&self, callback: TimeoutCallback, timeout: i32, exception_state: &ExceptionState) -> Result<i32, String> {
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc != 0 {
        println!("Invalid argument count for timeout callback");
        return NativeValue::new_null();
      }
      callback();
      NativeValue::new_null()
    });

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let result = unsafe {
      ((*self.method_pointer).set_timeout)(self.ptr, callback_context_ptr, timeout, exception_state.ptr)
    };

    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self));
    }

    Ok(result)
  }

  pub fn set_interval_with_callback(&self, callback: IntervalCallback, exception_state: &ExceptionState) -> Result<i32, String> {
    self.set_interval_with_callback_and_timeout(callback, 0, exception_state)
  }

  pub fn set_interval_with_callback_and_timeout(&self, callback: IntervalCallback, interval: i32, exception_state: &ExceptionState) -> Result<i32, String> {
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc != 0 {
        println!("Invalid argument count for interval callback");
        return NativeValue::new_null();
      }
      callback();
      NativeValue::new_null()
    });

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let result = unsafe {
      ((*self.method_pointer).set_interval)(self.ptr, callback_context_ptr, interval, exception_state.ptr)
    };

    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self));
    }

    Ok(result)
  }

  pub fn clear_timeout(&self, timeout_id: i32, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).clear_timeout)(self.ptr, timeout_id, exception_state.ptr)
    }
  }

  pub fn clear_interval(&self, interval_id: i32, exception_state: &ExceptionState) {
    unsafe {
      ((*self.method_pointer).clear_interval)(self.ptr, interval_id, exception_state.ptr)
    }
  }

  pub fn add_rust_future_task(&self, callback: RunRustFutureTasksCallback, exception_state: &ExceptionState) -> Result<i32, String> {
    let general_callback: WebFNativeFunction = Box::new(move |argc, argv| {
      if argc != 0 {
        println!("Invalid argument count for run rust future tasks callback");
        return NativeValue::new_null();
      }
      callback();
      NativeValue::new_null()
    });

    let callback_data = Box::new(WebFNativeFunctionContextData {
      func: general_callback,
    });
    let callback_context_data_ptr = Box::into_raw(callback_data);
    let callback_context = Box::new(WebFNativeFunctionContext {
      callback: invoke_webf_native_function,
      free_ptr: release_webf_native_function,
      ptr: callback_context_data_ptr,
    });
    let callback_context_ptr = Box::into_raw(callback_context);

    let callback_id = unsafe {
      ((*self.method_pointer).add_rust_future_task)(self.ptr, callback_context_ptr, self.meta_data, exception_state.ptr)
    };

    if exception_state.has_exception() {
      unsafe {
        let _ = Box::from_raw(callback_context_ptr);
        let _ = Box::from_raw(callback_context_data_ptr);
      }
      return Err(exception_state.stringify(self));
    }

    Ok((callback_id))

  }

  pub fn remove_rust_future_task(&self, callback_id: i32, exception_state: &ExceptionState) -> Result<(), String> {
    unsafe {
      ((*self.method_pointer).remove_rust_future_task)(self.ptr, callback_id, self.meta_data, exception_state.ptr);
    }

    Ok(())
  }

}

impl Drop for ExecutingContext {
  fn drop(&mut self) {
    unsafe {
      if (*((*self).status)).disposed {
        return;
      };
      ((*self.method_pointer).finish_recording_ui_operations)(self.ptr);
    }
  }
}

impl Clone for ExecutingContext {
  fn clone(&self) -> Self {
    ExecutingContext {
      ptr: self.ptr,
      method_pointer: self.method_pointer,
      meta_data: self.meta_data,
      status: self.status,
    }
  }
}
