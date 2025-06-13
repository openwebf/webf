/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "console.h"
#include <quickjs/quickjs.h>
#include <sstream>
#include "built_in_string.h"
#include "foundation/logging.h"
#include "core/devtools/remote_object.h"
#include "foundation/native_string.h"
#include "foundation/native_type.h"
#include "foundation/native_value.h"
#include "bindings/qjs/script_value.h"
#include "bindings/qjs/exception_state.h"

namespace webf {

void Console::__webf_print__(ExecutingContext* context,
                             const AtomicString& log,
                             const AtomicString& level,
                             ExceptionState& exception) {
  std::stringstream stream;
  std::string buffer = log.ToStdString(context->ctx());
  stream << buffer;
  printLog(context, stream, level != built_in_string::kempty_string ? level.ToStdString(context->ctx()) : "info",
           nullptr);
}

void Console::__webf_print__(ExecutingContext* context, const AtomicString& log, ExceptionState& exception_state) {
  std::stringstream stream;
  std::string buffer = log.ToStdString(context->ctx());
  stream << buffer;
  printLog(context, stream, "info", nullptr);
}

bool Console::__webf_is_proxy__(ExecutingContext* context, const ScriptValue& log, ExceptionState& exception_state) {
  return JS_IsProxy(log.QJSValue());
}

void Console::__webf_print_structured__(ExecutingContext* context,
                                       int32_t level,
                                       const std::vector<ScriptValue>& args,
                                       ExceptionState& exception_state) {
  // Create structured log data with remote object references
  RemoteObjectRegistry* registry = context->GetRemoteObjectRegistry();
  JSContext* ctx = context->ctx();
  
  // Convert args to NativeValue array for DevTools
  NativeValue* native_args = static_cast<NativeValue*>(malloc(sizeof(NativeValue) * args.size()));
  ExceptionState es;
  
  for (size_t i = 0; i < args.size(); i++) {
    JSValue js_value = args[i].QJSValue();
    
    if (JS_IsObject(js_value) && !JS_IsNull(js_value)) {
      // Get the already registered object
      std::string object_id = registry->RegisterObject(ctx, js_value);
      auto remote_obj = registry->GetObjectDetails(object_id);
      
      if (remote_obj) {
        // Create a map-like structure for remote object
        JSValue obj = JS_NewObject(ctx);
        JS_SetPropertyStr(ctx, obj, "type", JS_NewString(ctx, "remote-object"));
        JS_SetPropertyStr(ctx, obj, "objectId", JS_NewString(ctx, object_id.c_str()));
        JS_SetPropertyStr(ctx, obj, "className", JS_NewString(ctx, remote_obj->class_name().c_str()));
        JS_SetPropertyStr(ctx, obj, "description", JS_NewString(ctx, remote_obj->description().c_str()));
        JS_SetPropertyStr(ctx, obj, "objectType", JS_NewInt32(ctx, static_cast<int>(remote_obj->type())));
        
        // Convert to NativeValue using JSON
        ScriptValue scriptObj(ctx, obj);
        native_args[i] = Native_NewJSON(ctx, scriptObj, es);
        JS_FreeValue(ctx, obj);
      } else {
        native_args[i] = Native_NewNull();
      }
    } else {
      // For primitive values, convert them appropriately
      if (JS_IsNull(js_value)) {
        native_args[i] = Native_NewNull();
      } else if (JS_IsUndefined(js_value)) {
        native_args[i] = Native_NewUndefined();
      } else if (JS_IsBool(js_value)) {
        native_args[i] = Native_NewBool(JS_ToBool(ctx, js_value));
      } else if (JS_IsNumber(js_value)) {
        double num;
        JS_ToFloat64(ctx, &num, js_value);
        native_args[i] = Native_NewFloat64(num);
      } else if (JS_IsString(js_value)) {
        const char* str = JS_ToCString(ctx, js_value);
        native_args[i] = Native_NewCString(str ? str : "");
        JS_FreeCString(ctx, str);
      } else {
        native_args[i] = Native_NewNull();
      }
    }
  }
  
  // Send the structured data to DevTools
  context->dartMethodPtr()->onJSLogStructured(context->isDedicated(), context->contextId(), level, 
                                              args.size(), native_args);
}

}  // namespace webf
