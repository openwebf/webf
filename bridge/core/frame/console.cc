/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "console.h"
#include <quickjs/quickjs.h>
#include <sstream>
#include "foundation/logging.h"

namespace webf {

void Console::__webf_print__(ExecutingContext* context,
                             const AtomicString& log,
                             const AtomicString& level,
                             ExceptionState& exception) {
  std::stringstream stream;
  std::string buffer = log.ToStdString();
  stream << buffer;
  printLog(context, stream, level != g_empty_atom ? level.ToStdString() : "info", nullptr);
}

void Console::__webf_print__(ExecutingContext* context, const AtomicString& log, ExceptionState& exception_state) {
  std::stringstream stream;
  std::string buffer = log.ToStdString();
  stream << buffer;
  printLog(context, stream, "info", nullptr);
}

bool Console::__webf_is_proxy__(ExecutingContext* context, const ScriptValue& log, ExceptionState& exception_state) {
  return JS_IsProxy(log.QJSValue());
}

}  // namespace webf
