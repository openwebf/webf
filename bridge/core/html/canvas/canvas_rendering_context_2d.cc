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
  if (GetExecutingContext()->IsContextValid()) {
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

ScriptPromise CanvasRenderingContext2D::createPattern_async(
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
  return InvokeBindingMethodAsync(binding_call_methods::kcreatePattern, sizeof(arguments) / sizeof(NativeValue),
                                  arguments, exception_state);
}

std::shared_ptr<QJSUnionDomStringCanvasGradient> CanvasRenderingContext2D::fillStyle() {
  return fill_style_;
}

ScriptPromise CanvasRenderingContext2D::fillStyle_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(binding_call_methods::kfillStyle, exception_state);
}

void CanvasRenderingContext2D::setFillStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style,
                                            ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  }
  SetBindingProperty(binding_call_methods::kfillStyle, value, exception_state);

  fill_style_ = style;
}

void CanvasRenderingContext2D::setFillStyle_async(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style,
                                                  ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  }

  SetBindingPropertyAsync(binding_call_methods::kfillStyle, value, exception_state);
}

std::shared_ptr<QJSUnionDomStringCanvasGradient> CanvasRenderingContext2D::strokeStyle() {
  return stroke_style_;
}

ScriptPromise CanvasRenderingContext2D::strokeStyle_async(ExceptionState& exception_state) {
  return GetBindingPropertyAsync(binding_call_methods::kstrokeStyle, exception_state);
}

void CanvasRenderingContext2D::setStrokeStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style,
                                              ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  }

  SetBindingProperty(binding_call_methods::kstrokeStyle, value, exception_state);

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

void CanvasRenderingContext2D::setStrokeStyle_async(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style,
                                                    ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  }

  SetBindingPropertyAsync(binding_call_methods::kstrokeStyle, value, exception_state);
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

  InvokeBindingMethod(binding_call_methods::kroundRect, sizeof(arguments) / sizeof(NativeValue), arguments,
                      FlushUICommandReason::kDependentsOnElement, exception_state);
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
  if (!_needsPaint) return;
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
  InvokeBindingMethod(binding_call_methods::kfill, 0, nullptr, FlushUICommandReason::kDependentsOnElement,
                      exception_state);
}

void CanvasRenderingContext2D::fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
                                    webf::ExceptionState& exception_state) {
  if (pathOrPattern->IsDomString()) {
    NativeValue arguments[] = {
        NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), pathOrPattern->GetAsDomString())};
    InvokeBindingMethod(binding_call_methods::kfill, sizeof(arguments) / sizeof(NativeValue), arguments,
                        FlushUICommandReason::kDependentsOnElement, exception_state);
  } else if (pathOrPattern->IsPath2D()) {
    NativeValue arguments[] = {
        NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(pathOrPattern->GetAsPath2D())};
    InvokeBindingMethod(binding_call_methods::kfill, sizeof(arguments) / sizeof(NativeValue), arguments,
                        FlushUICommandReason::kDependentsOnElement, exception_state);
  }
}

void CanvasRenderingContext2D::fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
                                    const webf::AtomicString& fillRule,
                                    webf::ExceptionState& exception_state) {
  assert(pathOrPattern->IsPath2D());
  NativeValue arguments[] = {
      NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(pathOrPattern->GetAsPath2D()),
      NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), fillRule)};
  InvokeBindingMethod(binding_call_methods::kfill, sizeof(arguments) / sizeof(NativeValue), arguments,
                      FlushUICommandReason::kDependentsOnElement, exception_state);
}

void CanvasRenderingContext2D::fill_async(webf::ExceptionState& exception_state) {
  InvokeBindingMethodAsync(binding_call_methods::kfill, 0, nullptr, exception_state);
}

void CanvasRenderingContext2D::fill_async(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
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

void CanvasRenderingContext2D::fill_async(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
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

}  // namespace webf