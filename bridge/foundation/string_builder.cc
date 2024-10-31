/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "string_builder.h"

namespace webf {

void StringBuilder::CreateBuffer8(size_t added_size) {
  DCHECK(!HasBuffer());
  has_buffer_ = true;
  // createBuffer is called right before appending addedSize more bytes. We
  // want to ensure we have enough space to fit m_string plus the added
  // size.
  //
  // We also ensure that we have at least the initialBufferSize of extra space
  // for appending new bytes to avoid future mallocs for appending short
  // strings or single characters. This is a no-op if m_length == 0 since
  // initialBufferSize() is the same as the inline capacity of the vector.
  // This allows doing append(string); append('\0') without extra mallocs.
  string_.reserve(length_ +
                                  std::max(added_size, InitialBufferSize()));
  length_ = 0;
}

void StringBuilder::Reserve(unsigned int new_size) {
  if (!HasBuffer()) {
    CreateBuffer8(new_size);
    return;
  }
  string_.reserve(new_size);
}

}