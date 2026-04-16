/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_PROFILING_JS_PROFILER_HOOKS_H_
#define WEBF_CORE_PROFILING_JS_PROFILER_HOOKS_H_

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/*
 * Function-pointer hooks for JS thread profiling.
 *
 * quickjs.dylib calls these thin wrappers. By default the pointers are NULL
 * (profiling disabled). webf.dylib sets them to point at the real
 * JSThreadProfiler methods so that both libraries share the same instance.
 */

typedef int (*webf_profiler_enabled_fn)(void);
typedef int32_t (*webf_profiler_on_entry_fn)(uint8_t category, uint32_t func_name_atom);
typedef void (*webf_profiler_on_exit_fn)(int32_t entry_idx);
typedef void (*webf_profiler_register_atom_name_fn)(uint32_t atom, const char* name);
typedef int (*webf_profiler_is_atom_known_fn)(uint32_t atom);

extern webf_profiler_enabled_fn  webf_js_profiler_enabled_hook;
extern webf_profiler_on_entry_fn webf_js_profiler_on_entry_hook;
extern webf_profiler_on_exit_fn  webf_js_profiler_on_exit_hook;
extern webf_profiler_register_atom_name_fn webf_js_profiler_register_atom_name_hook;
extern webf_profiler_is_atom_known_fn webf_js_profiler_is_atom_known_hook;

/* Thin wrappers called from quickjs.c — check hook != NULL before calling */
int webf_js_profiler_enabled(void);
int32_t webf_js_profiler_on_function_entry(uint8_t category, uint32_t func_name_atom);
void webf_js_profiler_on_function_exit(int32_t entry_idx);
void webf_js_profiler_register_atom_name(uint32_t atom, const char* name);
int webf_js_profiler_is_atom_known(uint32_t atom);

#ifdef __cplusplus
}
#endif

#endif  /* WEBF_CORE_PROFILING_JS_PROFILER_HOOKS_H_ */
