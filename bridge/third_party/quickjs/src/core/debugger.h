/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/


#ifndef QUICKJS_DEBUGGER_H
#define QUICKJS_DEBUGGER_H

#include <quickjs/quickjs.h>
#include <quickjs/list.h>
#include "base.h"
#include "dap_protocol.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct DebuggerSuspendedState {
  uint32_t variable_reference_count;
  JSValue variable_references;
  JSValue variable_pointers;
  JSValue this_object;
  const uint8_t* cur_pc;
} DebuggerSuspendedState;

typedef struct JSDebuggerFunctionInfo {
  // same length as byte_code_buf.
  uint8_t* breakpoints;
  uint32_t dirty;
  int last_line_num;
} JSDebuggerFunctionInfo;

typedef struct JSDebuggerLocation {
  JSAtom filename;
  int line;
  int column;
} JSDebuggerLocation;

#define JS_DEBUGGER_STEP 1
#define JS_DEBUGGER_STEP_IN 2
#define JS_DEBUGGER_STEP_OUT 3
#define JS_DEBUGGER_STEP_CONTINUE 4

typedef struct MessageItem {
  char* buf;
  uint32_t length;
  struct list_head link;
} MessageItem;

typedef struct BreakPointMapItem {
  SourceBreakpoint* breakpoints;
  size_t breakpointLen;
  size_t dirty;
} BreakPointMapItem;

typedef struct JSDebuggerInfo {
  // JSContext that is used to for the JSON transport and debugger state.
  JSContext* ctx;
  JSRuntime* runtime;
  JSContext* debugging_ctx;

  int is_debugging;
  int is_paused;
  int is_connected;

  // Message cache and shared between JS main thread and dart isolate thread.
  struct list_head frontend_messages;
  struct list_head backend_message;

  // Locks when dart isolate thread write new commands to debugger info, the JS main thread should wait for the writing operation complete.
  pthread_mutex_t frontend_message_access;
  // Locks when dart JS main thread write new commands to the client. The dart isolate thread should wait for the writing operation complete.
  pthread_mutex_t backend_message_access;

  JSValue breakpoints;
  int exception_breakpoint;
  uint32_t breakpoints_dirty_counter;
  int stepping;
  JSDebuggerLocation step_over;
  uint32_t step_depth;
} JSDebuggerInfo;

void js_debugger_new_context(JSContext* ctx);
void js_debugger_free_context(JSContext* ctx);
void js_debugger_check(JSContext* ctx, const uint8_t* pc, JSValue this_object);
void js_debugger_exception(JSContext* ctx);
void js_debugger_free(JSRuntime* rt, JSDebuggerInfo* info);
int js_debugger_is_transport_connected(JSRuntime* rt);

BreakPointMapItem* js_debugger_file_breakpoints(JSContext* ctx, const char* path);

// begin internal api functions
// these functions all require access to quickjs internal structures.

JSDebuggerInfo* js_debugger_info(JSRuntime* rt);

// this may be able to be done with an Error backtrace,
// but would be clunky and require stack string parsing.
uint32_t js_debugger_stack_depth(JSContext* ctx);
void js_debugger_build_backtrace(JSContext* ctx, const uint8_t* cur_pc, StackTraceResponseBody* body);
JSDebuggerLocation js_debugger_current_location(JSContext* ctx, const uint8_t* cur_pc);

// checks to see if a breakpoint exists on the current pc.
// calls back into js_debugger_file_breakpoints.
int js_debugger_check_breakpoint(JSContext* ctx, uint32_t current_dirty, const uint8_t* cur_pc);

JSValue js_debugger_local_variables(JSContext* ctx, int64_t stack_index, DebuggerSuspendedState* state);
JSValue js_debugger_closure_variables(JSContext* ctx, int64_t stack_index);

// evaluates an expression at any stack frame. JS_Evaluate* only evaluates at the top frame.
JSValue js_debugger_evaluate(JSContext* ctx, int64_t stack_index, const char* expression);

#ifdef __cplusplus
}
#endif

#endif