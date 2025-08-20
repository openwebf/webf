/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_
#define BRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_

#include <unordered_map>
#include "cppgc/gc_visitor.h"

namespace webf {

template <typename K, typename V>
class HeapHashMap {
 public:
  HeapHashMap();
  ~HeapHashMap();

  bool Contains(K key);
  V GetProperty(K key);
  void SetProperty(K key, V value);
  void CopyWith(HeapHashMap* newValue);
  void Erase(K key);

  void Trace(GCVisitor* visitor) const;

 private:
  std::unordered_map<K, V> entries_;
};

template <typename K, typename V>
HeapHashMap<K, V>::HeapHashMap() {}

template <typename K, typename V>
HeapHashMap<K, V>::~HeapHashMap() {}

template <typename K, typename V>
bool HeapHashMap<K, V>::Contains(K key) {
  return entries_.count(key) > 0;
}

template <typename K, typename V>
V HeapHashMap<K, V>::GetProperty(K key) {
  if (entries_.count(key) == 0)
    return JS_NULL;

  return entries_[key];
}

template <typename K, typename V>
void HeapHashMap<K, V>::SetProperty(K key, V value) {
  entries_[key] = value;
}

template <typename K, typename V>
void HeapHashMap<K, V>::CopyWith(HeapHashMap* newValue) {
  newValue->entries_ = entries_;
}

template <typename K, typename V>
void HeapHashMap<K, V>::Erase(K key) {
  if (entries_.count(key) == 0)
    return;
  entries_.erase(key);
}

template <typename K, typename V>
void HeapHashMap<K, V>::Trace(GCVisitor* visitor) const {
  for (auto& entry : entries_) {
    visitor->TraceMember(entry.second);
  }
}

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_HEAP_HASHMAP_H_
