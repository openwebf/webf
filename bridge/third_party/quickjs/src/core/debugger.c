/*
 * Copyright (C) 2022 Koushik Dutta. https://github.com/koush
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "debugger.h"
#include <pthread.h>
#include "base.h"
#include "dap_converter.h"
#include "dap_protocol.h"
#include "parser.h"
#include "runtime.h"
#include "types.h"

#if ENABLE_DEBUGGER

static void js_process_breakpoints(JSDebuggerInfo* info,
                                   Source* source,
                                   SourceBreakpoint* breakpoints,
                                   size_t breakpointsLen);

typedef struct DebuggerSuspendedState {
  uint32_t variable_reference_count;
  JSValue variable_references;
  JSValue variable_pointers;
  const uint8_t* cur_pc;
} DebuggerSuspendedState;

typedef struct VariableType {
  const char* type;
  int64_t variablesReference;
} VariableType;

const char* to_json_string(JSContext* ctx, JSValue value) {
  JSValue stringify_value = JS_JSONStringify(ctx, value, JS_UNDEFINED, JS_UNDEFINED);
  const char* value_str = JS_ToCString(ctx, stringify_value);
  const char* result = copy_string(value_str, strlen(value_str));
  JS_FreeCString(ctx, value_str);
  JS_FreeValue(ctx, stringify_value);
  return result;
}

const char* atom_to_string(JSContext* ctx, JSAtom atom) {
  JSValue name_value = JS_AtomToString(ctx, atom);
  const char* value_str = JS_ToCString(ctx, name_value);
  const char* result = copy_string(value_str, strlen(value_str));
  JS_FreeCString(ctx, value_str);
  JS_FreeValue(ctx, name_value);
  return result;
}

static uint32_t handle_client_write(void* ptr, DebuggerMessage* message) {
  JSDebuggerInfo* info = (JSDebuggerInfo*)ptr;
  // Gain access to front_message.
  pthread_mutex_lock(&info->frontend_message_access);

  char* buf = js_malloc_rt(info->runtime, message->length + 1);
  strcpy(buf, message->buf);

  MessageItem* item = js_malloc_rt(info->runtime, sizeof(MessageItem));
  item->buf = buf;
  item->length = message->length;

  printf("client write item, buffer: %p len: %d\n", item->buf, item->length);
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

  // Calculate the head through byte offset.
  struct list_head* el = info->backend_message.next;
  MessageItem* head = list_entry(el, MessageItem, link);
  message->buf = head->buf;
  message->length = head->length;
  list_del(&head->link);

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
  struct list_head* el = info->frontend_messages.next;
  MessageItem* head = list_entry(el, MessageItem, link);

  printf("debugger read item, buffer %p len: %d\n", head->buf, head->length);

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

static void js_transport_send_response(JSDebuggerInfo* info, JSContext* ctx, Response* response) {
  const char* buf = stringify_response(ctx, (Response*) response);
  write_backend_message(info, buf, strlen(buf));
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

static uint32_t js_transport_send_event(JSDebuggerInfo* info, Event* event) {
  size_t length;
  const char* buf = stringify_event(info->ctx, event, &length);
  write_backend_message(info, buf, length);
}

static void js_send_stopped_event(JSDebuggerInfo* info, const char* reason) {
  JSContext* ctx = info->debugging_ctx;

  StoppedEvent* event = initialize_event(ctx, "stopped");
  event->body->reason = reason;
  event->body->threadId = (int64_t)info->ctx;
  js_transport_send_event(info, (Event*) event);
}

static Scope* js_get_scopes(JSContext* ctx, int64_t frame) {
  // for now this is always the same.
  // global, local, closure. may change in the future. can check if closure is empty.
  Scope* scope = js_malloc(ctx, sizeof(Scope) * 3);

  // Get local scope
  scope[0].name = "Local";
  scope[0].variablesReference = (frame << 2) + 1;
  scope[0].expensive = 0;

  // Get closure
  scope[1].name = "Closure";
  scope[1].variablesReference = (frame << 2) + 2;
  scope[1].expensive = 0;

  // Get global
  scope[2].name = "Global";
  scope[2].variablesReference = (frame << 2) + 0;
  scope[2].expensive = 0;

  return scope;
}

static inline JS_BOOL JS_IsInteger(JSValueConst v) {
  int tag = JS_VALUE_GET_TAG(v);
  return tag == JS_TAG_INT || tag == JS_TAG_BIG_INT;
}

static void js_debugger_get_variable_type(JSContext* ctx,
                                          struct DebuggerSuspendedState* state,
                                          VariableType* variable_type,
                                          JSValue var_val) {
  // 0 means not expandible
  uint32_t reference = 0;
  if (JS_IsString(var_val))
    variable_type->type = "string";
  else if (JS_IsInteger(var_val))
    variable_type->type = "integer";
  else if (JS_IsNumber(var_val) || JS_IsBigFloat(var_val))
    variable_type->type = "float";
  else if (JS_IsBool(var_val))
    variable_type->type = "boolean";
  else if (JS_IsNull(var_val))
    variable_type->type = "null";
  else if (JS_IsUndefined(var_val))
    variable_type->type = "undefined";
  else if (JS_IsObject(var_val)) {
    variable_type->type = "object";

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
  variable_type->variablesReference = reference;
}

//static void js_debugger_get_value(JSContext* ctx, JSValue var_val, JSValue var, const char* value_property) {
//  // do not toString on Arrays, since that makes a giant string of all the elements.
//  // todo: typed arrays?
//  if (JS_IsArray(ctx, var_val)) {
//    JSValue length = JS_GetPropertyStr(ctx, var_val, "length");
//    uint32_t len;
//    JS_ToUint32(ctx, &len, length);
//    JS_FreeValue(ctx, length);
//    char lenBuf[64];
//    sprintf(lenBuf, "Array (%d)", len);
//    JS_SetPropertyStr(ctx, var, value_property, JS_NewString(ctx, lenBuf));
//    JS_SetPropertyStr(ctx, var, "indexedVariables", JS_NewInt32(ctx, len));
//  } else {
//    JS_SetPropertyStr(ctx, var, value_property, JS_ToString(ctx, var_val));
//  }
//}

//static JSValue js_debugger_get_variable(JSContext* ctx,
//                                        struct DebuggerSuspendedState* state,
//                                        JSValue var_name,
//                                        JSValue var_val) {
////  JSValue var = JS_NewObject(ctx);
////  JS_SetPropertyStr(ctx, var, "name", var_name);
////  js_debugger_get_value(ctx, var_val, var, "value");
////  js_debugger_get_variable_type(ctx, state, var, var_val);
//  return var;
//}

static int js_debugger_get_frame(JSContext* ctx, JSValue args) {
  JSValue reference_property = JS_GetPropertyStr(ctx, args, "frameId");
  int frame;
  JS_ToInt32(ctx, &frame, reference_property);
  JS_FreeValue(ctx, reference_property);

  return frame;
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

static void process_request(JSDebuggerInfo* info, struct DebuggerSuspendedState* state, const Request* request) {
  JSContext* ctx = info->ctx;
  const char* command = request->command;

  if (strcmp(command, "evaluate") == 0) {
    EvaluateArguments* arguments = (EvaluateArguments*) request->arguments;
    int frame = arguments->frameId;
    const char* expression = arguments->expression;
    JSValue result = js_debugger_evaluate(ctx, frame, expression);
    if (JS_IsException(result)) {
      JS_FreeValue(ctx, result);
      result = JS_GetException(ctx);
    }

    EvaluateResponse* response = (EvaluateResponse*) initialize_response(ctx, request, "evaluate");
    size_t len;
    const char* evaluate_result = JS_ToCStringLen(ctx, &len, result);
    response->body->result = copy_string(evaluate_result, len);
    VariableType variable_type;
    js_debugger_get_variable_type(ctx, state, &variable_type, result);
    response->body->type = variable_type.type;
    response->body->variablesReference = variable_type.variablesReference;

    const char* buf = stringify_response(ctx, (Response*)response);
    write_backend_message(info, buf, strlen(buf));

    JS_FreeCString(ctx, evaluate_result);
    JS_FreeValue(ctx, result);
  } else if (strcmp(command, "continue") == 0) {
    info->stepping = JS_DEBUGGER_STEP_CONTINUE;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    ContinueResponse* response = (ContinueResponse*) initialize_response(ctx, request, "continue");
    js_transport_send_response(info, ctx, (Response*) response);
    info->is_paused = 0;
  } else if (strcmp(command, "pause") == 0) {
    PauseResponse* response = (PauseResponse*)initialize_response(ctx, request, "pause");
    js_transport_send_response(info, ctx, (Response*) response);
    js_send_stopped_event(info, "pause");
    info->is_paused = 1;
  } else if (strcmp(command, "next") == 0) {
    info->stepping = JS_DEBUGGER_STEP;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    NextResponse* response = initialize_response(ctx, request, "next");
    js_transport_send_response(info, ctx, (Response*) response);
    info->is_paused = 0;
  } else if (strcmp(command, "stepIn") == 0) {
    info->stepping = JS_DEBUGGER_STEP_IN;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    StepInResponse* response = initialize_response(ctx, request, "stepIn");
    js_transport_send_response(info, ctx, (Response*) response);
    info->is_paused = 0;
  } else if (strcmp(command, "stepOut") == 0) {
    info->stepping = JS_DEBUGGER_STEP_OUT;
    info->step_over = js_debugger_current_location(ctx, state->cur_pc);
    info->step_depth = js_debugger_stack_depth(ctx);
    StepOutResponse* response = initialize_response(ctx, request, "stepOut");
    js_transport_send_response(info, ctx, (Response*) response);
    info->is_paused = 0;
  } else if (strcmp(command, "stackTrace") == 0) {
    StackTraceResponse* response = initialize_response(ctx, request, "stackTrace");
    js_debugger_build_backtrace(ctx, state->cur_pc, response->body);
    js_transport_send_response(info, ctx, (Response*) response);
  } else if (strcmp(command, "scopes") == 0) {
    ScopesArguments* arguments = (ScopesArguments*)request->arguments;
    int64_t frame = arguments->frameId;
    ScopeResponse* response = initialize_response(ctx, request, "scopes");
    response->body->scopes = js_get_scopes(ctx, frame);
    js_transport_send_response(info, ctx, (Response*)response);
  } else if (strcmp(command, "setBreakpoints") == 0) {
    SetBreakpointsArguments* arguments = (SetBreakpointsArguments*)request->arguments;
    js_process_breakpoints(info, arguments->source, arguments->breakpoints, arguments->breakpointsLen);
    SetBreakpointsResponse* response = initialize_response(ctx, request, "setBreakpoints");
    js_transport_send_response(info, ctx, (Response*) response);
  } else if (strcmp(command, "setExceptionBreakpoints") == 0) {
    SetExceptionBreakpointsArguments* arguments = (SetExceptionBreakpointsArguments*) request->arguments;
    info->exception_breakpoint = arguments->filtersLen > 0;
    SetExceptionBreakpointsResponse* response = initialize_response(ctx, request, "setExceptionBreakpoints");
    js_transport_send_response(info, ctx, (Response*) response);
  } else if (strcmp(command, "variables") == 0) {
    VariablesArguments* arguments = (VariablesArguments*)request->arguments;
    int64_t reference = arguments->variablesReference;
    JSValue variable = JS_GetPropertyUint32(ctx, state->variable_references, reference);
    Variable* variables;
    size_t variableLen = 0;

    int skip_proto = 0;
    // if the variable reference was not found,
    // then it must be a frame locals, frame closures, or the global
    if (JS_IsUndefined(variable)) {
      skip_proto = 1;
      int64_t frame = reference >> 2;
      int64_t scope = reference % 4;

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

    const char* filter = arguments->filter;
    if (filter != NULL) {
      // only index filtering is supported by this server.
      // name filtering exists in VS Code, but is not implemented here.
      int indexed = strcmp(filter, "indexed") == 0;
      if (!indexed)
        goto unfiltered;

      int64_t start = arguments->start;
      int64_t count = arguments->count;

      variables = js_malloc(ctx, sizeof(Variable) * count);
      variableLen = count;

      char name_buf[64];
      for (uint32_t i = 0; i < count; i++) {
        JSValue value = JS_GetPropertyUint32(ctx, variable, start + i);
        VariableType variable_type;
        js_debugger_get_variable_type(ctx, state, &variable_type, value);

        sprintf(name_buf, "%d", i);
        variables[i].name = copy_string(name_buf, strlen(name_buf));
        variables[i].type = variable_type.type;
        variables[i].variablesReference = variable_type.variablesReference;
        variables[i].value = to_json_string(ctx, value);

        JS_FreeValue(ctx, value);
      }
      goto done;
    }

  unfiltered:
    if (!JS_GetOwnPropertyNames(ctx, &tab_atom, &tab_atom_count, variable, JS_GPN_STRING_MASK | JS_GPN_SYMBOL_MASK)) {
      int offset = 0;

      if (!skip_proto) {
        const JSValue proto = JS_GetPrototype(ctx, variable);
        if (!JS_IsException(proto)) {
          JSValue value = JS_GetPropertyStr(ctx, state->variable_references, "__proto__");

          VariableType variable_type;
          js_debugger_get_variable_type(ctx, state, &variable_type, value);

          variables[offset++].name = "__proto__";
          variables[offset++].value = to_json_string(ctx, value);
          variables[offset++].type = variable_type.type;
          variables[offset++].variablesReference = variable_type.variablesReference;
          JS_FreeValue(ctx, value);
        }
        JS_FreeValue(ctx, proto);
      }

      for (int i = 0; i < tab_atom_count; i++) {
        JSValue value = JS_GetProperty(ctx, variable, tab_atom[i].atom);

        VariableType variable_type;
        js_debugger_get_variable_type(ctx, state, &variable_type, value);
        variables[i + offset].name = atom_to_string(ctx, tab_atom[i].atom);
        variables[i + offset].type = variable_type.type;
        variables[i + offset].variablesReference = variable_type.variablesReference;
        variables[i + offset].value = to_json_string(ctx, value);
        JS_FreeValue(ctx, value);
      }

      variableLen = offset + tab_atom_count;
      js_free_prop_enum(ctx, tab_atom, tab_atom_count);
    }

  done:
    JS_FreeValue(ctx, variable);
    VariablesResponse* response = initialize_response(ctx, request, "variable");
    response->body->variables = variables;
    response->body->variablesLen = variableLen;
    js_transport_send_response(info, ctx, response);
  }
}

static void js_process_breakpoints(JSDebuggerInfo* info,
                                   Source* source,
                                   SourceBreakpoint* breakpoints,
                                   size_t breakpointsLen) {
  JSContext* ctx = info->ctx;

  // force all functions to reprocess their breakpoints.
  info->breakpoints_dirty_counter++;

  const char* path = source->path;
  SourceBreakpoint* breakpoint = hashmap_get(info->breakpoints, &(struct BreakPointMapItem){.key = path});
  if (breakpoints != NULL) {
    js_free(ctx, breakpoint);
  }

  hashmap_set(info->breakpoints, &(struct BreakPointMapItem){.key = path,
                                                             .breakpoints = breakpoints,
                                                             .breakpointLen = breakpointsLen,
                                                             .dirty = info->breakpoints_dirty_counter});
}

BreakPointMapItem* js_debugger_file_breakpoints(JSContext* ctx, const char* path) {
  JSDebuggerInfo* info = js_debugger_info(JS_GetRuntime(ctx));
  return hashmap_get(info->breakpoints, &(struct BreakPointMapItem){ .key = path });
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

//    JSValue message = JS_ParseJSON(ctx, item.buf, item.length, "<debugger>");
//    if (JS_IsException(message)) {
//      printf("item message error %s", item.buf);
//    }

    Request* request = js_malloc(ctx, sizeof(Request));
    parse_request(ctx, request, item.buf, item.length);
    process_request(info, &state, request);
    info->is_paused = 0;

//    JSValue vtype = JS_GetPropertyStr(ctx, message, "type");
//    const char* type = JS_ToCString(ctx, vtype);
//    if (strcmp("request", type) == 0) {
//      js_process_request(info, &state,message);
//      // done_processing = 1;
//    } else if (strcmp("continue", type) == 0) {
//      info->is_paused = 0;
//    } else if (strcmp("breakpoints", type) == 0) {
//      js_process_breakpoints(info, JS_GetPropertyStr(ctx, message, "breakpoints"));
//    } else if (strcmp("stopOnException", type) == 0) {
//      JSValue stop = JS_GetPropertyStr(ctx, message, "stopOnException");
//      info->exception_breakpoint = JS_ToBool(ctx, stop);
//      JS_FreeValue(ctx, stop);
//    }

//    JS_FreeCString(ctx, type);
//    JS_FreeValue(ctx, vtype);
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

  ThreadEvent* event = initialize_event(ctx, "thread");
  event->body->reason = reason;
  event->body->threadId = (int64_t)caller_ctx;
  js_transport_send_event(info, (Event*) event);
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
  JS_FreeContext(info->debugging_ctx);
  info->debugging_ctx = NULL;
}

int breakpoint_compare(const void* a, const void* b, void* udata) {
  const struct BreakPointMapItem* ua = a;
  const struct BreakPointMapItem* ub = b;
  return strcmp(ua->key, ub->key);
}

uint64_t breakpoint_hash(const void* item, uint64_t seed0, uint64_t seed1) {
  const struct BreakPointMapItem* user = item;
  return hashmap_sip(user->key, strlen(user->key), seed0, seed1);
}

void* JS_AttachDebugger(JSContext* ctx, DebuggerMethods* methods) {
  JSRuntime* rt = JS_GetRuntime(ctx);
  JSDebuggerInfo* info = js_debugger_info(rt);
  js_debugger_free(rt, info);

  init_list_head(&info->frontend_messages);
  init_list_head(&info->backend_message);

  info->breakpoints =
      hashmap_new(sizeof(struct BreakPointMapItem), 0, 0, 0, breakpoint_hash, breakpoint_compare, NULL, NULL);

  // Attach native methods and export to Dart.
  methods->write_frontend_commands = handle_client_write;
  methods->read_backend_commands = handle_client_read;

  info->debugging_ctx = JS_NewContext(rt);
  info->is_connected = TRUE;

  JSContext* original_ctx = info->ctx;
  info->ctx = ctx;

  js_send_stopped_event(info, "entry");

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

void js_debugger_build_backtrace(JSContext* ctx, const uint8_t* cur_pc, StackTraceResponseBody* body) {
  JSStackFrame* sf;
  const char* func_name_str;
  JSObject* p;
  uint32_t stack_index = 0;

  int MAX_STACK_FRAME = 30;
  StackFrame* stack_frames = js_malloc(ctx, sizeof(StackFrame) * MAX_STACK_FRAME);

  for (sf = ctx->rt->current_stack_frame; sf != NULL; sf = sf->prev_frame) {
    uint32_t id = stack_index++;
    stack_frames[id].id = id;
    func_name_str = get_func_name(ctx, sf->cur_func);
    if (!func_name_str || func_name_str[0] == '\0') {
      stack_frames[id].name = "<anonymous>";
    } else {
      stack_frames[id].name = copy_string(func_name_str, strlen(func_name_str));
    }
    JS_FreeCString(ctx, func_name_str);

    p = JS_VALUE_GET_OBJ(sf->cur_func);
    if (p && js_class_has_bytecode(p->class_id)) {
      JSFunctionBytecode* b;
      int line_num1;
      int column_num1;

      b = p->u.func.function_bytecode;
      if (b->has_debug) {
        const uint8_t* pc = sf != ctx->rt->current_stack_frame || !cur_pc ? sf->cur_pc : cur_pc;
        line_num1 = find_line_num(ctx, b, pc - b->byte_code_buf - 1);
        column_num1 = find_column_num(ctx, b, pc - b->byte_code_buf - 1);
        if (line_num1 != -1) {
          stack_frames[id].line = line_num1;
        }
        if (column_num1 != -1) {
          stack_frames[id].column = column_num1;
        }
      }
    } else {
      stack_frames[id].name = "(native)";
    }
  }

  body->totalFrames = stack_index;
  body->stackFramesLen = stack_index;
  body->stackFrames = stack_frames;
}

int js_debugger_check_breakpoint(JSContext* ctx, uint32_t current_dirty, const uint8_t* cur_pc) {
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
  BreakPointMapItem* path_data = js_debugger_file_breakpoints(ctx, filename);
  JS_FreeCString(ctx, filename);
  if (path_data == NULL)
    goto done;

  uint32_t path_dirty = path_data->dirty;
  // check the dirty value on this source file specifically
  if (path_dirty == dirty)
    goto done;

  // todo: bit field?
  // clear/alloc breakpoints
  if (!b->debugger.breakpoints)
    b->debugger.breakpoints = js_malloc_rt(ctx->rt, b->byte_code_len);
  memset(b->debugger.breakpoints, 0, b->byte_code_len);

  SourceBreakpoint* breakpoints = path_data->breakpoints;
  size_t breakpoints_length = path_data->breakpointLen;

  const uint8_t *p_end, *p;
  int new_line_num, line_num, pc, v, ret;
  unsigned int op;

  p = b->debug.pc2line_buf;
  p_end = p + b->debug.pc2line_len;
  pc = 0;
  line_num = b->debug.line_num;

  for (uint32_t i = 0; i < breakpoints_length; i++) {
    SourceBreakpoint breakpoint = breakpoints[i];
    uint32_t breakpoint_line = breakpoint.line;

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

done:
  if (!b->debugger.breakpoints)
    return 0;

  pc = (cur_pc ? cur_pc : ctx->rt->current_stack_frame->cur_pc) - b->byte_code_buf - 1;
  if (pc < 0 || pc > b->byte_code_len)
    return 0;
  return b->debugger.breakpoints[pc];
}

JSValue js_debugger_local_variables(JSContext* ctx, int64_t stack_index) {
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

JSValue js_debugger_closure_variables(JSContext* ctx, int64_t stack_index) {
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

JSValue js_debugger_evaluate(JSContext* ctx, int64_t stack_index, const char* expression) {
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
    JSValue ret =
        js_debugger_eval(ctx, sf->var_buf[b->var_count], sf, expression, strlen(expression), "<debugger>", JS_EVAL_TYPE_DIRECT, scope_idx);
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