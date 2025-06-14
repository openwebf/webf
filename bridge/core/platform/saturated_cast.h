/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_SATURATED_CAST_H
#define WEBF_SATURATED_CAST_H

#include <iostream>
#include <limits>
#include <type_traits>

namespace webf {

// 基础类型定义
template <typename T>
struct UnderlyingType {
  using type = T;
};

// 默认饱和处理程序
template <typename T>
struct SaturationDefaultLimits {
  static constexpr T min() { return std::numeric_limits<T>::min(); }
  static constexpr T max() { return std::numeric_limits<T>::max(); }
};

// 饱和转换实现
template <typename Dst, typename Src>
constexpr Dst saturated_cast_impl(Src value) {
  if (value < SaturationDefaultLimits<Dst>::min()) {
    return SaturationDefaultLimits<Dst>::min();
  } else if (value > SaturationDefaultLimits<Dst>::max()) {
    return SaturationDefaultLimits<Dst>::max();
  } else {
    return static_cast<Dst>(value);
  }
}

// 饱和转换函数
template <typename Dst, template <typename> class SaturationHandler = SaturationDefaultLimits, typename Src>
constexpr Dst saturated_cast(Src value) {
  using SrcType = typename UnderlyingType<Src>::type;
  return saturated_cast_impl<Dst, SrcType>(static_cast<SrcType>(value));
}

}  // namespace webf

#endif  // WEBF_SATURATED_CAST_H
