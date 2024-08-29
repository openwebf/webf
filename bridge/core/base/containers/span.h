// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// Copyright (C) 2022-present The WebF authors. All rights reserved.

#ifndef BASE_CONTAINERS_SPAN_H_
#define BASE_CONTAINERS_SPAN_H_

#include <cstddef>
#include <stdint.h>

#include <algorithm>
#include <array>
#include <concepts>
#include <iosfwd>
#include <iterator>
#include <limits>
#include <memory>
#include <span>
#include <type_traits>
#include <utility>

namespace webf {

// [views.constants]
inline constexpr size_t dynamic_extent = std::numeric_limits<size_t>::max();

// [span], class template span
template <typename T, size_t Extent = std::dynamic_extent>
class span {
public:
  using element_type = T;
  using value_type = std::remove_cv_t<T>;
  using size_type = size_t;
  using difference_type = std::ptrdiff_t;
  using pointer = T*;
  using reference = T&;
  using iterator = T*;
  using const_iterator = const T*;

  constexpr span() noexcept = default;
  constexpr span(T* ptr, size_t count) noexcept : span_(ptr, count) {}
  constexpr span(T* first, T* last) noexcept : span_(first, last) {}
  template <size_t N>
  constexpr span(T (&arr)[N]) noexcept : span_(arr) {}
  template <typename Container>
  constexpr span(Container& cont) noexcept : span_(cont.data(), cont.size()) {}
  template <typename Container>
  constexpr span(const Container& cont) noexcept : span_(cont.data(), cont.size()) {}

  constexpr span(const span& other) noexcept = default;
  constexpr span& operator=(const span& other) noexcept = default;

  constexpr iterator begin() const noexcept { return span_.begin(); }
  constexpr iterator end() const noexcept { return span_.end(); }

  constexpr const_iterator cbegin() const noexcept { return span_.cbegin(); }
  constexpr const_iterator cend() const noexcept { return span_.cend(); }

  constexpr reference front() const { return span_.front(); }
  constexpr reference back() const { return span_.back(); }
  constexpr reference operator[](size_type idx) const { return span_[idx]; }

  constexpr pointer data() const noexcept { return span_.data(); }
  constexpr size_type size() const noexcept { return span_.size(); }
  constexpr size_type size_bytes() const noexcept { return span_.size_bytes(); }
  constexpr bool empty() const noexcept { return span_.empty(); }

private:
  std::span<T, Extent> span_;
};

namespace internal {
template <typename Container>
struct Extent : std::integral_constant<size_t, std::dynamic_extent> {};
}

template <int&... ExplicitArgumentBarrier, typename Container>
constexpr auto make_span(Container&& container) noexcept {
  using T = std::remove_pointer_t<decltype(std::data(std::declval<Container>()))>;
  using Extent = internal::Extent<Container>;
  return span<T, Extent::value>(std::forward<Container>(container).data(), std::forward<Container>(container).size());
}

// as_chars() is the equivalent of as_bytes(), except that it returns a
// span of const char rather than const uint8_t. This non-std function is
// added since chrome still represents many things as char arrays which
// rightfully should be uint8_t.
template <typename T, size_t X>
constexpr auto as_chars(span<T, X> s) noexcept {
  constexpr size_t N = X == std::dynamic_extent ? std::dynamic_extent : sizeof(T) * X;
  return span<const char, N>(
      reinterpret_cast<const char*>(s.data()), s.size_bytes());
}

template <typename T, size_t X>
constexpr auto as_bytes(webf::span<T, X> s) noexcept {
  constexpr size_t N = X == std::dynamic_extent ? std::dynamic_extent : sizeof(T) * X;
  return span<const uint8_t, N>(
      reinterpret_cast<const uint8_t*>(s.data()), s.size_bytes());
}

// Convenience function for converting an object which is itself convertible
// to span into a span of bytes (i.e. span of const uint8_t). Typically used
// to convert std::string or string-objects holding chars, or std::vector
// or vector-like objects holding other scalar types, prior to passing them
// into an API that requires byte spans.
template <typename T>
  requires requires(const T& arg) {
  requires !std::is_array_v<std::remove_reference_t<T>>;
  make_span(arg);
  }
constexpr span<const uint8_t> as_byte_span(const T& arg) {
  return as_bytes(make_span(arg));
}

// This overload for arrays preserves the compile-time size N of the array in
// the span type signature span<uint8_t, N>.
template <typename T, size_t N>
constexpr span<const uint8_t, N * sizeof(T)> as_byte_span(
    const T (&arr)[N]) {
  return as_bytes(make_span<N>(arr));
}

// This overload adds a compile-time size that must be explicitly given,
// checking that the size is correct at runtime. The template argument `N` is
// the number of _bytes_ in the input range, not the number of elements.
//
// This is sugar for `base::span<const uint8_t, N>(base::as_byte_span(x))`.
//
// Example:
// ```
// std::string foo = "hello";
// base::span<const uint8_t, 5> s = base::as_byte_span<5>(foo);
// ```
template <size_t N, typename T>
  requires requires(const T& arg) {
  requires !std::is_array_v<std::remove_reference_t<T>>;
  make_span(arg);
  }
constexpr span<const uint8_t, N> as_byte_span(const T& arg) {
  return span<const uint8_t, N>(as_byte_span(arg));
}

// Helper functions to convert a reference to T into a span of uint8_t
template <typename T>
constexpr span<const std::byte, sizeof(T)> byte_span_from_ref(const T& single_object) noexcept {
  return std::as_bytes(std::span<const T, 1>(&single_object, 1));
}

template <typename T>
constexpr span<std::byte, sizeof(T)> byte_span_from_ref(T& single_object) noexcept {
  return std::as_writable_bytes(std::span<T, 1>(&single_object, 1));
}

}  // namespace base
#endif  // BASE_CONTAINERS_SPAN_H_