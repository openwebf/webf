/*
 * Copyright (C) 2022 Koushik Dutta. https://github.com/koush
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <pthread.h>
#include "debugger.h"
#include "base.h"
#include "parser.h"
#include "runtime.h"
#include "types.h"

#if ENABLE_DEBUGGER

typedef struct DebuggerSuspendedState {
  uint32_t variable_reference_count;
  JSValue variable_references;
  JSValue variable_pointers;
  const uint8_t* cur_pc;
} DebuggerSuspendedState;

static uint32_t handle_client_write(void* ptr, DebuggerMessage* message) {
  JSDebuggerInfo* info = (JSDebuggerInfo*)ptr;
  // Gain access to front_message.
  pthread_mutex_lock(&info->frontend_message_access);

  char* buf = js_malloc_rt(info->runtime, message->length);
  memcpy(buf, message->buf, message->length);

  MessageItem* item = js_malloc_rt(info->runtime, sizeof(MessageItem));
  item->buf = buf;
  item->length = message->length;

  // Push this item to the queue.
  list_add_tail(&item->link, &info->frontend_messages);

  // Release the lock, so the JS Main thread can read front-end messages.
  pthread_mutex_unlock(&info->frontend_message_access);

  return 1;
}

// Handler for read backend messages from Dart Client.
static uint32_t handle_client_read(void* ptr, DebuggerMessage* message) {
  JSDebuggerInfo* info = (JSDebuggerInfo*)ptr;

  // Gain access to back_end_message
  pthread_mutex_lock(&info->backend_message_access);

  if (list_empty(&info->backend_message)) {
    pthread_mutex_unlock(&info->backend_message_access);
    return 0;
  }

  // Sum the total length of buffer.
  size_t bufferLength = 0;
  struct list_head* el;
  list_for_each(el, &info->backend_message) {
    MessageItem* message_item = list_entry(el, MessageItem, link);
    bufferLength += message_item->length + 3;
  }

  char* buffer = js_malloc_rt(info->runtime, bufferLength);
  size_t index = 0;
  list_for_each(el, &info->backend_message) {
    MessageItem* message_item = list_entry(el, MessageItem, link);
    memcpy(buffer + index, message_item->buf, message_item->length);
    // Set the magic separator between commands.
    memset(buffer + index + message_item->length, '%', 1);
    memset(buffer + index + message_item->length + 1, '@', 1);
    memset(buffer + index + message_item->length + 2, '!', 1);

    index += message_item->length + 3;
  }

  message->length = bufferLength;
  message->buf = buffer;

  // Release the lock, so the JS Main thread can read front-end messages.
  pthread_mutex_unlock(&info->backend_message_access);

  return 1;
}

static uint32_t read_frontend_messages(JSDebuggerInfo* info, MessageItem* item) {
  // Gain access to front_message.
  pthread_mutex_lock(&info->frontend_message_access);

  if (list_empty(&info->frontend_messages)) {
    pthread_mutex_unlock(&info->frontend_message_access);
    return 0;
  };

  // Calculate the head through byte offset.
  MessageItem* head = (MessageItem*)(&info->frontend_messages - offsetof(MessageItem, link));

  item->buf = head->buf;
  item->length = head->length;

  list_del(&head->link);

  // Release the lock, so the dart isolate thread can read front-end messages.
  pthread_mutex_unlock(&info->frontend_message_access);

  return 1;
}

static uint32_t write_backend_message(JSDebuggerInfo* info, const char* buffer, size_t length) {
  // Gain access to backend_message.
  pthread_mutex_lock(&info->backend_message_access);

  MessageItem* item = js_malloc_rt(info->runtime, sizeof(MessageItem));
  char* buf = js_malloc_rt(info->runtime, length);
  memcpy(buf, buffer, length);

  item->buf = buf;
  item->length = length;

  list_add_tail(&item->link, &info->backend_message);

  // Release the lock, so the dart isolate thread can read back-end messages.
  pthread_mutex_unlock(&info->backend_message_access);

  return 1;
}

static uint32_t js_transport_write_fully(JSDebuggerInfo* info, const char* buffer, size_t length) {
  return write_backend_message(info, buffer, length);
}

static uint32_t js_transport_write_value(JSDebuggerInfo* info, JSValue value) {
  JSValue stringified = JS_JSONStringify(info->ctx, value, JS_UNDEFINED, JS_UNDEFINED);
  size_t len;
  const char* str = JS_ToCStringLen(info->ctx, &len, stringified);
  uint32_t ret = 0;
  if (len)
    ret = js_transport_write_fully(info, str, len);
  // else send error somewhere?
  JS_FreeCString(info->ctx, str);
  JS_FreeValue(info->ctx, stringified);
  JS_FreeValue(info->ctx, value);
  return ret;
}

static JSValue js_transport_new_envelope(JSDebuggerInfo* info, const char* type) {
  JSValue ret = JS_NewObject(info->ctx);
  JS_SetPropertyStr(info->ctx, ret, "type", JS_NewString(info->ctx, type));
  return ret;
}

static uint32_t js_transport_send_event(JSDebuggerInfo* info, JSValue event) {
  JSValue envelope = js_transport_new_envelope(info, "event");
  JS_SetPropertyStr(info->ctx, envelope, "event", event);
  return js_transport_write_value(info, envelope);
}

static uint32_t js_transport_send_response(JSDebuggerInfo* info, JSValue request, JSValue body) {
  JSContext* ctx = info->ctx;
  JSValue envelope = js_transport_new_envelope(info, "response");
  JS_SetPropertyStr(ctx, envelope, "body", body);
  JS_SetPropertyStr(ctx, envelope, "request_seq", JS_GetPropertyStr(ctx, request, "request_seq"));
  return js_transport_write_value(info, envelope);
}

static JSValue js_get_scopes(JSContext* ctx, int frame) {
  // for now this is always the same.
  // global, local, closure. may change in the future. can check if closure is empty.

  JSValue scopes = JS_NewArray(ctx);

  int scope_count = 0;

  JSValue local = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, local, "name", JS_NewString(ctx, "Local"));
  JS_SetPropertyStr(ctx, local, "reference", JS_NewInt32(ctx, (frame << 2) + 1));
  JS_SetPropertyStr(ctx, local, "expensive", JS_FALSE);
  JS_SetPropertyUint32(ctx, scopes, scope_count++, local);

  JSValue closure = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, closure, "name", JS_NewString(ctx, "Closure"));
  JS_SetPropertyStr(ctx, closure, "reference", JS_NewInt32(ctx, (frame << 2) + 2));
  JS_SetPropertyStr(ctx, closure, "expensive", JS_FALSE);
  JS_SetPropertyUint32(ctx, scopes, scope_count++, closure);

  JSValue global = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, global, "name", JS_NewString(ctx, "Global"));
  JS_SetPropertyStr(ctx, global, "reference", JS_NewInt32(ctx, (frame << 2) + 0));
  JS_SetPropertyStr(ctx, global, "expensive", JS_TRUE);
  JS_SetPropertyUint32(ctx, scopes, scope_count++, global);

  return scopes;
}

static inline JS_BOOL JS_IsInteger(JSValueConst v) {
  int tag = JS_VALUE_GET_TAG(v);
  return tag == JS_TAG_INT || tag == JS_TAG_BIG_INT;
}

static void js_debugger_get_variable_type(JSContext* ctx,
                                          struct DebuggerSuspendedState* state,
                                          JSValue var,
                                          JSValue var_val) {
  // 0 means not expandible
  uint32_t reference = 0;
  if (JS_IsString(var_val))
    JS_SetPropertyStr(ctx, var, "type", JS_NewString(ctx, "string"));
  else if (JS_IsInteger(var_val))
    JS_SetPropertyStr(ctx, var, "type", JS_NewString(ctx, "integer"));
  else if (JS_IsNumber(var_val) || JS_IsBigFloat(var_val))
    JS_SetPropertyStr(ctx, var, "type", JS_NewString(ctx, "float"));
  else if (JS_IsBool(var_val))
    JS_SetPropertyStr(ctx, var, "type", JS_NewString(ctx, "boolean"));
  else if (JS_IsNull(var_val))
    JS_SetPropertyStr(ctx, var, "type", JS_NewString(ctx, "null"));
  else if (JS_IsUndefined(var_val))
    JS_SetPropertyStr(ctx, var, "type", JS_NewString(ctx, "undefined"));
  else if (JS_IsObject(var_val)) {
    JS_SetPropertyStr(ctx, var, "type", JS_NewString(ctx, "object"));

    JSObject* p = JS_VALUE_GET_OBJ(var_val);
    // todo: xor the the two dwords to get a better hash?
    uint32_t pl = (uint32_t)(uint64_t)p;
    JSValue found = JS_GetPropertyUint32(ctx, state->variable_pointers, pl);
    if (JS_IsUndefined(found)) {
      reference = state->variable_reference_count++;
      JS_SetPropertyUint32(ctx, state->variable_references, reference, JS_DupValue(ctx, var_val));
      JS_SetPropertyUint32(ctx, state->variable_pointers, pl, JS_NewInt32(ctx, reference));
    } else {
      JS_ToUint32(ctx, &reference, found);
    }
    JS_FreeValue(ctx, found);
  }
  JS_SetPropertyStr(ctx, var, "variablesReference", JS_NewInt32(ctx, reference));
}

static void js_debugger_get_value(JSContext* ctx, JSValue var_val, JSValue var, const char* value_property) {
  // do not toString on Arrays, since that makes a giant string of all the elements.
  // todo: typed arrays?
  if (JS_IsArray(ctx, var_val)) {
    JSValue length = JS_GetPropertyStr(ctx, var_val, "length");
    uint32_t len;
    JS_ToUint32(ctx, &len, length);
    JS_FreeValue(ctx, length);
    char lenBuf[64];
    sprintf(lenBuf, "Array (%d)", len);
    JS_SetPropertyStr(ctx, var, value_property, JS_NewString(ctx, lenBuf));
    JS_SetPropertyStr(ctx, var, "indexedVariables", JS_NewInt32(ctx, len));
  } else {
    JS_SetPropertyStr(ctx, var, value_property, JS_ToString(ctx, var_val));
  }
}

static JSValue js_debugger_get_variable(JSContext* ctx,
                                        struct DebuggerSuspendedState* state,
                                        JSValue var_name,
                                        JSValue var_val) {
  JSValue var = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, var, "name", var_name);
  js_debugger_get_value(ctx, var_val, var, "value");
  js_debugger_get_variable_type(ctx, state, var, var_val);
  return var;
}

static int js_debugger_get_frame(JSContext* ctx, JSValue args) {
  JSValue reference_property = JS_GetPropertyStr(ctx, args, "frameId");
  int frame;
  JS_ToInt32(ctx, &frame, reference_property);
  JS_FreeValue(ctx, reference_property);

  return frame;
}

static void js_send_stopped_event(JSDebuggerInfo* info, const char* reason) {
  JSContext* ctx = info->debugging_ctx;

  JSValue event = JS_NewObject(ctx);
  // better thread id?
  JS_SetPropertyStr(ctx, event, "type", JS_NewString(ctx, "StoppedEvent"));
  JS_SetPropertyStr(ctx, event, "reason", JS_NewString(ctx, reason));
  int64_t id = (int64_t)info->ctx;
  JS_SetPropertyStr(ctx, event, "thread", JS_NewInt64(ctx, id));
  js_transport_send_event(info, event);
}

static void js_free_prop_enum(JSContext* ctx, JSPropertyEnum* tab, uint32_t len) {
  uint32_t i;
  if (tab) {
    for (i = 0; i < len; i++)
      JS_FreeAtom(ctx, tab[i].atom);
    js_free(ctx, tab);
  }
}

static uint32_t js_get_property_as_uint32(JSContext* ctx, JSValue obj, const char* property) {
  JSValue prop = JS_GetPropertyStr(ctx, obj, property);
  uint32_t ret;
  JS_ToUint32(ctx, &ret, prop);
  JS_FreeValue(ctx, prop);
  return ret;
}

static void js_process_request(JSDebuggerInfo* info, struct DebuggerSuspendedState* state, JSValue request) {
  JSContext* ctx = info->ctx;
  JSValue command_property = JS_GetPropertyStr(ctx, request, "command");
  const char* command = JS_ToCString(ctx, command_property);
  if (strcmp("continue", command) == 0) {
    info->stepping = JS_DEBUGGER_STEP_CONTINUE;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    js_transport_send_response(info, request, JS_UNDEFINED);
    info->is_paused = 0;
  }
  if (strcmp("pause", command) == 0) {
    js_transport_send_response(info, request, JS_UNDEFINED);
    js_send_stopped_event(info, "pause");
    info->is_paused = 1;
  } else if (strcmp("next", command) == 0) {
    info->stepping = JS_DEBUGGER_STEP;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    js_transport_send_response(info, request, JS_UNDEFINED);
    info->is_paused = 0;
  } else if (strcmp("stepIn", command) == 0) {
    info->stepping = JS_DEBUGGER_STEP_IN;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    js_transport_send_response(info, request, JS_UNDEFINED);
    info->is_paused = 0;
  } else if (strcmp("stepOut", command) == 0) {
    info->stepping = JS_DEBUGGER_STEP_OUT;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    js_transport_send_response(info, request, JS_UNDEFINED);
    info->is_paused = 0;
  } else if (strcmp("evaluate", command) == 0) {
    JSValue args = JS_GetPropertyStr(ctx, request, "args");
    int frame = js_debugger_get_frame(ctx, args);
    JSValue expression = JS_GetPropertyStr(ctx, args, "expression");
    JS_FreeValue(ctx, args);
    JSValue result = js_debugger_evaluate(ctx, frame, expression);
    if (JS_IsException(result)) {
      JS_FreeValue(ctx, result);
      result = JS_GetException(ctx);
    }
    JS_FreeValue(ctx, expression);

    JSValue body = JS_NewObject(ctx);
    js_debugger_get_value(ctx, result, body, "result");
    js_debugger_get_variable_type(ctx, state, body, result);
    JS_FreeValue(ctx, result);
    js_transport_send_response(info, request, body);
  } else if (strcmp("stackTrace", command) == 0) {
    JSValue stack_trace = js_debugger_build_backtrace(ctx, state->cur_pc);
    js_transport_send_response(info, request, stack_trace);
  } else if (strcmp("scopes", command) == 0) {
    JSValue args = JS_GetPropertyStr(ctx, request, "args");
    int frame = js_debugger_get_frame(ctx, args);
    JS_FreeValue(ctx, args);
    JSValue scopes = js_get_scopes(ctx, frame);
    js_transport_send_response(info, request, scopes);
  } else if (strcmp("variables", command) == 0) {
    JSValue args = JS_GetPropertyStr(ctx, request, "args");
    JSValue reference_property = JS_GetPropertyStr(ctx, args, "variablesReference");
    JS_FreeValue(ctx, args);
    uint32_t reference;
    JS_ToUint32(ctx, &reference, reference_property);
    JS_FreeValue(ctx, reference_property);

    JSValue properties = JS_NewArray(ctx);

    JSValue variable = JS_GetPropertyUint32(ctx, state->variable_references, reference);

    int skip_proto = 0;
    // if the variable reference was not found,
    // then it must be a frame locals, frame closures, or the global
    if (JS_IsUndefined(variable)) {
      skip_proto = 1;
      int frame = reference >> 2;
      int scope = reference % 4;

      assert(frame < js_debugger_stack_depth(ctx));

      if (scope == 0)
        variable = JS_GetGlobalObject(ctx);
      else if (scope == 1)
        variable = js_debugger_local_variables(ctx, frame);
      else if (scope == 2)
        variable = js_debugger_closure_variables(ctx, frame);
      else
        assert(0);

      // need to dupe the variable, as it's used below as well.
      JS_SetPropertyUint32(ctx, state->variable_references, reference, JS_DupValue(ctx, variable));
    }

    JSPropertyEnum* tab_atom;
    uint32_t tab_atom_count;

    JSValue filter = JS_GetPropertyStr(ctx, args, "filter");
    if (!JS_IsUndefined(filter)) {
      const char* filter_str = JS_ToCString(ctx, filter);
      JS_FreeValue(ctx, filter);
      // only index filtering is supported by this server.
      // name filtering exists in VS Code, but is not implemented here.
      int indexed = strcmp(filter_str, "indexed") == 0;
      JS_FreeCString(ctx, filter_str);
      if (!indexed)
        goto unfiltered;

      uint32_t start = js_get_property_as_uint32(ctx, args, "start");
      uint32_t count = js_get_property_as_uint32(ctx, args, "count");

      char name_buf[64];
      for (uint32_t i = 0; i < count; i++) {
        JSValue value = JS_GetPropertyUint32(ctx, variable, start + i);
        sprintf(name_buf, "%d", i);
        JSValue variable_json = js_debugger_get_variable(ctx, state, JS_NewString(ctx, name_buf), value);
        JS_FreeValue(ctx, value);
        JS_SetPropertyUint32(ctx, properties, i, variable_json);
      }
      goto done;
    }

  unfiltered:

    if (!JS_GetOwnPropertyNames(ctx, &tab_atom, &tab_atom_count, variable, JS_GPN_STRING_MASK | JS_GPN_SYMBOL_MASK)) {
      int offset = 0;

      if (!skip_proto) {
        const JSValue proto = JS_GetPrototype(ctx, variable);
        if (!JS_IsException(proto)) {
          JSValue variable_json = js_debugger_get_variable(ctx, state, JS_NewString(ctx, "__proto__"), proto);
          JS_FreeValue(ctx, proto);
          JS_SetPropertyUint32(ctx, properties, offset++, variable_json);
        } else {
          JS_FreeValue(ctx, proto);
        }
      }

      for (int i = 0; i < tab_atom_count; i++) {
        JSValue value = JS_GetProperty(ctx, variable, tab_atom[i].atom);
        JSValue variable_json = js_debugger_get_variable(ctx, state, JS_AtomToString(ctx, tab_atom[i].atom), value);
        JS_FreeValue(ctx, value);
        JS_SetPropertyUint32(ctx, properties, i + offset, variable_json);
      }

      js_free_prop_enum(ctx, tab_atom, tab_atom_count);
    }

  done:
    JS_FreeValue(ctx, variable);

    js_transport_send_response(info, request, properties);
  }
  JS_FreeCString(ctx, command);
  JS_FreeValue(ctx, command_property);
  JS_FreeValue(ctx, request);
}

static void js_process_breakpoints(JSDebuggerInfo* info, JSValue message) {
  JSContext* ctx = info->ctx;

  // force all functions to reprocess their breakpoints.
  info->breakpoints_dirty_counter++;

  JSValue path_property = JS_GetPropertyStr(ctx, message, "path");
  const char* path = JS_ToCString(ctx, path_property);
  JSValue path_data = JS_GetPropertyStr(ctx, info->breakpoints, path);

  if (!JS_IsUndefined(path_data))
    JS_FreeValue(ctx, path_data);
  // use an object to store the breakpoints as a sparse array, basically.
  // this will get resolved into a pc array mirror when its detected as dirty.
  path_data = JS_NewObject(ctx);
  JS_SetPropertyStr(ctx, info->breakpoints, path, path_data);
  JS_FreeCString(ctx, path);
  JS_FreeValue(ctx, path_property);

  JSValue breakpoints = JS_GetPropertyStr(ctx, message, "breakpoints");
  JS_SetPropertyStr(ctx, path_data, "breakpoints", breakpoints);
  JS_SetPropertyStr(ctx, path_data, "dirty", JS_NewInt32(ctx, info->breakpoints_dirty_counter));

  JS_FreeValue(ctx, message);
}

JSValue js_debugger_file_breakpoints(JSContext* ctx, const char* path) {
  JSDebuggerInfo* info = js_debugger_info(JS_GetRuntime(ctx));
  JSValue path_data = JS_GetPropertyStr(ctx, info->breakpoints, path);
  return path_data;
}

static int js_process_debugger_messages(JSDebuggerInfo* info, const uint8_t* cur_pc) {
  // continue processing messages until the continue message is received.
  JSContext* ctx = info->ctx;
  struct DebuggerSuspendedState state;
  state.variable_reference_count = js_debugger_stack_depth(ctx) << 2;
  state.variable_pointers = JS_NewObject(ctx);
  state.variable_references = JS_NewObject(ctx);
  state.cur_pc = cur_pc;
  int ret = 0;

  do {
    MessageItem item;
    if (!read_frontend_messages(info, &item)) {
      goto done;
    }

    JSValue message = JS_ParseJSON(ctx, item.buf, item.length, "<debugger>");
    JSValue vtype = JS_GetPropertyStr(ctx, message, "type");
    const char* type = JS_ToCString(ctx, vtype);
    if (strcmp("request", type) == 0) {
      js_process_request(info, &state, JS_GetPropertyStr(ctx, message, "request"));
      // done_processing = 1;
    } else if (strcmp("continue", type) == 0) {
      info->is_paused = 0;
    } else if (strcmp("breakpoints", type) == 0) {
      js_process_breakpoints(info, JS_GetPropertyStr(ctx, message, "breakpoints"));
    } else if (strcmp("stopOnException", type) == 0) {
      JSValue stop = JS_GetPropertyStr(ctx, message, "stopOnException");
      info->exception_breakpoint = JS_ToBool(ctx, stop);
      JS_FreeValue(ctx, stop);
    }

    JS_FreeCString(ctx, type);
    JS_FreeValue(ctx, vtype);
    JS_FreeValue(ctx, message);
  } while (info->is_paused);

  ret = 1;

done:
  JS_FreeValue(ctx, state.variable_references);
  JS_FreeValue(ctx, state.variable_pointers);
  return ret;
}

void js_debugger_exception(JSContext* ctx) {
  JSDebuggerInfo* info = js_debugger_info(JS_GetRuntime(ctx));
  if (!info->exception_breakpoint)
    return;
  if (info->is_debugging)
    return;
  info->is_debugging = 1;
  info->ctx = ctx;
  js_send_stopped_event(info, "exception");
  info->is_paused = 1;
  js_process_debugger_messages(info, NULL);
  info->is_debugging = 0;
  info->ctx = NULL;
}

static void js_debugger_context_event(JSContext* caller_ctx, const char* reason) {
  if (!js_debugger_is_transport_connected(JS_GetRuntime(caller_ctx)))
    return;

  JSDebuggerInfo* info = js_debugger_info(JS_GetRuntime(caller_ctx));
  if (info->debugging_ctx == caller_ctx)
    return;

  JSContext* ctx = info->debugging_ctx;

  JSValue event = JS_NewObject(ctx);
  // better thread id?
  JS_SetPropertyStr(ctx, event, "type", JS_NewString(ctx, "ThreadEvent"));
  JS_SetPropertyStr(ctx, event, "reason", JS_NewString(ctx, reason));
  JS_SetPropertyStr(ctx, event, "thread", JS_NewInt64(ctx, (int64_t)caller_ctx));
  js_transport_send_event(info, event);
}

void js_debugger_new_context(JSContext* ctx) {
  js_debugger_context_event(ctx, "new");
}

void js_debugger_free_context(JSContext* ctx) {
  js_debugger_context_event(ctx, "exited");
}

// in thread check request/response of pending commands.
// todo: background thread that reads the socket.
void js_debugger_check(JSContext* ctx, const uint8_t* cur_pc) {
  JSDebuggerInfo* info = js_debugger_info(JS_GetRuntime(ctx));
  if (info->is_debugging)
    return;
  if (info->debugging_ctx == ctx)
    return;
  info->is_debugging = TRUE;
  info->ctx = ctx;

  if (info->is_connected != TRUE)
    goto done;

  struct JSDebuggerLocation location;
  uint32_t depth;

  // perform stepping checks prior to the breakpoint check
  // as those need to preempt breakpoint behavior to skip their last
  // position, which may be a breakpoint.
  if (info->stepping) {
    // all step operations need to ignore their step location, as those
    // may be on a breakpoint.
    location = js_debugger_current_location(ctx, cur_pc);
    depth = js_debugger_stack_depth(ctx);
    if (info->step_depth == depth && location.filename == info->step_over.filename &&
        location.line == info->step_over.line && location.column == info->step_over.column)
      goto done;
  }

  int at_breakpoint = js_debugger_check_breakpoint(ctx, info->breakpoints_dirty_counter, cur_pc);
  if (at_breakpoint) {
    // reaching a breakpoint resets any existing stepping.
    info->stepping = 0;
    info->is_paused = 1;
    js_send_stopped_event(info, "breakpoint");
  } else if (info->stepping) {
    if (info->stepping == JS_DEBUGGER_STEP_CONTINUE) {
      // continue needs to proceed over the existing statement (which may be multiple ops)
      // once any change in location is detecting, turn off stepping.
      // since reaching here after performing the check above, that is in fact the case.
      // turn off stepping.
      info->stepping = 0;
    } else if (info->stepping == JS_DEBUGGER_STEP_IN) {
      uint32_t current_depth = js_debugger_stack_depth(ctx);
      // break if the stack is deeper
      // or
      // break if the depth is the same, but the location has changed
      // or
      // break if the stack unwinds
      if (info->step_depth == current_depth) {
        struct JSDebuggerLocation current_location = js_debugger_current_location(ctx, cur_pc);
        if (current_location.filename == info->step_over.filename && current_location.line == info->step_over.line &&
            current_location.column == info->step_over.column)
          goto done;
      }
      info->stepping = 0;
      info->is_paused = 1;
      js_send_stopped_event(info, "stepIn");
    } else if (info->stepping == JS_DEBUGGER_STEP_OUT) {
      uint32_t current_depth = js_debugger_stack_depth(ctx);
      if (current_depth >= info->step_depth)
        goto done;
      info->stepping = 0;
      info->is_paused = 1;
      js_send_stopped_event(info, "stepOut");
    } else if (info->stepping == JS_DEBUGGER_STEP) {
      struct JSDebuggerLocation current_location = js_debugger_current_location(ctx, cur_pc);
      // to step over, need to make sure the location changes,
      // and that the location change isn't into a function call (deeper stack).
      if ((current_location.filename == info->step_over.filename && current_location.line == info->step_over.line &&
           current_location.column == info->step_over.column) ||
          js_debugger_stack_depth(ctx) > info->step_depth)
        goto done;
      info->stepping = 0;
      info->is_paused = 1;
      js_send_stopped_event(info, "step");
    } else {
      // ???
      info->stepping = 0;
    }
  }

  if (js_process_debugger_messages(info, cur_pc))
    goto done;
done:
  info->is_debugging = 0;
  info->ctx = NULL;
}

void js_debugger_free(JSRuntime* rt, JSDebuggerInfo* info) {
  if (!info->is_connected)
    return;

  // don't use the JSContext because it might be in a funky state during teardown.
  const char* terminated = "{\"type\":\"event\",\"event\":{\"type\":\"terminated\"}}";
  js_transport_write_fully(info, terminated, strlen(terminated));

  struct list_head* el;

  list_for_each(el, &info->backend_message) {
    MessageItem* message_item = list_entry(el, MessageItem, link);
    list_del(&message_item->link);
  }

  list_for_each(el, &info->frontend_messages) {
    MessageItem* message_item = list_entry(el, MessageItem, link);
    list_del(&message_item->link);
    js_free(info->ctx, message_item->buf);
  }

  info->is_connected = FALSE;
  JS_FreeValue(info->debugging_ctx, info->breakpoints);
  JS_FreeContext(info->debugging_ctx);
  info->debugging_ctx = NULL;
}


void* JS_AttachDebugger(JSContext* ctx, DebuggerMethods* methods) {
  JSRuntime* rt = JS_GetRuntime(ctx);
  JSDebuggerInfo* info = js_debugger_info(rt);
  js_debugger_free(rt, info);

  init_list_head(&info->frontend_messages);
  init_list_head(&info->backend_message);

  // Attach native methods and export to Dart.
  methods->write_frontend_commands = handle_client_write;
  methods->read_backend_commands = handle_client_read;

  info->debugging_ctx = JS_NewContext(rt);
  info->is_connected = TRUE;

  JSContext* original_ctx = info->ctx;
  info->ctx = ctx;

  js_send_stopped_event(info, "entry");

  info->breakpoints = JS_NewObject(info->debugging_ctx);
  info->is_paused = 1;

  js_process_debugger_messages(info, NULL);

  info->ctx = original_ctx;

  return info;
}

int js_debugger_is_transport_connected(JSRuntime* rt) {
  return js_debugger_info(rt)->is_connected;
}

JSDebuggerLocation js_debugger_current_location(JSContext* ctx, const uint8_t* cur_pc) {
  JSDebuggerLocation location;
  location.filename = 0;
  JSStackFrame* sf = ctx->rt->current_stack_frame;
  if (!sf)
    return location;

  JSObject* p = JS_VALUE_GET_OBJ(sf->cur_func);
  if (!p)
    return location;

  JSFunctionBytecode* b = p->u.func.function_bytecode;
  if (!b || !b->has_debug)
    return location;

  location.line = find_line_num(ctx, b, (cur_pc ? cur_pc : sf->cur_pc) - b->byte_code_buf - 1);
  location.column = find_column_num(ctx, b, (cur_pc ? cur_pc : sf->cur_pc) - b->byte_code_buf - 1);
  location.filename = b->debug.filename;
  return location;
}

JSDebuggerInfo* js_debugger_info(JSRuntime* rt) {
  return &rt->debugger_info;
}

uint32_t js_debugger_stack_depth(JSContext* ctx) {
  uint32_t stack_index = 0;
  JSStackFrame* sf = ctx->rt->current_stack_frame;
  while (sf != NULL) {
    sf = sf->prev_frame;
    stack_index++;
  }
  return stack_index;
}

JSValue js_debugger_build_backtrace(JSContext* ctx, const uint8_t* cur_pc) {
  JSStackFrame* sf;
  const char* func_name_str;
  JSObject* p;
  JSValue ret = JS_NewArray(ctx);
  uint32_t stack_index = 0;

  for (sf = ctx->rt->current_stack_frame; sf != NULL; sf = sf->prev_frame) {
    JSValue current_frame = JS_NewObject(ctx);

    uint32_t id = stack_index++;
    JS_SetPropertyStr(ctx, current_frame, "id", JS_NewUint32(ctx, id));

    func_name_str = get_func_name(ctx, sf->cur_func);
    if (!func_name_str || func_name_str[0] == '\0')
      JS_SetPropertyStr(ctx, current_frame, "name", JS_NewString(ctx, "<anonymous>"));
    else
      JS_SetPropertyStr(ctx, current_frame, "name", JS_NewString(ctx, func_name_str));
    JS_FreeCString(ctx, func_name_str);

    p = JS_VALUE_GET_OBJ(sf->cur_func);
    if (p && js_class_has_bytecode(p->class_id)) {
      JSFunctionBytecode* b;
      int line_num1;

      b = p->u.func.function_bytecode;
      if (b->has_debug) {
        const uint8_t* pc = sf != ctx->rt->current_stack_frame || !cur_pc ? sf->cur_pc : cur_pc;
        line_num1 = find_line_num(ctx, b, pc - b->byte_code_buf - 1);
        JS_SetPropertyStr(ctx, current_frame, "filename", JS_AtomToString(ctx, b->debug.filename));
        if (line_num1 != -1)
          JS_SetPropertyStr(ctx, current_frame, "line", JS_NewUint32(ctx, line_num1));
      }
    } else {
      JS_SetPropertyStr(ctx, current_frame, "name", JS_NewString(ctx, "(native)"));
    }
    JS_SetPropertyUint32(ctx, ret, id, current_frame);
  }
  return ret;
}

int js_debugger_check_breakpoint(JSContext* ctx, uint32_t current_dirty, const uint8_t* cur_pc) {
  JSValue path_data = JS_UNDEFINED;
  if (!ctx->rt->current_stack_frame)
    return 0;
  JSObject* f = JS_VALUE_GET_OBJ(ctx->rt->current_stack_frame->cur_func);
  if (!f || !js_class_has_bytecode(f->class_id))
    return 0;
  JSFunctionBytecode* b = f->u.func.function_bytecode;
  if (!b->has_debug || !b->debug.filename)
    return 0;

  // check if up to date
  if (b->debugger.dirty == current_dirty)
    goto done;

  // note the dirty value and mark as up to date
  uint32_t dirty = b->debugger.dirty;
  b->debugger.dirty = current_dirty;

  const char* filename = JS_AtomToCString(ctx, b->debug.filename);
  path_data = js_debugger_file_breakpoints(ctx, filename);
  JS_FreeCString(ctx, filename);
  if (JS_IsUndefined(path_data))
    goto done;

  JSValue path_dirty_value = JS_GetPropertyStr(ctx, path_data, "dirty");
  uint32_t path_dirty;
  JS_ToUint32(ctx, &path_dirty, path_dirty_value);
  JS_FreeValue(ctx, path_dirty_value);
  // check the dirty value on this source file specifically
  if (path_dirty == dirty)
    goto done;

  // todo: bit field?
  // clear/alloc breakpoints
  if (!b->debugger.breakpoints)
    b->debugger.breakpoints = js_malloc_rt(ctx->rt, b->byte_code_len);
  memset(b->debugger.breakpoints, 0, b->byte_code_len);

  JSValue breakpoints = JS_GetPropertyStr(ctx, path_data, "breakpoints");

  JSValue breakpoints_length_property = JS_GetPropertyStr(ctx, breakpoints, "length");
  uint32_t breakpoints_length;
  JS_ToUint32(ctx, &breakpoints_length, breakpoints_length_property);
  JS_FreeValue(ctx, breakpoints_length_property);

  const uint8_t *p_end, *p;
  int new_line_num, line_num, pc, v, ret;
  unsigned int op;

  p = b->debug.pc2line_buf;
  p_end = p + b->debug.pc2line_len;
  pc = 0;
  line_num = b->debug.line_num;

  for (uint32_t i = 0; i < breakpoints_length; i++) {
    JSValue breakpoint = JS_GetPropertyUint32(ctx, breakpoints, i);
    JSValue breakpoint_line_prop = JS_GetPropertyStr(ctx, breakpoint, "line");
    uint32_t breakpoint_line;
    JS_ToUint32(ctx, &breakpoint_line, breakpoint_line_prop);
    JS_FreeValue(ctx, breakpoint_line_prop);
    JS_FreeValue(ctx, breakpoint);

    // breakpoint is before the current line.
    // todo: this may be an invalid breakpoint if it's inside the function, but got
    // skipped over.
    if (breakpoint_line < line_num)
      continue;
    // breakpoint is after function end. can stop, as breakpoints are in sorted order.
    if (b->debugger.last_line_num && breakpoint_line > b->debugger.last_line_num)
      break;

    int last_line_num = line_num;
    int line_pc = pc;

    // scan until we find the start pc for the breakpoint
    while (p < p_end && line_num <= breakpoint_line) {
      // scan line by line
      while (p < p_end && line_num == last_line_num) {
        op = *p++;
        if (op == 0) {
          uint32_t val;
          ret = get_leb128(&val, p, p_end);
          if (ret < 0)
            goto fail;
          pc += val;
          p += ret;
          ret = get_sleb128(&v, p, p_end);
          if (ret < 0)
            goto fail;
          p += ret;
          new_line_num = line_num + v;
        } else {
          op -= PC2LINE_OP_FIRST;
          pc += (op / PC2LINE_RANGE);
          new_line_num = line_num + (op % PC2LINE_RANGE) + PC2LINE_BASE;
        }
        line_num = new_line_num;
      }

      if (line_num != last_line_num) {
        // new line found, check if it is the one with breakpoint.
        if (last_line_num == breakpoint_line && line_num > last_line_num)
          memset(b->debugger.breakpoints + line_pc, 1, pc - line_pc);

        // update the line trackers
        line_pc = pc;
        last_line_num = line_num;
      }
    }

    if (p >= p_end)
      b->debugger.last_line_num = line_num;
  }

fail:
  JS_FreeValue(ctx, breakpoints);

done:
  JS_FreeValue(ctx, path_data);

  if (!b->debugger.breakpoints)
    return 0;

  pc = (cur_pc ? cur_pc : ctx->rt->current_stack_frame->cur_pc) - b->byte_code_buf - 1;
  if (pc < 0 || pc > b->byte_code_len)
    return 0;
  return b->debugger.breakpoints[pc];
}

JSValue js_debugger_local_variables(JSContext* ctx, int stack_index) {
  JSValue ret = JS_NewObject(ctx);

  // put exceptions on the top stack frame
  if (stack_index == 0 && !JS_IsNull(ctx->rt->current_exception) && !JS_IsUndefined(ctx->rt->current_exception))
    JS_SetPropertyStr(ctx, ret, "<exception>", JS_DupValue(ctx, ctx->rt->current_exception));

  JSStackFrame* sf;
  int cur_index = 0;

  for (sf = ctx->rt->current_stack_frame; sf != NULL; sf = sf->prev_frame) {
    // this val is one frame up
    if (cur_index == stack_index - 1) {
      JSObject* f = JS_VALUE_GET_OBJ(sf->cur_func);
      if (f && js_class_has_bytecode(f->class_id)) {
        JSFunctionBytecode* b = f->u.func.function_bytecode;

        JSValue this_obj = sf->var_buf[b->var_count];
        // only provide a this if it is not the global object.
        if (JS_VALUE_GET_OBJ(this_obj) != JS_VALUE_GET_OBJ(ctx->global_obj))
          JS_SetPropertyStr(ctx, ret, "this", JS_DupValue(ctx, this_obj));
      }
    }

    if (cur_index < stack_index) {
      cur_index++;
      continue;
    }

    JSObject* f = JS_VALUE_GET_OBJ(sf->cur_func);
    if (!f || !js_class_has_bytecode(f->class_id))
      goto done;
    JSFunctionBytecode* b = f->u.func.function_bytecode;

    for (uint32_t i = 0; i < b->arg_count + b->var_count; i++) {
      JSValue var_val;
      if (i < b->arg_count)
        var_val = sf->arg_buf[i];
      else
        var_val = sf->var_buf[i - b->arg_count];

      if (JS_IsUninitialized(var_val))
        continue;

      JSVarDef* vd = b->vardefs + i;
      JS_SetProperty(ctx, ret, vd->var_name, JS_DupValue(ctx, var_val));
    }

    break;
  }

done:
  return ret;
}

JSValue js_debugger_closure_variables(JSContext* ctx, int stack_index) {
  JSValue ret = JS_NewObject(ctx);

  JSStackFrame* sf;
  int cur_index = 0;
  for (sf = ctx->rt->current_stack_frame; sf != NULL; sf = sf->prev_frame) {
    if (cur_index < stack_index) {
      cur_index++;
      continue;
    }

    JSObject* f = JS_VALUE_GET_OBJ(sf->cur_func);
    if (!f || !js_class_has_bytecode(f->class_id))
      goto done;

    JSFunctionBytecode* b = f->u.func.function_bytecode;

    for (uint32_t i = 0; i < b->closure_var_count; i++) {
      JSClosureVar* cvar = b->closure_var + i;
      JSValue var_val;
      JSVarRef* var_ref = NULL;
      if (f->u.func.var_refs)
        var_ref = f->u.func.var_refs[i];
      if (!var_ref || !var_ref->pvalue)
        continue;
      var_val = *var_ref->pvalue;

      if (JS_IsUninitialized(var_val))
        continue;

      JS_SetProperty(ctx, ret, cvar->var_name, JS_DupValue(ctx, var_val));
    }

    break;
  }

done:
  return ret;
}

/* debugger needs ability to eval at any stack frame */
static JSValue js_debugger_eval(JSContext* ctx,
                                JSValueConst this_obj,
                                JSStackFrame* sf,
                                const char* input,
                                size_t input_len,
                                const char* filename,
                                int flags,
                                int scope_idx) {
  JSParseState s1, *s = &s1;
  int err, js_mode;
  JSValue fun_obj, ret_val;
  JSVarRef** var_refs;
  JSFunctionBytecode* b;
  JSFunctionDef* fd;

  js_parse_init(ctx, s, input, input_len, filename);
  skip_shebang(s);

  JSObject* p;
  assert(sf != NULL);
  assert(JS_VALUE_GET_TAG(sf->cur_func) == JS_TAG_OBJECT);
  p = JS_VALUE_GET_OBJ(sf->cur_func);
  assert(js_class_has_bytecode(p->class_id));
  b = p->u.func.function_bytecode;
  var_refs = p->u.func.var_refs;
  js_mode = b->js_mode;

  fd = js_new_function_def(ctx, NULL, TRUE, FALSE, filename, 1, 0);
  if (!fd)
    goto fail1;
  s->cur_func = fd;
  fd->eval_type = JS_EVAL_TYPE_DIRECT;
  fd->has_this_binding = 0;
  fd->new_target_allowed = b->new_target_allowed;
  fd->super_call_allowed = b->super_call_allowed;
  fd->super_allowed = b->super_allowed;
  fd->arguments_allowed = b->arguments_allowed;
  fd->js_mode = js_mode;
  fd->func_name = JS_DupAtom(ctx, JS_ATOM__eval_);
  if (b) {
    int idx;
    if (!b->var_count)
      idx = -1;
    else
      // use DEBUG_SCOP_INDEX to add all lexical variables to debug eval closure.
      idx = DEBUG_SCOPE_INDEX;
    if (add_closure_variables(ctx, fd, b, idx))
      goto fail;
  }
  fd->module = NULL;
  s->is_module = 0;
  s->allow_html_comments = !s->is_module;

  push_scope(s); /* body scope */

  err = js_parse_program(s);
  if (err) {
  fail:
    free_token(s, &s->token);
    js_free_function_def(ctx, fd);
    goto fail1;
  }

  /* create the function object and all the enclosed functions */
  fun_obj = js_create_function(ctx, fd);
  if (JS_IsException(fun_obj))
    goto fail1;
  if (flags & JS_EVAL_FLAG_COMPILE_ONLY) {
    ret_val = fun_obj;
  } else {
    ret_val = JS_EvalFunctionInternal(ctx, fun_obj, this_obj, var_refs, sf);
  }
  return ret_val;
fail1:
  return JS_EXCEPTION;
}

JSValue js_debugger_evaluate(JSContext* ctx, int stack_index, JSValue expression) {
  JSStackFrame* sf;
  int cur_index = 0;

  for (sf = ctx->rt->current_stack_frame; sf != NULL; sf = sf->prev_frame) {
    if (cur_index < stack_index) {
      cur_index++;
      continue;
    }

    JSObject* f = JS_VALUE_GET_OBJ(sf->cur_func);
    if (!f || !js_class_has_bytecode(f->class_id))
      return JS_UNDEFINED;
    JSFunctionBytecode* b = f->u.func.function_bytecode;

    int scope_idx = b->vardefs ? 0 : -1;
    size_t len;
    const char* str = JS_ToCStringLen(ctx, &len, expression);
    JSValue ret =
        js_debugger_eval(ctx, sf->var_buf[b->var_count], sf, str, len, "<debugger>", JS_EVAL_TYPE_DIRECT, scope_idx);
    JS_FreeCString(ctx, str);
    return ret;
  }
  return JS_UNDEFINED;
}

#else

void JS_AttachDebugger(JSContext* ctx,
                       uint32_t (*transport_read)(void* udata, char* buffer, uint32_t* length),
                       uint32_t (*transport_write)(void* udata, const char* buffer, uint32_t length),
                       void (*transport_close)(void* rt, void* udata),
                       void* udata) {}

#endif