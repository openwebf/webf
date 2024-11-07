/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "atomic_string_table.h"

namespace webf {

AtomicStringTable::AtomicStringTable() = default;

AtomicStringTable& AtomicStringTable::Instance() {
  thread_local static AtomicStringTable table;
  return table;
}

void AtomicStringTable::ReserveCapacity(unsigned int size) {
  table_.reserve(size);
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(std::shared_ptr<StringImpl> string) {
  if (!string->length())
    return nullptr;

  table_.insert(string);

  return string;
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(const char* chars, unsigned int length) {
  std::shared_ptr<StringImpl> ptr = StringImpl::Create(chars, length);
  table_.insert(ptr);

  return ptr;
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(const char16_t* chars, unsigned int length) {
  std::shared_ptr<StringImpl> ptr = StringImpl::Create(chars, length);
  table_.insert(ptr);

  return ptr;
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(const std::string_view& string_view) {
  std::shared_ptr<StringImpl> ptr = StringImpl::Create(string_view.data(), string_view.length());
  table_.insert(ptr);

  return ptr;
}

}