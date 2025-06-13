/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "remote_object.h"
#include <sstream>
#include "core/executing_context.h"

namespace webf {

RemoteObject::RemoteObject(const std::string& id, 
                         RemoteObjectType type,
                         const std::string& class_name,
                         const std::string& description)
    : id_(id), type_(type), class_name_(class_name), description_(description) {}

void RemoteObject::AddProperty(const RemoteObjectProperty& prop) {
  properties_.push_back(prop);
}

RemoteObjectRegistry::RemoteObjectRegistry(ExecutingContext* context) 
    : context_(context), ctx_(context->ctx()) {
}

RemoteObjectRegistry::~RemoteObjectRegistry() {
  // Release all JS values
  for (auto& pair : objects_) {
    JS_FreeValue(pair.second.ctx, pair.second.value);
  }
}

std::string RemoteObjectRegistry::RegisterObject(JSContext* ctx, JSValue value) {
  // For primitive values, return a special ID
  if (JS_IsNull(value) || JS_IsUndefined(value) || 
      JS_IsBool(value) || JS_IsNumber(value) || JS_IsString(value)) {
    // For primitives, we'll handle them differently
    return "";
  }
  
  std::string id = GenerateObjectId();
  
  // Duplicate the value to keep a reference
  JSValue dup_value = JS_DupValue(ctx, value);
  
  ExecutingContext* context = ExecutingContext::From(ctx);
  objects_[id] = {dup_value, ctx, context};
  
  // Track by context for cleanup
  context_objects_[context].push_back(id);
  
  return id;
}

std::shared_ptr<RemoteObject> RemoteObjectRegistry::GetObjectDetails(const std::string& id) {
  auto it = objects_.find(id);
  if (it == objects_.end()) {
    return nullptr;
  }
  
  JSContext* ctx = it->second.ctx;
  JSValue value = it->second.value;
  
  RemoteObjectType type = GetObjectType(ctx, value);
  std::string class_name = GetObjectClassName(ctx, value);
  std::string description = GetObjectDescription(ctx, value);
  
  return std::make_shared<RemoteObject>(id, type, class_name, description);
}

std::vector<RemoteObjectProperty> RemoteObjectRegistry::GetObjectProperties(const std::string& id, bool include_prototype) {
  std::vector<RemoteObjectProperty> properties;
  
  auto it = objects_.find(id);
  if (it == objects_.end()) {
    return properties;
  }
  
  JSContext* ctx = it->second.ctx;
  JSValue obj = it->second.value;
  
  // Get own properties
  JSPropertyEnum* props = nullptr;
  uint32_t prop_count = 0;
  
  int flags = JS_GPN_STRING_MASK | JS_GPN_SYMBOL_MASK;
  if (include_prototype) {
    flags |= JS_GPN_ENUM_ONLY;
  }
  
  if (JS_GetOwnPropertyNames(ctx, &props, &prop_count, obj, flags) >= 0) {
    for (uint32_t i = 0; i < prop_count; i++) {
      JSAtom atom = props[i].atom;
      
      // Check if this atom is a symbol
      JSValue atom_value = JS_AtomToValue(ctx, atom);
      bool is_symbol = JS_IsSymbol(atom_value);
      
      std::string prop_name;
      if (is_symbol) {
        // For symbols, format as Symbol(description)
        JSValue desc_val = JS_GetPropertyStr(ctx, atom_value, "description");
        if (!JS_IsUndefined(desc_val)) {
          const char* desc = JS_ToCString(ctx, desc_val);
          if (desc) {
            prop_name = "Symbol(" + std::string(desc) + ")";
            JS_FreeCString(ctx, desc);
          } else {
            prop_name = "Symbol()";
          }
        } else {
          prop_name = "Symbol()";
        }
        JS_FreeValue(ctx, desc_val);
      } else {
        // For regular string properties
        const char* key = JS_AtomToCString(ctx, atom);
        prop_name = key;
        JS_FreeCString(ctx, key);
      }
      JS_FreeValue(ctx, atom_value);
      
      JSValue prop_value = JS_GetProperty(ctx, obj, atom);
      
      RemoteObjectProperty prop;
      prop.name = prop_name;
      prop.is_own = true;
      
      // Handle primitive values directly
      if (JS_IsNull(prop_value) || JS_IsUndefined(prop_value) || 
          JS_IsBool(prop_value) || JS_IsNumber(prop_value) || JS_IsString(prop_value)) {
        // For primitives, store the actual value in the property
        prop.value_id = "";  // Empty ID for primitives
        prop.primitive_value = JS_DupValue(ctx, prop_value);  // Duplicate the value
        prop.has_primitive_value = true;
      } else {
        // For objects, register them and store the ID
        prop.value_id = RegisterObject(ctx, prop_value);
        prop.primitive_value = JS_UNDEFINED;
        prop.has_primitive_value = false;
      }
      
      // Get property descriptor
      JSPropertyDescriptor desc;
      if (JS_GetOwnProperty(ctx, &desc, obj, atom) >= 0) {
        prop.enumerable = (desc.flags & JS_PROP_ENUMERABLE) != 0;
        prop.configurable = (desc.flags & JS_PROP_CONFIGURABLE) != 0;
        prop.writable = (desc.flags & JS_PROP_WRITABLE) != 0;
        // Free the property descriptor values
        JS_FreeValue(ctx, desc.value);
        JS_FreeValue(ctx, desc.getter);
        JS_FreeValue(ctx, desc.setter);
      }
      
      properties.push_back(prop);
      
      JS_FreeValue(ctx, prop_value);
    }
    
    js_free(ctx, props);
  }
  
  // Get prototype properties if requested
  if (include_prototype) {
    JSValue proto = JS_GetPrototype(ctx, obj);
    
    // Only get properties from the immediate prototype (one level)
    if (!JS_IsNull(proto) && !JS_IsUndefined(proto)) {
      // Add a special [[Prototype]] property that represents the prototype object
      RemoteObjectProperty prototype_prop;
      prototype_prop.name = "[[Prototype]]";
      prototype_prop.is_own = false;
      prototype_prop.enumerable = false;
      prototype_prop.configurable = false;
      prototype_prop.writable = false;
      prototype_prop.has_primitive_value = false;
      prototype_prop.primitive_value = JS_UNDEFINED;
      
      // Register the prototype object itself
      prototype_prop.value_id = RegisterObject(ctx, proto);
      properties.push_back(prototype_prop);
      
      JS_FreeValue(ctx, proto);
    }
  }
  
  return properties;
}

JSValue RemoteObjectRegistry::EvaluatePropertyPath(const std::string& object_id, const std::string& property_path) {
  auto it = objects_.find(object_id);
  if (it == objects_.end()) {
    return JS_UNDEFINED;
  }
  
  JSContext* ctx = it->second.ctx;
  JSValue current = JS_DupValue(ctx, it->second.value);
  
  // Split property path by '.'
  std::stringstream ss(property_path);
  std::string segment;
  
  while (std::getline(ss, segment, '.')) {
    if (segment.empty()) continue;
    
    // Check if current value is undefined or null before property access
    if (JS_IsUndefined(current) || JS_IsNull(current)) {
      JS_FreeValue(ctx, current);
      return JS_UNDEFINED;
    }
    
    JSValue next = JS_GetPropertyStr(ctx, current, segment.c_str());
    JS_FreeValue(ctx, current);
    current = next;
    
    if (JS_IsException(current)) {
      // Clear the exception to avoid assertion failure during cleanup
      JS_GetException(ctx);
      return JS_UNDEFINED;
    }
  }
  
  return current;
}

void RemoteObjectRegistry::ReleaseObject(const std::string& id) {
  auto it = objects_.find(id);
  if (it != objects_.end()) {
    JS_FreeValue(it->second.ctx, it->second.value);
    
    // Remove from context tracking
    auto& context_objs = context_objects_[it->second.context];
    context_objs.erase(std::remove(context_objs.begin(), context_objs.end(), id), 
                      context_objs.end());
    
    objects_.erase(it);
  }
}

void RemoteObjectRegistry::ClearContext(ExecutingContext* context) {
  auto it = context_objects_.find(context);
  if (it != context_objects_.end()) {
    for (const auto& id : it->second) {
      auto obj_it = objects_.find(id);
      if (obj_it != objects_.end()) {
        JS_FreeValue(obj_it->second.ctx, obj_it->second.value);
        objects_.erase(obj_it);
      }
    }
    context_objects_.erase(it);
  }
}

std::string RemoteObjectRegistry::GenerateObjectId() {
  return "remote-object-" + std::to_string(next_object_id_++);
}

RemoteObjectType RemoteObjectRegistry::GetObjectType(JSContext* ctx, JSValue value) {
  if (JS_IsUndefined(value)) return RemoteObjectType::Undefined;
  if (JS_IsNull(value)) return RemoteObjectType::Null;
  if (JS_IsBool(value)) return RemoteObjectType::Boolean;
  if (JS_IsNumber(value)) return RemoteObjectType::Number;
  if (JS_IsString(value)) return RemoteObjectType::String;
  if (JS_IsSymbol(value)) return RemoteObjectType::Symbol;
  if (JS_IsBigInt(ctx, value)) return RemoteObjectType::BigInt;
  if (JS_IsFunction(ctx, value)) return RemoteObjectType::Function;
  if (JS_IsArray(ctx, value) > 0) return RemoteObjectType::Array;
  
  // Check for specific object types
  JSValue ctor = JS_GetPropertyStr(ctx, value, "constructor");
  if (!JS_IsUndefined(ctor)) {
    JSValue name = JS_GetPropertyStr(ctx, ctor, "name");
    if (JS_IsString(name)) {
      const char* name_str = JS_ToCString(ctx, name);
      std::string type_name(name_str);
      JS_FreeCString(ctx, name_str);
      
      if (type_name == "Date") return RemoteObjectType::Date;
      if (type_name == "RegExp") return RemoteObjectType::RegExp;
      if (type_name == "Error") return RemoteObjectType::Error;
      if (type_name == "Promise") return RemoteObjectType::Promise;
      if (type_name == "Map") return RemoteObjectType::Map;
      if (type_name == "Set") return RemoteObjectType::Set;
      if (type_name == "WeakMap") return RemoteObjectType::WeakMap;
      if (type_name == "WeakSet") return RemoteObjectType::WeakSet;
    }
    JS_FreeValue(ctx, name);
  }
  JS_FreeValue(ctx, ctor);
  
  return RemoteObjectType::Object;
}

std::string RemoteObjectRegistry::GetObjectClassName(JSContext* ctx, JSValue value) {
  if (JS_IsFunction(ctx, value)) {
    JSValue name = JS_GetPropertyStr(ctx, value, "name");
    if (JS_IsString(name)) {
      const char* name_str = JS_ToCString(ctx, name);
      std::string result = name_str ? name_str : "(anonymous)";
      JS_FreeCString(ctx, name_str);
      JS_FreeValue(ctx, name);
      return "Function: " + result;
    }
    JS_FreeValue(ctx, name);
    return "Function";
  }
  
  if (JS_IsArray(ctx, value)) {
    return "Array";
  }
  
  // Get the constructor from the object's constructor property
  JSValue ctor = JS_GetPropertyStr(ctx, value, "constructor");
  if (!JS_IsUndefined(ctor) && JS_IsFunction(ctx, ctor)) {
    JSValue name = JS_GetPropertyStr(ctx, ctor, "name");
    if (JS_IsString(name)) {
      const char* name_str = JS_ToCString(ctx, name);
      std::string result = name_str ? name_str : "Object";
      JS_FreeCString(ctx, name_str);
      JS_FreeValue(ctx, name);
      JS_FreeValue(ctx, ctor);
      return result;
    }
    JS_FreeValue(ctx, name);
  }
  JS_FreeValue(ctx, ctor);
  
  return "Object";
}

std::string RemoteObjectRegistry::GetObjectDescription(JSContext* ctx, JSValue value) {
  RemoteObjectType type = GetObjectType(ctx, value);
  
  switch (type) {
    case RemoteObjectType::Undefined:
      return "undefined";
    case RemoteObjectType::Null:
      return "null";
    case RemoteObjectType::Boolean: {
      int bool_val = JS_ToBool(ctx, value);
      return bool_val ? "true" : "false";
    }
    case RemoteObjectType::Number: {
      double num;
      JS_ToFloat64(ctx, &num, value);
      return std::to_string(num);
    }
    case RemoteObjectType::String: {
      const char* str = JS_ToCString(ctx, value);
      std::string result = str ? str : "";
      JS_FreeCString(ctx, str);
      return "\"" + result + "\"";
    }
    case RemoteObjectType::Array: {
      JSValue length_val = JS_GetPropertyStr(ctx, value, "length");
      int64_t length = 0;
      JS_ToInt64(ctx, &length, length_val);
      JS_FreeValue(ctx, length_val);
      return "Array(" + std::to_string(length) + ")";
    }
    case RemoteObjectType::Function: {
      std::string class_name = GetObjectClassName(ctx, value);
      return "ƒ " + class_name + "()";
    }
    default: {
      std::string class_name = GetObjectClassName(ctx, value);
      return class_name + " {...}";
    }
  }
}

NativeValue CreateRemoteObjectValue(const std::string& object_id, 
                                   RemoteObjectType type,
                                   const std::string& class_name,
                                   const std::string& description) {
  // Create a JSON object with remote object info
  std::stringstream json;
  json << "{";
  json << "\"type\":\"remote-object\",";
  json << "\"objectId\":\"" << object_id << "\",";
  json << "\"objectType\":" << static_cast<int>(type) << ",";
  json << "\"className\":\"" << class_name << "\",";
  json << "\"description\":\"" << description << "\"";
  json << "}";
  
  return Native_NewCString(json.str());
}

}  // namespace webf