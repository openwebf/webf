/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/


#ifndef WEBF_BINDINGS_V8_PER_CONTEXT_DATA_H_
#define WEBF_BINDINGS_V8_PER_CONTEXT_DATA_H_

#include <memory>

//#include "base/memory/raw_ptr.h"
//#include "gin/public/context_holder.h"
//#include "gin/public/gin_embedders.h"
//#include "third_party/blink/renderer/platform/bindings/scoped_persistent.h"
//#include "third_party/blink/renderer/platform/bindings/trace_wrapper_v8_reference.h"
//#include "third_party/blink/renderer/platform/heap/collection_support/heap_hash_map.h"
//#include "third_party/blink/renderer/platform/heap/garbage_collected.h"
//#include "third_party/blink/renderer/platform/heap/persistent.h"
//#include "third_party/blink/renderer/platform/platform_export.h"
//#include "third_party/blink/renderer/platform/wtf/text/atomic_string.h"
//#include "third_party/blink/renderer/platform/wtf/text/atomic_string_hash.h"
//#include "third_party/blink/renderer/platform/wtf/vector.h"
//#include "v8/include/v8.h"
#include <v8/v8.h>
#include "bindings/v8/platform/heap/garbage_collected.h"
#include "bindings/v8/base/allocator/partition_allocator/src/partition_alloc/pointers/raw_ptr.h"
#include "bindings/v8/trace_wrapper_v8_reference.h"
#include "bindings/v8/platform/scoped_persistent.h"

namespace webf {

class V8DOMActivityLogger;
class V8PerContextData;
struct WrapperTypeInfo;

// Used to hold data that is associated with a single v8::Context object, and
// has a 1:1 relationship with v8::Context.
class V8PerContextData final
    : public GarbageCollected<V8PerContextData> {
 public:
  explicit V8PerContextData(v8::Local<v8::Context>);
  V8PerContextData(const V8PerContextData&) = delete;
  V8PerContextData& operator=(const V8PerContextData&) = delete;

  ~V8PerContextData();

  void Trace(Visitor* visitor) const;
  void Dispose();

  v8::Local<v8::Context> GetContext() { return context_.NewLocal(isolate_); }

  // To create JS Wrapper objects, we create a cache of a 'boiler plate'
  // object, and then simply Clone that object each time we need a new one.
  // This is faster than going through the full object creation process.
  v8::Local<v8::Object> CreateWrapperFromCache(const WrapperTypeInfo* type) {
    if (auto it = wrapper_boilerplates_.find(type);
        it != wrapper_boilerplates_.end()) {
      v8::Local<v8::Object> obj = it->value.Get(isolate_);
      return obj->Clone();
    }
    return CreateWrapperFromCacheSlowCase(type);
  }

  // Returns the interface object that is appropriately initialized (e.g.
  // context-dependent properties are installed).
  v8::Local<v8::Function> ConstructorForType(const WrapperTypeInfo* type) {
    auto it = constructor_map_.find(type);
    return it != constructor_map_.end() ? it->value.Get(isolate_)
                                        : ConstructorForTypeSlowCase(type);
  }

  v8::Local<v8::Object> PrototypeForType(const WrapperTypeInfo*);

  // Gets the constructor and prototype for a type, if they have already been
  // created. Returns true if they exist, and sets the existing values in
  // |prototypeObject| and |interfaceObject|. Otherwise, returns false, and the
  // values are set to empty objects (non-null).
  bool GetExistingConstructorAndPrototypeForType(
      const WrapperTypeInfo*,
      v8::Local<v8::Object>* prototype_object,
      v8::Local<v8::Function>* interface_object);

  V8DOMActivityLogger* ActivityLogger() const { return activity_logger_; }
  void SetActivityLogger(V8DOMActivityLogger* activity_logger) {
    activity_logger_ = activity_logger;
  }

  // Garbage collected classes that use V8PerContextData to hold an instance
  // should subclass Data, and use addData / clearData / getData to manage the
  // instance.
  class Data : public GarbageCollectedMixin {};

  void AddData(const char* key, Data*);
  void ClearData(const char* key);
  Data* GetData(const char* key);

 private:
  v8::Local<v8::Object> CreateWrapperFromCacheSlowCase(const WrapperTypeInfo*);
  v8::Local<v8::Function> ConstructorForTypeSlowCase(const WrapperTypeInfo*);

  const raw_ptr<v8::Isolate> isolate_;

  // For each possible type of wrapper, we keep a boilerplate object.
  // The boilerplate is used to create additional wrappers of the same type.
  HeapHashMap<const WrapperTypeInfo*, TraceWrapperV8Reference<v8::Object>>
      wrapper_boilerplates_;

  HeapHashMap<const WrapperTypeInfo*, TraceWrapperV8Reference<v8::Function>>
      constructor_map_;

  std::unique_ptr<gin::ContextHolder> context_holder_;

  ScopedPersistent<v8::Context> context_;

  // This is owned by a static hash map in V8DOMActivityLogger.
  raw_ptr<V8DOMActivityLogger, DanglingUntriaged> activity_logger_;

  using DataMap = HeapHashMap<const char*, Member<Data>>;
  DataMap data_map_;
};

}  // namespace webf

#endif  // WEBF_BINDINGS_V8_PER_CONTEXT_DATA_H_

