/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_COMMENT_H_
#define WEBF_CORE_RUST_API_COMMENT_H_

#include "character_data.h"

namespace webf {

typedef struct EventTarget EventTarget;
typedef struct SharedExceptionState SharedExceptionState;
typedef struct ExecutingContext ExecutingContext;
typedef struct Event Event;

struct CommentWebFMethods : WebFPublicMethods {
  CommentWebFMethods(CharacterDataWebFMethods* super_rust_method);

  double version{1.0};
  CharacterDataWebFMethods* character_data;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_COMMENT_H_
