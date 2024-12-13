/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */


#include "binding_initializer.h"
#include "v8_window_or_worker_global_scope.h"

namespace webf {

void InstallBindings(ExecutingContext* context) {
  // Must follow the inheritance order when install.
  // Exp: Node extends EventTarget, EventTarget must be install first.
  V8WindowOrWorkerGlobalScope::Install(context);
  /*TODO  support DOM API
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
  QJSHybridRouterChangeEvent::Install(context);
  QJSFocusEvent::Install(context);
  QJSGestureEvent::Install(context);
  QJSHashchangeEvent::Install(context);
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
  QJSHTMLIFrameElement::Install(context);
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
  QJSPath2D::Install(context);
  QJSDOMMatrixReadOnly::Install(context);
  QJSDOMMatrix::Install(context);
  QJSDOMPointReadOnly::Install(context);
  QJSDOMPoint::Install(context);
  QJSCSSStyleDeclaration::Install(context);
  QJSInlineCssStyleDeclaration::Install(context);
  QJSComputedCssStyleDeclaration::Install(context);
  QJSBoundingClientRect::Install(context);
  QJSScreen::Install(context);
  QJSBlob::Install(context);
  QJSTouch::Install(context);
  QJSTouchList::Install(context);
  QJSDOMStringMap::Install(context);
  QJSMutationObserver::Install(context);
  QJSMutationRecord::Install(context);
  QJSMutationObserverRegistration::Install(context);
  QJSDOMTokenList::Install(context);
  QJSPerformance::Install(context);
  QJSPerformanceEntry::Install(context);
  QJSPerformanceMark::Install(context);
  QJSPerformanceMeasure::Install(context);
  QJSHTMLCollection::Install(context);
  QJSHTMLAllCollection::Install(context);

  // SVG
  QJSSVGElement::Install(context);
  QJSSVGGraphicsElement::Install(context);
  QJSSVGGeometryElement::Install(context);
  QJSSVGSVGElement::Install(context);
  QJSSVGRectElement::Install(context);
  QJSSVGTextContentElement::Install(context);
  QJSSVGTextPositioningElement::Install(context);
  QJSSVGPathElement::Install(context);
  QJSSVGTextElement::Install(context);
  QJSSVGGElement::Install(context);
  QJSSVGCircleElement::Install(context);
  QJSSVGEllipseElement::Install(context);
  QJSSVGStyleElement::Install(context);
  QJSSVGLineElement::Install(context);
  QJSNativeLoader::Install(context);

  // Legacy bindings, not standard.
  QJSElementAttributes::Install(context);
  */
}

}  // namespace webf