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

#define STACK_FRAME_INDEX_START INT32_MAX
#define LOGGING_VAR_REFERENCE_MAX INT16_MAX

static Variable* js_debugger_get_variables(JSContext* ctx,
                                           JSValue reference_value,
                                           struct DebuggerSuspendedState* state,
                                           int64_t* variable_len,
                                           int8_t skip_proto,
                                           const char* filter,
                                           int64_t filter_start,
                                           int64_t filter_count);
static JSValue js_debugger_get_scope_variable(JSContext* ctx,
                                              int64_t reference,
                                              struct DebuggerSuspendedState* state,
                                              int8_t* skip_proto);
static CompletionItem* js_debugger_get_completions(JSContext* ctx,
                                                   struct DebuggerSuspendedState* state,
                                                   int64_t* completions_len,
                                                   int64_t frame,
                                                   const char* text,
                                                   int64_t completions_column,
                                                   int64_t completion_line);

typedef struct VariableType {
  const char* type;
  const char* value;
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

const char* value_to_string(JSContext* ctx, JSValue value) {
  JSValue name_value = JS_ToString(ctx, value);
  const char* value_str = JS_ToCString(ctx, name_value);
  const char* result = copy_string(value_str, strlen(value_str));
  JS_FreeCString(ctx, value_str);
  JS_FreeValue(ctx, name_value);
  return result;
}


void init_source(Source* source) {
  source->path = NULL;
  source->name = NULL;
  source->presentationHint = NULL;
  source->origin = NULL;
  source->checksums = NULL;
  source->checksumsLen = 0;
  source->sourceReference = NAN;
  source->sources = 0;
  source->sourcesLen = 0;
}

void init_source_breakpoint(SourceBreakpoint* breakpoint) {
  breakpoint->line = NAN;
  breakpoint->column = NAN;
  breakpoint->condition = NULL;
  breakpoint->hitCondition = NULL;
  breakpoint->logMessage = NULL;
}

static void init_stackframe(StackFrame* stack_frame) {
  stack_frame->id = NAN;
  stack_frame->name = NULL;
  stack_frame->source = NULL;
  stack_frame->line = NAN;
  stack_frame->column = NAN;
  stack_frame->endColumn = NAN;
  stack_frame->endLine = NAN;
  stack_frame->canRestart = 0;
  stack_frame->presentationHint = NULL;
  stack_frame->instructionPointerReference = NULL;
  stack_frame->moduleId = NULL;
}

static void init_scope(Scope* scope) {
  scope->name = NULL;
  scope->presentationHint = NULL;
  scope->variablesReference = NAN;
  scope->namedVariables = NAN;
  scope->indexedVariables = NAN;
  scope->expensive = 0;
  scope->source = NULL;
  scope->line = NAN;
  scope->column = NAN;
  scope->endLine = NAN;
  scope->endColumn = NAN;
}

static void init_variable(Variable* variable) {
  variable->name = NULL;
  variable->value = NULL;
  variable->type = NULL;
  variable->presentationHint = NULL;
  variable->evaluateName = NULL;
  variable->variablesReference = NAN;
  variable->namedVariables = NAN;
  variable->indexedVariables = NAN;
  variable->memoryReference = NULL;
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
    message->buf = NULL;
    message->length = 0;
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

  printf("Write backend message %p \n", buffer);

  item->buf = buf;
  item->length = length;

  list_add_tail(&item->link, &info->backend_message);

  // Release the lock, so the dart isolate thread can read back-end messages.
  pthread_mutex_unlock(&info->backend_message_access);

  return 1;
}

static void js_transport_send_response(JSDebuggerInfo* info, JSContext* ctx, Response* response) {
  const char* buf = stringify_response(ctx, (Response*) response);
  write_backend_message(info, buf, strlen(buf));
}

static void js_transport_send_event(JSDebuggerInfo* info, Event* event) {
  size_t length;
  printf("ctx %p\n", info->ctx);
  const char* buf = stringify_event(info->ctx, event, &length);
  write_backend_message(info, buf, length);
}

static void js_send_stopped_event(JSDebuggerInfo* info, const char* reason) {
  JSContext* ctx = info->ctx;

  StoppedEvent* event = initialize_event(ctx, "stopped");
  event->body->reason = reason;
  event->body->threadId = (int64_t)info->ctx;
  js_transport_send_event(info, (Event*) event);
}

static void js_get_scopes(JSContext* ctx, int64_t frame, ScopesResponseBody* body) {
  // for now this is always the same.
  // global, local, closure. may change in the future. can check if closure is empty.
  Scope* scopes = js_malloc(ctx, sizeof(Scope) * 3);

  // Init scopes
  for(int i = 0; i < 3; i ++) {
    init_scope(&scopes[i]);
  }

  // Get local scope
  scopes[0].name = "Local";
  scopes[0].variablesReference = (frame << 2) + 1;
  scopes[0].expensive = 0;

  // Get closure
  scopes[1].name = "Closure";
  scopes[1].variablesReference = (frame << 2) + 2;
  scopes[1].expensive = 0;

  // Get global
  scopes[2].name = "Global";
  scopes[2].variablesReference = (frame << 2) + 0;
  scopes[2].expensive = 1;

  body->scopes = scopes;
  body->scopesLen = 3;
}

const char* js_get_object_proto_name(JSContext* ctx, JSValue value) {
  JSValue object_proto = JS_GetPrototype(ctx, value);
  JSValue constructor_func = JS_GetPropertyStr(ctx, object_proto, "constructor");
  const char* func_name = get_func_name(ctx, constructor_func);
  JS_FreeValue(ctx, object_proto);
  JS_FreeValue(ctx, constructor_func);
  return func_name;
}

static inline JS_BOOL JS_IsInteger(JSValueConst v) {
  int tag = JS_VALUE_GET_TAG(v);
  return tag == JS_TAG_INT || tag == JS_TAG_BIG_INT;
}

static void js_debugger_get_variable_type(JSContext* ctx,
                                          struct DebuggerSuspendedState* state,
                                          VariableType* variable_type,
                                          JSValue var_val,
                                          JSValue this_val,
                                          size_t depth,
                                          int8_t is_short) {
  // 0 means not expandible
  uint32_t reference = 0;
  if (JS_IsString(var_val)) {
    variable_type->type = "string";
    const char* s = value_to_string(ctx, var_val);
    char* buffer = js_malloc(ctx, sizeof(char) * (strlen(s) + 3));
    sprintf(buffer, "\"%s\"", s);
    variable_type->value = buffer;
    js_free(ctx, (void*)s);
  }
  else if (JS_IsInteger(var_val)) {
    variable_type->type = "integer";
    variable_type->value = value_to_string(ctx, var_val);
  }
  else if (JS_IsNumber(var_val) || JS_IsBigFloat(var_val)) {
    variable_type->type = "float";
    variable_type->value = value_to_string(ctx, var_val);
  }
  else if (JS_IsBool(var_val)) {
    variable_type->type = "boolean";
    variable_type->value = value_to_string(ctx, var_val);
  }
  else if (JS_IsNull(var_val)) {
    variable_type->type = "null";
    variable_type->value = "null";
  }
  else if (JS_IsUndefined(var_val)) {
    variable_type->type = "undefined";
    variable_type->value = "undefined";
  }
  else if (JS_IsObject(var_val)) {
    variable_type->type = "object";
    if (JS_IsFunction(ctx, var_val)) {
      const char* func_name = get_func_name(ctx, var_val);
      char buffer[64];
      sprintf(buffer, "ƒ %s ()", func_name);
      variable_type->value = copy_string(buffer, strlen(buffer));
      variable_type->type = "function";
      JS_FreeCString(ctx, func_name);
    } else if (JS_IsArray(ctx, var_val)) {
      variable_type->type = "array";
      char buf[12];
      int64_t length;
      js_get_length64(ctx, &length, var_val);
      sprintf(buf, "Array(%lld)", length);
      variable_type->value = copy_string(buf, strlen(buf));
    } else {
      const char* func_name = js_get_object_proto_name(ctx, var_val);

      char buffer[64];
      if (func_name != NULL) {
        sprintf(buffer, "%s", func_name);
      } else {
        buffer[0] = '\0';
      }

      if (strcmp(buffer, "Object") == 0) {
        if (is_short) {
          variable_type->value = "{..}";
        } else {
          JSPropertyEnum* property_enum;
          uint32_t property_len;
          int8_t have_ellipse = FALSE;
          if (!JS_GetOwnPropertyNames(ctx,  &property_enum, &property_len, var_val, JS_GPN_SYMBOL_MASK | JS_GPN_STRING_MASK)) {
            size_t buf_len = 256;
            char* buf = js_malloc(ctx, buf_len);
            buf[0] = '{';
            size_t index = 1;

            if (property_len > 5) {
              property_len = 5;
              have_ellipse = TRUE;
            }

            for(int i = 0; i < property_len; i ++) {
              JSValue v = JS_GetProperty(ctx, this_val, property_enum[i].atom);
              const char* key = atom_to_string(ctx, property_enum[i].atom);
              VariableType object_var_type;
              js_debugger_get_variable_type(ctx, state, &object_var_type, v, v, depth + 1, 1);
              const char* tmp = object_var_type.value;
              size_t tmp_len = strlen(tmp);
              if (index + tmp_len + strlen(key) + 8 > buf_len) {
                buf_len = (buf_len + tmp_len) * 2;
                buf = js_realloc(ctx, buf, buf_len);
              }
              strcpy(buf + index, key);
              index += strlen(key);
              strcpy(buf + index, ": ");
              index += 2;
              strcpy(buf + index, tmp);
              index += tmp_len;

              if (i + 1 < property_len) {
                strcpy(buf + index, ", ");
                index += 2;
              }
              JS_FreeValue(ctx, v);
            }

            if (have_ellipse) {
              strcpy(buf + index, "...");
              index += 3;
            }

            buf[index] = '}';
            buf[index + 1] = 0;
            variable_type->value = buf;
          }
        }
      } else {
        variable_type->value = copy_string(buffer, strlen(buffer));
      }
    }

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

static void js_free_prop_enum(JSContext* ctx, JSPropertyEnum* tab, uint32_t len) {
  uint32_t i;
  if (tab) {
    for (i = 0; i < len; i++)
      JS_FreeAtom(ctx, tab[i].atom);
    js_free(ctx, tab);
  }
}

static void process_request(JSDebuggerInfo* info, struct DebuggerSuspendedState* state, const Request* request) {
  JSContext* ctx = info->ctx;
  const char* command = request->command;

  if (strcmp(command, "evaluate") == 0) {
    EvaluateArguments* arguments = (EvaluateArguments*) request->arguments;
    int64_t frame = arguments->frameId - STACK_FRAME_INDEX_START;
    const char* expression = arguments->expression;
    JSValue result = js_debugger_evaluate(ctx, frame, state, expression);
    if (JS_IsException(result)) {
      JS_FreeValue(ctx, result);
      result = JS_GetException(ctx);
    }

    EvaluateResponse* response = (EvaluateResponse*) initialize_response(ctx, request, "evaluate");
    VariableType result_variable_type;
    js_debugger_get_variable_type(ctx, state, &result_variable_type, result, result, 0, 0);
    response->body->result = result_variable_type.value;
    response->body->type = result_variable_type.type;
    response->body->variablesReference = result_variable_type.variablesReference;

    js_transport_send_response(info, ctx, (Response*) response);
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
    ScopesResponse* response = initialize_response(ctx, request, "scopes");
    js_get_scopes(ctx, frame, response->body);
    js_transport_send_response(info, ctx, (Response*)response);
  } else if (strcmp(command, "setBreakpoints") == 0) {
    SetBreakpointsArguments* arguments = (SetBreakpointsArguments*)request->arguments;
    js_debugger_set_breakpoints(info, arguments->source, arguments->breakpoints, arguments->breakpointsLen);
    SetBreakpointsResponse* response = initialize_response(ctx, request, "setBreakpoints");
    js_transport_send_response(info, ctx, (Response*) response);
  } else if (strcmp(command, "setExceptionBreakpoints") == 0) {
    SetExceptionBreakpointsArguments* arguments = (SetExceptionBreakpointsArguments*) request->arguments;
    info->exception_breakpoint = arguments->filtersLen > 0;
    SetExceptionBreakpointsResponse* response = initialize_response(ctx, request, "setExceptionBreakpoints");
    js_transport_send_response(info, ctx, (Response*) response);
  } else if (strcmp(command, "threads") == 0) {
    ThreadsResponse* response = initialize_response(ctx, request, "threads");
    response->body->threads = js_malloc(ctx, sizeof(Thread));
    response->body->threads->name = "main";
    response->body->threads->id = (int64_t)ctx;
    response->body->threadsLen = 1;
    js_transport_send_response(info, ctx, (Response*) response);
  } else if (strcmp(command, "configurationDone") == 0) {
    info->is_paused = 0;
    ConfigurationDoneResponse* response = initialize_response(ctx, request, "threads");
    js_transport_send_response(info, ctx, (Response*) response);
  } else if (strcmp(command, "variables") == 0) {
    VariablesArguments* arguments = (VariablesArguments*)request->arguments;
    int64_t reference = arguments->variablesReference;
    int8_t skip_proto;
    JSValue variable = JS_GetPropertyUint32(ctx, state->variable_references, reference);
    int64_t variable_len = 0;
    Variable* variables = NULL;
    if (JS_IsUndefined(variable) && reference < LOGGING_VAR_REFERENCE_MAX) {
      JSValue reference_value = js_debugger_get_scope_variable(ctx, reference, &info->logging_state, &skip_proto);
      variables = js_malloc(ctx, sizeof(Variable));
      init_variable(&variables[0]);
      variable_len = 1;

      VariableType variable_type;
      js_debugger_get_variable_type(ctx, state, &variable_type, reference_value, reference_value,  0, 0);

      variables[0].name = "";
      variables[0].value = variable_type.value;
      variables[0].variablesReference = variable_type.variablesReference;
      variables[0].type = variable_type.type;
    } else {
      JSValue reference_value = js_debugger_get_scope_variable(ctx, reference, state, &skip_proto);
      variables = js_debugger_get_variables(ctx, reference_value, state, &variable_len, skip_proto,
                                                      arguments->filter, arguments->start, arguments->count);
    }

    VariablesResponse* response = initialize_response(ctx, request, "variables");
    response->body->variables = variables;
    response->body->variablesLen = variable_len;
    js_transport_send_response(info, ctx, (Response*)response);
  } else if (strcmp(command, "completions") == 0) {
    CompletionsArguments* arguments = (CompletionsArguments*)request->arguments;
    int64_t frame = arguments->frameId - STACK_FRAME_INDEX_START;
    int64_t target_item_len = 0;
    CompletionItem* target_items = js_debugger_get_completions(ctx, state, &target_item_len, frame, arguments->text,
                                                               arguments->column, arguments->line);
    CompletionsResponse* response = initialize_response(ctx, request, "completions");
    response->body->targets = target_items;
    response->body->targetsLen = target_item_len;
    js_transport_send_response(info, ctx, (Response*)response);
  }
}

static JSValue js_debugger_get_scope_variable(JSContext* ctx,
                                              int64_t reference,
                                              struct DebuggerSuspendedState* state,
                                              int8_t* skip_proto) {
  JSValue variable = JS_GetPropertyUint32(ctx, state->variable_references, reference);
  // if the variable reference was not found,
  // then it must be a frame locals, frame closures, or the global
  if (JS_IsUndefined(variable)) {
    *skip_proto = 1;
    int64_t frame = (reference >> 2) - STACK_FRAME_INDEX_START;
    int64_t scope = reference % 4;

    assert(frame < js_debugger_stack_depth(ctx));

    if (scope == 0)
      variable = JS_GetGlobalObject(ctx);
    else if (scope == 1)
      variable = js_debugger_local_variables(ctx, frame, state);
    else if (scope == 2)
      variable = js_debugger_closure_variables(ctx, frame);
    else
      assert(0);

    // need to dupe the variable, as it's used below as well.
    JS_SetPropertyUint32(ctx, state->variable_references, reference, JS_DupValue(ctx, variable));
  }

  return variable;
}

static Variable* js_debugger_get_variables(JSContext* ctx,
                                           JSValue reference_value,
                                           struct DebuggerSuspendedState* state,
                                           int64_t* variable_len,
                                           int8_t skip_proto,
                                           const char* filter,
                                           int64_t filter_start,
                                           int64_t filter_count) {
  Variable* variables = NULL;

  JSPropertyEnum* tab_atom;
  uint32_t tab_atom_count;

  if (filter != NULL) {
    // only index filtering is supported by this server.
    // name filtering exists in VS Code, but is not implemented here.
    int indexed = strcmp(filter, "indexed") == 0;
    if (!indexed)
      goto unfiltered;

    int64_t start = filter_start;
    int64_t count = filter_count;

    variables = js_malloc(ctx, sizeof(Variable) * count);
    *variable_len = count;

    char name_buf[64];
    for (uint32_t i = 0; i < count; i++) {
      JSValue value = JS_GetPropertyUint32(ctx, reference_value, start + i);
      VariableType variable_type;
      js_debugger_get_variable_type(ctx, state, &variable_type, value, value, 0, 0);

      sprintf(name_buf, "%d", i);
      init_variable(&variables[i]);
      variables[i].name = copy_string(name_buf, strlen(name_buf));
      variables[i].type = variable_type.type;
      variables[i].variablesReference = variable_type.variablesReference;
      variables[i].value = variable_type.value;

      assert(variables[i].name != NULL);
      assert(variables[i].value != NULL);
      JS_FreeValue(ctx, value);
    }
    goto done;
  }

unfiltered:
  if (!JS_GetOwnPropertyNames(ctx, &tab_atom, &tab_atom_count, reference_value,
                              JS_GPN_STRING_MASK | JS_GPN_SYMBOL_MASK)) {
    if (tab_atom_count == 0) {
      variables = NULL;
      *variable_len = 0;
      goto done;
    }

    variables = js_malloc(ctx, sizeof(Variable) * (tab_atom_count + (skip_proto ? 0 : 1)));

    for (int i = 0; i < tab_atom_count; i++) {
      JSValue value = JS_GetProperty(ctx, reference_value, tab_atom[i].atom);
      VariableType variable_type;
      js_debugger_get_variable_type(ctx, state, &variable_type, value, value, 0, 0);
      init_variable(&variables[i]);
      variables[i].name = atom_to_string(ctx, tab_atom[i].atom);
      variables[i].type = variable_type.type;
      variables[i].variablesReference = variable_type.variablesReference;
      variables[i].value = variable_type.value;
      assert(variables[i].name != NULL);
      assert(variables[i].value != NULL);
      JS_FreeValue(ctx, value);
    }

    if (!skip_proto) {
      const JSValue proto = JS_GetPrototype(ctx, reference_value);
      if (!JS_IsException(proto)) {
        VariableType variable_type;
        js_debugger_get_variable_type(ctx, state, &variable_type, proto, reference_value, 0, 0);
        init_variable(&variables[tab_atom_count]);
        variables[tab_atom_count].name = "[[Prototype]]";
        variables[tab_atom_count].value = variable_type.type;
        variables[tab_atom_count].type = variable_type.value;
        variables[tab_atom_count].variablesReference = variable_type.variablesReference;
        VariablePresentationHint* presentation_hint = js_malloc(ctx, sizeof(VariablePresentationHint));
        presentation_hint->visibility = "internal";
        presentation_hint->attributes = NULL;
        presentation_hint->attributesLen = 0;
        presentation_hint->lazy = 0;
        presentation_hint->kind = NULL;
        variables[tab_atom_count].presentationHint = presentation_hint;
        assert(variables[tab_atom_count].name != NULL);
        assert(variables[tab_atom_count].value != NULL);
      }
      JS_FreeValue(ctx, proto);
    }

    *variable_len = tab_atom_count + (skip_proto ? 0 : 1);
    js_free_prop_enum(ctx, tab_atom, tab_atom_count);
  }

done:
  return variables;
}

static CompletionItem* js_debugger_get_completions(JSContext* ctx,
                                                   struct DebuggerSuspendedState* state,
                                                   int64_t* completions_len,
                                                   int64_t frame,
                                                   const char* text,
                                                   int64_t completions_column,
                                                   int64_t completion_line) {
  size_t text_len = strlen(text);
  if (text == NULL || text_len == 0) {
    *completions_len = 0;
    return NULL;
  };

  char try_script[text_len];
  memcpy(try_script, text, strlen(text) - 1);
  try_script[text_len - 1] = 0x00;

  JSValue evaluate_result = js_debugger_evaluate(ctx, frame, state, try_script);

  CompletionItem* completion_items = NULL;
  int64_t completions_index = 0;
  if (JS_IsObject(evaluate_result)) {
    int64_t object_property_variables_len;
    Variable* object_property_variables =
        js_debugger_get_variables(ctx, evaluate_result, state, &object_property_variables_len, 1, NULL, 0, 0);

    completion_items = js_malloc(ctx, sizeof(CompletionItem) * object_property_variables_len);
    for (int i = 0; i < object_property_variables_len; i++) {
      CompletionItem* item = &completion_items[completions_index++];
      item->label = (object_property_variables)[i].name;
      if (strcmp(object_property_variables[i].type, "function") == 0) {
        item->type = "method";
      } else {
        item->type = "variable";
      }
    }

    int64_t object_proto_property_variables_len = 0;
    JSValue proto = JS_GetPrototype(ctx, evaluate_result);
    while(!JS_IsNull(proto)) {
      int64_t proto_vars_len;
      Variable* proto_property_variables =
          js_debugger_get_variables(ctx, proto, state, &proto_vars_len, 1, NULL, 0, 0);

      object_property_variables_len += proto_vars_len;
      completion_items = js_realloc(ctx, completion_items, sizeof(CompletionItem) * (object_property_variables_len + object_proto_property_variables_len));

      for (int i = 0; i < proto_vars_len; i++) {
        CompletionItem* item = &completion_items[completions_index++];
        item->label = (proto_property_variables)[i].name;
        if (strcmp(proto_property_variables[i].type, "function") == 0) {
          item->type = "method";
        } else {
          item->type = "variable";
        }
      }

      JS_FreeValue(ctx, proto);
      proto = JS_GetPrototype(ctx, proto);
    }
  } else {
    JSValue global_reference_value = JS_GetGlobalObject(ctx);
    JSValue local_reference_value = js_debugger_local_variables(ctx, frame, state);
    JSValue closure_reference_value = js_debugger_closure_variables(ctx, frame);

    // Collect all variables
    int64_t global_vars_len;
    Variable* global_vars =
        js_debugger_get_variables(ctx, global_reference_value, state, &global_vars_len, 1, NULL, 0, 0);
    int64_t local_vars_len;
    Variable* local_vars = js_debugger_get_variables(ctx, local_reference_value, state, &local_vars_len, 1, NULL, 0, 0);
    int64_t closure_vars_len;
    Variable* closure_vars = js_debugger_get_variables(ctx, closure_reference_value, state, &closure_vars_len, 1, NULL, 0, 0);

    // Concat all variables into a array.
    size_t total_var_len = global_vars_len + local_vars_len + closure_vars_len;
    completion_items = js_malloc(ctx, sizeof(CompletionItem) * total_var_len);

#define CHECK_COMPLETIONS(LIST) \
  for(int i = 0; i < LIST##_len; i ++) { \
    if (strlen((LIST)[i].name) > 0 && strstr((LIST)[i].name, text)) { \
     CompletionItem* item = &completion_items[completions_index++]; \
     item->label = (LIST)[i].name; \
     item->type = "variable"; \
    } \
  }

    CHECK_COMPLETIONS(global_vars);
    CHECK_COMPLETIONS(local_vars);
    CHECK_COMPLETIONS(closure_vars);
  }

  *completions_len = completions_index;
  return completion_items;
}

void js_debugger_set_breakpoints(JSDebuggerInfo* info,
                                   Source* source,
                                   SourceBreakpoint* breakpoints,
                                   size_t breakpointsLen) {
  JSContext* ctx = info->ctx;

  // force all functions to reprocess their breakpoints.
  info->breakpoints_dirty_counter++;

  const char* path = source->path;
  if (JS_HasPropertyStr(ctx, info->breakpoints, path)) {
    JSAtom k = JS_NewAtom(ctx, path);
    JS_DeleteProperty(ctx, info->breakpoints, k, 0);
    JS_FreeAtom(ctx, k);
  }

  JSValue object = JS_NewObject(ctx);
  BreakPointMapItem* item = js_malloc(ctx, sizeof(BreakPointMapItem));
  item->breakpoints = breakpoints;
  item->breakpointLen = breakpointsLen;
  item->dirty = info->breakpoints_dirty_counter;
  JS_SetOpaque(object, item);

  JS_SetPropertyStr(ctx, info->breakpoints, path, object);
}

BreakPointMapItem* js_debugger_file_breakpoints(JSContext* ctx, const char* path) {
  JSDebuggerInfo* info = js_debugger_info(JS_GetRuntime(ctx));
  JSValue object = JS_GetPropertyStr(ctx, info->breakpoints, path);
  BreakPointMapItem* item = JS_GetOpaque(object, JS_CLASS_OBJECT);
  JS_FreeValue(ctx, object);
  return item;
}

static void js_process_debugger_messages(JSDebuggerInfo* info, const uint8_t* cur_pc, JSValue this_object) {
  // continue processing messages until the continue message is received.
  JSContext* ctx = info->ctx;
  struct DebuggerSuspendedState state;
  state.variable_reference_count = LOGGING_VAR_REFERENCE_MAX + 1;
  state.variable_pointers = JS_NewObject(ctx);
  state.variable_references = JS_NewObject(ctx);
  state.cur_pc = cur_pc;
  state.this_object = this_object;

  do {
    MessageItem item;
    if (!read_frontend_messages(info, &item)) {
      continue;
    }
    Request* request = js_malloc(ctx, sizeof(Request));
    parse_request(ctx, request, item.buf, item.length);
    process_request(info, &state, request);
//    free_request(ctx, request);

    js_free(ctx, item.buf);
  } while (info->is_paused);

done:
  JS_FreeValue(ctx, state.variable_references);
  JS_FreeValue(ctx, state.variable_pointers);
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
  js_process_debugger_messages(info, NULL, JS_NULL);
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
void js_debugger_check(JSContext* ctx, const uint8_t* cur_pc, JSValue this_object) {
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
        location.line == info->step_over.line)
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
      if ((current_location.filename == info->step_over.filename && current_location.line == info->step_over.line) ||
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

  js_process_debugger_messages(info, cur_pc, this_object);

done:
  info->is_debugging = 0;
  info->ctx = NULL;
}

void js_debugger_free(JSRuntime* rt, JSDebuggerInfo* info) {
  if (!info->is_connected)
    return;

  // don't use the JSContext because it might be in a funky state during teardown.
  TerminatedEvent* event = initialize_event(info->ctx, "terminated");
  js_transport_send_event(info, (Event*) event);

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

  info->breakpoints = JS_NewObject(ctx);

  // Attach native methods and export to Dart.
  methods->write_frontend_commands = handle_client_write;
  methods->read_backend_commands = handle_client_read;

  info->debugging_ctx = JS_NewContext(rt);
  info->is_connected = TRUE;

  rt->debugger_info.logging_state.variable_reference_count = 1;
  rt->debugger_info.logging_state.variable_pointers = JS_NewObject(ctx);
  rt->debugger_info.logging_state.variable_references = JS_NewObject(ctx);

  JSContext* original_ctx = info->ctx;
  info->ctx = ctx;

  js_send_stopped_event(info, "entry");

  info->is_paused = 1;

  info->ctx = original_ctx;

  return info;
}

void JS_DebuggerInspectValue(JSContext* ctx, JSValue value, const char* filepath, const char* filename, int64_t lineno, int64_t column) {
  if (!js_debugger_is_transport_connected(ctx->rt)) {
    return;
  }

  JSDebuggerInfo* info = js_debugger_info(ctx->rt);

  VariableType value_type;
  js_debugger_get_variable_type(ctx, &info->logging_state, &value_type, value, value, 0, 1);
info->ctx = ctx;
  assert(info->ctx != NULL);
  OutputEvent* event = initialize_event(ctx, "output");
  event->body->category = "stdout";

  uint32_t buf_len;
  char* buf = js_malloc(ctx, buf_len = (strlen(value_type.value) + 2));
  sprintf(buf, "%s\n", value_type.value);
  buf[buf_len - 1] = 0x00;
  event->body->output = buf;
  event->body->variablesReference = value_type.variablesReference;

  event->body->line = lineno;
  event->body->column = column;
  Source* source = js_malloc(ctx, sizeof(Source));
  init_source(source);
  source->name = filename;
  source->path = filepath;
  event->body->source = source;

  js_transport_send_event(info, (Event*)event);
  info->ctx = NULL;
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

    init_stackframe(&stack_frames[id]);

    stack_frames[id].id = id + STACK_FRAME_INDEX_START;
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
        column_num1 = find_column_num(ctx, b, pc - b->byte_code_buf - 1) + 1;
        if (line_num1 != -1) {
          stack_frames[id].line = line_num1;
        }
        if (column_num1 != -1) {
          stack_frames[id].column = column_num1;
        }

        stack_frames[id].source = js_malloc(ctx, sizeof(Source));
        init_source(stack_frames[id].source);
        stack_frames[id].source->path = atom_to_string(ctx, b->debug.filename);
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

JSValue js_debugger_local_variables(JSContext* ctx, int64_t stack_index, struct DebuggerSuspendedState* state) {
  JSValue ret = JS_NewObject(ctx);

  // put exceptions on the top stack frame
  if (stack_index == 0 && !JS_IsNull(ctx->rt->current_exception) && !JS_IsUndefined(ctx->rt->current_exception))
    JS_SetPropertyStr(ctx, ret, "<exception>", JS_DupValue(ctx, ctx->rt->current_exception));

  JSStackFrame* sf;
  int cur_index = 0;

  for (sf = ctx->rt->current_stack_frame; sf != NULL; sf = sf->prev_frame) {
    JSObject* f = JS_VALUE_GET_OBJ(sf->cur_func);
    if (f && js_class_has_bytecode(f->class_id)) {
      // only provide a this if it is not the global object.
      if (stack_index == 0 && JS_VALUE_GET_OBJ(state->this_object) != JS_VALUE_GET_OBJ(ctx->global_obj) && !JS_IsUndefined(state->this_object))
        JS_SetPropertyStr(ctx, ret, "this", JS_DupValue(ctx, state->this_object));
    }

    if (cur_index < stack_index) {
      cur_index++;
      continue;
    }

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
  fd->has_this_binding = 1;
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

JSValue js_debugger_evaluate(JSContext* ctx, int64_t stack_index, DebuggerSuspendedState* state, const char* expression) {
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
    JSValue this_object = stack_index == 0 ? state->this_object : sf->var_buf[b->var_count];
    JSValue ret =
        js_debugger_eval(ctx, this_object, sf, expression, strlen(expression), "<debugger>", JS_EVAL_TYPE_DIRECT, scope_idx);
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