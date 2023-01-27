/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef KRAKE_CONSOLE_H
#define KRAKE_CONSOLE_H

#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/script_value.h"
#include "core/executing_context.h"

namespace webf {

class Console final {
 public:
  static void __webf_print__(ExecutingContext* context,
                             const AtomicString& log,
                             const AtomicString& level,
                             ExceptionState& exception);
  static void __webf_print__(ExecutingContext* context, const AtomicString& log, ExceptionState& exception_state);

  static void __webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          ExceptionState& exception_state);
  static void __webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& file_path,
                                          ExceptionState& exception_state);
  static void __webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& file_path,
                                          const AtomicString& filename,
                                          ExceptionState& exception_state);
  static void __webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& file_path,
                                          const AtomicString& filename,
                                          int64_t lineno,
                                          ExceptionState& exception_state);
  static void __webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& file_path,
                                          const AtomicString& filename,
                                          int64_t lineno,
                                          int64_t column,
                                          ExceptionState& exception_state);
};

}  // namespace webf

#endif  // KRAKE_CONSOLE_H
