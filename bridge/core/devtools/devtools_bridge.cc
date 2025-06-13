/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "devtools_bridge.h"
#include "remote_object.h"
#include "core/executing_context.h"
#include "core/dart_isolate_context.h"
#include "foundation/native_value_converter.h"
#include "foundation/native_value.h"
#include "bindings/qjs/converter_impl.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_value.h"
#include <sstream>
#include <string>

namespace webf {

// Helper function to convert JSValue to NativeValue
static void JSValueToNativeValue(NativeValue* result, JSContext* ctx, JSValue value) {
  if (JS_IsNull(value)) {
    *result = Native_NewNull();
  } else if (JS_IsUndefined(value)) {
    *result = Native_NewNull();
  } else if (JS_IsBool(value)) {
    *result = Native_NewBool(JS_ToBool(ctx, value));
  } else if (JS_IsNumber(value)) {
    double d;
    JS_ToFloat64(ctx, &d, value);
    *result = Native_NewFloat64(d);
  } else if (JS_IsString(value)) {
    const char* str = JS_ToCString(ctx, value);
    *result = Native_NewCString(str);
    JS_FreeCString(ctx, str);
  } else if (JS_IsObject(value)) {
    // For objects, we'll convert to JSON
    ExceptionState exception_state;
    ExecutingContext* context = ExecutingContext::From(ctx);
    ScriptValue script_value(ctx, value);
    *result = Native_NewJSON(ctx, script_value, exception_state);
  } else {
    *result = Native_NewNull();
  }
}


// Internal implementation functions for DevTools remote object access
namespace devtools_internal {

// Thread-local storage for ExecutingContext mapping
thread_local std::unordered_map<double, ExecutingContext*> g_context_map;

// Register ExecutingContext in thread-local storage
void RegisterExecutingContext(ExecutingContext* context) {
  if (context) {
    g_context_map[context->contextId()] = context;
  }
}

// Unregister ExecutingContext from thread-local storage
void UnregisterExecutingContext(ExecutingContext* context) {
  if (context) {
    g_context_map.erase(context->contextId());
  }
}

// Helper to get ExecutingContext from context_id in the JS thread
ExecutingContext* GetExecutingContextById(double context_id) {
  auto it = g_context_map.find(context_id);
  return (it != g_context_map.end()) ? it->second : nullptr;
}

NativeValue* GetObjectPropertiesImpl(double context_id, 
                                    const char* object_id,
                                    int32_t include_prototype) {
  if (!isContextValid(context_id)) {
    return nullptr;
  }
  
  // Get ExecutingContext - this is a limitation in the current architecture
  ExecutingContext* context = GetExecutingContextById(context_id);
  if (!context) {
    return nullptr;
  }
  
  RemoteObjectRegistry* registry = context->GetRemoteObjectRegistry();
  if (!registry) {
    return nullptr;
  }
  
  // Get the properties
  std::vector<RemoteObjectProperty> properties = registry->GetObjectProperties(
    std::string(object_id), 
    include_prototype != 0
  );
  
  // Get JSContext from registry
  JSContext* ctx = registry->GetJSContext();
  if (!ctx) {
    return nullptr;
  }
  
  // Convert to NativeValue array
  JSValue array = JS_NewArray(ctx);
  
  for (size_t i = 0; i < properties.size(); i++) {
    const RemoteObjectProperty& prop = properties[i];
    JSValue propObj = JS_NewObject(ctx);
    
    // Add property fields
    JS_SetPropertyStr(ctx, propObj, "name", JS_NewString(ctx, prop.name.c_str()));
    JS_SetPropertyStr(ctx, propObj, "valueId", JS_NewString(ctx, prop.value_id.c_str()));
    JS_SetPropertyStr(ctx, propObj, "enumerable", JS_NewBool(ctx, prop.enumerable));
    JS_SetPropertyStr(ctx, propObj, "configurable", JS_NewBool(ctx, prop.configurable));
    JS_SetPropertyStr(ctx, propObj, "writable", JS_NewBool(ctx, prop.writable));
    JS_SetPropertyStr(ctx, propObj, "isOwn", JS_NewBool(ctx, prop.is_own));
    
    // Add value information if we have a valueId
    if (!prop.value_id.empty()) {
      auto valueDetails = registry->GetObjectDetails(prop.value_id);
      if (valueDetails) {
        // Check if it's a primitive type
        if (valueDetails->type() == RemoteObjectType::Undefined ||
            valueDetails->type() == RemoteObjectType::Null ||
            valueDetails->type() == RemoteObjectType::Boolean ||
            valueDetails->type() == RemoteObjectType::Number ||
            valueDetails->type() == RemoteObjectType::String) {
          // For primitive values, create a primitive value object
          JSValue valueObj = JS_NewObject(ctx);
          JS_SetPropertyStr(ctx, valueObj, "type", JS_NewString(ctx, "primitive"));
          
          // Convert description to actual value
          const std::string& desc = valueDetails->description();
          if (valueDetails->type() == RemoteObjectType::Undefined) {
            JS_SetPropertyStr(ctx, valueObj, "value", JS_NewString(ctx, "undefined"));
          } else if (valueDetails->type() == RemoteObjectType::Null) {
            JS_SetPropertyStr(ctx, valueObj, "value", JS_NULL);
          } else if (valueDetails->type() == RemoteObjectType::Boolean) {
            JS_SetPropertyStr(ctx, valueObj, "value", JS_NewBool(ctx, desc == "true"));
          } else if (valueDetails->type() == RemoteObjectType::Number) {
            double num = std::stod(desc);
            JS_SetPropertyStr(ctx, valueObj, "value", JS_NewFloat64(ctx, num));
          } else if (valueDetails->type() == RemoteObjectType::String) {
            // Remove quotes from string description
            std::string str = desc;
            if (str.length() >= 2 && str[0] == '"' && str[str.length()-1] == '"') {
              str = str.substr(1, str.length()-2);
            }
            JS_SetPropertyStr(ctx, valueObj, "value", JS_NewString(ctx, str.c_str()));
          }
          
          JS_SetPropertyStr(ctx, propObj, "value", valueObj);
        } else {
          // For objects, use remote object representation
          JSValue valueObj = JS_NewObject(ctx);
          JS_SetPropertyStr(ctx, valueObj, "type", JS_NewString(ctx, "remote-object"));
          JS_SetPropertyStr(ctx, valueObj, "objectId", JS_NewString(ctx, prop.value_id.c_str()));
          JS_SetPropertyStr(ctx, valueObj, "className", JS_NewString(ctx, valueDetails->class_name().c_str()));
          JS_SetPropertyStr(ctx, valueObj, "description", JS_NewString(ctx, valueDetails->description().c_str()));
          JS_SetPropertyStr(ctx, valueObj, "objectType", JS_NewInt32(ctx, static_cast<int>(valueDetails->type())));
          JS_SetPropertyStr(ctx, propObj, "value", valueObj);
        }
      }
    }
    
    JS_SetPropertyUint32(ctx, array, i, propObj);
  }
  
  // Convert to NativeValue
  NativeValue* result = new NativeValue();
  JSValueToNativeValue(result, ctx, array);
  JS_FreeValue(ctx, array);
  
  return result;
}

NativeValue* EvaluatePropertyPathImpl(double context_id,
                                     const char* object_id,
                                     const char* property_path) {
  if (!isContextValid(context_id)) {
    return nullptr;
  }
  
  ExecutingContext* context = GetExecutingContextById(context_id);
  if (!context) {
    return nullptr;
  }
  
  RemoteObjectRegistry* registry = context->GetRemoteObjectRegistry();
  if (!registry) {
    return nullptr;
  }
  
  JSContext* ctx = registry->GetJSContext();
  if (!ctx) {
    return nullptr;
  }
  
  JSValue value = registry->EvaluatePropertyPath(
    std::string(object_id),
    std::string(property_path)
  );
  
  if (JS_IsUndefined(value)) {
    return nullptr;
  }
  
  // Check if it's an object that should be registered
  NativeValue* result = new NativeValue();
  
  if (JS_IsObject(value) && !JS_IsNull(value)) {
    std::string new_object_id = registry->RegisterObject(ctx, value);
    auto remote_obj = registry->GetObjectDetails(new_object_id);
    
    if (remote_obj) {
      JSValue resultObj = JS_NewObject(ctx);
      JS_SetPropertyStr(ctx, resultObj, "type", JS_NewString(ctx, "remote-object"));
      JS_SetPropertyStr(ctx, resultObj, "objectId", JS_NewString(ctx, new_object_id.c_str()));
      JS_SetPropertyStr(ctx, resultObj, "className", JS_NewString(ctx, remote_obj->class_name().c_str()));
      JS_SetPropertyStr(ctx, resultObj, "description", JS_NewString(ctx, remote_obj->description().c_str()));
      JS_SetPropertyStr(ctx, resultObj, "objectType", JS_NewInt32(ctx, static_cast<int>(remote_obj->type())));
      
      JSValueToNativeValue(result, ctx, resultObj);
      JS_FreeValue(ctx, resultObj);
    }
  } else {
    // For primitive values, create a primitive result
    JSValue resultObj = JS_NewObject(ctx);
    JS_SetPropertyStr(ctx, resultObj, "type", JS_NewString(ctx, "primitive"));
    
    if (JS_IsUndefined(value)) {
      JS_SetPropertyStr(ctx, resultObj, "value", JS_NewString(ctx, "undefined"));
    } else if (JS_IsNull(value)) {
      JS_SetPropertyStr(ctx, resultObj, "value", JS_NULL);
    } else if (JS_IsBool(value)) {
      JS_SetPropertyStr(ctx, resultObj, "value", JS_DupValue(ctx, value));
    } else if (JS_IsNumber(value)) {
      JS_SetPropertyStr(ctx, resultObj, "value", JS_DupValue(ctx, value));
    } else if (JS_IsString(value)) {
      JS_SetPropertyStr(ctx, resultObj, "value", JS_DupValue(ctx, value));
    }
    
    JSValueToNativeValue(result, ctx, resultObj);
    JS_FreeValue(ctx, resultObj);
  }
  
  JS_FreeValue(ctx, value);
  return result;
}

void ReleaseObjectImpl(double context_id, const char* object_id) {
  if (!isContextValid(context_id)) {
    return;
  }
  
  ExecutingContext* context = GetExecutingContextById(context_id);
  if (!context) {
    return;
  }
  
  RemoteObjectRegistry* registry = context->GetRemoteObjectRegistry();
  if (registry) {
    registry->ReleaseObject(std::string(object_id));
  }
}

}  // namespace devtools_internal

}  // namespace webf

// C++ implementations that are called from Dart via FFI
// These functions need to handle cross-thread calls from Dart UI thread to JS thread
// The dart_isolate_context pointer is passed from Dart to ensure thread safety
WEBF_EXPORT_C
webf::NativeValue* GetObjectPropertiesFromDart(void* dart_isolate_context_ptr,
                                               double context_id, 
                                               const char* object_id, 
                                               int32_t include_prototype) {
  // Cast the pointer to DartIsolateContext
  webf::DartIsolateContext* dart_isolate_context = static_cast<webf::DartIsolateContext*>(dart_isolate_context_ptr);
  if (!dart_isolate_context || !dart_isolate_context->dispatcher()) {
    return nullptr;
  }
  
  // Copy the object_id string since it might be freed before the lambda executes
  std::string object_id_str(object_id);
  
  // Execute on JS thread synchronously
  return dart_isolate_context->dispatcher()->PostToJsSync(
    true, // is_dedicated - always true for devtools operations
    static_cast<int32_t>(context_id),
    [context_id, object_id_str, include_prototype](bool cancel) -> webf::NativeValue* {
      if (cancel) {
        return nullptr;
      }
      
      // This lambda runs on the JS thread
      return webf::devtools_internal::GetObjectPropertiesImpl(context_id, object_id_str.c_str(), include_prototype);
    }
  );
}

WEBF_EXPORT_C
webf::NativeValue* EvaluatePropertyPathFromDart(void* dart_isolate_context_ptr,
                                                double context_id, 
                                                const char* object_id, 
                                                const char* property_path) {
  // Cast the pointer to DartIsolateContext
  webf::DartIsolateContext* dart_isolate_context = static_cast<webf::DartIsolateContext*>(dart_isolate_context_ptr);
  if (!dart_isolate_context || !dart_isolate_context->dispatcher()) {
    return nullptr;
  }
  
  // Copy the strings since they might be freed before the lambda executes
  std::string object_id_str(object_id);
  std::string property_path_str(property_path);
  
  // Execute on JS thread synchronously
  return dart_isolate_context->dispatcher()->PostToJsSync(
    true, // is_dedicated
    static_cast<int32_t>(context_id),
    [context_id, object_id_str, property_path_str](bool cancel) -> webf::NativeValue* {
      if (cancel) {
        return nullptr;
      }
      return webf::devtools_internal::EvaluatePropertyPathImpl(context_id, object_id_str.c_str(), property_path_str.c_str());
    }
  );
}

WEBF_EXPORT_C
void ReleaseObjectFromDart(void* dart_isolate_context_ptr,
                          double context_id, 
                          const char* object_id) {
  // Cast the pointer to DartIsolateContext
  webf::DartIsolateContext* dart_isolate_context = static_cast<webf::DartIsolateContext*>(dart_isolate_context_ptr);
  if (!dart_isolate_context || !dart_isolate_context->dispatcher()) {
    return;
  }
  
  // Copy the object_id string since it might be freed before the lambda executes
  std::string object_id_str(object_id);
  
  // Execute on JS thread synchronously
  dart_isolate_context->dispatcher()->PostToJsSync(
    true, // is_dedicated
    static_cast<int32_t>(context_id),
    [context_id, object_id_str](bool cancel) -> void {
      if (cancel) {
        return;
      }
      webf::devtools_internal::ReleaseObjectImpl(context_id, object_id_str.c_str());
    }
  );
}