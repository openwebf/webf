/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef KRAKENBRIDGE_BINDINGS_QJS_EXCEPTION_MESSAGE_H_
#define KRAKENBRIDGE_BINDINGS_QJS_EXCEPTION_MESSAGE_H_

#include <string>

namespace kraken {

class ExceptionMessage {
 public:
  static std::string FormatString(const char* format, ...);

  static std::string ArgumentNotOfType(int argument_index, const char* expect_type);
  static std::string ArgumentNullOrIncorrectType(int argument_index, const char* expect_type);

 private:
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_EXCEPTION_MESSAGE_H_
