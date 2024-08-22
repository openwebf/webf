/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_HEAP_VECTOR_H_
#define BRIDGE_BINDINGS_QJS_HEAP_VECTOR_H_

namespace webf {

template <typename V>
class HeapVector final {
 public:
  HeapVector() = default;

  void push_back(const V& value) { entries_.push_back(value); }

  V& at(size_t index) {
    if (index >= entries_.size()) {
      throw std::out_of_range("Index out of range");
    }
    return entries_.at(index);
  }

  size_t size() const { return entries_.size(); }

  bool empty() const { return entries_.empty(); }

  void clear() { entries_.clear(); }

  bool contains(const V& value) const { return std::find(entries_.begin(), entries_.end(), value) != entries_.end(); }

  int find(const V& value) const {
    auto it = std::find(entries_.begin(), entries_.end(), value);
    if (it != entries_.end()) {
      return std::distance(entries_.begin(), it);
    } else {
      return -1;  // 未找到元素
    }
  }

  void erase_at(size_t index) {
    if (index >= entries_.size()) {
      throw std::out_of_range("Index out of range");
    }
    entries_.erase(entries_.begin() + index);
  }

  void TraceValue(GCVisitor* visitor) const;
  void TraceMember(GCVisitor* visitor) const;

  const std::vector<V>& ToStdVector() const {
    return entries_;
  }

 private:
  std::vector<V> entries_;
};

template <typename V>
void HeapVector<V>::TraceValue(GCVisitor* visitor) const {
  for (auto& item : entries_) {
    visitor->TraceValue(item);
  }
}

template <typename V>
void HeapVector<V>::TraceMember(GCVisitor* visitor) const {
  for (auto& item : entries_) {
    visitor->TraceMember(item);
  }
}

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_HEAP_VECTOR_H_
