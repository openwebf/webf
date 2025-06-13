/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_DEVTOOLS_REMOTE_OBJECT_H_
#define WEBF_CORE_DEVTOOLS_REMOTE_OBJECT_H_

#include <quickjs/quickjs.h>
#include <unordered_map>
#include <memory>
#include <string>
#include <vector>
#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"
#include "foundation/native_value.h"

namespace webf {

enum class RemoteObjectType {
  Object,
  Function,
  Array,
  Date,
  RegExp,
  Error,
  Promise,
  Map,
  Set,
  WeakMap,
  WeakSet,
  Symbol,
  BigInt,
  Undefined,
  Null,
  Boolean,
  Number,
  String
};

struct RemoteObjectProperty {
  std::string name;
  std::string value_id;  // ID of the remote value (empty for primitives)
  bool enumerable;
  bool configurable;
  bool writable;
  bool is_own;  // true for own properties, false for prototype properties
  bool is_primitive;  // true if this is a primitive value
  
  RemoteObjectProperty() 
    : enumerable(true), 
      configurable(true), 
      writable(true), 
      is_own(true),
      is_primitive(false) {}
};

class RemoteObject {
 public:
  RemoteObject(const std::string& id, 
               RemoteObjectType type,
               const std::string& class_name,
               const std::string& description);
  
  const std::string& id() const { return id_; }
  RemoteObjectType type() const { return type_; }
  const std::string& class_name() const { return class_name_; }
  const std::string& description() const { return description_; }
  
  void AddProperty(const RemoteObjectProperty& prop);
  const std::vector<RemoteObjectProperty>& properties() const { return properties_; }
  
 private:
  std::string id_;
  RemoteObjectType type_;
  std::string class_name_;
  std::string description_;
  std::vector<RemoteObjectProperty> properties_;
};

class RemoteObjectRegistry {
 public:
  // Get JSContext for this registry
  JSContext* GetJSContext() const { return ctx_; }
  
  // Register a JS value and return its remote ID
  std::string RegisterObject(JSContext* ctx, JSValue value);
  
  // Get object details by ID
  std::shared_ptr<RemoteObject> GetObjectDetails(const std::string& id);
  
  // Get object properties
  std::vector<RemoteObjectProperty> GetObjectProperties(const std::string& id, bool include_prototype = false);
  
  // Get primitive value for a property (must be called with the object_id and property name)
  JSValue GetPropertyValue(const std::string& object_id, const std::string& property_name);
  
  // Evaluate property access (e.g., "obj.prop.subprop")
  JSValue EvaluatePropertyPath(const std::string& object_id, const std::string& property_path);
  
  // Release an object reference
  void ReleaseObject(const std::string& id);
  
  // Clear all references for a context
  void ClearContext(ExecutingContext* context);
  
  // Constructor and destructor need to be public for std::make_unique
  explicit RemoteObjectRegistry(ExecutingContext* context);
  ~RemoteObjectRegistry();
  
 private:
  
  std::string GenerateObjectId();
  RemoteObjectType GetObjectType(JSContext* ctx, JSValue value);
  std::string GetObjectClassName(JSContext* ctx, JSValue value);
  std::string GetObjectDescription(JSContext* ctx, JSValue value);
  
  struct ObjectReference {
    JSValue value;
    JSContext* ctx;
    ExecutingContext* context;
  };
  
  std::unordered_map<std::string, ObjectReference> objects_;
  std::unordered_map<ExecutingContext*, std::vector<std::string>> context_objects_;
  uint64_t next_object_id_ = 1;
  ExecutingContext* context_;
  JSContext* ctx_;
};

// Helper to create a NativeValue containing remote object info
NativeValue CreateRemoteObjectValue(const std::string& object_id, 
                                   RemoteObjectType type,
                                   const std::string& class_name,
                                   const std::string& description);

}  // namespace webf

#endif  // WEBF_CORE_DEVTOOLS_REMOTE_OBJECT_H_