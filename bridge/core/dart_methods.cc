/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_methods.h"
#include <cassert>
#include "dart_isolate_context.h"

using namespace webf;

namespace webf {

DartMethodPointer::DartMethodPointer(DartIsolateContext* dart_isolate_context,
                                     const uint64_t* dart_methods,
                                     int32_t dart_methods_length)
    : dart_isolate_context_(dart_isolate_context) {
  size_t i = 0;
  invoke_module_ = reinterpret_cast<InvokeModule>(dart_methods[i++]);
  request_batch_update_ = reinterpret_cast<RequestBatchUpdate>(dart_methods[i++]);
  reload_app_ = reinterpret_cast<ReloadApp>(dart_methods[i++]);
  set_timeout_ = reinterpret_cast<SetTimeout>(dart_methods[i++]);
  set_interval_ = reinterpret_cast<SetInterval>(dart_methods[i++]);
  clear_timeout_ = reinterpret_cast<ClearTimeout>(dart_methods[i++]);
  request_animation_frame_ = reinterpret_cast<RequestAnimationFrame>(dart_methods[i++]);
  cancel_animation_frame_ = reinterpret_cast<CancelAnimationFrame>(dart_methods[i++]);
  to_blob_ = reinterpret_cast<ToBlob>(dart_methods[i++]);
  flush_ui_command_ = reinterpret_cast<FlushUICommand>(dart_methods[i++]);
  create_binding_object_ = reinterpret_cast<CreateBindingObject>(dart_methods[i++]);
  on_js_error_ = reinterpret_cast<OnJSError>(dart_methods[i++]);
  on_js_log_ = reinterpret_cast<OnJSLog>(dart_methods[i++]);

  assert_m(i == dart_methods_length, "Dart native methods count is not equal with C++ side method registrations.");
}

NativeValue* DartMethodPointer::invokeModule(bool is_dedicated,
                                             void* callback_context,
                                             double context_id,
                                             SharedNativeString* moduleName,
                                             SharedNativeString* method,
                                             NativeValue* params,
                                             AsyncModuleCallback callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] invokeModuleWrapper call" << std::endl;
#endif
  return dart_isolate_context_->dispatcher()->PostToDartSync(is_dedicated, invoke_module_, callback_context, context_id,
                                                             moduleName, method, params, callback);
}

void DartMethodPointer::requestBatchUpdate(bool is_dedicated, double context_id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] requestBatchUpdateWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, request_batch_update_, context_id);
}

void DartMethodPointer::reloadApp(bool is_dedicated, double context_id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] reloadAppWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, reload_app_, context_id);
}

int32_t DartMethodPointer::setTimeout(bool is_dedicated,
                                      void* callback_context,
                                      double context_id,
                                      AsyncCallback callback,
                                      int32_t timeout) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] SetTimeoutWrapper call" << std::endl;
#endif

  return dart_isolate_context_->dispatcher()->PostToDartSync(is_dedicated, set_timeout_, callback_context, context_id,
                                                             callback, timeout);
}

int32_t DartMethodPointer::setInterval(bool is_dedicated,
                                       void* callback_context,
                                       double context_id,
                                       AsyncCallback callback,
                                       int32_t timeout) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] SetIntervalWrapper call" << std::endl;
#endif

  return dart_isolate_context_->dispatcher()->PostToDartSync(is_dedicated, set_interval_, callback_context, context_id,
                                                             callback, timeout);
}

void DartMethodPointer::clearTimeout(bool is_dedicated, double context_id, int32_t timerId) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] ClearTimeoutWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, clear_timeout_, context_id, timerId);
}

int32_t DartMethodPointer::requestAnimationFrame(bool is_dedicated,
                                                 void* callback_context,
                                                 double context_id,
                                                 AsyncRAFCallback callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] RequestAnimationFrameWrapper call" << std::endl;
#endif
  return dart_isolate_context_->dispatcher()->PostToDartSync(is_dedicated, request_animation_frame_, callback_context,
                                                             context_id, callback);
}

void DartMethodPointer::cancelAnimationFrame(bool is_dedicated, double context_id, int32_t id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] CancelAnimationFrameWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, cancel_animation_frame_, context_id, id);
}

void DartMethodPointer::toBlob(bool is_dedicated,
                               void* callback_context,
                               double context_id,
                               AsyncBlobCallback blobCallback,
                               void* element_ptr,
                               double devicePixelRatio) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "ToBlobWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, to_blob_, callback_context, context_id, blobCallback,
                                                  element_ptr, devicePixelRatio);
}

void DartMethodPointer::flushUICommand(bool is_dedicated, double context_id) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] FlushUICommandWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, flush_ui_command_, context_id);
}

void DartMethodPointer::createBindingObject(bool is_dedicated,
                                            double context_id,
                                            void* native_binding_object,
                                            int32_t type,
                                            void* args,
                                            int32_t argc) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] CreateBindingObjectWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, create_binding_object_, context_id,
                                                  native_binding_object, type, args, argc);
}

void DartMethodPointer::onJSError(bool is_dedicated, double context_id, const char* error) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] OnJSErrorWrapper call" << std::endl;
#endif

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, on_js_error_, context_id, error);
}

void DartMethodPointer::onJSLog(bool is_dedicated, double context_id, int32_t level, const char* log) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] OnJSLogWrapper call" << std::endl;
#endif
  if (on_js_log_ == nullptr)
    return;

  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, on_js_log_, context_id, level, log);
}

void DartMethodPointer::matchImageSnapshot(bool is_dedicated,
                                           void* callback_context,
                                           double context_id,
                                           uint8_t* bytes,
                                           int32_t length,
                                           SharedNativeString* name,
                                           MatchImageSnapshotCallback callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] matchImageSnapshot call" << std::endl;
#endif
  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, match_image_snapshot_, callback_context, context_id,
                                                  bytes, length, name, callback);
}

void DartMethodPointer::matchImageSnapshotBytes(bool is_dedicated,
                                                void* callback_context,
                                                double context_id,
                                                uint8_t* image_a_bytes,
                                                int32_t image_a_size,
                                                uint8_t* image_b_bytes,
                                                int32_t image_b_size,
                                                MatchImageSnapshotCallback callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] matchImageSnapshotBytes call" << std::endl;
#endif
  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, match_image_snapshot_bytes_, callback_context,
                                                  context_id, image_a_bytes, image_a_size, image_b_bytes, image_b_size,
                                                  callback);
}

const char* DartMethodPointer::environment(bool is_dedicated) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] matchImageSnapshotBytes call" << std::endl;
#endif
  return dart_isolate_context_->dispatcher()->PostToDartSync(is_dedicated, environment_);
}

void DartMethodPointer::simulatePointer(bool is_dedicated,
                                        void* ptr,
                                        MousePointer* mouse_pointer,
                                        int32_t length,
                                        int32_t pointer,
                                        AsyncCallback async_callback) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] simulatePointer call" << std::endl;
#endif
  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, simulate_pointer_, ptr, mouse_pointer, length, pointer,
                                                  async_callback);
}

void DartMethodPointer::simulateInputText(bool is_dedicated, SharedNativeString* nativeString) {
#if ENABLE_LOG
  WEBF_LOG(VERBOSE) << "[CPP] simulatePointer call" << std::endl;
#endif
  dart_isolate_context_->dispatcher()->PostToDart(is_dedicated, simulate_input_text_, nativeString);
}

void DartMethodPointer::SetOnJSError(webf::OnJSError func) {
  on_js_error_ = func;
}

void DartMethodPointer::SetMatchImageSnapshot(MatchImageSnapshot func) {
  match_image_snapshot_ = func;
}

void DartMethodPointer::SetMatchImageSnapshotBytes(MatchImageSnapshotBytes func) {
  match_image_snapshot_bytes_ = func;
}

void DartMethodPointer::SetEnvironment(Environment func) {
  environment_ = func;
}

void DartMethodPointer::SetSimulateInputText(SimulateInputText func) {
  simulate_input_text_ = func;
}

void DartMethodPointer::SetSimulatePointer(SimulatePointer func) {
  simulate_pointer_ = func;
}

}  // namespace webf
