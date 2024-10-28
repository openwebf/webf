// Generated by WebF TSDL, don't edit this file directly.
// Generate command: node scripts/generate_binding_code.js
// clang-format off
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef WEBF_CORE_WEBF_API_PLUGIN_API_KEYBOARD_EVENT_INIT_H_
#define WEBF_CORE_WEBF_API_PLUGIN_API_KEYBOARD_EVENT_INIT_H_
#include <stdint.h>
#include "webf_value.h"
namespace webf {
typedef struct Window Window;
typedef struct WindowPublicMethods WindowPublicMethods;
struct WebFKeyboardEventInit {
  double detail;
  WebFValue<Window, WindowPublicMethods> view;
  double which;
  int32_t alt_key;
  double char_code;
  const char* code;
  int32_t ctrl_key;
  int32_t is_composing;
  const char* key;
  double key_code;
  double location;
  int32_t meta_key;
  int32_t repeat;
  int32_t shift_key;
};
}  // namespace webf
#endif  // WEBF_CORE_WEBF_API_PLUGIN_API_KEYBOARD_EVENT_INIT_H_