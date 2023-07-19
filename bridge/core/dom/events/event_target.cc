/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "event_target.h"
#include "include/dart_api.h"
#include <cstdint>
#include "binding_call_methods.h"
#include "bindings/qjs/converter_impl.h"
#include "event_factory.h"
#include "native_value_converter.h"
#include "qjs_add_event_listener_options.h"
#include "qjs_event_target.h"

#define PROPAGATION_STOPPED 1
#define PROPAGATION_CONTINUE 0

#if UNIT_TEST
#include "webf_test_env.h"
#endif

namespace webf {

struct EventDispatchResult : public DartReadable {
  bool canceled{false};
  bool propagationStopped{false};
};

struct DartEventListenerOptions : public DartReadable {
  bool capture{false};
};

struct DartAddEventListenerOptions : public DartEventListenerOptions {
  bool passive{false};
  bool once{false};
};

Event::PassiveMode EventPassiveMode(const RegisteredEventListener& event_listener) {
  if (!event_listener.Passive()) {
    return Event::PassiveMode::kNotPassiveDefault;
  }
  return Event::PassiveMode::kPassiveDefault;
}

// EventTargetData
EventTargetData::EventTargetData() {}

EventTargetData::~EventTargetData() {}

void EventTargetData::Trace(GCVisitor* visitor) const {
  event_listener_map.Trace(visitor);
  event_capture_listener_map.Trace(visitor);
}

EventTarget* EventTarget::Create(ExecutingContext* context, ExceptionState& exception_state) {
  return MakeGarbageCollected<EventTargetWithInlineData>(context);
}

EventTarget::~EventTarget() {
#if UNIT_TEST
  // Callback to unit test specs before eventTarget finalized.
  if (TEST_getEnv(GetExecutingContext()->uniqueId())->on_event_target_disposed != nullptr) {
    TEST_getEnv(GetExecutingContext()->uniqueId())->on_event_target_disposed(this);
  }
#endif
}

EventTarget::EventTarget(ExecutingContext* context) : BindingObject(context->ctx()) {}

EventTarget::EventTarget(ExecutingContext* context, NativeBindingObject* native_binding_object)
    : BindingObject(context->ctx(), native_binding_object) {}

Node* EventTarget::ToNode() {
  return nullptr;
}

bool EventTarget::addEventListener(const AtomicString& event_type,
                                   const std::shared_ptr<EventListener>& event_listener,
                                   const std::shared_ptr<QJSUnionAddEventListenerOptionsBoolean>& options,
                                   ExceptionState& exception_state) {
  std::shared_ptr<AddEventListenerOptions> event_listener_options;
  if (options == nullptr) {
    event_listener_options = AddEventListenerOptions::Create();
  } else {
    if (options->IsBoolean()) {
      event_listener_options = AddEventListenerOptions::Create();
      event_listener_options->setCapture(options->GetAsBoolean());
    } else if (options->IsAddEventListenerOptions()) {
      event_listener_options = options->GetAsAddEventListenerOptions();
    }
  }

  return AddEventListenerInternal(event_type, event_listener, event_listener_options);
}

bool EventTarget::addEventListener(const AtomicString& event_type,
                                   const std::shared_ptr<EventListener>& event_listener,
                                   ExceptionState& exception_state) {
  std::shared_ptr<AddEventListenerOptions> options = AddEventListenerOptions::Create();
  return AddEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::removeEventListener(const AtomicString& event_type,
                                      const std::shared_ptr<EventListener>& event_listener,
                                      ExceptionState& exception_state) {
  std::shared_ptr<EventListenerOptions> options = EventListenerOptions::Create();
  return RemoveEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::removeEventListener(const AtomicString& event_type,
                                      const std::shared_ptr<EventListener>& event_listener,
                                      const std::shared_ptr<QJSUnionEventListenerOptionsBoolean>& options,
                                      ExceptionState& exception_state) {
  std::shared_ptr<EventListenerOptions> event_listener_options;
  if (options->IsBoolean()) {
    event_listener_options = EventListenerOptions::Create();
    event_listener_options->setCapture(options->GetAsBoolean());
  } else {
    if (options->IsBoolean()) {
      event_listener_options = AddEventListenerOptions::Create();
      event_listener_options->setCapture(options->GetAsBoolean());
    } else if (options->IsEventListenerOptions()) {
      event_listener_options = options->GetAsEventListenerOptions();
    }
  }

  return RemoveEventListenerInternal(event_type, event_listener, event_listener_options);
}

bool EventTarget::removeEventListener(const AtomicString& event_type,
                                      const std::shared_ptr<EventListener>& event_listener,
                                      bool use_capture,
                                      ExceptionState& exception_state) {
  auto options = EventListenerOptions::Create();
  options->setCapture(use_capture);
  return RemoveEventListenerInternal(event_type, event_listener, options);
}

bool EventTarget::dispatchEvent(Event* event, ExceptionState& exception_state) {
  if (!event->WasInitialized()) {
    exception_state.ThrowException(event->ctx(), ErrorType::InternalError, "The event provided is uninitialized.");
    return false;
  }

  if (event->IsBeingDispatched()) {
    exception_state.ThrowException(event->ctx(), ErrorType::InternalError, "The event is already being dispatched.");
    return false;
  }

  if (!GetExecutingContext())
    return false;

  event->SetTrusted(false);

  // Return whether the event was cancelled or not to JS not that it
  // might have actually been default handled; so check only against
  // CanceledByEventHandler.
  return DispatchEventInternal(*event, exception_state) != DispatchEventResult::kCanceledByEventHandler;
}

DispatchEventResult EventTarget::FireEventListeners(Event& event, ExceptionState& exception_state) {
  assert(event.WasInitialized());

  EventTargetData* d = GetEventTargetData();
  if (!d)
    return DispatchEventResult::kNotCanceled;

  EventListenerVector* listeners_vector = d->event_listener_map.Find(event.type());

  bool fired_event_listeners = false;
  if (listeners_vector) {
    fired_event_listeners = FireEventListeners(event, d, *listeners_vector, exception_state);
  }

  // Only invoke the callback if event listeners were fired for this phase.
  if (fired_event_listeners) {
    event.DoneDispatchingEventAtCurrentTarget();
  }
  return GetDispatchEventResult(event);
}

DispatchEventResult EventTarget::FireEventListeners(Event& event, bool isCapture, ExceptionState& exception_state) {
  assert(event.WasInitialized());

  EventTargetData* d = GetEventTargetData();
  if (!d)
    return DispatchEventResult::kNotCanceled;

  EventListenerVector* listeners_vector;
  if (!isCapture)
    listeners_vector = d->event_listener_map.Find(event.type());
  else
    listeners_vector = d->event_capture_listener_map.Find(event.type());

  bool fired_event_listeners = false;
  if (listeners_vector) {
    fired_event_listeners = FireEventListeners(event, d, *listeners_vector, exception_state);
  }

  // Only invoke the callback if event listeners were fired for this phase.
  if (fired_event_listeners) {
    event.DoneDispatchingEventAtCurrentTarget();
  }
  return GetDispatchEventResult(event);
}

DispatchEventResult EventTarget::GetDispatchEventResult(const Event& event) {
  if (event.defaultPrevented())
    return DispatchEventResult::kCanceledByEventHandler;
  if (event.DefaultHandled())
    return DispatchEventResult::kCanceledByDefaultEventHandler;
  return DispatchEventResult::kNotCanceled;
}

bool EventTarget::SetAttributeEventListener(const AtomicString& event_type,
                                            const std::shared_ptr<EventListener>& listener,
                                            ExceptionState& exception_state) {
  RegisteredEventListener* registered_listener = GetAttributeRegisteredEventListener(event_type);
  if (!listener) {
    if (registered_listener)
      removeEventListener(event_type, registered_listener->Callback(), exception_state);
    return false;
  }
  if (registered_listener) {
    registered_listener->SetCallback(listener);
    return true;
  }
  return addEventListener(event_type, listener, exception_state);
}

std::shared_ptr<EventListener> EventTarget::GetAttributeEventListener(const AtomicString& event_type) {
  RegisteredEventListener* registered_listener = GetAttributeRegisteredEventListener(event_type);
  if (registered_listener)
    return registered_listener->Callback();
  return nullptr;
}

EventListenerVector* EventTarget::GetEventListeners(const AtomicString& event_type) {
  EventTargetData* data = GetEventTargetData();
  if (!data)
    return nullptr;
  return data->event_listener_map.Find(event_type);
}

bool EventTarget::IsEventTarget() const {
  return true;
}

void EventTarget::Trace(GCVisitor* visitor) const {
  ScriptWrappable::Trace(visitor);
  BindingObject::Trace(visitor);
}

bool EventTarget::AddEventListenerInternal(const AtomicString& event_type,
                                           const std::shared_ptr<EventListener>& listener,
                                           const std::shared_ptr<AddEventListenerOptions>& options) {
  if (!listener)
    return false;

  RegisteredEventListener registered_listener;
  uint32_t listener_count = 0;
  bool added;
  if (options->hasCapture() && options->capture())
    added = EnsureEventTargetData().event_capture_listener_map.Add(event_type, listener, options, &registered_listener,
                                                                   &listener_count);
  else
    added = EnsureEventTargetData().event_listener_map.Add(event_type, listener, options, &registered_listener,
                                                           &listener_count);

  if (added && listener_count == 1) {
    auto* listener_options = new DartAddEventListenerOptions{};
    if (options->hasOnce()) {
      listener_options->once = options->once();
    }
    if (options->hasCapture()) {
      listener_options->capture = options->capture();
    }
    if (options->hasPassive()) {
      listener_options->passive = options->passive();
    }

    GetExecutingContext()->uiCommandBuffer()->addCommand(
        UICommand::kAddEvent, std::move(event_type.ToNativeString(ctx())), bindingObject(), listener_options);
  }

  return added;
}

bool EventTarget::RemoveEventListenerInternal(const AtomicString& event_type,
                                              const std::shared_ptr<EventListener>& listener,
                                              const std::shared_ptr<EventListenerOptions>& options) {
  if (!listener)
    return false;

  EventTargetData* d = GetEventTargetData();
  if (!d)
    return false;

  size_t index_of_removed_listener;
  RegisteredEventListener registered_listener;

  uint32_t listener_count = UINT32_MAX;
  if (!d->event_listener_map.Remove(event_type, listener, options, &index_of_removed_listener, &registered_listener,
                                    &listener_count))
    return false;

  // Notify firing events planning to invoke the listener at 'index' that
  // they have one less listener to invoke.
  if (d->firing_event_iterators) {
    for (const auto& firing_iterator : *d->firing_event_iterators) {
      if (event_type != firing_iterator.event_type)
        continue;

      if (index_of_removed_listener >= firing_iterator.end)
        continue;

      --firing_iterator.end;
      // Note that when firing an event listener,
      // firingIterator.iterator indicates the next event listener
      // that would fire, not the currently firing event
      // listener. See EventTarget::fireEventListeners.
      if (index_of_removed_listener < firing_iterator.iterator)
        --firing_iterator.iterator;
    }
  }

  if (listener_count == 0) {
    bool has_capture = options->hasCapture() && options->capture();

    GetExecutingContext()->uiCommandBuffer()->addCommand(UICommand::kRemoveEvent,
                                                         std::move(event_type.ToNativeString(ctx())), bindingObject(),
                                                         has_capture ? (void*)0x01 : nullptr);
  }

  return true;
}

DispatchEventResult EventTarget::DispatchEventInternal(Event& event, ExceptionState& exception_state) {
  event.SetTarget(this);
  event.SetCurrentTarget(this);
  event.SetEventPhase(Event::kAtTarget);
  DispatchEventResult dispatch_result = FireEventListeners(event, exception_state);
  event.SetEventPhase(0);
  return dispatch_result;
}

NativeValue EventTarget::HandleCallFromDartSide(const AtomicString& method,
                                                int32_t argc,
                                                const NativeValue* argv,
                                                Dart_Handle dart_object) {
   if (!isContextValid(contextId()))
      return Native_NewNull();M
  emberMutationScope mutation_scope{GetExecutingContext()};

  if (method == binding_call_methods::kdispatchEvent) {
    return HandleDispatchEventFromDart(argc, argv, dart_object);
  }

  return Native_NewNull();
}

NativeValue EventTarget::HandleDispatchEventFromDart(int32_t argc, const NativeValue* argv, Dart_Handle dart_object) {
  assert(argc >= 2);
  NativeValue native_event_type = argv[0];
  NativeValue native_is_capture = argv[2];
  bool isCapture = NativeValueConverter<NativeTypeBool>::FromNativeValue(native_is_capture);
  AtomicString event_type =
      NativeValueConverter<NativeTypeString>::FromNativeValue(ctx(), std::move(native_event_type));
  RawEvent* raw_event = NativeValueConverter<NativeTypePointer<RawEvent>>::FromNativeValue(argv[1]);

  Event* event = EventFactory::Create(GetExecutingContext(), event_type, raw_event);
  ExceptionState exception_state;
  event->SetTrusted(false);
  event->SetEventPhase(Event::kAtTarget);
  DispatchEventResult dispatch_result = FireEventListeners(*event, isCapture, exception_state);
  event->SetEventPhase(0);

  auto* wire = new DartWireContext();
  wire->jsObject = event->ToValue();

  auto dart_object_finalize_callback = [](void* isolate_callback_data, void* peer) {
    auto* wire = (DartWireContext*)(peer);
    if (IsDartWireAlive(wire)) {
      DeleteDartWire(wire);
    }
  };

  WatchDartWire(wire);
  Dart_NewFinalizableHandle_DL(dart_object, reinterpret_cast<void*>(wire),
                               sizeof(DartWireContext), dart_object_finalize_callback);

  if (exception_state.HasException()) {
    JSValue error = JS_GetException(ctx());
    GetExecutingContext()->ReportError(error);
    JS_FreeValue(ctx(), error);
  }

  auto* result = new EventDispatchResult{.canceled = dispatch_result == DispatchEventResult::kCanceledByEventHandler,
                                         .propagationStopped = event->propagationStopped()};
  return NativeValueConverter<NativeTypePointer<EventDispatchResult>>::ToNativeValue(result);
}

RegisteredEventListener* EventTarget::GetAttributeRegisteredEventListener(const AtomicString& event_type) {
  EventListenerVector* listener_vector = GetEventListeners(event_type);
  if (!listener_vector)
    return nullptr;

  for (auto& event_listener : *listener_vector) {
    auto listener = event_listener.Callback();
    if (GetExecutingContext() && listener->IsEventHandler())
      return &event_listener;
  }
  return nullptr;
}

bool EventTarget::FireEventListeners(Event& event,
                                     EventTargetData* d,
                                     EventListenerVector& entry,
                                     ExceptionState& exception_state) {
  // Fire all listeners registered for this event. Don't fire listeners removed
  // during event dispatch. Also, don't fire event listeners added during event
  // dispatch. Conveniently, all new event listeners will be added after or at
  // index |size|, so iterating up to (but not including) |size| naturally
  // excludes new event listeners.
  ExecutingContext* context = GetExecutingContext();
  if (!context)
    return false;

  size_t i = 0;
  size_t size = entry.size();
  if (!d->firing_event_iterators)
    d->firing_event_iterators = std::make_unique<FiringEventIteratorVector>();
  d->firing_event_iterators->push_back(FiringEventIterator(event.type(), i, size));

  bool fired_listener = false;

  while (i < size) {
    // If stopImmediatePropagation has been called, we just break out
    // immediately, without handling any more events on this target.
    if (event.ImmediatePropagationStopped())
      break;

    RegisteredEventListener registered_listener = entry[i];

    // Move the iterator past this event listener. This must match
    // the handling of the FiringEventIterator::iterator in
    // EventTarget::removeEventListener.
    ++i;

    if (!registered_listener.ShouldFire(event))
      continue;

    std::shared_ptr<EventListener> listener = registered_listener.Callback();
    // The listener will be retained by Member<EventListener> in the
    // registeredListener, i and size are updated with the firing event iterator
    // in case the listener is removed from the listener vector below.
    if (registered_listener.Once())
      removeEventListener(event.type(), listener, registered_listener.Capture(), exception_state);

    event.SetHandlingPassive(EventPassiveMode(registered_listener));

    // To match Mozilla, the AT_TARGET phase fires both capturing and bubbling
    // event listeners, even though that violates some versions of the DOM spec.
    listener->Invoke(context, &event, exception_state);
    fired_listener = true;

    event.SetHandlingPassive(Event::PassiveMode::kNotPassive);

    assert(i <= size);
  }
  d->firing_event_iterators->pop_back();
  return fired_listener;
}

void EventTargetWithInlineData::Trace(GCVisitor* visitor) const {
  EventTarget::Trace(visitor);
  data_.Trace(visitor);
}

}  // namespace webf

// namespace webf::binding::qjs
