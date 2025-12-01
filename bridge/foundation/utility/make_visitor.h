/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
* Copyright (C) 2025-present The WebF authors. All rights reserved.
*/
#ifndef WEBF_MAKE_VISITOR_H
#define WEBF_MAKE_VISITOR_H

namespace webf {

namespace internal {
template<typename Tf, typename... Tremains>
struct Overloaded : Overloaded<Tf>, Overloaded<Tremains...> {
  using Overloaded<Tf>::operator();
  using Overloaded<Tremains...>::operator();

  explicit Overloaded(Tf f, Tremains... remains): Overloaded<Tf>(f), Overloaded<Tremains...>(remains...) {}
};

template<typename Tf>
struct Overloaded<Tf> : Tf {
  using Tf::operator();

  explicit Overloaded(Tf f): Tf(f) {}
};
}

constexpr auto MakeVisitor(auto... fn) {
  return internal::Overloaded(fn...);
}

constexpr auto MakeVisitorWithUnreachableWildcard(auto... fn) {
  return internal::Overloaded(fn..., [](auto&&...) {unreachable();});
}

} // namespace webf

#endif  // WEBF_MAKE_VISITOR_H
