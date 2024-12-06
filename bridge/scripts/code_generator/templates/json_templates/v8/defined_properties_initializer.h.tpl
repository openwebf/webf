/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_DEFINED_PROPERTIES_INTIALIZER_H_
#define BRIDGE_DEFINED_PROPERTIES_INTIALIZER_H_

#include "bindings/v8/atomic_string.h"

namespace webf {

class DefinedPropertiesInitializer {
 public:
  static void Init();
  static void Dispose();
};


}  // namespace webf

#endif  // BRIDGE_DEFINED_PROPERTIES_INTIALIZER_H_
