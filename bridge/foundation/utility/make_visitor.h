/*
* Copyright (C) 2025-present The WebF authors. All rights reserved.
*/
#ifndef WEBF_MAKE_VISITOR_H
#define WEBF_MAKE_VISITOR_H

namespace webf {

namespace internal {
template<typename Tf, typename Tremains...>
struct Overloaded {
  using Tf::operator();
  using Overloaded<Tremains...>::operator();

  explicit Overloaded(Tf f, Tremains remains...): Overloaded<Tf>(f), Overloaded<Tremains...>(remains...) {}
};

template<typename Tf>
struct Overloaded<Tf> {
  using Tf::operator();

  explicit Overloaded(Tf f): Overloaded<Tf>(f) {}
};
}

auto MakeVisitor(auto... fn) {
  return internal::Overloaded(fn...);
}

} // namespace webf

#endif  // WEBF_MAKE_VISITOR_H
