/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_BINDINGS_QJS_SOURCE_LOCATION_H_
#define BRIDGE_BINDINGS_QJS_SOURCE_LOCATION_H_

#include <memory>
#include <string>

namespace webf {

class ExecutingContext;

class SourceLocation {
 public:
  // Zero lineNumber and columnNumber mean unknown. Captures current stack
  // trace.
  static std::unique_ptr<SourceLocation> Capture(const std::string& url, unsigned line_number, unsigned column_number);

  SourceLocation(const std::string& url, unsigned line_number, unsigned column_number);
  ~SourceLocation();

  const std::string& Url() const { return url_; }
  unsigned LineNumber() const { return line_number_; }
  unsigned ColumnNumber() const { return column_number_; }

 private:
  std::string url_;
  unsigned line_number_;
  unsigned column_number_;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_SOURCE_LOCATION_H_
