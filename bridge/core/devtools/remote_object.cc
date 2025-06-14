/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "remote_object.h"
#include <sstream>
#include <set>
#include <algorithm>
#include <cctype>
#include <cstring>
#include "core/executing_context.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/wrapper_type_info.h"
#include "core/dom/element.h"
#include "core/dom/node.h"
#include "core/dom/container_node.h"
#include "core/dom/events/event_target.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "foundation/native_value.h"

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
  
  // Check if this is an Element object - if so, return child nodes instead
  // Check for nodeType property to determine if it's a DOM node
  JSValue nodeTypeValue = JS_GetPropertyStr(ctx, obj, "nodeType");
  if (!JS_IsUndefined(nodeTypeValue) && !JS_IsException(nodeTypeValue) && JS_IsNumber(nodeTypeValue)) {
    int32_t nodeType = 0;
    JS_ToInt32(ctx, &nodeType, nodeTypeValue);
    JS_FreeValue(ctx, nodeTypeValue);
    
    // Element node (1) or DocumentFragment (11) - show child nodes
    if (nodeType == 1 || nodeType == 11) {
      return GetChildNodes(id);
    }
  } else {
    JS_FreeValue(ctx, nodeTypeValue);
  }
  
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
      prop.is_symbol = is_symbol;
      prop.property_index = i;  // Store the index for later retrieval
      
      // Handle primitive values directly
      if (JS_IsNull(prop_value) || JS_IsUndefined(prop_value) || 
          JS_IsBool(prop_value) || JS_IsNumber(prop_value) || JS_IsString(prop_value)) {
        // For primitives, we don't register them
        prop.value_id = "";  // Empty ID for primitives
        prop.is_primitive = true;
      } else {
        // For objects, register them and store the ID
        prop.value_id = RegisterObject(ctx, prop_value);
        prop.is_primitive = false;
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
    // Keep track of properties we've already seen to avoid duplicates
    std::set<std::string> seen_properties;
    for (const auto& prop : properties) {
      seen_properties.insert(prop.name);
    }
    
    // Walk up the prototype chain
    JSValue current_proto = JS_GetPrototype(ctx, obj);
    
    while (!JS_IsNull(current_proto) && !JS_IsUndefined(current_proto)) {
      // Get properties from current prototype
      JSPropertyEnum* proto_props = nullptr;
      uint32_t proto_prop_count = 0;
      
      if (JS_GetOwnPropertyNames(ctx, &proto_props, &proto_prop_count, current_proto, 
                                 JS_GPN_STRING_MASK | JS_GPN_SYMBOL_MASK | JS_GPN_ENUM_ONLY) >= 0) {
        for (uint32_t i = 0; i < proto_prop_count; i++) {
          JSAtom atom = proto_props[i].atom;
          
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
          
          // Skip if we've already seen this property
          if (seen_properties.find(prop_name) != seen_properties.end()) {
            continue;
          }
          seen_properties.insert(prop_name);
          
          // Get property value using the original object as receiver for correct 'this' binding
          JSValue prop_value = JS_GetProperty(ctx, obj, atom);
          
          RemoteObjectProperty prop;
          prop.name = prop_name;
          prop.is_own = false;  // These are prototype properties
          prop.is_symbol = is_symbol;
          prop.property_index = -1;  // Not applicable for prototype properties
          
          // Handle primitive values directly
          if (JS_IsNull(prop_value) || JS_IsUndefined(prop_value) || 
              JS_IsBool(prop_value) || JS_IsNumber(prop_value) || JS_IsString(prop_value)) {
            // For primitives, we don't register them
            prop.value_id = "";  // Empty ID for primitives
            prop.is_primitive = true;
          } else {
            // For objects, register them and store the ID
            prop.value_id = RegisterObject(ctx, prop_value);
            prop.is_primitive = false;
          }
          
          // Get property descriptor from prototype
          JSPropertyDescriptor desc;
          if (JS_GetOwnProperty(ctx, &desc, current_proto, atom) >= 0) {
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
        
        js_free(ctx, proto_props);
      }
      
      // Move to next prototype in chain
      JSValue next_proto = JS_GetPrototype(ctx, current_proto);
      JS_FreeValue(ctx, current_proto);
      current_proto = next_proto;
    }
    
    if (!JS_IsNull(current_proto)) {
      JS_FreeValue(ctx, current_proto);
    }
    
    // Add a special [[Prototype]] property that represents the immediate prototype object
    JSValue proto = JS_GetPrototype(ctx, obj);
    if (!JS_IsNull(proto) && !JS_IsUndefined(proto)) {
      RemoteObjectProperty prototype_prop;
      prototype_prop.name = "[[Prototype]]";
      prototype_prop.is_own = false;
      prototype_prop.enumerable = false;
      prototype_prop.configurable = false;
      prototype_prop.writable = false;
      prototype_prop.is_primitive = false;
      prototype_prop.is_symbol = false;
      prototype_prop.property_index = -1;
      
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
  
  // Check for specific object types using class ID
  if (JS_IsObject(value)) {
    JSClassID class_id = JS_GetClassID(value);
    switch (class_id) {
      case JS_CLASS_DATE:
        return RemoteObjectType::Date;
      case JS_CLASS_REGEXP:
        return RemoteObjectType::RegExp;
      case JS_CLASS_ERROR:
        return RemoteObjectType::Error;
      // Other types still need constructor check
      default:
        break;
    }
    
    // For types not covered by class ID, check constructor name
    JSValue ctor = JS_GetPropertyStr(ctx, value, "constructor");
    if (!JS_IsUndefined(ctor)) {
      JSValue name = JS_GetPropertyStr(ctx, ctor, "name");
      if (JS_IsString(name)) {
        const char* name_str = JS_ToCString(ctx, name);
        std::string type_name(name_str);
        JS_FreeCString(ctx, name_str);
        
        if (type_name == "Promise") return RemoteObjectType::Promise;
        if (type_name == "Map") return RemoteObjectType::Map;
        if (type_name == "Set") return RemoteObjectType::Set;
        if (type_name == "WeakMap") return RemoteObjectType::WeakMap;
        if (type_name == "WeakSet") return RemoteObjectType::WeakSet;
      }
      JS_FreeValue(ctx, name);
    }
    JS_FreeValue(ctx, ctor);
  }
  
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
  
  // Check for specific object types using class ID first
  if (JS_IsObject(value)) {
    JSClassID class_id = JS_GetClassID(value);
    switch (class_id) {
      case JS_CLASS_DATE:
        return "Date";
      case JS_CLASS_REGEXP:
        return "RegExp";
      case JS_CLASS_ERROR:
        return "Error";
      default:
        break;
    }
    
    // For WebF objects, try to determine type from nodeType property
    JSValue nodeTypeValue = JS_GetPropertyStr(ctx, value, "nodeType");
    if (!JS_IsUndefined(nodeTypeValue) && !JS_IsException(nodeTypeValue) && JS_IsNumber(nodeTypeValue)) {
      int32_t nodeType = 0;
      JS_ToInt32(ctx, &nodeType, nodeTypeValue);
      JS_FreeValue(ctx, nodeTypeValue);
      
      // Map nodeType to class name
      switch (nodeType) {
        case 1: { // Element node
          // Try to get tag name for more specific class name
          JSValue tagNameValue = JS_GetPropertyStr(ctx, value, "tagName");
          if (!JS_IsUndefined(tagNameValue) && !JS_IsException(tagNameValue) && JS_IsString(tagNameValue)) {
            const char* tagName = JS_ToCString(ctx, tagNameValue);
            if (tagName != nullptr) {
              std::string result;
              // Convert tag name to proper class name format
              if (strncmp(tagName, "HTML", 4) != 0) {
                result = "HTML" + std::string(tagName) + "Element";
              } else {
                result = std::string(tagName) + "Element";
              }
              JS_FreeCString(ctx, tagName);
              JS_FreeValue(ctx, tagNameValue);
              return result;
            }
            JS_FreeValue(ctx, tagNameValue);
          }
          return "Element";
        }
        case 3:  // Text node
          return "Text";
        case 8:  // Comment node
          return "Comment";
        case 9:  // Document node
          return "Document";
        case 11: // DocumentFragment
          return "DocumentFragment";
        default:
          break;
      }
    } else {
      JS_FreeValue(ctx, nodeTypeValue);
    }
  }
  
  // Get the constructor from the object's constructor property
  JSValue ctor = JS_GetPropertyStr(ctx, value, "constructor");
  if (!JS_IsUndefined(ctor) && !JS_IsException(ctor)) {
    JSValue name = JS_GetPropertyStr(ctx, ctor, "name");
    if (!JS_IsException(name) && JS_IsString(name)) {
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
      // Check if this is an Element or Node object
      if (JS_IsObject(value)) {
        // Get the class ID to check if it's a WebF object
        JSClassID class_id = JS_GetClassID(value);
        
        // Check if this value has opaque data (WebF objects have opaque data)
        if (class_id != 0 && class_id != JS_CLASS_OBJECT) {
          void* opaque = JS_GetOpaque(value, class_id);
          if (opaque != nullptr) {
            // For WebF objects, we need to check if they are DOM nodes
            // We can check for specific properties that DOM nodes have
            
            // Check for nodeType property (all DOM nodes have this)
            JSValue nodeTypeValue = JS_GetPropertyStr(ctx, value, "nodeType");
            if (!JS_IsUndefined(nodeTypeValue) && !JS_IsException(nodeTypeValue) && JS_IsNumber(nodeTypeValue)) {
              int32_t nodeType = 0;
              JS_ToInt32(ctx, &nodeType, nodeTypeValue);
              JS_FreeValue(ctx, nodeTypeValue);
              
              if (nodeType == 1) {  // Element node
                // For Element nodes, construct a description that shows just the opening tag
                // Get tag name
                JSValue tagNameValue = JS_GetPropertyStr(ctx, value, "tagName");
                if (!JS_IsUndefined(tagNameValue) && !JS_IsException(tagNameValue) && JS_IsString(tagNameValue)) {
                  const char* tagName = JS_ToCString(ctx, tagNameValue);
                  if (tagName != nullptr) {
                    std::string tagStr = tagName;
                    // Convert to lowercase for consistency
                    std::transform(tagStr.begin(), tagStr.end(), tagStr.begin(), ::tolower);
                    JS_FreeCString(ctx, tagName);
                    JS_FreeValue(ctx, tagNameValue);
                    
                    // Build opening tag with key attributes
                    std::string result = "<" + tagStr;
                    
                    // Add id if present
                    JSValue idValue = JS_GetPropertyStr(ctx, value, "id");
                    if (!JS_IsUndefined(idValue) && !JS_IsException(idValue) && JS_IsString(idValue)) {
                      const char* id = JS_ToCString(ctx, idValue);
                      if (id != nullptr && strlen(id) > 0) {
                        result += " id=\"" + std::string(id) + "\"";
                        JS_FreeCString(ctx, id);
                      }
                    }
                    JS_FreeValue(ctx, idValue);
                    
                    // Add class if present
                    JSValue classValue = JS_GetPropertyStr(ctx, value, "className");
                    if (!JS_IsUndefined(classValue) && !JS_IsException(classValue) && JS_IsString(classValue)) {
                      const char* className = JS_ToCString(ctx, classValue);
                      if (className != nullptr && strlen(className) > 0) {
                        result += " class=\"" + std::string(className) + "\"";
                        JS_FreeCString(ctx, className);
                      }
                    }
                    JS_FreeValue(ctx, classValue);
                    
                    // Check if it has children
                    JSValue childNodesValue = JS_GetPropertyStr(ctx, value, "childNodes");
                    bool hasChildren = false;
                    if (!JS_IsUndefined(childNodesValue) && !JS_IsException(childNodesValue) && JS_IsObject(childNodesValue)) {
                      JSValue lengthValue = JS_GetPropertyStr(ctx, childNodesValue, "length");
                      if (!JS_IsUndefined(lengthValue) && !JS_IsException(lengthValue) && JS_IsNumber(lengthValue)) {
                        int32_t length = 0;
                        JS_ToInt32(ctx, &length, lengthValue);
                        hasChildren = length > 0;
                      }
                      JS_FreeValue(ctx, lengthValue);
                    }
                    JS_FreeValue(ctx, childNodesValue);
                    
                    if (hasChildren) {
                      result += ">…</" + tagStr + ">";
                    } else {
                      // Self-closing for empty elements
                      result += " />";
                    }
                    
                    return result;
                  } else {
                    JS_FreeValue(ctx, tagNameValue);
                  }
                }
              } else if (nodeType == 3 || nodeType == 8) {  // Text node or Comment node
                // For Text/Comment nodes, get data property
                JSValue dataValue = JS_GetPropertyStr(ctx, value, "data");
                if (!JS_IsUndefined(dataValue) && !JS_IsException(dataValue) && JS_IsString(dataValue)) {
                  const char* data = JS_ToCString(ctx, dataValue);
                  if (data != nullptr) {
                    std::string result;
                    if (nodeType == 3) {  // Text node
                      result = "\"" + std::string(data) + "\"";
                    } else {  // Comment node
                      result = "<!--" + std::string(data) + "-->";
                    }
                    JS_FreeCString(ctx, data);
                    JS_FreeValue(ctx, dataValue);
                    return result;
                  }
                  JS_FreeValue(ctx, dataValue);
                }
              }
            } else {
              JS_FreeValue(ctx, nodeTypeValue);
            }
          }
        }
        
        // For plain objects, check if they have Element-like properties
        // This is mainly for testing with mock objects
        std::string class_name = GetObjectClassName(ctx, value);
        if (class_name.find("HTML") == 0 || class_name.find("SVG") == 0 || 
            class_name == "Element" || class_name == "Text" || class_name == "Comment") {
          // Check for outerHTML property
          JSValue outerHTMLValue = JS_GetPropertyStr(ctx, value, "outerHTML");
          if (!JS_IsUndefined(outerHTMLValue) && !JS_IsException(outerHTMLValue) && JS_IsString(outerHTMLValue)) {
            const char* html = JS_ToCString(ctx, outerHTMLValue);
            if (html != nullptr) {
              std::string result = html;
              JS_FreeCString(ctx, html);
              JS_FreeValue(ctx, outerHTMLValue);
              return result;
            }
            JS_FreeValue(ctx, outerHTMLValue);
          }
          
          // Check for data property (Text/Comment)
          if (class_name == "Text" || class_name == "Comment") {
            JSValue dataValue = JS_GetPropertyStr(ctx, value, "data");
            if (!JS_IsUndefined(dataValue) && !JS_IsException(dataValue) && JS_IsString(dataValue)) {
              const char* data = JS_ToCString(ctx, dataValue);
              if (data != nullptr) {
                std::string result;
                if (class_name == "Text") {
                  result = "\"" + std::string(data) + "\"";
                } else {
                  result = "<!--" + std::string(data) + "-->";
                }
                JS_FreeCString(ctx, data);
                JS_FreeValue(ctx, dataValue);
                return result;
              }
              JS_FreeValue(ctx, dataValue);
            }
          }
        }
      }
      
      // Default object description
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

JSValue RemoteObjectRegistry::GetPropertyValue(const std::string& object_id, const RemoteObjectProperty& property) {
  auto it = objects_.find(object_id);
  if (it == objects_.end()) {
    return JS_UNDEFINED;
  }
  
  JSContext* ctx = it->second.ctx;
  JSValue obj = it->second.value;
  
  // Get the property value directly
  JSValue prop_value;
  if (property.is_symbol && property.property_index >= 0) {
    // For symbol properties, we need to re-enumerate to get the atom
    JSPropertyEnum* props = nullptr;
    uint32_t prop_count = 0;
    int flags = JS_GPN_STRING_MASK | JS_GPN_SYMBOL_MASK;
    
    if (JS_GetOwnPropertyNames(ctx, &props, &prop_count, obj, flags) >= 0) {
      if (property.property_index < prop_count) {
        JSAtom atom = props[property.property_index].atom;
        prop_value = JS_GetProperty(ctx, obj, atom);
      } else {
        prop_value = JS_UNDEFINED;
      }
      js_free(ctx, props);
    } else {
      prop_value = JS_UNDEFINED;
    }
  } else {
    // For string properties
    prop_value = JS_GetPropertyStr(ctx, obj, property.name.c_str());
  }
  return prop_value;  // Caller is responsible for freeing this
}

std::vector<RemoteObjectProperty> RemoteObjectRegistry::GetChildNodes(const std::string& id) {
  std::vector<RemoteObjectProperty> child_nodes;
  
  auto it = objects_.find(id);
  if (it == objects_.end()) {
    return child_nodes;
  }
  
  JSContext* ctx = it->second.ctx;
  JSValue obj = it->second.value;
  
  // Check if this object has childNodes property (all DOM nodes have this)
  JSValue childNodesValue = JS_GetPropertyStr(ctx, obj, "childNodes");
  if (!JS_IsUndefined(childNodesValue) && !JS_IsException(childNodesValue) && JS_IsObject(childNodesValue)) {
    // Get length of childNodes
    JSValue lengthValue = JS_GetPropertyStr(ctx, childNodesValue, "length");
    if (!JS_IsUndefined(lengthValue) && !JS_IsException(lengthValue) && JS_IsNumber(lengthValue)) {
      int32_t length = 0;
      JS_ToInt32(ctx, &length, lengthValue);
      JS_FreeValue(ctx, lengthValue);
      
      // Iterate through child nodes
      for (int i = 0; i < length; i++) {
        RemoteObjectProperty prop;
        prop.is_own = true;
        prop.enumerable = true;
        prop.configurable = false;
        prop.writable = false;
        prop.is_primitive = false;
        prop.is_symbol = false;
        
        // Get child node at index i
        JSValue child_value = JS_GetPropertyUint32(ctx, childNodesValue, i);
        if (!JS_IsUndefined(child_value) && !JS_IsNull(child_value) && JS_IsObject(child_value)) {
          // Get the node type to determine how to display it
          JSValue nodeTypeValue = JS_GetPropertyStr(ctx, child_value, "nodeType");
          int32_t nodeType = 0;
          if (!JS_IsUndefined(nodeTypeValue) && !JS_IsException(nodeTypeValue) && JS_IsNumber(nodeTypeValue)) {
            JS_ToInt32(ctx, &nodeType, nodeTypeValue);
          }
          JS_FreeValue(ctx, nodeTypeValue);
          
          // Create a descriptive name based on node type
          if (nodeType == 3) {  // Text node
            JSValue dataValue = JS_GetPropertyStr(ctx, child_value, "data");
            if (!JS_IsUndefined(dataValue) && !JS_IsException(dataValue) && JS_IsString(dataValue)) {
              const char* text = JS_ToCString(ctx, dataValue);
              if (text != nullptr) {
                std::string textStr = text;
                // Limit length for display but preserve meaningful whitespace
                if (textStr.length() > 50) {
                  textStr = textStr.substr(0, 47) + "...";
                }
                prop.name = "\"" + textStr + "\"";
                JS_FreeCString(ctx, text);
              } else {
                prop.name = "#text";
              }
            } else {
              prop.name = "#text";
            }
            JS_FreeValue(ctx, dataValue);
          } else if (nodeType == 1) {  // Element node
            // Get the tag name
            JSValue tagNameValue = JS_GetPropertyStr(ctx, child_value, "tagName");
            if (!JS_IsUndefined(tagNameValue) && !JS_IsException(tagNameValue) && JS_IsString(tagNameValue)) {
              const char* tagName = JS_ToCString(ctx, tagNameValue);
              if (tagName != nullptr) {
                std::string tagStr = tagName;
                // Convert to lowercase for consistency
                std::transform(tagStr.begin(), tagStr.end(), tagStr.begin(), ::tolower);
                prop.name = "<" + tagStr + ">";
                JS_FreeCString(ctx, tagName);
              } else {
                prop.name = "<element>";
              }
            } else {
              prop.name = "<element>";
            }
            JS_FreeValue(ctx, tagNameValue);
          } else if (nodeType == 8) {  // Comment node
            prop.name = "<!-- -->";
          } else {
            // Default for other node types
            prop.name = "[" + std::to_string(i) + "]";
          }
          
          // Register the child node and get its ID
          prop.value_id = RegisterObject(ctx, child_value);
        } else {
          prop.value_id = "";
          prop.name = "[" + std::to_string(i) + "]";
        }
        JS_FreeValue(ctx, child_value);
        
        child_nodes.push_back(prop);
      }
    } else {
      JS_FreeValue(ctx, lengthValue);
    }
    JS_FreeValue(ctx, childNodesValue);
  } else {
    JS_FreeValue(ctx, childNodesValue);
  }
  
  return child_nodes;
}

}  // namespace webf