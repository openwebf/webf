/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "module_listener.h"

#include <utility>

namespace webf {

std::shared_ptr<ModuleListener> ModuleListener::Create(const std::shared_ptr<QJSFunction>& function) {
  return std::make_shared<ModuleListener>(function);
}

ModuleListener::ModuleListener(std::shared_ptr<QJSFunction> function) : function_(std::move(function)) {}

const std::shared_ptr<QJSFunction>& ModuleListener::value() {
  return function_;
}

}  // namespace webf
