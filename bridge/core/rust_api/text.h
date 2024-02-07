/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_TEXT_H_
#define WEBF_CORE_RUST_API_TEXT_H_

#include "core/rust_api/character_data.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct TextNodeRustMethods : RustMethods {
  TextNodeRustMethods(CharacterDataRustMethods* super_rust_method);

  double version{1.0};
  CharacterDataRustMethods* character_data;
};

}

#endif  // WEBF_CORE_RUST_API_TEXT_H_
