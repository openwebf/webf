/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_CANVAS_TEXT_METRICS_H_
#define WEBF_CORE_HTML_CANVAS_TEXT_METRICS_H_

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/binding_object.h"

namespace webf {

struct TextMetricsData {
  double width;
#if 0
  double actualBoundingBoxLeft;
  double actualBoundingBoxRight;

  double fontBoundingBoxAscent;
  double fontBoundingBoxDescent;
  double actualBoundingBoxAscent;
  double actualBoundingBoxDescent;
  double emHeightAscent;
  double emHeightDescent;
  double hangingBaseline;
  double alphabeticBaseline;
  double ideographicBaseline;
#endif
};

class TextMetrics : public BindingObject {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = TextMetrics*;
  TextMetrics() = delete;
  static TextMetrics* Create(ExecutingContext* context, NativeBindingObject* native_binding_object);
  explicit TextMetrics(ExecutingContext* context, NativeBindingObject* native_binding_object);

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;

  double width() const { return extra_->width; }
#if 0
  double actualBoundingBoxLeft() const { return extra_->actualBoundingBoxLeft; }
  double actualBoundingBoxRight() const { return extra_->actualBoundingBoxRight; }

  double fontBoundingBoxAscent() const { return extra_->fontBoundingBoxAscent; }
  double fontBoundingBoxDescent() const { return extra_->fontBoundingBoxDescent; }
  double actualBoundingBoxAscent() const { return extra_->actualBoundingBoxAscent; }
  double actualBoundingBoxDescent() const { return extra_->actualBoundingBoxDescent; }

  double emHeightAscent() const { return extra_->emHeightAscent; }
  double emHeightDescent() const { return extra_->emHeightDescent; }
  double hangingBaseline() const { return extra_->hangingBaseline; }
  double alphabeticBaseline() const { return extra_->alphabeticBaseline; }
  double ideographicBaseline() const { return extra_->ideographicBaseline; }
#endif
 private:
  TextMetricsData* extra_ = nullptr;
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_CANVAS_TEXT_METRICS_H_