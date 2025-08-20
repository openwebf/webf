/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "source_location.h"

namespace webf {

std::unique_ptr<SourceLocation> SourceLocation::Capture(const std::string& url,
                                                        unsigned int line_number,
                                                        unsigned int column_number) {
  return std::make_unique<SourceLocation>(url, line_number, column_number);
}

SourceLocation::SourceLocation(const std::string& url, unsigned int line_number, unsigned int column_number)
    : url_(url), line_number_(line_number), column_number_(column_number) {}

SourceLocation::~SourceLocation() {}

}  // namespace webf
