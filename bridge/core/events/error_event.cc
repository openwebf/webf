/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "error_event.h"
#include "event_type_names.h"

namespace webf {

ErrorEvent* ErrorEvent::Create(ExecutingContext* context, const std::string& message) {
  return MakeGarbageCollected<ErrorEvent>(context, message);
}
ErrorEvent* ErrorEvent::Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state) {
  return MakeGarbageCollected<ErrorEvent>(context, type, exception_state);
}
ErrorEvent* ErrorEvent::Create(ExecutingContext* context,
                               const AtomicString& type,
                               const std::shared_ptr<ErrorEventInit>& initializer,
                               ExceptionState& exception_state) {
  return MakeGarbageCollected<ErrorEvent>(context, type, initializer, exception_state);
}

ErrorEvent::ErrorEvent(ExecutingContext* context, const std::string& message)
    : Event(context, event_type_names::kerror),
      message_(message),
      source_location_(std::make_unique<SourceLocation>("", 0, 0)) {}

ErrorEvent::ErrorEvent(ExecutingContext* context, const std::string& message, std::unique_ptr<SourceLocation> location)
    : Event(context, event_type_names::kerror), message_(message), source_location_(std::move(location)) {}

ErrorEvent::ErrorEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state)
    : Event(context, event_type_names::kerror),
      message_(type.ToStdString(ctx())),
      source_location_(std::make_unique<SourceLocation>("", 0, 0)) {}

ErrorEvent::ErrorEvent(ExecutingContext* context,
                       const AtomicString& type,
                       const std::shared_ptr<ErrorEventInit>& initializer,
                       ExceptionState& exception_state)
    : Event(context, event_type_names::kerror),
      message_(initializer->hasMessage() ? type.ToStdString(ctx()) : ""),
      error_(initializer->hasError() ? initializer->error() : ScriptValue::Empty(ctx())),
      source_location_(
          std::make_unique<SourceLocation>(initializer->hasFilename() ? initializer->filename().ToStdString(ctx()) : "",
                                           initializer->lineno(),
                                           initializer->colno())) {}

bool ErrorEvent::IsErrorEvent() const {
  return true;
}

}  // namespace webf
