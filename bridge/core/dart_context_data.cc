/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_context_data.h"

namespace webf {

const WidgetElementShape* DartContextData::GetWidgetElementShape(const AtomicString& key) {
  return widget_element_shapes_[key].get();
}

bool DartContextData::HasWidgetElementShape(const AtomicString& key) {
  return widget_element_shapes_.count(key) > 0;
}

void DartContextData::SetWidgetElementShape(const AtomicString& key, const std::shared_ptr<WidgetElementShape>& shape) {
  widget_element_shapes_[key] = shape;
}

}  // namespace webf