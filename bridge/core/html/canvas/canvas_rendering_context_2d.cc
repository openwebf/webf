/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_rendering_context_2d.h"
#include "binding_call_methods.h"
#include "canvas_gradient.h"
#include "core/html/canvas/html_canvas_element.h"
#include "core/html/html_image_element.h"
#include "foundation/native_value_converter.h"

namespace webf {

bool CanvasRenderingContext2D::IsCanvas2d() const {
  return true;
}

CanvasRenderingContext2D::CanvasRenderingContext2D(ExecutingContext* context,
                                                   NativeBindingObject* native_binding_object)
    : CanvasRenderingContext(context->ctx(), native_binding_object) {
  context->RegisterActiveCanvasContext2D(this);
}

CanvasRenderingContext2D::~CanvasRenderingContext2D() {
  if (isContextValid(contextId())) {
    GetExecutingContext()->RemoveCanvasContext2D(this);
  }
}

NativeValue CanvasRenderingContext2D::HandleCallFromDartSide(const AtomicString& method,
                                                             int32_t argc,
                                                             const NativeValue* argv,
                                                             Dart_Handle dart_object) {
  return Native_NewNull();
}

CanvasGradient* CanvasRenderingContext2D::createLinearGradient(double x0,
                                                               double y0,
                                                               double x1,
                                                               double y1,
                                                               ExceptionState& exception_state) const {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x0),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y0),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x1),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y1)};
  NativeValue value =
      InvokeBindingMethod(binding_call_methods::kcreateLinearGradient, sizeof(arguments) / sizeof(NativeValue),
                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);

  if (native_binding_object == nullptr)
    return nullptr;

  return MakeGarbageCollected<CanvasGradient>(GetExecutingContext(), native_binding_object);
}

CanvasGradient* CanvasRenderingContext2D::createRadialGradient(double x0,
                                                               double y0,
                                                               double r0,
                                                               double x1,
                                                               double y1,
                                                               double r1,
                                                               ExceptionState& exception_state) const {
  NativeValue arguments[] = {
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(r0),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(x1),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(y1),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(r1),
  };
  NativeValue value =
      InvokeBindingMethod(binding_call_methods::kcreateRadialGradient, sizeof(arguments) / sizeof(NativeValue),
                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);

  if (native_binding_object == nullptr)
    return nullptr;

  return MakeGarbageCollected<CanvasGradient>(GetExecutingContext(), native_binding_object);
}

CanvasPattern* CanvasRenderingContext2D::createPattern(
    const std::shared_ptr<QJSUnionHTMLImageElementHTMLCanvasElement>& init,
    const AtomicString& repetition,
    ExceptionState& exception_state) {
  NativeValue arguments[2];

  if (init->IsHTMLImageElement()) {
    arguments[0] =
        NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(init->GetAsHTMLImageElement());
  } else if (init->IsHTMLCanvasElement()) {
    arguments[0] =
        NativeValueConverter<NativeTypePointer<HTMLCanvasElement>>::ToNativeValue(init->GetAsHTMLCanvasElement());
  }

  arguments[1] = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), repetition);
  NativeValue value = InvokeBindingMethod(binding_call_methods::kcreatePattern, sizeof(arguments) / sizeof(NativeValue),
                                          arguments, FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);

  if (native_binding_object == nullptr)
    return nullptr;

  return MakeGarbageCollected<CanvasPattern>(GetExecutingContext(), native_binding_object);
}

std::shared_ptr<QJSUnionDomStringCanvasGradient> CanvasRenderingContext2D::fillStyle() {
  return fill_style_;
}

void CanvasRenderingContext2D::setFillStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style,
                                            ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  }
  SetBindingPropertyAsync(binding_call_methods::kfillStyle, value, exception_state);

  fill_style_ = style;
}

AtomicString CanvasRenderingContext2D::direction() {
  if (direction_cache_.has_value())
    return direction_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kdirection,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setDirection(const AtomicString& direction, ExceptionState& exception_state) {
  direction_cache_ = direction;
  SetBindingPropertyAsync(binding_call_methods::kdirection,
                          NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), direction), exception_state);
}

AtomicString CanvasRenderingContext2D::font() {
  if (font_cache_.has_value())
    return font_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kfont, FlushUICommandReason::kDependentsOnElement,
                                          ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setFont(const AtomicString& font, ExceptionState& exception_state) {
  font_cache_ = font;
  SetBindingPropertyAsync(binding_call_methods::kfont, NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), font),
                          exception_state);
}

AtomicString CanvasRenderingContext2D::lineCap() {
  if (line_cap_cache_.has_value())
    return line_cap_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::klineCap, FlushUICommandReason::kDependentsOnElement,
                                          ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setLineCap(const AtomicString& line_cap, ExceptionState& exception_state) {
  line_cap_cache_ = line_cap;
  SetBindingPropertyAsync(binding_call_methods::klineCap,
                          NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), line_cap), exception_state);
}

double CanvasRenderingContext2D::lineDashOffset() {
  if (line_dash_offset_cache_.has_value())
    return line_dash_offset_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::klineDashOffset,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(result);
}

void CanvasRenderingContext2D::setLineDashOffset(double line_dash_offset, ExceptionState& exception_state) {
  line_dash_offset_cache_ = line_dash_offset;
  SetBindingPropertyAsync(binding_call_methods::klineDashOffset,
                          NativeValueConverter<NativeTypeDouble>::ToNativeValue(line_dash_offset), exception_state);
}

AtomicString CanvasRenderingContext2D::lineJoin() {
  if (line_join_cache_.has_value())
    return line_join_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::klineJoin,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setLineJoin(const AtomicString& line_join, ExceptionState& exception_state) {
  line_join_cache_ = line_join;
  SetBindingPropertyAsync(binding_call_methods::klineJoin,
                          NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), line_join), exception_state);
}

double CanvasRenderingContext2D::lineWidth() {
  if (line_width_cache_.has_value())
    return line_width_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::klineWidth, FlushUICommandReason::kDependentsOnElement,
                                          ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(result);
}

void CanvasRenderingContext2D::setLineWidth(double line_width, ExceptionState& exception_state) {
  line_width_cache_ = line_width;
  SetBindingPropertyAsync(binding_call_methods::klineWidth,
                          NativeValueConverter<NativeTypeDouble>::ToNativeValue(line_width), exception_state);
}

double CanvasRenderingContext2D::miterLimit() {
  if (miter_limit_cache_.has_value())
    return miter_limit_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kmiterLimit,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(result);
}

void CanvasRenderingContext2D::setMiterLimit(double miter_limit, ExceptionState& exception_state) {
  miter_limit_cache_ = miter_limit;
  SetBindingPropertyAsync(binding_call_methods::kmiterLimit,
                          NativeValueConverter<NativeTypeDouble>::ToNativeValue(miter_limit), exception_state);
}

AtomicString CanvasRenderingContext2D::textAlign() {
  if (text_align_cache_.has_value())
    return text_align_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::ktextAlign,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setTextAlign(const AtomicString& text_align, ExceptionState& exception_state) {
  text_align_cache_ = text_align;
  SetBindingPropertyAsync(binding_call_methods::ktextAlign,
                          NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), text_align), exception_state);
}

AtomicString CanvasRenderingContext2D::textBaseline() {
  if (text_baseline_cache_.has_value())
    return text_baseline_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::ktextBaseline,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setTextBaseline(const AtomicString& text_baseline, ExceptionState& exception_state) {
  text_baseline_cache_ = text_baseline;
  SetBindingPropertyAsync(binding_call_methods::ktextBaseline,
                          NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), text_baseline), exception_state);
}

std::shared_ptr<QJSUnionDomStringCanvasGradient> CanvasRenderingContext2D::strokeStyle() {
  return stroke_style_;
}

void CanvasRenderingContext2D::setStrokeStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style,
                                              ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  }

  SetBindingPropertyAsync(binding_call_methods::kstrokeStyle, value, exception_state);

  stroke_style_ = style;
}
TextMetrics* CanvasRenderingContext2D::measureText(const AtomicString& text, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), text)};
  NativeValue result = InvokeBindingMethod(binding_call_methods::kmeasureText, 1, arguments,
                                           FlushUICommandReason::kDependentsOnElement, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(result);

  if (native_binding_object == nullptr) {
    return nullptr;
  }
  return TextMetrics::Create(GetExecutingContext(), native_binding_object);
}

void CanvasRenderingContext2D::arc(double x,
                                   double y,
                                   double radius,
                                   double startAngle,
                                   double endAngle,
                                   ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(radius),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(startAngle),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(endAngle)};
  InvokeBindingMethodAsync(binding_call_methods::karc, sizeof(arguments) / sizeof(NativeValue), arguments, exception_state);
}

void CanvasRenderingContext2D::arc(double x,
                                   double y,
                                   double radius,
                                   double startAngle,
                                   double endAngle,
                                   bool anticlockwise,
                                   ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(radius),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(startAngle),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(endAngle),
                             NativeValueConverter<NativeTypeBool>::ToNativeValue(anticlockwise)};
  InvokeBindingMethodAsync(binding_call_methods::karc, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::arcTo(double x1,
                                     double y1,
                                     double x2,
                                     double y2,
                                     double radius,
                                     ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x1),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y1),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x2),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y2),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(radius)};
  InvokeBindingMethodAsync(binding_call_methods::karcTo, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::beginPath(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kbeginPath, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::bezierCurveTo(double cp1x,
                                             double cp1y,
                                             double cp2x,
                                             double cp2y,
                                             double x,
                                             double y,
                                             ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(cp1x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(cp1y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(cp2x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(cp2y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::kbezierCurveTo, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::clearRect(double x,
                                         double y,
                                         double w,
                                         double h,
                                         ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(h)};
  InvokeBindingMethodAsync(binding_call_methods::kclearRect, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::closePath(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kclosePath, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::clip(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kclip, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::clip(Path2D* path, ExceptionState& exception_state) {
  if (path == nullptr) {
    clip(exception_state);
    return;
  }
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(path)};
  InvokeBindingMethodAsync(binding_call_methods::kclip, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::clip(Path2D* path, const AtomicString& fillRule, ExceptionState& exception_state) {
  if (path == nullptr) {
    clip(exception_state);
    return;
  }
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(path),
                             NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), fillRule)};
  InvokeBindingMethodAsync(binding_call_methods::kclip, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::drawImage(HTMLImageElement* image, double dx, double dy, ExceptionState& exception_state) {
  if (image == nullptr)
    return;
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(image),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy)};
  InvokeBindingMethodAsync(binding_call_methods::kdrawImage, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::drawImage(HTMLImageElement* image,
                                         double dx,
                                         double dy,
                                         double dw,
                                         double dh,
                                         ExceptionState& exception_state) {
  if (image == nullptr)
    return;
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(image),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dw),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dh)};
  InvokeBindingMethodAsync(binding_call_methods::kdrawImage, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::drawImage(HTMLImageElement* image,
                                         double sx,
                                         double sy,
                                         double sw,
                                         double sh,
                                         double dx,
                                         double dy,
                                         double dw,
                                         double dh,
                                         ExceptionState& exception_state) {
  if (image == nullptr)
    return;
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(image),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(sx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(sy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(sw),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(sh),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dw),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dh)};
  InvokeBindingMethodAsync(binding_call_methods::kdrawImage, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::ellipse(double x,
                                       double y,
                                       double radiusX,
                                       double radiusY,
                                       double rotation,
                                       double startAngle,
                                       double endAngle,
                                       ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(radiusX),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(radiusY),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(rotation),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(startAngle),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(endAngle)};
  InvokeBindingMethodAsync(binding_call_methods::kellipse, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::ellipse(double x,
                                       double y,
                                       double radiusX,
                                       double radiusY,
                                       double rotation,
                                       double startAngle,
                                       double endAngle,
                                       bool anticlockwise,
                                       ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(radiusX),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(radiusY),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(rotation),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(startAngle),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(endAngle),
                             NativeValueConverter<NativeTypeBool>::ToNativeValue(anticlockwise)};
  InvokeBindingMethodAsync(binding_call_methods::kellipse, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::fillRect(double x,
                                        double y,
                                        double w,
                                        double h,
                                        ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(h)};
  InvokeBindingMethodAsync(binding_call_methods::kfillRect, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::fillText(const AtomicString& text,
                                        double x,
                                        double y,
                                        ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), text),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::kfillText, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::fillText(const AtomicString& text,
                                        double x,
                                        double y,
                                        double maxWidth,
                                        ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), text),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(maxWidth)};
  InvokeBindingMethodAsync(binding_call_methods::kfillText, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::lineTo(double x, double y, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::klineTo, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::moveTo(double x, double y, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::kmoveTo, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::rect(double x, double y, double w, double h, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(h)};
  InvokeBindingMethodAsync(binding_call_methods::krect, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::restore(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::krestore, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::resetTransform(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kresetTransform, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::rotate(double angle, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(angle)};
  InvokeBindingMethodAsync(binding_call_methods::krotate, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::quadraticCurveTo(double cpx,
                                                double cpy,
                                                double x,
                                                double y,
                                                ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(cpx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(cpy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::kquadraticCurveTo, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::stroke(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kstroke, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::stroke(Path2D* path, ExceptionState& exception_state) {
  if (path == nullptr) {
    stroke(exception_state);
    return;
  }
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(path)};
  InvokeBindingMethodAsync(binding_call_methods::kstroke, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::strokeRect(double x,
                                          double y,
                                          double w,
                                          double h,
                                          ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(h)};
  InvokeBindingMethodAsync(binding_call_methods::kstrokeRect, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::save(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::ksave, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::scale(double x, double y, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::kscale, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::strokeText(const AtomicString& text,
                                          double x,
                                          double y,
                                          ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), text),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::kstrokeText, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::strokeText(const AtomicString& text,
                                          double x,
                                          double y,
                                          double maxWidth,
                                          ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), text),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(maxWidth)};
  InvokeBindingMethodAsync(binding_call_methods::kstrokeText, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::setTransform(double a,
                                            double b,
                                            double c,
                                            double d,
                                            double e,
                                            double f,
                                            ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(a),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(b),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(c),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(d),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(e),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(f)};
  InvokeBindingMethodAsync(binding_call_methods::ksetTransform, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::transform(double a,
                                         double b,
                                         double c,
                                         double d,
                                         double e,
                                         double f,
                                         ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(a),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(b),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(c),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(d),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(e),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(f)};
  InvokeBindingMethodAsync(binding_call_methods::ktransform, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::translate(double x, double y, ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  InvokeBindingMethodAsync(binding_call_methods::ktranslate, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::reset(ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kreset, 0, nullptr, exception_state);
  ClearPropertyCaches();
}

void CanvasRenderingContext2D::roundRect(double x,
                                         double y,
                                         double w,
                                         double h,
                                         std::shared_ptr<const QJSUnionDoubleSequenceDouble> radii,
                                         ExceptionState& exception_state) {
  std::vector<double> radii_vector;
  if (radii->IsDouble()) {
    radii_vector.emplace_back(radii->GetAsDouble());
  } else if (radii->IsSequenceDouble()) {
    std::vector<double> radii_sequence = radii->GetAsSequenceDouble();
    radii_vector.assign(radii_sequence.begin(), radii_sequence.end());
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(h),
                             NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(radii_vector)};

  InvokeBindingMethodAsync(binding_call_methods::kroundRect, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::requestPaint() const {
  _needsPaint = true;
}

bool CanvasRenderingContext2D::IsCanvasRenderingContext2D() const {
  return true;
}

void CanvasRenderingContext2D::needsPaint() const {
  if (bindingObject()->invoke_bindings_methods_from_native == nullptr)
    return;
  if (!_needsPaint)
    return;
  InvokeBindingMethod(binding_call_methods::kneedsPaint, 0, nullptr, kDependentsOnElement, ASSERT_NO_EXCEPTION());
}

void CanvasRenderingContext2D::roundRect_async(double x,
                                               double y,
                                               double w,
                                               double h,
                                               std::shared_ptr<const QJSUnionDoubleSequenceDouble> radii,
                                               ExceptionState& exception_state) {
  std::vector<double> radii_vector;
  if (radii->IsDouble()) {
    radii_vector.emplace_back(radii->GetAsDouble());
  } else if (radii->IsSequenceDouble()) {
    std::vector<double> radii_sequence = radii->GetAsSequenceDouble();
    radii_vector.assign(radii_sequence.begin(), radii_sequence.end());
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(w),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(h),
                             NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(radii_vector)};

  InvokeBindingMethodAsync(binding_call_methods::kroundRect, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::fill(webf::ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kfill, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
                                    webf::ExceptionState& exception_state) {
  if (pathOrPattern->IsDomString()) {
    NativeValue arguments[] = {
        NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), pathOrPattern->GetAsDomString())};
    InvokeBindingMethodAsync(binding_call_methods::kfill, sizeof(arguments) / sizeof(NativeValue), arguments,
                             exception_state);
  } else if (pathOrPattern->IsPath2D()) {
    NativeValue arguments[] = {
        NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(pathOrPattern->GetAsPath2D())};
    InvokeBindingMethodAsync(binding_call_methods::kfill, sizeof(arguments) / sizeof(NativeValue), arguments,
                             exception_state);
  }
}

void CanvasRenderingContext2D::fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
                                    const webf::AtomicString& fillRule,
                                    webf::ExceptionState& exception_state) {
  assert(pathOrPattern->IsPath2D());
  NativeValue arguments[] = {
      NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(pathOrPattern->GetAsPath2D()),
      NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), fillRule)};
  InvokeBindingMethodAsync(binding_call_methods::kfill, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::Trace(GCVisitor* visitor) const {
  if (fill_style_ != nullptr)
    fill_style_->Trace(visitor);
  if (stroke_style_ != nullptr)
    stroke_style_->Trace(visitor);
}

void CanvasRenderingContext2D::ClearPropertyCaches() {
  direction_cache_.reset();
  font_cache_.reset();
  line_cap_cache_.reset();
  line_dash_offset_cache_.reset();
  line_join_cache_.reset();
  line_width_cache_.reset();
  miter_limit_cache_.reset();
  text_align_cache_.reset();
  text_baseline_cache_.reset();
}

}  // namespace webf
