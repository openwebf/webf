/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#include "gc_visitor.h"
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

void GCVisitor::Trace(JSValue value) {
  JS_MarkValue(runtime_, value, markFunc_);
}

}  // namespace kraken
