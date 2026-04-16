/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "js_profiler_hooks.h"
#include <stddef.h>

/* Global function pointers — NULL means profiling is disabled. */
webf_profiler_enabled_fn  webf_js_profiler_enabled_hook  = NULL;
webf_profiler_on_entry_fn webf_js_profiler_on_entry_hook = NULL;
webf_profiler_on_exit_fn  webf_js_profiler_on_exit_hook  = NULL;
webf_profiler_register_atom_name_fn webf_js_profiler_register_atom_name_hook = NULL;
webf_profiler_is_atom_known_fn webf_js_profiler_is_atom_known_hook = NULL;

int webf_js_profiler_enabled(void) {
  webf_profiler_enabled_fn fn = webf_js_profiler_enabled_hook;
  return fn ? fn() : 0;
}

int32_t webf_js_profiler_on_function_entry(uint8_t category, uint32_t func_name_atom) {
  webf_profiler_on_entry_fn fn = webf_js_profiler_on_entry_hook;
  return fn ? fn(category, func_name_atom) : -1;
}

void webf_js_profiler_on_function_exit(int32_t entry_idx) {
  webf_profiler_on_exit_fn fn = webf_js_profiler_on_exit_hook;
  if (fn) fn(entry_idx);
}

void webf_js_profiler_register_atom_name(uint32_t atom, const char* name) {
  webf_profiler_register_atom_name_fn fn = webf_js_profiler_register_atom_name_hook;
  if (fn) fn(atom, name);
}

int webf_js_profiler_is_atom_known(uint32_t atom) {
  webf_profiler_is_atom_known_fn fn = webf_js_profiler_is_atom_known_hook;
  return fn ? fn(atom) : 1;
}
