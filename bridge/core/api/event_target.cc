/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/event_target.h"
#include "bindings/qjs/atomic_string.h"
#include "core/dom/container_node.h"
#include "core/dom/document.h"
#include "core/dom/document_fragment.h"
#include "core/dom/element.h"
#include "core/dom/comment.h"
#include "core/dom/events/event.h"
#include "core/dom/events/event_target.h"
#include "core/dom/node.h"
#include "core/dom/text.h"
#include "core/frame/window.h"
#include "core/html/html_element.h"
#include "core/html/html_image_element.h"
#include "core/html/canvas/html_canvas_element.h"
#include "plugin_api/exception_state.h"
#include "html_element_type_helper.h"

namespace webf {

class WebFPublicPluginEventListener : public EventListener {
 public:
  WebFPublicPluginEventListener(WebFEventListenerContext* callback_context,
                                SharedExceptionState* shared_exception_state)
      : callback_context_(callback_context), shared_exception_state_(shared_exception_state) {}

  ~WebFPublicPluginEventListener() {
    callback_context_->free_ptr(callback_context_);
    delete callback_context_;
  }

  static const std::shared_ptr<WebFPublicPluginEventListener> Create(WebFEventListenerContext* WebF_event_listener,
                                                                     SharedExceptionState* shared_exception_state) {
    return std::make_shared<WebFPublicPluginEventListener>(WebF_event_listener, shared_exception_state);
  };

  [[nodiscard]] bool IsPublicPluginEventHandler() const override { return true; }

  void Invoke(ExecutingContext* context, Event* event, ExceptionState& exception_state) override {
    event->KeepAlive();
    callback_context_->callback(callback_context_, event, event->eventPublicMethods(),
                                shared_exception_state_);
  }

  [[nodiscard]] bool Matches(const EventListener& other) const override {
    const auto* other_listener = DynamicTo<WebFPublicPluginEventListener>(other);
    return other_listener && other_listener->callback_context_ &&
           other_listener->callback_context_->callback == callback_context_->callback;
  }

  void Trace(GCVisitor* visitor) const override {}

  WebFEventListenerContext* callback_context_;
  SharedExceptionState* shared_exception_state_;
};

template <>
struct DowncastTraits<WebFPublicPluginEventListener> {
  static bool AllowFrom(const EventListener& event_listener) { return event_listener.IsPublicPluginEventHandler(); }
};

void EventTargetPublicMethods::AddEventListener(EventTarget* event_target,
                                              const char* event_name_str,
                                              WebFEventListenerContext* callback_context,
                                              WebFAddEventListenerOptions* options,
                                              SharedExceptionState* shared_exception_state) {
  AtomicString event_name = AtomicString(event_target->ctx(), event_name_str);
  std::shared_ptr<AddEventListenerOptions> event_listener_options = AddEventListenerOptions::Create();

  // Preparing for the event listener options.
  event_listener_options->setOnce(options->once);
  event_listener_options->setPassive(options->passive);
  event_listener_options->setCapture(options->capture);

  auto listener_impl = WebFPublicPluginEventListener::Create(callback_context, shared_exception_state);

  event_target->addEventListener(event_name, listener_impl, event_listener_options,
                                 shared_exception_state->exception_state);
}

void EventTargetPublicMethods::RemoveEventListener(EventTarget* event_target,
                                                 const char* event_name_str,
                                                 WebFEventListenerContext* callback_context,
                                                 SharedExceptionState* shared_exception_state) {
  AtomicString event_name = AtomicString(event_target->ctx(), event_name_str);
  auto listener_impl = WebFPublicPluginEventListener::Create(callback_context, shared_exception_state);

  event_target->removeEventListener(event_name, listener_impl, shared_exception_state->exception_state);
}

bool EventTargetPublicMethods::DispatchEvent(EventTarget* event_target,
                                           Event* event,
                                           SharedExceptionState* shared_exception_state) {
  return event_target->dispatchEvent(event, shared_exception_state->exception_state);
}

void EventTargetPublicMethods::Release(EventTarget* event_target) {
  event_target->ReleaseAlive();
}

WebFValue<EventTarget, WebFPublicMethods> EventTargetPublicMethods::DynamicTo(webf::EventTarget* event_target,
                                                                            webf::EventTargetType event_target_type) {
  switch (event_target_type) {
    case EventTargetType::kEventTarget: {
      return {.value = event_target, .method_pointer = event_target->eventTargetPublicMethods()};
    }
    case EventTargetType::kNode: {
      auto* node = webf::DynamicTo<Node>(event_target);
      if (node == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = node, .method_pointer = node->nodePublicMethods()};
    }
    case EventTargetType::kContainerNode: {
      auto* container_node = webf::DynamicTo<ContainerNode>(event_target);
      if (container_node == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = container_node, .method_pointer = container_node->containerNodePublicMethods()};
    }
    case EventTargetType::kWindow: {
      auto* window = webf::DynamicTo<Window>(event_target);
      if (window == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = window, .method_pointer = window->windowPublicMethods()};
    }
    case EventTargetType::kDocument: {
      auto* document = webf::DynamicTo<Document>(event_target);
      if (document == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = document, .method_pointer = document->documentPublicMethods()};
    }
    case EventTargetType::kElement: {
      auto* element = webf::DynamicTo<Element>(event_target);
      if (element == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = element, .method_pointer = element->elementPublicMethods()};
    }
    case EventTargetType::kHTMLDivElement:
    case EventTargetType::kHTMLScriptElement:
    case EventTargetType::HTMLElement: {
      auto* html_element = webf::DynamicTo<HTMLElement>(event_target);
      if (html_element == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = html_element, .method_pointer = html_element->htmlElementPublicMethods()};
    }
    case EventTargetType::kHTMLImageElement: {
      auto* html_image_element = webf::DynamicTo<HTMLImageElement>(event_target);
      if (html_image_element == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = html_image_element, .method_pointer = html_image_element->htmlImageElementPublicMethods()};
    }
    case EventTargetType::kDocumentFragment: {
      auto* document_fragment = webf::DynamicTo<DocumentFragment>(event_target);
      if (document_fragment == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = document_fragment, .method_pointer = document_fragment->documentFragmentPublicMethods()};
    }
    case EventTargetType::kText: {
      auto* text = webf::DynamicTo<Text>(event_target);
      if (text == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = text, .method_pointer = text->textNodePublicMethods()};
    }
    case EventTargetType::kComment: {
      auto* comment = webf::DynamicTo<Comment>(event_target);
      if (comment == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = comment, .method_pointer = comment->commentPublicMethods()};
    }
    case EventTargetType::kHTMLCanvasElement: {
      auto* canvas_element = webf::DynamicTo<HTMLCanvasElement>(event_target);
      if (canvas_element == nullptr) {
        return {.value = nullptr, .method_pointer = nullptr};
      }
      return {.value = canvas_element, .method_pointer = canvas_element->htmlCanvasElementPublicMethods() };
    }
  }
}

}  // namespace webf
