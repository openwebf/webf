/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDING_INITIALIZER_H
#define KRAKENBRIDGE_BINDING_INITIALIZER_H

#include <quickjs/quickjs.h>

namespace webf {

class ExecutingContext;

void InstallBindings(ExecutingContext* context);

}  // namespace webf

#endif  // KRAKENBRIDGE_BINDING_INITIALIZER_H
