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

  void TraceValue(GCVisitor* visitor) const;
  void TraceMember(GCVisitor* visitor) const;

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
