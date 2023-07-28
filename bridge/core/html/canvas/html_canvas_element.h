/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_
#define BRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_

#include <vector>
#include "canvas_rendering_context.h"
#include "core/html/html_element.h"

namespace webf {

class HTMLCanvasElement : public HTMLElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit HTMLCanvasElement(Document&);

  CanvasRenderingContext* getContext(const AtomicString& type, ExceptionState& exception_state);

  void Trace(GCVisitor* visitor) const override;

  std::vector<Member<CanvasRenderingContext>> running_context_2ds_;
};

}  // namespace webf

#endif  // BRIDGE_CORE_HTML_CANVAS_HTML_CANVAS_ELEMENT_H_
