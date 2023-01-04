/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "binding_initializer.h"
#include "core/executing_context.h"

#include "qjs_animation_event.h"
#include "qjs_blob.h"
#include "qjs_bounding_client_rect.h"
#include "qjs_canvas_gradient.h"
#include "qjs_canvas_pattern.h"
#include "qjs_canvas_rendering_context.h"
#include "qjs_canvas_rendering_context_2d.h"
#include "qjs_character_data.h"
#include "qjs_close_event.h"
#include "qjs_comment.h"
#include "qjs_console.h"
#include "qjs_css_style_declaration.h"
#include "qjs_custom_event.h"
#include "qjs_document.h"
#include "qjs_document_fragment.h"
#include "qjs_dom_matrix.h"
#include "qjs_dom_matrix_readonly.h"
#include "qjs_dom_token_list.h"
#include "qjs_element.h"
#include "qjs_element_attributes.h"
#include "qjs_error_event.h"
#include "qjs_event.h"
#include "qjs_event_target.h"
#include "qjs_focus_event.h"
#include "qjs_gesture_event.h"
#include "qjs_html_all_collection.h"
#include "qjs_html_anchor_element.h"
#include "qjs_html_body_element.h"
#include "qjs_html_button_element.h"
#include "qjs_html_canvas_element.h"
#include "qjs_html_div_element.h"
#include "qjs_html_element.h"
#include "qjs_html_form_element.h"
#include "qjs_html_head_element.h"
#include "qjs_html_html_element.h"
#include "qjs_html_image_element.h"
#include "qjs_html_input_element.h"
#include "qjs_html_link_element.h"
#include "qjs_html_script_element.h"
#include "qjs_html_template_element.h"
#include "qjs_html_textarea_element.h"
#include "qjs_html_unknown_element.h"
#include "qjs_image.h"
#include "qjs_input_event.h"
#include "qjs_intersection_change_event.h"
#include "qjs_keyboard_event.h"
#include "qjs_location.h"
#include "qjs_message_event.h"
#include "qjs_module_manager.h"
#include "qjs_mouse_event.h"
#include "qjs_node.h"
#include "qjs_node_list.h"
#include "qjs_performance.h"
#include "qjs_performance_entry.h"
#include "qjs_performance_mark.h"
#include "qjs_performance_measure.h"
#include "qjs_pointer_event.h"
#include "qjs_pop_state_event.h"
#include "qjs_promise_rejection_event.h"
#include "qjs_screen.h"
#include "qjs_text.h"
#include "qjs_touch.h"
#include "qjs_touch_event.h"
#include "qjs_touch_list.h"
#include "qjs_transition_event.h"
#include "qjs_ui_event.h"
#include "qjs_widget_element.h"
#include "qjs_window.h"
#include "qjs_window_or_worker_global_scope.h"

namespace webf {

void InstallBindings(ExecutingContext* context) {
  // Must follow the inheritance order when install.
  // Exp: Node extends EventTarget, EventTarget must be install first.
  QJSWindowOrWorkerGlobalScope::Install(context);
  QJSLocation::Install(context);
  QJSModuleManager::Install(context);
  QJSConsole::Install(context);
  QJSEventTarget::Install(context);
  QJSWindow::Install(context);
  QJSEvent::Install(context);
  QJSUIEvent::Install(context);
  QJSErrorEvent::Install(context);
  QJSPromiseRejectionEvent::Install(context);
  QJSMessageEvent::Install(context);
  QJSAnimationEvent::Install(context);
  QJSCloseEvent::Install(context);
  QJSFocusEvent::Install(context);
  QJSGestureEvent::Install(context);
  QJSInputEvent::Install(context);
  QJSCustomEvent::Install(context);
  QJSMouseEvent::Install(context);
  QJSPointerEvent::Install(context);
  QJSTouchEvent::Install(context);
  QJSPopStateEvent::Install(context);
  QJSTransitionEvent::Install(context);
  QJSIntersectionChangeEvent::Install(context);
  QJSKeyboardEvent::Install(context);
  QJSNode::Install(context);
  QJSNodeList::Install(context);
  QJSDocument::Install(context);
  QJSDocumentFragment::Install(context);
  QJSCharacterData::Install(context);
  QJSText::Install(context);
  QJSComment::Install(context);
  QJSElement::Install(context);
  QJSHTMLElement::Install(context);
  QJSWidgetElement::Install(context);
  QJSHTMLDivElement::Install(context);
  QJSHTMLHeadElement::Install(context);
  QJSHTMLBodyElement::Install(context);
  QJSHTMLHtmlElement::Install(context);
  QJSHTMLAnchorElement::Install(context);
  QJSHTMLImageElement::Install(context);
  QJSHTMLInputElement::Install(context);
  QJSHTMLTextareaElement::Install(context);
  QJSHTMLButtonElement::Install(context);
  QJSHTMLFormElement::Install(context);
  QJSImage::Install(context);
  QJSHTMLScriptElement::Install(context);
  QJSHTMLLinkElement::Install(context);
  QJSHTMLUnknownElement::Install(context);
  QJSHTMLTemplateElement::Install(context);
  QJSHTMLCanvasElement::Install(context);
  QJSCanvasRenderingContext::Install(context);
  QJSCanvasRenderingContext2D::Install(context);
  QJSCanvasPattern::Install(context);
  QJSCanvasGradient::Install(context);
  QJSDOMMatrixReadonly::Install(context);
  QJSDOMMatrix::Install(context);
  QJSCSSStyleDeclaration::Install(context);
  QJSBoundingClientRect::Install(context);
  QJSHTMLAllCollection::Install(context);
  QJSScreen::Install(context);
  QJSBlob::Install(context);
  QJSTouch::Install(context);
  QJSTouchList::Install(context);
  QJSDOMTokenList::Install(context);
  QJSPerformance::Install(context);
  QJSPerformanceEntry::Install(context);
  QJSPerformanceMark::Install(context);
  QJSPerformanceMeasure::Install(context);

  // Legacy bindings, not standard.
  QJSElementAttributes::Install(context);
}

}  // namespace webf
