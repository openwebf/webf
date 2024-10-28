/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef EXCEPTION_STATE_H
#define EXCEPTION_STATE_H

#include "bindings/qjs/exception_state.h"
#include "foundation/rust_readable.h"

namespace webf {

class SharedExceptionState : public RustReadable {
 public:
  SharedExceptionState();

  ExceptionState exception_state;
};

}  // namespace webf

#endif  // EXCEPTION_STATE_H
