/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "module_listener_container.h"
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

void ModuleListenerContainer::AddModuleListener(const AtomicString& name,
                                                const std::shared_ptr<ModuleListener>& listener) {
  listeners_[name] = listener;
}

void ModuleListenerContainer::RemoveModuleListener(const AtomicString& name) {
  listeners_.erase(name);
}

std::shared_ptr<ModuleListener> ModuleListenerContainer::listener(const AtomicString& name) {
  if (listeners_.count(name) == 0)
    return nullptr;
  return listeners_[name];
}

void ModuleListenerContainer::Clear() {
  listeners_.clear();
}

}  // namespace webf
