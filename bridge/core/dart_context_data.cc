/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "dart_context_data.h"

namespace webf {

const WidgetElementShape* DartContextData::GetWidgetElementShape(const std::string& key) {
  assert(widget_element_shapes_.count(key) > 0);
  std::unique_lock<std::mutex> lock(context_data_mutex_);
  return widget_element_shapes_[key].get();
}

bool DartContextData::HasWidgetElementShape(const std::string& key) {
  std::unique_lock<std::mutex> lock(context_data_mutex_);
  return widget_element_shapes_.count(key) > 0;
}

void DartContextData::SetWidgetElementShape(const std::string& key, const std::shared_ptr<WidgetElementShape>& shape) {
  std::unique_lock<std::mutex> lock(context_data_mutex_);
  widget_element_shapes_[key] = shape;
}

}  // namespace webf