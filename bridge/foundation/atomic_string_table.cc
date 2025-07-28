/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "atomic_string_table.h"
#include "foundation/logging.h"
#include "foundation/string_hasher.h"

namespace webf {

AtomicStringTable::AtomicStringTable() = default;

AtomicStringTable& AtomicStringTable::Instance() {
  thread_local static AtomicStringTable table;
  return table;
}

void AtomicStringTable::ReserveCapacity(unsigned int size) {
  table_.reserve(size);
}

void AtomicStringTable::Clear() {
  table_.clear();
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(std::shared_ptr<StringImpl> string) {
  if (!string->length())
    return StringImpl::empty_shared();

  auto result = table_.insert(string);
  
  // Return the existing string if it was already in the table
  return *result.first;
}

static size_t count_ascii(const uint8_t *buf, size_t len)
{
  const uint8_t *p, *p_end;
  p = buf;
  p_end = buf + len;
  while (p < p_end && *p < 128)
    p++;
  return p - buf;
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(const char* chars, unsigned int length) {
  if (!chars)
    return nullptr;

  if (!length)
    return StringImpl::empty_shared();

  std::shared_ptr<StringImpl> ptr = StringImpl::CreateFromUTF8(chars, length);

  auto result = table_.insert(ptr);

  return *result.first;
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(const char16_t* chars, unsigned int length) {
  if (!chars)
    return nullptr;

  if (!length)
    return StringImpl::empty_shared();

  std::shared_ptr<StringImpl> ptr = StringImpl::Create(chars, length);
  auto result = table_.insert(ptr);

  return *result.first;
}

std::shared_ptr<StringImpl> AtomicStringTable::Add(const std::string_view& string_view) {
  if (string_view.empty())
    return StringImpl::empty_shared();

  std::shared_ptr<StringImpl> ptr = StringImpl::Create(string_view.data(), string_view.length());
  auto result = table_.insert(ptr);

  return *result.first;
}

}  // namespace webf