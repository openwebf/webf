/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "string_view.h"

namespace webf {

StringView::StringView(const std::string& string) : bytes_(string.data()), length_(string.length()), is_8bit_(true) {}

StringView::StringView(const SharedNativeString* string)
    : bytes_(string->string()), length_(string->length()), is_8bit_(false) {}

StringView::StringView(void* bytes, unsigned length, bool is_wide_char)
    : bytes_(bytes), length_(length), is_8bit_(!is_wide_char) {}
}  // namespace webf
