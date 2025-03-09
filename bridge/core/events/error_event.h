/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_
#define BRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_

#include "plugin_api/error_event.h"
#include "bindings/qjs/dictionary_base.h"
#include "bindings/qjs/source_location.h"
#include "core/dom/events/event.h"
#include "qjs_error_event_init.h"

namespace webf {

class ErrorEvent : public Event {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = ErrorEvent*;
  static ErrorEvent* Create(ExecutingContext* context, const std::string& message);
  static ErrorEvent* Create(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  static ErrorEvent* Create(ExecutingContext* context,
                            const AtomicString& type,
                            const std::shared_ptr<ErrorEventInit>& initializer,
                            ExceptionState& exception_state);

  explicit ErrorEvent(ExecutingContext* context, const std::string& message);
  explicit ErrorEvent(ExecutingContext* context, const std::string& message, std::unique_ptr<SourceLocation> location);
  explicit ErrorEvent(ExecutingContext* context, const AtomicString& type, ExceptionState& exception_state);
  explicit ErrorEvent(ExecutingContext* context,
                      const AtomicString& type,
                      const std::shared_ptr<ErrorEventInit>& initializer,
                      ExceptionState& exception_state);

  // As |message| is exposed to JavaScript, never return |unsanitized_message_|.
  const std::string& message() const { return message_; }
  const std::string& filename() const { return source_location_->Url(); }
  unsigned lineno() const { return source_location_->LineNumber(); }
  unsigned colno() const { return source_location_->ColumnNumber(); }

  ScriptValue error() const { return error_; }

  SourceLocation* Location() const { return source_location_.get(); }

  bool IsErrorEvent() const override;

  const ErrorEventPublicMethods* errorEventPublicMethods();

 private:
  std::string message_;
  std::unique_ptr<SourceLocation> source_location_{nullptr};
  ScriptValue error_;
};

template <>
struct DowncastTraits<ErrorEvent> {
  static bool AllowFrom(const Event& event) { return event.IsErrorEvent(); }
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_EVENTS_ERROR_EVENT_H_
