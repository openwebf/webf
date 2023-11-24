/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_SCREEN_H
#define BRIDGE_SCREEN_H

#include "core/dom/events/event_target.h"

namespace webf {

class Window;

struct ScreenData {
  int64_t availWidth;
  int64_t availHeight;
  int64_t width;
  int64_t height;
};

class Screen : public EventTargetWithInlineData {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = Screen*;
  explicit Screen(Window* window, NativeBindingObject* binding_object);

  [[nodiscard]] int64_t availWidth() const { return extra_->availWidth; }
  [[nodiscard]] int64_t availHeight() const { return extra_->availHeight; }
  [[nodiscard]] int64_t width() const { return extra_->width; }
  [[nodiscard]] int64_t height() const { return extra_->height; }

 private:
  ScreenData* extra_;
};

}  // namespace webf

#endif  // BRIDGE_SCREEN_H
