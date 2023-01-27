/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "console.h"
#include <quickjs/quickjs.h>
#include <sstream>
#include "built_in_string.h"
#include "foundation/logging.h"

namespace webf {

void Console::__webf_print__(ExecutingContext* context,
                             const AtomicString& log,
                             const AtomicString& level,
                             ExceptionState& exception) {
  std::stringstream stream;
  std::string buffer = log.ToStdString(context->ctx());
  stream << buffer;
  printLog(context, stream, level != built_in_string::kempty_string ? level.ToStdString(context->ctx()) : "info",
           nullptr);
}

void Console::__webf_print__(ExecutingContext* context, const AtomicString& log, ExceptionState& exception_state) {
  std::stringstream stream;
  std::string buffer = log.ToStdString(context->ctx());
  stream << buffer;
  printLog(context, stream, "info", nullptr);
}

void Console::__webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          ExceptionState& exception_state) {
  __webf_debug_inspect_vars__(context, value, built_in_string::kempty_string, built_in_string::kempty_string, 0, 0, exception_state);
}
void Console::__webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& filepath,
                                          ExceptionState& exception_state) {
  __webf_debug_inspect_vars__(context, value, filepath, built_in_string::kempty_string, 0, 0, exception_state);
}
void Console::__webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& filepath,
                                          const AtomicString& file_name,
                                          ExceptionState& exception_state) {
  __webf_debug_inspect_vars__(context, value, filepath, file_name, 0, 0, exception_state);
}
void Console::__webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& filepath,
                                          const AtomicString& file_name,
                                          int64_t lineno,
                                          ExceptionState& exception_state) {
  __webf_debug_inspect_vars__(context, value, filepath, file_name, lineno, 0, exception_state);
}

void Console::__webf_debug_inspect_vars__(ExecutingContext* context,
                                          const ScriptValue& value,
                                          const AtomicString& filepath,
                                          const AtomicString& file_name,
                                          int64_t lineno,
                                          int64_t column,
                                          ExceptionState& exception_state) {
  JS_DebuggerInspectValue(context->ctx(), value.QJSValue(), filepath.ToStdString(context->ctx()).c_str(), file_name.ToStdString(context->ctx()).c_str(), lineno, column);
}

}  // namespace webf
