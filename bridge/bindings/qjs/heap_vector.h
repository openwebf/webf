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

  const V& at(size_t index) const {
    assert(index < entries_.size() && "Index out of range");
    return entries_.at(index);
  }

  V& at(size_t index) {
    assert(index < entries_.size() && "Index out of range");
    return entries_.at(index);
  }

  size_t size() const { return entries_.size(); }
  const V* data() const { return entries_.data(); }

  bool empty() const { return entries_.empty(); }

  void clear() { entries_.clear(); }
  void reserve(size_t size) { entries_.reserve(size); }

  bool contains(const V& value) const { return std::find(entries_.begin(), entries_.end(), value) != entries_.end(); }

  int find(const V& value) const {
    auto it = std::find(entries_.begin(), entries_.end(), value);
    if (it != entries_.end()) {
      return std::distance(entries_.begin(), it);
    } else {
      return -1;  // not find
    }
  }

  bool erase_at(size_t index) {
    if (index >= entries_.size()) {
      std::cerr << "Index out of range" << std::endl;
      return false;
    }
    entries_.erase(entries_.begin() + index);
    return true;
  }

  void AppendVector(const HeapVector<V>& other) {
    entries_.insert(entries_.end(), other.entries_.begin(), other.entries_.end());
  }

  void TraceValue(GCVisitor* visitor) const;
  void TraceMember(GCVisitor* visitor) const;

  using iterator = typename std::vector<V>::iterator;
  using const_iterator = typename std::vector<V>::const_iterator;

  iterator begin() { return entries_.begin(); }
  const_iterator begin() const { return entries_.begin(); }
  iterator end() { return entries_.end(); }
  const_iterator end() const { return entries_.end(); }

  const std::vector<V>& ToStdVector() const { return entries_; }

  using ValueType = V;
  using value_type = V;

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
