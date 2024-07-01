//
// Created by 谢作兵 on 21/06/24.
//

#ifndef WEBF_STATIC_CONSTRUCTORS_H
#define WEBF_STATIC_CONSTRUCTORS_H

namespace webf {

// We need to avoid having static constructors. This is accomplished by defining
// a buffer of the appropriate size and alignment, and defining a const
// reference that points to the buffer. During initialization, the object will
// be constructed with placement new into the buffer. This works with MSVC, GCC,
// and Clang without producing dynamic initialization code even at -O0. The only
// downside is that all external translation units will have to emit one more
// load, while a real global could be referenced directly by absolute or
// relative addressing.

// Use an array of pointers instead of an array of char in case there is some
// alignment issue.
#define DEFINE_GLOBAL(type, name)                                          \
  std::aligned_storage_t<sizeof(type), alignof(type)> name##Storage; \
  const type& name = *std::launder(reinterpret_cast<type*>(&name##Storage))

}  // namespace webf

#endif  // WEBF_STATIC_CONSTRUCTORS_H
