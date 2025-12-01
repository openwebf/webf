/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_
#define BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_

#include <optional>

#include "bindings/qjs/script_value.h"
#include "canvas_gradient.h"
#include "canvas_pattern.h"
#include "canvas_rendering_context.h"
#include "path_2d.h"
#include "qjs_union_dom_stringcanvas_gradientcanvas_pattern.h"
#include "qjs_unionhtml_image_elementhtml_canvas_element.h"
#include "qjs_unionpath_2_d_dom_string.h"
#include "qjs_unionpath_2_d_double.h"
#include "qjs_union_dom_string_double.h"
#include "qjs_unionhtml_image_elementimage_bitmap.h"
#include "text_metrics.h"

namespace webf {

class HTMLImageElement;

class CanvasRenderingContext2D : public CanvasRenderingContext {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = CanvasRenderingContext2D*;
  CanvasRenderingContext2D() = delete;
  explicit CanvasRenderingContext2D(ExecutingContext* context, NativeBindingObject* native_binding_object);
  ~CanvasRenderingContext2D();

  NativeValue HandleCallFromDartSide(const AtomicString& method,
                                     int32_t argc,
                                     const NativeValue* argv,
                                     Dart_Handle dart_object) override;
  CanvasGradient* createLinearGradient(double x0,
                                       double y0,
                                       double x1,
                                       double y1,
                                       ExceptionState& exception_state) const;
  CanvasGradient* createRadialGradient(double x0,
                                       double y0,
                                       double r0,
                                       double x1,
                                       double y1,
                                       double r1,
                                       ExceptionState& exception_state) const;
  CanvasPattern* createPattern(const std::shared_ptr<QJSUnionHTMLImageElementHTMLCanvasElement>& init,
                               const AtomicString& repetition,
                               ExceptionState& exception_state);
  std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern> fillStyle();
  void setFillStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern>& style,
                    ExceptionState& exception_state);

  double globalAlpha();
  void setGlobalAlpha(double global_alpha, ExceptionState& exception_state);
  AtomicString globalCompositeOperation();
  void setGlobalCompositeOperation(const AtomicString& global_composite_operation,
                                   ExceptionState& exception_state);

  AtomicString direction();
  void setDirection(const AtomicString& direction, ExceptionState& exception_state);
  AtomicString font();
  void setFont(const AtomicString& font, ExceptionState& exception_state);
  AtomicString lineCap();
  void setLineCap(const AtomicString& line_cap, ExceptionState& exception_state);
  double lineDashOffset();
  void setLineDashOffset(double line_dash_offset, ExceptionState& exception_state);
  AtomicString lineJoin();
  void setLineJoin(const AtomicString& line_join, ExceptionState& exception_state);
  double lineWidth();
  void setLineWidth(double line_width, ExceptionState& exception_state);
  double miterLimit();
  void setMiterLimit(double miter_limit, ExceptionState& exception_state);
  AtomicString textAlign();
  void setTextAlign(const AtomicString& text_align, ExceptionState& exception_state);
  AtomicString textBaseline();
  void setTextBaseline(const AtomicString& text_baseline, ExceptionState& exception_state);
  double shadowOffsetX();
  void setShadowOffsetX(double shadow_offset_x, ExceptionState& exception_state);
  double shadowOffsetY();
  void setShadowOffsetY(double shadow_offset_y, ExceptionState& exception_state);
  double shadowBlur();
  void setShadowBlur(double shadow_blur, ExceptionState& exception_state);
  AtomicString shadowColor();
  void setShadowColor(const AtomicString& shadow_color, ExceptionState& exception_state);
  bool IsCanvas2d() const override;

  // ImageData APIs implemented purely on the C++ side.
  ScriptValue createImageData(double sw, double sh, ExceptionState& exception_state);
  ScriptValue createImageData(const ScriptValue& imagedata, ExceptionState& exception_state);
  ScriptValue getImageData(double sx, double sy, double sw, double sh, ExceptionState& exception_state);
  void putImageData(const ScriptValue& imagedata, double dx, double dy, ExceptionState& exception_state);
  void putImageData(const ScriptValue& imagedata,
                    double dx,
                    double dy,
                    double dirtyX,
                    ExceptionState& exception_state);
  void putImageData(const ScriptValue& imagedata,
                    double dx,
                    double dy,
                    double dirtyX,
                    double dirtyY,
                    ExceptionState& exception_state);
  void putImageData(const ScriptValue& imagedata,
                    double dx,
                    double dy,
                    double dirtyX,
                    double dirtyY,
                    double dirtyWidth,
                    ExceptionState& exception_state);
  void putImageData(const ScriptValue& imagedata,
                    double dx,
                    double dy,
                    double dirtyX,
                    double dirtyY,
                    double dirtyWidth,
                    double dirtyHeight,
                    ExceptionState& exception_state);

  void fill(ExceptionState& exception_state);
  void fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern, ExceptionState& exception_state);
  void fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
            const AtomicString& fillRule,
            ExceptionState& exception_state);
  std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern> strokeStyle();
  void setStrokeStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern>& style,
                      ExceptionState& exception_state);

  TextMetrics* measureText(const AtomicString& text, ExceptionState& exception_state);
  bool isPointInPath(std::shared_ptr<const QJSUnionPath2DDouble> $1,
                     double $2,
                     ExceptionState &exception_state);
  bool isPointInPath(std::shared_ptr<const QJSUnionPath2DDouble> $1,
                     double $2,
                     std::shared_ptr<const QJSUnionDomStringDouble> $3,
                     ExceptionState &exception_state);
  bool isPointInPath(std::shared_ptr<const QJSUnionPath2DDouble> $1,
                     double $2,
                     std::shared_ptr<const QJSUnionDomStringDouble> $3,
                     const AtomicString &fillRule,
                     ExceptionState &exception_state);
  bool isPointInStroke(double x, double y, ExceptionState& exception_state);
  bool isPointInStroke(Path2D* path, double x, double y, ExceptionState& exception_state);
  void arc(double x,
           double y,
           double radius,
           double startAngle,
           double endAngle,
           ExceptionState& exception_state);
  void arc(double x,
           double y,
           double radius,
           double startAngle,
           double endAngle,
           bool anticlockwise,
           ExceptionState& exception_state);
  void arcTo(double x1, double y1, double x2, double y2, double radius, ExceptionState& exception_state);
  void beginPath(ExceptionState& exception_state);
  void bezierCurveTo(double cp1x,
                     double cp1y,
                     double cp2x,
                     double cp2y,
                     double x,
                     double y,
                     ExceptionState& exception_state);
  void clearRect(double x, double y, double w, double h, ExceptionState& exception_state);
  void closePath(ExceptionState& exception_state);
  void clip(ExceptionState& exception_state);
  void clip(Path2D* path, ExceptionState& exception_state);
  void clip(Path2D* path, const AtomicString& fillRule, ExceptionState& exception_state);
  void drawImage(const std::shared_ptr<QJSUnionHTMLImageElementImageBitmap>& image,
                 double dx,
                 double dy,
                 ExceptionState& exception_state);
  void drawImage(const std::shared_ptr<QJSUnionHTMLImageElementImageBitmap>& image,
                 double dx,
                 double dy,
                 double dw,
                 double dh,
                 ExceptionState& exception_state);
  void drawImage(const std::shared_ptr<QJSUnionHTMLImageElementImageBitmap>& image,
                 double sx,
                 double sy,
                 double sw,
                 double sh,
                 double dx,
                 double dy,
                 double dw,
                 double dh,
                 ExceptionState& exception_state);
  void ellipse(double x,
               double y,
               double radiusX,
               double radiusY,
               double rotation,
               double startAngle,
               double endAngle,
               ExceptionState& exception_state);
  void ellipse(double x,
               double y,
               double radiusX,
               double radiusY,
               double rotation,
               double startAngle,
               double endAngle,
               bool anticlockwise,
               ExceptionState& exception_state);
  void fillRect(double x, double y, double w, double h, ExceptionState& exception_state);
  void fillText(const AtomicString& text, double x, double y, ExceptionState& exception_state);
  void fillText(const AtomicString& text, double x, double y, double maxWidth, ExceptionState& exception_state);
  void setLineDash(const std::vector<double>& segments, ExceptionState& exception_state);
  std::vector<double> getLineDash(ExceptionState& exception_state);
  void lineTo(double x, double y, ExceptionState& exception_state);
  void moveTo(double x, double y, ExceptionState& exception_state);
  void rect(double x, double y, double w, double h, ExceptionState& exception_state);
  void restore(ExceptionState& exception_state);
  void resetTransform(ExceptionState& exception_state);
  void rotate(double angle, ExceptionState& exception_state);
  void quadraticCurveTo(double cpx, double cpy, double x, double y, ExceptionState& exception_state);
  void stroke(ExceptionState& exception_state);
  void stroke(Path2D* path, ExceptionState& exception_state);
  void strokeRect(double x, double y, double w, double h, ExceptionState& exception_state);
  void save(ExceptionState& exception_state);
  void scale(double x, double y, ExceptionState& exception_state);
  void strokeText(const AtomicString& text, double x, double y, ExceptionState& exception_state);
  void strokeText(const AtomicString& text, double x, double y, double maxWidth, ExceptionState& exception_state);
  void setTransform(double a, double b, double c, double d, double e, double f, ExceptionState& exception_state);
  void transform(double a, double b, double c, double d, double e, double f, ExceptionState& exception_state);
  void translate(double x, double y, ExceptionState& exception_state);
  void reset(ExceptionState& exception_state);

  void roundRect(double x,
                 double y,
                 double w,
                 double h,
                 std::shared_ptr<const QJSUnionDoubleSequenceDouble> radii,
                 ExceptionState& exception_state);

 void roundRect_async(double x,
                       double y,
                       double w,
                       double h,
                       std::shared_ptr<const QJSUnionDoubleSequenceDouble> radii,
                       ExceptionState& exception_state);

  bool IsCanvasRenderingContext2D() const override;

  void requestPaint() const;
  void needsPaint() const;

  void Trace(GCVisitor* visitor) const override;

 private:
  void ClearPropertyCaches();

  mutable bool _needsPaint = false;
  std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern> fill_style_ = nullptr;
  std::shared_ptr<QJSUnionDomStringCanvasGradientCanvasPattern> stroke_style_ = nullptr;
  std::vector<double> line_dash_segments_;
  std::optional<double> global_alpha_cache_;
  std::optional<AtomicString> global_composite_operation_cache_;
  std::optional<AtomicString> direction_cache_;
  std::optional<AtomicString> font_cache_;
  std::optional<AtomicString> line_cap_cache_;
  std::optional<double> line_dash_offset_cache_;
  std::optional<AtomicString> line_join_cache_;
  std::optional<double> line_width_cache_;
  std::optional<double> miter_limit_cache_;
  std::optional<AtomicString> text_align_cache_;
  std::optional<AtomicString> text_baseline_cache_;
  std::optional<double> shadow_offset_x_cache_;
  std::optional<double> shadow_offset_y_cache_;
  std::optional<double> shadow_blur_cache_;
  std::optional<AtomicString> shadow_color_cache_;
};

template <>
struct DowncastTraits<CanvasRenderingContext2D> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsCanvasRenderingContext2D(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_
