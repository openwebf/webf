/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_CSS_PARSER_TYPE_ALIASES_H_
#define WEBF_CORE_CSS_PARSER_TYPE_ALIASES_H_

#include <memory>
#include <string>
#include <string_view>
#include <vector>

// This file provides type aliases to ease migration between WebF and Blink types.
// It allows gradual migration and testing of Blink-compatible code.

namespace webf {

// Feature flag to enable Blink-compatible types (for future use)
#ifndef WEBF_USE_BLINK_TYPES
#define WEBF_USE_BLINK_TYPES 0
#endif

namespace css_parser {

// String types
#if WEBF_USE_BLINK_TYPES
  // Future: When we integrate with Blink types
  // using String = WTF::String;
  // using StringView = WTF::StringView;
  // using AtomicString = WTF::AtomicString;
#else
  using String = std::string;
  using StringView = std::string_view;
  using AtomicString = std::string;  // WebF doesn't have atomic strings yet
#endif

// Container types
template<typename T>
#if WEBF_USE_BLINK_TYPES
  // Future: using Vector = WTF::Vector<T>;
  using Vector = std::vector<T>;
#else
  using Vector = std::vector<T>;
#endif

// Smart pointer types
template<typename T>
#if WEBF_USE_BLINK_TYPES
  // Future: using RefPtr = scoped_refptr<T>;
  // Future: using Member = Member<T>;
  using RefPtr = std::shared_ptr<T>;
  using Member = std::shared_ptr<T>;
#else
  using RefPtr = std::shared_ptr<T>;
  using Member = std::shared_ptr<T>;
#endif

// Unique pointer
template<typename T>
using UniquePtr = std::unique_ptr<T>;

// Optional type
template<typename T>
using Optional = std::optional<T>;

// Span type (already using tcb::span in WebF)
template<typename T>
using Span = tcb::span<T>;

// Helper functions for type conversions
inline String ToString(const std::string& str) { return str; }
inline String ToString(std::string_view str) { return String(str); }
inline std::string ToStdString(const String& str) { return str; }

// Helper for creating shared pointers
template<typename T, typename... Args>
inline RefPtr<T> MakeRefPtr(Args&&... args) {
  return std::make_shared<T>(std::forward<Args>(args)...);
}

// Helper for creating unique pointers
template<typename T, typename... Args>
inline UniquePtr<T> MakeUniquePtr(Args&&... args) {
  return std::make_unique<T>(std::forward<Args>(args)...);
}

}  // namespace css_parser
}  // namespace webf

#endif  // WEBF_CORE_CSS_PARSER_TYPE_ALIASES_H_