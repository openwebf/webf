/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_CHARACTER_DATA_H_
#define WEBF_CORE_RUST_API_CHARACTER_DATA_H_

#include "node.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct CharacterDataWebFMethods : WebFPublicMethods {
  CharacterDataWebFMethods(NodeWebFMethods* super_method);

  double version{1.0};
  NodeWebFMethods* node;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_CHARACTER_DATA_H_
