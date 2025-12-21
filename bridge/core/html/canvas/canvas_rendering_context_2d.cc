/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "canvas_rendering_context_2d.h"
#include <cmath>
#include <limits>
#include "binding_call_methods.h"
#include "canvas_gradient.h"
#include "core/html/canvas/html_canvas_element.h"
#include "core/html/html_image_element.h"
#include "core/html/image_bitmap.h"
#include "foundation/native_value_converter.h"
#include "foundation/logging.h"


#if defined(_WIN32)
#include <Windows.h>
#endif

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

// --- ImageData APIs implemented on the C++ side ---

namespace {

// Helper to create a new ImageData-like JS object:
// { width, height, data: Uint8ClampedArray(buffer) }
ScriptValue CreateBlankImageDataObject(JSContext* ctx, int32_t width, int32_t height, ExceptionState& exception_state) {
  if (width <= 0 || height <= 0) {
    return ScriptValue::Empty(ctx);
  }

  size_t byte_length = static_cast<size_t>(width) * static_cast<size_t>(height) * 4u;

  uint8_t* buffer = nullptr;
  if (byte_length > 0) {
#if defined(_WIN32)
    buffer = static_cast<uint8_t*>(CoTaskMemAlloc(byte_length));
#else
    buffer = static_cast<uint8_t*>(malloc(byte_length));
#endif
  }

  if (buffer == nullptr && byte_length > 0) {
    exception_state.ThrowException(ctx, ErrorType::InternalError,
                                   "Failed to allocate memory for ImageData.");
    return ScriptValue::Empty(ctx);
  }

  if (byte_length > 0) {
    memset(buffer, 0, byte_length);
  }

  auto free_func = [](JSRuntime* rt, void* opaque, void* ptr) {
#if defined(_WIN32)
    CoTaskMemFree(ptr);
#else
    free(ptr);
#endif
  };

  JSValue array_buffer = JS_NewArrayBuffer(ctx, buffer, byte_length, free_func, nullptr, 0);
  if (JS_IsException(array_buffer)) {
    free_func(JS_GetRuntime(ctx), nullptr, buffer);
    exception_state.ThrowException(ctx, array_buffer);
    return ScriptValue::Empty(ctx);
  }

  JSValue global = JS_GetGlobalObject(ctx);
  JSValue ctor = JS_GetPropertyStr(ctx, global, "Uint8ClampedArray");
  JS_FreeValue(ctx, global);

  JSValue data;
  if (JS_IsFunction(ctx, ctor)) {
    JSValue argv[1] = {array_buffer};
    data = JS_CallConstructor(ctx, ctor, 1, argv);
  } else {
    // Fallback: use plain ArrayBuffer when Uint8ClampedArray is missing.
    data = JS_DupValue(ctx, array_buffer);
  }
  JS_FreeValue(ctx, ctor);
  JS_FreeValue(ctx, array_buffer);

  if (JS_IsException(data)) {
    exception_state.ThrowException(ctx, data);
    return ScriptValue::Empty(ctx);
  }

  JSValue image_data = JS_NewObject(ctx);
  JS_DefinePropertyValueStr(ctx, image_data, "width", JS_NewInt32(ctx, width), JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, image_data, "height", JS_NewInt32(ctx, height), JS_PROP_C_W_E);
  JS_DefinePropertyValueStr(ctx, image_data, "data", data, JS_PROP_C_W_E);

  ScriptValue result(ctx, image_data);
  JS_FreeValue(ctx, image_data);
  return result;
}

// Extract width/height from an ImageData-like object.
bool GetImageDataSize(JSContext* ctx, JSValue value, int32_t& width, int32_t& height) {
  width = 0;
  height = 0;
  if (!JS_IsObject(value)) {
    return false;
  }

  JSValue w = JS_GetPropertyStr(ctx, value, "width");
  JSValue h = JS_GetPropertyStr(ctx, value, "height");
  bool ok = true;
  if (!JS_IsUndefined(w) && !JS_IsNull(w)) {
    JS_ToInt32(ctx, &width, w);
  } else {
    ok = false;
  }
  if (!JS_IsUndefined(h) && !JS_IsNull(h)) {
    JS_ToInt32(ctx, &height, h);
  } else {
    ok = false;
  }
  JS_FreeValue(ctx, w);
  JS_FreeValue(ctx, h);
  return ok && width > 0 && height > 0;
}

// Extract underlying byte buffer from ImageData.data (ArrayBuffer or TypedArray).
// Returns a NativeValue that wraps NativeByteData so Dart receives a NativeByteData object.
NativeValue ExtractImageDataBytes(JSContext* ctx,
                                  JSValue image_data_value,
                                  size_t& out_byte_length,
                                  ExceptionState& exception_state) {
  out_byte_length = 0;

  if (!JS_IsObject(image_data_value)) {
    exception_state.ThrowException(ctx, ErrorType::TypeError, "ImageData object expected.");
    return Native_NewNull();
  }

  JSValue data = JS_GetPropertyStr(ctx, image_data_value, "data");
  if (JS_IsException(data)) {
    exception_state.ThrowException(ctx, data);
    return Native_NewNull();
  }

  uint8_t* bytes = nullptr;
  size_t byte_length = 0;

  if (JS_IsArrayBuffer(data)) {
    bytes = JS_GetArrayBuffer(ctx, &byte_length, data);
    if (bytes == nullptr) {
      JS_FreeValue(ctx, data);
      exception_state.ThrowException(ctx, ErrorType::TypeError,
                                     "Failed to read ImageData.data ArrayBuffer.");
      return Native_NewNull();
    }
    NativeValue native_bytes =
        NativeValueConverter<NativeTypePointer<uint8_t>>::ToNativeValue(ctx, data, bytes, byte_length);
    out_byte_length = byte_length;
    JS_FreeValue(ctx, data);
    return native_bytes;
  }

  if (JS_IsArrayBufferView(data)) {
    size_t byte_offset = 0;
    size_t byte_per_element = 0;
    JSValue array_buffer_obj = JS_GetTypedArrayBuffer(ctx, data, &byte_offset, &byte_length, &byte_per_element);
    if (JS_IsException(array_buffer_obj)) {
      JS_FreeValue(ctx, data);
      exception_state.ThrowException(ctx, array_buffer_obj);
      return Native_NewNull();
    }

    size_t total_length = 0;
    uint8_t* base = JS_GetArrayBuffer(ctx, &total_length, array_buffer_obj);
    if (base == nullptr || byte_offset + byte_length > total_length) {
      JS_FreeValue(ctx, array_buffer_obj);
      JS_FreeValue(ctx, data);
      exception_state.ThrowException(ctx, ErrorType::TypeError, "Invalid ImageData.data view.");
      return Native_NewNull();
    }

    bytes = base + byte_offset;
    NativeValue native_bytes =
        NativeValueConverter<NativeTypePointer<uint8_t>>::ToNativeValue(ctx, array_buffer_obj, bytes, byte_length);
    out_byte_length = byte_length;
    JS_FreeValue(ctx, array_buffer_obj);
    JS_FreeValue(ctx, data);
    return native_bytes;
  }

  JS_FreeValue(ctx, data);
  exception_state.ThrowException(ctx, ErrorType::TypeError,
                                 "ImageData.data must be an ArrayBuffer or TypedArray.");
  return Native_NewNull();
}

}  // namespace

ScriptValue CanvasRenderingContext2D::createImageData(double sw, double sh, ExceptionState& exception_state) {
  JSContext* js_ctx = ctx();
  int32_t width = static_cast<int32_t>(sw);
  int32_t height = static_cast<int32_t>(sh);
  if (width <= 0 || height <= 0) {
    exception_state.ThrowException(js_ctx, ErrorType::RangeError,
                                   "createImageData: width and height must be positive.");
    return ScriptValue::Empty(js_ctx);
  }
  return CreateBlankImageDataObject(js_ctx, width, height, exception_state);
}

ScriptValue CanvasRenderingContext2D::createImageData(const ScriptValue& imagedata,
                                                      ExceptionState& exception_state) {
  JSContext* js_ctx = ctx();
  JSValue value = imagedata.QJSValue();
  int32_t width = 0;
  int32_t height = 0;
  if (!GetImageDataSize(js_ctx, value, width, height)) {
    exception_state.ThrowException(js_ctx, ErrorType::TypeError,
                                   "createImageData(ImageData): invalid source ImageData object.");
    return ScriptValue::Empty(js_ctx);
  }
  return CreateBlankImageDataObject(js_ctx, width, height, exception_state);
}

ScriptValue CanvasRenderingContext2D::getImageData(double sx,
                                                   double sy,
                                                   double sw,
                                                   double sh,
                                                   ExceptionState& exception_state) {
  JSContext* js_ctx = ctx();
  // NOTE: Full pixel readback would require a canvas snapshot from Dart.
  // For now, return a blank ImageData of the requested size.
  int32_t width = static_cast<int32_t>(sw);
  int32_t height = static_cast<int32_t>(sh);
  if (width <= 0 || height <= 0) {
    exception_state.ThrowException(js_ctx, ErrorType::RangeError,
                                   "getImageData: width and height must be positive.");
    return ScriptValue::Empty(js_ctx);
  }
  return CreateBlankImageDataObject(js_ctx, width, height, exception_state);
}

void CanvasRenderingContext2D::putImageData(const ScriptValue& imagedata,
                                            double dx,
                                            double dy,
                                            ExceptionState& exception_state) {
  putImageData(imagedata, dx, dy, 0.0, 0.0, std::numeric_limits<double>::quiet_NaN(),
               std::numeric_limits<double>::quiet_NaN(), exception_state);
}

void CanvasRenderingContext2D::putImageData(const ScriptValue& imagedata,
                                            double dx,
                                            double dy,
                                            double dirtyX,
                                            ExceptionState& exception_state) {
  putImageData(imagedata, dx, dy, dirtyX, 0.0, std::numeric_limits<double>::quiet_NaN(),
               std::numeric_limits<double>::quiet_NaN(), exception_state);
}

void CanvasRenderingContext2D::putImageData(const ScriptValue& imagedata,
                                            double dx,
                                            double dy,
                                            double dirtyX,
                                            double dirtyY,
                                            ExceptionState& exception_state) {
  putImageData(imagedata, dx, dy, dirtyX, dirtyY, std::numeric_limits<double>::quiet_NaN(),
               std::numeric_limits<double>::quiet_NaN(), exception_state);
}

void CanvasRenderingContext2D::putImageData(const ScriptValue& imagedata,
                                            double dx,
                                            double dy,
                                            double dirtyX,
                                            double dirtyY,
                                            double dirtyWidth,
                                            ExceptionState& exception_state) {
  putImageData(imagedata, dx, dy, dirtyX, dirtyY, dirtyWidth, std::numeric_limits<double>::quiet_NaN(),
               exception_state);
}

void CanvasRenderingContext2D::putImageData(const ScriptValue& imagedata,
                                            double dx,
                                            double dy,
                                            double dirtyX,
                                            double dirtyY,
                                            double dirtyWidth,
                                            double dirtyHeight,
                                            ExceptionState& exception_state) {
  JSContext* js_ctx = ctx();
  JSValue image_data_value = imagedata.QJSValue();

  int32_t width = 0;
  int32_t height = 0;
  if (!GetImageDataSize(js_ctx, image_data_value, width, height)) {
    exception_state.ThrowException(js_ctx, ErrorType::TypeError,
                                   "putImageData: invalid ImageData object.");
    return;
  }

  size_t byte_length = 0;
  NativeValue bytes_native = ExtractImageDataBytes(js_ctx, image_data_value, byte_length, exception_state);
  if (exception_state.HasException() || byte_length == 0) {
    return;
  }

  // Normalize dirty rectangle defaults according to the spec:
  // dirtyX/Y default to 0; dirtyWidth/Height default to image width/height.
  double local_dirtyX = dirtyX;
  double local_dirtyY = dirtyY;
  double local_dirtyWidth = std::isnan(dirtyWidth) ? static_cast<double>(width) : dirtyWidth;
  double local_dirtyHeight = std::isnan(dirtyHeight) ? static_cast<double>(height) : dirtyHeight;

  NativeValue arguments[] = {
      bytes_native,
      NativeValueConverter<NativeTypeInt64>::ToNativeValue(width),
      NativeValueConverter<NativeTypeInt64>::ToNativeValue(height),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(local_dirtyX),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(local_dirtyY),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(local_dirtyWidth),
      NativeValueConverter<NativeTypeDouble>::ToNativeValue(local_dirtyHeight),
  };

  InvokeBindingMethodAsync(binding_call_methods::kputImageData, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
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

std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern> CanvasRenderingContext2D::strokeStyle() {
  return stroke_style_;
}

std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern> CanvasRenderingContext2D::fillStyle() {
  return fill_style_;
}

void CanvasRenderingContext2D::setFillStyle(
    const std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern>& style,
    ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  } else if (style->IsCanvasPattern()) {
    value = NativeValueConverter<NativeTypePointer<CanvasPattern>>::ToNativeValue(style->GetAsCanvasPattern());
  }
  SetBindingPropertyAsync(binding_call_methods::kfillStyle, value, exception_state);

  fill_style_ = style;
}

double CanvasRenderingContext2D::globalAlpha() {
  if (global_alpha_cache_.has_value())
    return global_alpha_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kglobalAlpha,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(result);
}

void CanvasRenderingContext2D::setGlobalAlpha(double global_alpha, ExceptionState& exception_state) {
  global_alpha_cache_ = global_alpha;
  SetBindingPropertyAsync(binding_call_methods::kglobalAlpha,
                          NativeValueConverter<NativeTypeDouble>::ToNativeValue(global_alpha), exception_state);
}

AtomicString CanvasRenderingContext2D::globalCompositeOperation() {
  if (global_composite_operation_cache_.has_value())
    return global_composite_operation_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kglobalCompositeOperation,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setGlobalCompositeOperation(const AtomicString& global_composite_operation,
                                                           ExceptionState& exception_state) {
  global_composite_operation_cache_ = global_composite_operation;
  SetBindingPropertyAsync(binding_call_methods::kglobalCompositeOperation,
                          NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), global_composite_operation),
                          exception_state);
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

double CanvasRenderingContext2D::shadowOffsetX() {
  if (shadow_offset_x_cache_.has_value())
    return shadow_offset_x_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kshadowOffsetX,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(result);
}

void CanvasRenderingContext2D::setShadowOffsetX(double shadow_offset_x, ExceptionState& exception_state) {
  shadow_offset_x_cache_ = shadow_offset_x;
  SetBindingPropertyAsync(binding_call_methods::kshadowOffsetX,
                          NativeValueConverter<NativeTypeDouble>::ToNativeValue(shadow_offset_x), exception_state);
}

double CanvasRenderingContext2D::shadowOffsetY() {
  if (shadow_offset_y_cache_.has_value())
    return shadow_offset_y_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kshadowOffsetY,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(result);
}

void CanvasRenderingContext2D::setShadowOffsetY(double shadow_offset_y, ExceptionState& exception_state) {
  shadow_offset_y_cache_ = shadow_offset_y;
  SetBindingPropertyAsync(binding_call_methods::kshadowOffsetY,
                          NativeValueConverter<NativeTypeDouble>::ToNativeValue(shadow_offset_y), exception_state);
}

double CanvasRenderingContext2D::shadowBlur() {
  if (shadow_blur_cache_.has_value())
    return shadow_blur_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kshadowBlur,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeDouble>::FromNativeValue(result);
}

void CanvasRenderingContext2D::setShadowBlur(double shadow_blur, ExceptionState& exception_state) {
  shadow_blur_cache_ = shadow_blur;
  SetBindingPropertyAsync(binding_call_methods::kshadowBlur,
                          NativeValueConverter<NativeTypeDouble>::ToNativeValue(shadow_blur), exception_state);
}

AtomicString CanvasRenderingContext2D::shadowColor() {
  if (shadow_color_cache_.has_value())
    return shadow_color_cache_.value();
  NativeValue result = GetBindingProperty(binding_call_methods::kshadowColor,
                                          FlushUICommandReason::kDependentsOnElement, ASSERT_NO_EXCEPTION());
  return NativeValueConverter<NativeTypeString>::FromNativeValue(std::move(result));
}

void CanvasRenderingContext2D::setShadowColor(const AtomicString& shadow_color, ExceptionState& exception_state) {
  shadow_color_cache_ = shadow_color;
  SetBindingPropertyAsync(binding_call_methods::kshadowColor,
                          NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), shadow_color), exception_state);
}

void CanvasRenderingContext2D::setStrokeStyle(
    const std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern>& style,
    ExceptionState& exception_state) {
  NativeValue value = Native_NewNull();

  if (style->IsDomString()) {
    value = NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), style->GetAsDomString());
  } else if (style->IsCanvasGradient()) {
    value = NativeValueConverter<NativeTypePointer<CanvasGradient>>::ToNativeValue(style->GetAsCanvasGradient());
  } else if (style->IsCanvasPattern()) {
    value = NativeValueConverter<NativeTypePointer<CanvasPattern>>::ToNativeValue(style->GetAsCanvasPattern());
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


bool CanvasRenderingContext2D::isPointInPath(std::shared_ptr<const QJSUnionPath2DDouble> $1,
                                             double $2,
                                             ExceptionState &exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue($1->GetAsDouble()),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue($2)};
  NativeValue result = InvokeBindingMethod(AtomicString::CreateFromUTF8("isPointInPath"),
                                           sizeof(arguments) / sizeof(NativeValue), arguments,
                                           FlushUICommandReason::kStandard, exception_state);
  if (exception_state.HasException()) {
    return false;
  }
  bool value = NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
  return value;
}

bool CanvasRenderingContext2D::isPointInPath(std::shared_ptr<const QJSUnionPath2DDouble> $1,
                                             double $2,
                                             std::shared_ptr<const QJSUnionDomStringDouble> $3,
                                             ExceptionState &exception_state) {
  bool result = isPointInPath($1, $2, $3, AtomicString::CreateFromUTF8("nonzero"), exception_state);
  return result;
}

bool CanvasRenderingContext2D::isPointInPath(std::shared_ptr<const QJSUnionPath2DDouble> $1,
                                             double $2,
                                             std::shared_ptr<const QJSUnionDomStringDouble> $3,
                                             const AtomicString& fillRule,
                                             ExceptionState& exception_state) {
  if ($1->IsPath2D()) {
    NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue($1->GetAsPath2D()),
                               NativeValueConverter<NativeTypeDouble>::ToNativeValue($2),
                               NativeValueConverter<NativeTypeDouble>::ToNativeValue($3->GetAsDouble()),
                               NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), fillRule)};
    NativeValue result = InvokeBindingMethod(AtomicString::CreateFromUTF8("isPointInPath"),
                                             sizeof(arguments) / sizeof(NativeValue), arguments,
                                             FlushUICommandReason::kStandard, exception_state);
    if (exception_state.HasException()) {
      return false;
    }
    bool value = NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
    return value;
  } else {
    NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue($1->GetAsDouble()),
                               NativeValueConverter<NativeTypeDouble>::ToNativeValue($2),
                               NativeValueConverter<NativeTypeString>::ToNativeValue(ctx(), $3->GetAsDomString())};
    NativeValue result = InvokeBindingMethod(AtomicString::CreateFromUTF8("isPointInPath"),
                                             sizeof(arguments) / sizeof(NativeValue), arguments,
                                             FlushUICommandReason::kStandard, exception_state);
    bool value = NativeValueConverter<NativeTypeBool>::FromNativeValue(result);

    if (exception_state.HasException()) {
      return false;
    }

    return value;
  }
}

bool CanvasRenderingContext2D::isPointInStroke(double x,
                                               double y,
                                               ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  NativeValue result = InvokeBindingMethod(AtomicString::CreateFromUTF8("isPointInStroke"),
                                           sizeof(arguments) / sizeof(NativeValue), arguments,
                                           FlushUICommandReason::kStandard, exception_state);
  if (exception_state.HasException()) {
    return false;
  }
  bool value = NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
  return value;
}

bool CanvasRenderingContext2D::isPointInStroke(Path2D* path,
                                               double x,
                                               double y,
                                               ExceptionState& exception_state) {
  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<Path2D>>::ToNativeValue(path),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(x),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(y)};
  NativeValue result = InvokeBindingMethod(AtomicString::CreateFromUTF8("isPointInStroke"),
                                           sizeof(arguments) / sizeof(NativeValue), arguments,
                                           FlushUICommandReason::kStandard, exception_state);
  if (exception_state.HasException()) {
    return false;
  }
  bool value = NativeValueConverter<NativeTypeBool>::FromNativeValue(result);
  return value;
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

namespace {

struct ResolvedImageSource {
  HTMLImageElement* image_element = nullptr;
  ImageBitmap* bitmap = nullptr;
};

ResolvedImageSource ResolveImageSource(const std::shared_ptr<QJSUnionHTMLImageElementImageBitmap>& source) {
  ResolvedImageSource result;
  if (source == nullptr)
    return result;

  if (source->IsHTMLImageElement()) {
    result.image_element = source->GetAsHTMLImageElement();
    return result;
  }

  if (source->IsImageBitmap()) {
    result.bitmap = source->GetAsImageBitmap();
    if (result.bitmap != nullptr) {
      result.image_element = result.bitmap->sourceImageElement();
    }
  }

  return result;
}

}  // namespace

void CanvasRenderingContext2D::drawImage(const std::shared_ptr<QJSUnionHTMLImageElementImageBitmap>& image,
                                         double dx,
                                         double dy,
                                         ExceptionState& exception_state) {
  ResolvedImageSource resolved = ResolveImageSource(image);
  if (resolved.image_element == nullptr)
    return;

  // If the source is an ImageBitmap with a valid crop rect and intrinsic
  // size, emulate drawImage(imageBitmap, dx, dy) by forwarding the stored
  // crop rectangle to the 9-argument drawImage implementation.
  if (resolved.bitmap != nullptr && resolved.bitmap->sw() > 0 && resolved.bitmap->sh() > 0 &&
      resolved.bitmap->width() > 0 && resolved.bitmap->height() > 0) {
    NativeValue arguments[] = {
        NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(resolved.image_element),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sx()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sy()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sw()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sh()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->width()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->height())};
    InvokeBindingMethodAsync(binding_call_methods::kdrawImage, sizeof(arguments) / sizeof(NativeValue), arguments,
                             exception_state);
    return;
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(
                                 resolved.image_element),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy)};
  InvokeBindingMethodAsync(binding_call_methods::kdrawImage, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::drawImage(const std::shared_ptr<QJSUnionHTMLImageElementImageBitmap>& image,
                                         double dx,
                                         double dy,
                                         double dw,
                                         double dh,
                                         ExceptionState& exception_state) {
  ResolvedImageSource resolved = ResolveImageSource(image);
  if (resolved.image_element == nullptr)
    return;

  if (resolved.bitmap != nullptr && resolved.bitmap->sw() > 0 && resolved.bitmap->sh() > 0) {
    NativeValue arguments[] = {
        NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(resolved.image_element),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sx()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sy()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sw()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(resolved.bitmap->sh()),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(dw),
        NativeValueConverter<NativeTypeDouble>::ToNativeValue(dh)};
    InvokeBindingMethodAsync(binding_call_methods::kdrawImage, sizeof(arguments) / sizeof(NativeValue), arguments,
                             exception_state);
    return;
  }

  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(
                                 resolved.image_element),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dx),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dy),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dw),
                             NativeValueConverter<NativeTypeDouble>::ToNativeValue(dh)};
  InvokeBindingMethodAsync(binding_call_methods::kdrawImage, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

void CanvasRenderingContext2D::drawImage(const std::shared_ptr<QJSUnionHTMLImageElementImageBitmap>& image,
                                         double sx,
                                         double sy,
                                         double sw,
                                         double sh,
                                         double dx,
                                         double dy,
                                         double dw,
                                         double dh,
                                         ExceptionState& exception_state) {
  ResolvedImageSource resolved = ResolveImageSource(image);
  if (resolved.image_element == nullptr)
    return;

  NativeValue arguments[] = {NativeValueConverter<NativeTypePointer<HTMLImageElement>>::ToNativeValue(
                                 resolved.image_element),
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

void CanvasRenderingContext2D::setLineDash(const std::vector<double>& segments, ExceptionState& exception_state) {
  line_dash_segments_ = segments;
  NativeValue arguments[] = {
      NativeValueConverter<NativeTypeArray<NativeTypeDouble>>::ToNativeValue(segments),
  };
  InvokeBindingMethodAsync(binding_call_methods::ksetLineDash, sizeof(arguments) / sizeof(NativeValue), arguments,
                           exception_state);
}

std::vector<double> CanvasRenderingContext2D::getLineDash(ExceptionState& exception_state) {
  return line_dash_segments_;
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
  _needsPaint = false;
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kRequestCanvasPaint, nullptr, bindingObject(), nullptr, true);
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
  global_alpha_cache_.reset();
  global_composite_operation_cache_.reset();
  line_dash_segments_.clear();
  direction_cache_.reset();
  font_cache_.reset();
  line_cap_cache_.reset();
  line_dash_offset_cache_.reset();
  line_join_cache_.reset();
  line_width_cache_.reset();
  miter_limit_cache_.reset();
  text_align_cache_.reset();
  text_baseline_cache_.reset();
  shadow_offset_x_cache_.reset();
  shadow_offset_y_cache_.reset();
  shadow_blur_cache_.reset();
  shadow_color_cache_.reset();
}

}  // namespace webf
