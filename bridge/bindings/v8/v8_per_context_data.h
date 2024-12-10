/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_V8_PER_CONTEXT_DATA_H
#define WEBF_V8_PER_CONTEXT_DATA_H

#include <v8/v8.h>
#include <memory>
#include "heap/garbage_collected.h"
#include "heap/member.h"
#include "scoped_persistent.h"

namespace webf {

/* TODO support V8DOMActivityLogger
class V8DOMActivityLogger;
 */
class V8PerContextData;

/* TODO support WrapperTypeInfo
struct WrapperTypeInfo;
*/

// Used to hold data that is associated with a single v8::Context object, and
// has a 1:1 relationship with v8::Context.
class V8PerContextData final : public GarbageCollected<V8PerContextData> {
 public:
  explicit V8PerContextData(v8::Local<v8::Context>);

  V8PerContextData(const V8PerContextData&) = delete;

  V8PerContextData& operator=(const V8PerContextData&) = delete;

  ~V8PerContextData();

  void Trace(Visitor* visitor) const;

  void Dispose();

  v8::Local<v8::Context> GetContext() { return context_.NewLocal(isolate_); }

  /* TODO support WrapperTypeInfo
  // To create JS Wrapper objects, we create a cache of a 'boiler plate'
  // object, and then simply Clone that object each time we need a new one.
  // This is faster than going through the full object creation process.
  v8::Local<v8::Object> CreateWrapperFromCache(v8::Isolate *isolate,
                                               const WrapperTypeInfo *type) {
      if (auto it = wrapper_boilerplates_.find(type);
              it != wrapper_boilerplates_.end()) {
          v8::Local<v8::Object> obj = it->second.Get(isolate_);
          return obj->Clone();
      }
      return CreateWrapperFromCacheSlowCase(isolate, type);
  }

  // Returns the interface object that is appropriately initialized (e.g.
  // context-dependent properties are installed).
  v8::Local<v8::Function> ConstructorForType(const WrapperTypeInfo *type) {
      auto it = constructor_map_.find(type);
      return it != constructor_map_.end() ? it->second.Get(isolate_)
                                          : ConstructorForTypeSlowCase(type);
  }

  v8::Local<v8::Object> PrototypeForType(const WrapperTypeInfo *);

  // Gets the constructor and prototype for a type, if they have already been
  // created. Returns true if they exist, and sets the existing values in
  // |prototypeObject| and |interfaceObject|. Otherwise, returns false, and the
  // values are set to empty objects (non-null).
  bool GetExistingConstructorAndPrototypeForType(
          const WrapperTypeInfo *,
          v8::Local<v8::Object> *prototype_object,
          v8::Local<v8::Function> *interface_object);
  */

  /*TODO support V8DOMActivityLogger
  V8DOMActivityLogger* ActivityLogger() const { return activity_logger_; }
  void SetActivityLogger(V8DOMActivityLogger* activity_logger) {
      activity_logger_ = activity_logger;
  }
  */

  // Garbage collected classes that use V8PerContextData to hold an instance
  // should subclass Data, and use addData / clearData / getData to manage the
  // instance.
  class Data : public GarbageCollectedMixin {};

  void AddData(const char* key, Data*);

  void ClearData(const char* key);

  Data* GetData(const char* key);

 private:
  /* TODO support WrapperTypeInfo
  v8::Local<v8::Object> CreateWrapperFromCacheSlowCase(v8::Isolate *,
                                                       const WrapperTypeInfo *);

  v8::Local<v8::Function> ConstructorForTypeSlowCase(const WrapperTypeInfo *);
  */

  v8::Isolate* isolate_;

  /* TODO support WrapperTypeInfo
  // For each possible type of wrapper, we keep a boilerplate object.
  // The boilerplate is used to create additional wrappers of the same type.
  std::unordered_map<const WrapperTypeInfo *, v8::TracedReference<v8::Object>> wrapper_boilerplates_;

  std::unordered_map<const WrapperTypeInfo *, v8::TracedReference<v8::Function>> constructor_map_;
  */

  /*TODO support ContextHolder
  std::unique_ptr<gin::ContextHolder> context_holder_;
  */
  ScopedPersistent<v8::Context> context_;

  /* TODO support V8DOMActivityLogger
  // This is owned by a static hash map in V8DOMActivityLogger.
  V8DOMActivityLogger* activity_logger_;
  */

  using DataMap = std::unordered_map<const char*, Member<Data>>;
  DataMap data_map_;
};

}  // namespace webf

#endif  // WEBF_V8_PER_CONTEXT_DATA_H
