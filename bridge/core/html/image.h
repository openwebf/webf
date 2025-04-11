/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_HTML_IMAGE_H_
#define WEBF_CORE_HTML_IMAGE_H_

#include "html_image_element.h"
#include "plugin_api/image.h"

namespace webf {

class Image : public HTMLImageElement {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static Image* Create(ExecutingContext* context, ExceptionState& exception_state);

  explicit Image(ExecutingContext* context, ExceptionState& exception_state);

  bool IsImage() const override { return true; }

  const ImagePublicMethods* imagePublicMethods() {
    static ImagePublicMethods image_public_methods;
    return &image_public_methods;
  }

 private:
};

template <>
struct DowncastTraits<Image> {
  static bool AllowFrom(const EventTarget& event_target) {
    return event_target.IsNode() && To<Node>(event_target).IsHTMLElement() &&
           To<HTMLElement>(event_target).tagName() == html_names::kimg && To<HTMLImageElement>(event_target).IsImage();
  }
};

}  // namespace webf

#endif  // WEBF_CORE_HTML_IMAGE_H_
