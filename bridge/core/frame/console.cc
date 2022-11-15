/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "console.h"
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

}  // namespace webf
