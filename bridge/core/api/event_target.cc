/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "plugin_api/event_target.h"
#include "bindings/qjs/atomic_string.h"
#include "core/api/exception_state.h"
#include "core/dom/comment.h"
#include "core/dom/container_node.h"
#include "core/dom/document.h"
#include "core/dom/document_fragment.h"
#include "core/dom/element.h"
#include "core/dom/events/event.h"
#include "core/dom/events/event_target.h"
#include "core/dom/node.h"
#include "core/dom/text.h"
#include "core/frame/window.h"
#include "core/html/canvas/html_canvas_element.h"
#include "core/html/html_element.h"
#include "core/html/html_image_element.h"
#include "html_element_type_helper.h"
#include "plugin_api/add_event_listener_options.h"
#include "plugin_api/webf_event_listener.h"

namespace webf {

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
      WebFValueStatus* status_block = event_target->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(event_target, event_target->eventTargetPublicMethods(),
                                                       status_block);
    }
    case EventTargetType::kNode: {
      auto* node = webf::DynamicTo<Node>(event_target);
      if (node == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = node->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(node, node->nodePublicMethods(), status_block);
    }
    case EventTargetType::kContainerNode: {
      auto* container_node = webf::DynamicTo<ContainerNode>(event_target);
      if (container_node == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = container_node->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(container_node, container_node->containerNodePublicMethods(),
                                                       status_block);
    }
    case EventTargetType::kWindow: {
      auto* window = webf::DynamicTo<Window>(event_target);
      if (window == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = window->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(window, window->windowPublicMethods(), status_block);
    }
    case EventTargetType::kDocument: {
      auto* document = webf::DynamicTo<Document>(event_target);
      if (document == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = document->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(document, document->documentPublicMethods(), status_block);
    }
    case EventTargetType::kElement: {
      auto* element = webf::DynamicTo<Element>(event_target);
      if (element == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = element->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(element, element->elementPublicMethods(), status_block);
    }
    case EventTargetType::kHTMLDivElement:
    case EventTargetType::kHTMLScriptElement:
    case EventTargetType::HTMLElement: {
      auto* html_element = webf::DynamicTo<HTMLElement>(event_target);
      if (html_element == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = html_element->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(html_element, html_element->htmlElementPublicMethods(),
                                                       status_block);
    }
    case EventTargetType::kHTMLImageElement: {
      auto* html_image_element = webf::DynamicTo<HTMLImageElement>(event_target);
      if (html_image_element == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = html_image_element->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(
          html_image_element, html_image_element->htmlImageElementPublicMethods(), status_block);
    }
    case EventTargetType::kDocumentFragment: {
      auto* document_fragment = webf::DynamicTo<DocumentFragment>(event_target);
      if (document_fragment == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = document_fragment->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(
          document_fragment, document_fragment->documentFragmentPublicMethods(), status_block);
    }
    case EventTargetType::kText: {
      auto* text = webf::DynamicTo<Text>(event_target);
      if (text == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = text->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(text, text->textNodePublicMethods(), status_block);
    }
    case EventTargetType::kComment: {
      auto* comment = webf::DynamicTo<Comment>(event_target);
      if (comment == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = comment->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(comment, comment->commentPublicMethods(), status_block);
    }
    case EventTargetType::kHTMLCanvasElement: {
      auto* canvas_element = webf::DynamicTo<HTMLCanvasElement>(event_target);
      if (canvas_element == nullptr) {
        return WebFValue<EventTarget, WebFPublicMethods>::Null();
      }
      WebFValueStatus* status_block = canvas_element->KeepAlive();
      return WebFValue<EventTarget, WebFPublicMethods>(canvas_element, canvas_element->htmlCanvasElementPublicMethods(),
                                                       status_block);
    }
    default:
      assert_m(false, ("Unknown event_target_type " + std::to_string(static_cast<int32_t>(event_target_type))).c_str());
  }
}

}  // namespace webf
