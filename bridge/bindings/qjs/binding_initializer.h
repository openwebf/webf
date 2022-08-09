/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDING_INITIALIZER_H
#define BRIDGE_BINDING_INITIALIZER_H

#include <quickjs/quickjs.h>

namespace webf {

class ExecutingContext;

void InstallBindings(ExecutingContext* context);

}  // namespace webf

#endif  // BRIDGE_BINDING_INITIALIZER_H
