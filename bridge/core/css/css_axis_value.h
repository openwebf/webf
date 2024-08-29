// Copyright 2019 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_AXIS_VALUE_H
#define WEBF_CSS_AXIS_VALUE_H

#include "bindings/qjs/atomic_string.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/css/css_value.h"
#include "core/css/css_value_list.h"
#include "css_value_keywords.h"
#include "foundation/casting.h"

namespace webf {

class CSSLengthResolver;
class CSSPrimitiveValue;

class CSSValueList;

namespace cssvalue {

// TODO(xiezuobing): to xxx
class CSSAxisValue : public CSSValueList {
 public:
  struct Axis : std::tuple<double, double, double> {};

  explicit CSSAxisValue(CSSValueID axis_name);
  CSSAxisValue(const std::shared_ptr<const CSSPrimitiveValue>& x,
               const std::shared_ptr<const CSSPrimitiveValue>& y,
               const std::shared_ptr<const CSSPrimitiveValue>& z);

  std::string CustomCSSText() const;

  Axis ComputeAxis(const CSSLengthResolver&) const;
  CSSValueID AxisName() const { return axis_name_; }

  void TraceAfterDispatch(GCVisitor* visitor) const { CSSValueList::TraceAfterDispatch(visitor); }

 private:
  CSSValueID axis_name_;
};

}  // namespace cssvalue

template <>
struct DowncastTraits<cssvalue::CSSAxisValue> {
  static bool AllowFrom(const CSSValue& value) { return value.IsAxisValue(); }
};

}  // namespace webf

#endif  // WEBF_CSS_AXIS_VALUE_H
