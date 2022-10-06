/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_MODULE_LISTENER_CONTAINER_H
#define BRIDGE_MODULE_LISTENER_CONTAINER_H

#include <unordered_map>
#include "module_listener.h"

namespace webf {

class ModuleListenerContainer final {
 public:
  void AddModuleListener(const AtomicString& name, const std::shared_ptr<ModuleListener>& listener);
  void RemoveModuleListener(const AtomicString& name);
  std::shared_ptr<ModuleListener> listener(const AtomicString& name);
  void Clear();

 private:
  std::unordered_map<AtomicString, std::shared_ptr<ModuleListener>, AtomicString::KeyHasher> listeners_;
  friend ModuleListener;
};

}  // namespace webf

#endif  // BRIDGE_MODULE_LISTENER_CONTAINER_H
