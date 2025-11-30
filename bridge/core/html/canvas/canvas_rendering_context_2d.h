/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_
#define BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_

#include <optional>

#include "canvas_gradient.h"
#include "canvas_pattern.h"
#include "canvas_rendering_context.h"
#include "path_2d.h"
#include "qjs_union_dom_stringcanvas_gradient.h"
#include "qjs_unionhtml_image_elementhtml_canvas_element.h"
#include "qjs_unionpath_2_d_dom_string.h"
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
  std::shared_ptr<QJSUnionDomStringCanvasGradient> fillStyle();
 void setFillStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style, ExceptionState& exception_state);

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
  bool IsCanvas2d() const override;

  void fill(ExceptionState& exception_state);
  void fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern, ExceptionState& exception_state);
  void fill(std::shared_ptr<const QJSUnionPath2DDomString> pathOrPattern,
            const AtomicString& fillRule,
            ExceptionState& exception_state);
  std::shared_ptr<QJSUnionDomStringCanvasGradient> strokeStyle();
  void setStrokeStyle(const std::shared_ptr<QJSUnionDomStringCanvasGradient>& style, ExceptionState& exception_state);

  TextMetrics* measureText(const AtomicString& text, ExceptionState& exception_state);
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
  void drawImage(HTMLImageElement* image, double dx, double dy, ExceptionState& exception_state);
  void drawImage(HTMLImageElement* image,
                 double dx,
                 double dy,
                 double dw,
                 double dh,
                 ExceptionState& exception_state);
  void drawImage(HTMLImageElement* image,
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
  std::shared_ptr<QJSUnionDomStringCanvasGradient> fill_style_ = nullptr;
  std::shared_ptr<QJSUnionDomStringCanvasGradient> stroke_style_ = nullptr;
  std::optional<AtomicString> direction_cache_;
  std::optional<AtomicString> font_cache_;
  std::optional<AtomicString> line_cap_cache_;
  std::optional<double> line_dash_offset_cache_;
  std::optional<AtomicString> line_join_cache_;
  std::optional<double> line_width_cache_;
  std::optional<double> miter_limit_cache_;
  std::optional<AtomicString> text_align_cache_;
  std::optional<AtomicString> text_baseline_cache_;
};

template <>
struct DowncastTraits<CanvasRenderingContext2D> {
  static bool AllowFrom(const BindingObject& binding_object) { return binding_object.IsCanvasRenderingContext2D(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_CANVAS_CANVAS_RENDERING_CONTEXT_2D_H_
