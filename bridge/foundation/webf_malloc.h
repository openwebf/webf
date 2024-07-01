/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_WEBF_MALLOC_H
#define WEBF_WEBF_MALLOC_H
#include <cstdint>
#include <memory>

namespace webf {

#define USING_FAST_MALLOC(type) \
  USING_FAST_MALLOC_INTERNAL(type)

#define USING_FAST_MALLOC_INTERNAL(type)                        \
 public:                                                        \
  void* operator new(size_t, void* p) {                         \
    return p;                                                   \
  }                                                             \
  void* operator new[](size_t, void* p) {                       \
    return p;                                                   \
  }                                                             \
                                                                \
  void* operator new(size_t size) {                             \
    return malloc(size);                                        \
  }                                                             \
                                                                \
  void operator delete(void* p) {                               \
    free(p);                                                    \
  }                                                             \
                                                                \
  void* operator new[](size_t size) {                           \
    return malloc(size);                                        \
  }                                                             \
                                                                \
  void operator delete[](void* p) {                             \
    free(p);                                                    \
  }                                                             \


#define STACK_UNINITIALIZED [[clang::uninitialized]]

}  // namespace webf

#endif  // WEBF_WEBF_MALLOC_H
