/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef EXCEPTION_STATE_H
#define EXCEPTION_STATE_H

#include "bindings/qjs/exception_state.h"
#include "plugin_api/rust_readable.h"

namespace webf {

class SharedExceptionState : public RustReadable {
 public:
  SharedExceptionState();

  ExceptionState exception_state;
};

}  // namespace webf

#endif  // EXCEPTION_STATE_H
