/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_PLATFORM_BINDINGS_V8_OBJECT_CONSTRUCTOR_H_
#define WEBF_PLATFORM_BINDINGS_V8_OBJECT_CONSTRUCTOR_H_

#include <v8/v8.h>
#include "foundation/macros.h"
// #include "v8_per_isolate_data.h"

namespace webf {

class ConstructorMode {
  WEBF_STACK_ALLOCATED();

 public:
  enum Mode { kWrapExistingObject, kCreateNewObject };

  ConstructorMode(v8::Isolate* isolate) : isolate_(isolate) {
    /*TODO support V8PerIsolateData
    V8PerIsolateData *data = V8PerIsolateData::From(isolate_);
    previous_ = data->constructor_mode_;
    data->constructor_mode_ = kWrapExistingObject;
     */
  }

  ~ConstructorMode() {
    /*TODO support V8PerIsolateData
    V8PerIsolateData *data = V8PerIsolateData::From(isolate_);
    data->constructor_mode_ = previous_;
     */
  }

  static bool Current(v8::Isolate* isolate) {
    /*TODO support V8PerIsolateData
    return V8PerIsolateData::From(isolate)->constructor_mode_;
     */
    return false;
  }

 private:
  v8::Isolate* isolate_;
  bool previous_;
};

class V8ObjectConstructor {
  WEBF_STATIC_ONLY(V8ObjectConstructor);

 public:
  enum class CreationMode {
    kInstallConditionalFeatures,
    kDoNotInstallConditionalFeatures,
  };

  static v8::MaybeLocal<v8::Object> NewInstance(v8::Isolate*,
                                                v8::Local<v8::Function>,
                                                int argc = 0,
                                                v8::Local<v8::Value> argv[] = nullptr);

  static void IsValidConstructorMode(const v8::FunctionCallbackInfo<v8::Value>&);

  // Returns the interface object of the wrapper type in the context. If you
  // call with CreationMode::kDoNotInstallConditionalFeatures, no conditional
  // features are installed.
  /*TODO support CreateInterfaceObject
  static v8::Local<v8::Function> CreateInterfaceObject(
          const WrapperTypeInfo *,
          v8::Local<v8::Context>,
          v8::Isolate *,
          v8::Local<v8::Function> parent_interface,
          CreationMode);
  */
};

}  // namespace webf

#endif  // WEBF_PLATFORM_BINDINGS_V8_OBJECT_CONSTRUCTOR_H_
