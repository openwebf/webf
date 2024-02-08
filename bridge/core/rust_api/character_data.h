/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_CHARACTER_DATA_H_
#define WEBF_CORE_RUST_API_CHARACTER_DATA_H_

#include "core/rust_api/node.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct CharacterDataRustMethods : RustMethods {
  CharacterDataRustMethods(NodeRustMethods* super_rust_method);

  double version{1.0};
  NodeRustMethods* node;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_CHARACTER_DATA_H_
