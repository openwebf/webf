/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_LOCATION_H
#define BRIDGE_LOCATION_H

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_wrappable.h"

namespace webf {

class Location {
 public:
  static void __webf_location_reload__(ExecutingContext* context, ExceptionState& exception_state);
};

}  // namespace webf

#endif  // BRIDGE_LOCATION_H
