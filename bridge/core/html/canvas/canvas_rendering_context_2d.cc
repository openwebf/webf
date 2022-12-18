/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_rendering_context_2d.h"
#include "binding_call_methods.h"
#include "canvas_gradient.h"
#include "foundation/native_value_converter.h"

namespace webf {

bool CanvasRenderingContext2D::IsCanvas2d() const {
  return true;
}

CanvasRenderingContext2D::CanvasRenderingContext2D(ExecutingContext* context,
                                                   NativeBindingObject* native_binding_object)
    : BindingObject(context, native_binding_object), CanvasRenderingContext(context) {}

NativeValue CanvasRenderingContext2D::HandleCallFromDartSide(const NativeValue* method,
                                                             int32_t argc,
                                                             const NativeValue* argv) {
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
  NativeValue value = InvokeBindingMethod(binding_call_methods::kcreateLinearGradient,
                                          sizeof(arguments) / sizeof(NativeValue), arguments, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
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
  NativeValue value = InvokeBindingMethod(binding_call_methods::kcreateRadialGradient,
                                          sizeof(arguments) / sizeof(NativeValue), arguments, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
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
                                          arguments, exception_state);
  NativeBindingObject* native_binding_object =
      NativeValueConverter<NativeTypePointer<NativeBindingObject>>::FromNativeValue(value);
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
  SetBindingProperty(binding_call_methods::kfillStyle, value, exception_state);

  fill_style_ = style;
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

  SetBindingProperty(binding_call_methods::kstrokeStyle, value, exception_state);

  stroke_style_ = style;
}

void CanvasRenderingContext2D::Trace(GCVisitor* visitor) const {
  if (fill_style_ != nullptr)
    fill_style_->Trace(visitor);
  if (stroke_style_ != nullptr)
    stroke_style_->Trace(visitor);
}

}  // namespace webf