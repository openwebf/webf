/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_NATIVE_NATIVE_LOADER_H_
#define WEBF_CORE_NATIVE_NATIVE_LOADER_H_

#include "bindings/qjs/script_promise.h"
#include "bindings/qjs/script_wrappable.h"

namespace webf {

class ScriptPromiseResolver;
class WebFNativeFunction;

struct NativeLibraryLoadContext {
  ExecutingContext* context{nullptr};
  std::shared_ptr<ScriptPromiseResolver> promise_resolver{nullptr};
};

struct NativeLibraryMetaDataCallback {
  int32_t callback_id;
  std::shared_ptr<WebFNativeFunction> callback;

  NativeLibraryMetaDataCallback(int32_t id, std::shared_ptr<WebFNativeFunction> cb) : callback_id(id), callback(cb) {}
};

struct NativeLibraryMetaData {
  NativeValue* lib_name;
  NativeLibraryLoadContext* load_context;
  int32_t unique_id_{0};
  std::vector<NativeLibraryMetaDataCallback> callbacks;
  std::vector<int32_t> removed_callbacks;
};

class NativeLoader : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = NativeLoader*;

  NativeLoader() = delete;
  explicit NativeLoader(ExecutingContext* context);

  ScriptPromise loadNativeLibrary(const AtomicString& lib_name,
                                  const ScriptValue& import_object,
                                  ExceptionState& exception_state);
};

}  // namespace webf

#endif  // WEBF_CORE_NATIVE_NATIVE_LOADER_H_
