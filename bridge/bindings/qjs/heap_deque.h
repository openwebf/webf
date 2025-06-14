/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/*
 * replace third_party/blink/renderer/platform/heap/collection_support/heap_deque.h
 */

#ifndef BRIDGE_BINDINGS_QJS_HEAP_DEQUE_H_
#define BRIDGE_BINDINGS_QJS_HEAP_DEQUE_H_

// Include heap_vector.h to also make general VectorTraits available.
#include <deque>
#include <iostream>
#include "bindings/qjs/cppgc/gc_visitor.h"

namespace webf {

template <typename T>
class HeapDeque {
 public:
  HeapDeque() = default;

  explicit HeapDeque(size_t size) : deque_(size) {}

  HeapDeque(size_t size, const T& val) : deque_(size, val) {}

  HeapDeque(const HeapDeque<T>& other) : deque_(other.deque_) {}

  HeapDeque& operator=(const HeapDeque& other) {
    deque_ = other.deque_;
    return *this;
  }

  HeapDeque(HeapDeque&& other) noexcept : deque_(std::move(other.deque_)) {}

  HeapDeque& operator=(HeapDeque&& other) noexcept {
    deque_ = std::move(other.deque_);
    return *this;
  }

  void push_back(const T& value) { deque_.push_back(value); }

  void push_front(const T& value) { deque_.push_front(value); }

  void pop_back() { deque_.pop_back(); }

  void pop_front() { deque_.pop_front(); }

  T& front() { return deque_.front(); }

  T& back() { return deque_.back(); }

  bool empty() const { return deque_.empty(); }

  size_t size() const { return deque_.size(); }

  void TraceValue(GCVisitor* visitor) const {
    for (auto& item : deque_) {
      visitor->TraceValue(item);
    }
  }

  void TraceMember(GCVisitor* visitor) const {
    for (auto& item : deque_) {
      visitor->TraceMember(item);
    }
  }

 private:
  std::deque<T> deque_;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_HEAP_DEQUE_H_
