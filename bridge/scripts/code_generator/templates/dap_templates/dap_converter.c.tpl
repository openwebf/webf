/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#include "dap_converter.h"
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "dap_protocol.h"
#if ENABLE_DEBUGGER
static int64_t response_seq = 0;

const char* copy_string(const char* string, size_t len) {
  char* buf = (char*)malloc(len + 1);
  memcpy(buf, string, len);
  buf[len] = 0;
  return buf;
}

static const char* get_property_string_copy(JSContext* ctx, JSValue this_object, const char* prop) {
 JSValue vp = JS_GetPropertyStr(ctx, this_object, prop);
 size_t len;
 const char* tmp = JS_ToCStringLen(ctx, &len, vp);
 const char* result = copy_string(tmp, len);
 JS_FreeCString(ctx, tmp);
 JS_FreeValue(ctx, vp);
 return result;
}
static int64_t get_property_int64(JSContext* ctx, JSValue this_object, const char* prop) {
 JSValue vp = JS_GetPropertyStr(ctx, this_object, prop);
 int64_t v;
 JS_ToInt64(ctx, &v, vp);
 JS_FreeValue(ctx, vp);
 return v;
}
static double get_property_float64(JSContext* ctx, JSValue this_object, const char* prop) {
 JSValue vp = JS_GetPropertyStr(ctx, this_object, prop);
 double v;
 JS_ToFloat64(ctx, &v, vp);
 JS_FreeValue(ctx, vp);
 return v;
}
static int8_t get_property_boolean(JSContext* ctx, JSValue this_object, const char* prop) {
  JSValue vp = JS_GetPropertyStr(ctx, this_object, prop);
  int8_t v = JS_ToBool(ctx, vp);
  JS_FreeValue(ctx, vp);
  return v;
}
<%= externalInitialize.join('\n') %>
enum RequestType {
 <% requests.forEach((request) => { %>
   k<%= request[0].toUpperCase() + request.substring(1) %>,
 <% }) %>
};
static void* parse_request_arguments(JSContext* ctx, const char* command, JSValue arguments) {
 <%= requestParser %>
 return NULL;
}
int parse_request(JSContext* ctx, Request* request, const char* buf, size_t length) {
 JSValue json = JS_ParseJSON(ctx, buf, length, "<debugger>");
 if (JS_IsException(json)) {
   return 0;
 }
 const char* type = get_property_string_copy(ctx, json, "type");
 assert(strcmp(type, "request") == 0);
 request->seq = get_property_int64(ctx, json, "seq");
 request->command = get_property_string_copy(ctx, json, "command");
 request->type = type;
 JSValue varguments = JS_GetPropertyStr(ctx, json, "arguments");
 request->arguments = parse_request_arguments(ctx, request->command, varguments);
 JS_FreeValue(ctx, varguments);
 return 1;
}
static JSValue stringify_event_body(JSContext* ctx, const char* event, void* body) {
 JSValue object = JS_NewObject(ctx);
 if (body == NULL) return object;
<%= eventBodyStringifyCode %>
 return object;
}
void* initialize_event(JSContext* ctx, const char* event) {
  <%= eventInit %>
  return NULL;
}

void* initialize_response(JSContext* ctx, const Request* corresponding_request, const char* response) {
  <%= responseInit %>
  return NULL;
}

const char* stringify_event(JSContext* ctx, Event* event, size_t* length) {
  JSValue object = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, object, "seq", JS_NewInt64(ctx, event->seq));
  JS_SetPropertyStr(ctx, object, "type", JS_NewString(ctx, "event"));
  JS_SetPropertyStr(ctx, object, "event", JS_NewString(ctx, event->event));
  JS_SetPropertyStr(ctx, object, "body",  stringify_event_body(ctx, event->event, event->body));
  JSValue jsonString = JS_JSONStringify(ctx, object, JS_NULL, JS_NULL);
  size_t len;
  const char* tmp = JS_ToCStringLen(ctx, &len, jsonString);
  const char* result = copy_string(tmp, len);
  JS_FreeCString(ctx, tmp);
  JS_FreeValue(ctx, jsonString);
  JS_FreeValue(ctx, object);
  return result;
}
static JSValue stringify_response_body(JSContext* ctx, const char* command, void* body) {
 JSValue object = JS_NewObject(ctx);
 <%= responseBodyStringifyCode %>
 return object;
}
const char* stringify_response(JSContext* ctx, Response* response) {
 JSValue object = JS_NewObject(ctx);
 printf("response command %s", response->command);
 JS_SetPropertyStr(ctx, object, "type", JS_NewString(ctx, "response"));
 JS_SetPropertyStr(ctx, object, "request_seq", JS_NewInt64(ctx, response->seq));
 JS_SetPropertyStr(ctx, object, "success", JS_NewBool(ctx, response->success == 1));
 JS_SetPropertyStr(ctx, object, "command", JS_NewString(ctx, response->command));
 if (response->message != NULL) {
   JS_SetPropertyStr(ctx, object, "message", JS_NewString(ctx, response->message));
 }
 JS_SetPropertyStr(ctx, object, "body", stringify_response_body(ctx, response->command, response->body));
 JSValue jsonString = JS_JSONStringify(ctx, object, JS_NULL, JS_NULL);
 size_t len;
 const char* tmp = JS_ToCStringLen(ctx,  &len,jsonString);
 const char* result = copy_string(tmp, len);
 JS_FreeCString(ctx, tmp);
 JS_FreeValue(ctx, jsonString);
 JS_FreeValue(ctx, object);
 return result;
}
#endif