/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_RUST_API_COMMENT_H_
#define WEBF_CORE_RUST_API_COMMENT_H_

#include "character_data.h"

namespace webf {

class EventTarget;
class SharedExceptionState;
class ExecutingContext;
class Event;

struct CommentPublicMethods : WebFPublicMethods {
  double version{1.0};
  CharacterDataPublicMethods character_data;
};

}  // namespace webf

#endif  // WEBF_CORE_RUST_API_COMMENT_H_
