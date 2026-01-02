/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-2024 The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_QJS_DART_BINDING_OBJECT_H
#define BRIDGE_QJS_DART_BINDING_OBJECT_H

namespace webf {

class ExecutingContext;

class QJSDartBindingObject final {
 public:
  static void Install(ExecutingContext* context);

 private:
  static void InstallGlobalFunctions(ExecutingContext* context);
};

}  // namespace webf

#endif  // BRIDGE_QJS_DART_BINDING_OBJECT_H

