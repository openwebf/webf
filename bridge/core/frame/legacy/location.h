/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#ifndef KRAKENBRIDGE_LOCATION_H
#define KRAKENBRIDGE_LOCATION_H

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_wrappable.h"

namespace kraken {

class Location {
 public:
  static void __kraken_location_reload__(ExecutingContext* context, ExceptionState& exception_state);
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_LOCATION_H
