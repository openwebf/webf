/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_meta_element.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/css/style_engine.h"
#include "core/css/style_change_reason.h"
#include "bindings/qjs/exception_state.h"
#include <string>

namespace webf {

HTMLMetaElement::HTMLMetaElement(Document& document) : HTMLElement(AtomicString::CreateFromUTF8("meta"), &document) {}

void HTMLMetaElement::AttributeChanged(const AttributeModificationParams& params) {
  // Call parent class implementation first
  HTMLElement::AttributeChanged(params);
  
  // Process meta element if we're connected to the document
  if (isConnected()) {
    ProcessMetaElement();
  }
}

Node::InsertionNotificationRequest HTMLMetaElement::InsertedInto(ContainerNode& insertion_point) {
  HTMLElement::InsertedInto(insertion_point);
  if (isConnected()) {
    ProcessMetaElement();
  }
  return kInsertionDone;
}

void HTMLMetaElement::RemovedFrom(ContainerNode& insertion_point) {
  HTMLElement::RemovedFrom(insertion_point);
  // Note: We don't disable Blink engine on removal to avoid inconsistent state
}

void HTMLMetaElement::ProcessMetaElement() {
  // Check if this is a webf-feature meta tag
  ExceptionState exception_state;
  AtomicString name_attr = AtomicString::CreateFromUTF8("name");
  AtomicString content_attr = AtomicString::CreateFromUTF8("content");
  
  AtomicString name = getAttribute(name_attr, exception_state);
  AtomicString content = getAttribute(content_attr, exception_state);
  
  if (name == AtomicString::CreateFromUTF8("webf-feature")) {
    // Check if content contains "blink-css-enabled"
    std::string content_str = content.ToUTF8String();
    if (content_str.find("blink-css-enabled") != std::string::npos) {
      // Enable the Blink CSS engine
      GetExecutingContext()->EnableBlinkEngine();

      // Ensure that the style engine is created
      GetDocument().EnsureStyleEngine();
      
      // Log that Blink CSS is enabled
      WEBF_LOG(INFO) << "Blink CSS engine enabled via meta tag";
      
      // Trigger style recalculation for existing elements if document is ready
      if (GetDocument().documentElement() && GetExecutingContext()->isBlinkEnabled()) {
        // Mark all elements for style recalc
        GetDocument().documentElement()->SetNeedsStyleRecalc(
            kSubtreeStyleChange, 
            StyleChangeReasonForTracing::Create(style_change_reason::kSettings));
      }
    }
  }
}

}  // namespace webf