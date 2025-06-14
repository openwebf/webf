// Copyright 2020 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CONTAINS_H
#define WEBF_CONTAINS_H

#include <type_traits>
#include <utility>

namespace webf {

namespace internal {

// Small helper to detect whether a given type has a nested `key_type` typedef.
// Used below to catch misuses of the API for associative containers.
template <typename T, typename SFINAE = void>
struct HasKeyType : std::false_type {};

template <typename T>
struct HasKeyType<T, std::void_t<typename T::key_type>> : std::true_type {};

}  // namespace internal

// A general purpose utility to check whether `container` contains `value`. This
// will probe whether a `contains` or `find` member function on `container`
// exists, and fall back to a generic linear search over `container`.
// Helper to check if container has a `contains` method.
template <typename Container, typename Value, typename = void>
struct has_contains_method : std::false_type {};

template <typename Container, typename Value>
struct has_contains_method<Container,
                           Value,
                           std::void_t<decltype(std::declval<Container>().contains(std::declval<Value>()))>>
    : std::true_type {};

template <typename Container, typename Value>
constexpr bool has_contains_v = has_contains_method<Container, Value>::value;

// Helper to check if container has a `find` method that returns `npos`.
template <typename Container, typename Value, typename = void>
struct has_find_npos_method : std::false_type {};

template <typename Container, typename Value>
struct has_find_npos_method<
    Container,
    Value,
    std::void_t<decltype(std::declval<Container>().find(std::declval<Value>()) != Container::npos)>> : std::true_type {
};

template <typename Container, typename Value>
constexpr bool has_find_npos_v = has_find_npos_method<Container, Value>::value;

// Helper to check if container has a `find` method that returns an iterator.
template <typename Container, typename Value, typename = void>
struct has_find_iterator_method : std::false_type {};

template <typename Container, typename Value>
struct has_find_iterator_method<
    Container,
    Value,
    std::void_t<decltype(std::declval<Container>().find(std::declval<Value>()) != std::declval<Container>().end())>>
    : std::true_type {};

template <typename Container, typename Value>
constexpr bool has_find_iterator_v = has_find_iterator_method<Container, Value>::value;

// Helper to check if linear search is necessary.
template <typename Container, typename = void>
struct is_associative_container : std::false_type {};

template <typename Container>
struct is_associative_container<Container, std::void_t<typename Container::key_type>> : std::true_type {};

template <typename Container, typename Value>
constexpr bool Contains(const Container& container, const Value& value) {
  if constexpr (has_contains_v<Container, Value>) {
    return container.contains(value);
  } else if constexpr (has_find_npos_v<Container, Value>) {
    return container.find(value) != Container::npos;
  } else if constexpr (has_find_iterator_v<Container, Value>) {
    return container.find(value) != container.end();
  } else {
    static_assert(!is_associative_container<Container>::value,
                  "Error: About to perform linear search on an associative container. "
                  "Either use a more generic comparator (e.g. std::less<>) or, if a "
                  "linear search is desired, provide an explicit projection parameter.");
    return std::find(std::begin(container), std::end(container), value) != std::end(container);
  }
}

// Overload that allows to provide an additional projection invocable. This
// projection will be applied to every element in `container` before comparing
// it with `value`. This will always perform a linear search.
template <typename Container, typename Value, typename Proj>
constexpr bool Contains(const Container& container, const Value& value, Proj proj) {
  // Use std::find_if with a custom predicate based on the projection
  return std::find_if(container.begin(), container.end(),
                      [&value, &proj](const auto& elem) { return proj(elem) == value; }) != container.end();
}

}  // namespace webf

#endif  // WEBF_CONTAINS_H
