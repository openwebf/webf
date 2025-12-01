/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_meta_element.h"
#include "html_head_element.h"
#include "html_html_element.h"
#include "core/dom/document.h"
#include "core/executing_context.h"
#include "core/css/style_engine.h"
#include "test/webf_test_env.h"
#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "gtest/gtest.h"

// Undefine Windows macros that conflict with our logging constants
#ifdef ERROR
#undef ERROR
#endif

namespace webf {

class HTMLMetaElementTest : public testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init([](double contextId, const char* errmsg) {
      WEBF_LOG(ERROR) << "JS Error: " << errmsg;
    });
    context_ = env_->page()->executingContext();
    document_ = context_->document();
  }

  void TearDown() override {
    document_ = nullptr;
    context_ = nullptr;
    env_.reset();
  }

  Document* GetDocument() { return document_; }
  ExecutingContext* GetExecutingContext() { return context_; }

 private:
  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_ = nullptr;
  Document* document_ = nullptr;
};

TEST_F(HTMLMetaElementTest, EnableBlinkCSSViaMetaTag) {
  // Initially, Blink engine should be disabled
  EXPECT_FALSE(GetExecutingContext()->isBlinkEnabled());
  
  // Create a MemberMutationScope for garbage collected objects
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create a meta element
  auto* meta = MakeGarbageCollected<HTMLMetaElement>(*GetDocument());
  
  // Set the webf-feature meta tag attributes
  ExceptionState exception_state;
  meta->setAttribute(AtomicString::CreateFromUTF8("name"), 
                     AtomicString::CreateFromUTF8("webf-feature"), 
                     exception_state);
  meta->setAttribute(AtomicString::CreateFromUTF8("content"), 
                     AtomicString::CreateFromUTF8("blink-css-enabled"), 
                     exception_state);
  
  // Add meta element to the document head
  auto* head = GetDocument()->head();
  if (!head) {
    // Create head if it doesn't exist
    auto* html = GetDocument()->documentElement();
    if (!html) {
      html = MakeGarbageCollected<HTMLHtmlElement>(*GetDocument());
      GetDocument()->appendChild(html, exception_state);
    }
    head = MakeGarbageCollected<HTMLHeadElement>(*GetDocument());
    html->appendChild(head, exception_state);
  }
  
  // Append meta element to head
  head->appendChild(meta, exception_state);
  
  // Now Blink engine should be enabled
  EXPECT_TRUE(GetExecutingContext()->isBlinkEnabled());
}

TEST_F(HTMLMetaElementTest, EnableBlinkCSSWithMultipleFeatures) {
  // Initially, Blink engine should be disabled
  EXPECT_FALSE(GetExecutingContext()->isBlinkEnabled());
  
  // Create a MemberMutationScope for garbage collected objects
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create a meta element with multiple features
  auto* meta = MakeGarbageCollected<HTMLMetaElement>(*GetDocument());
  
  ExceptionState exception_state;
  meta->setAttribute(AtomicString::CreateFromUTF8("name"), 
                     AtomicString::CreateFromUTF8("webf-feature"), 
                     exception_state);
  meta->setAttribute(AtomicString::CreateFromUTF8("content"), 
                     AtomicString::CreateFromUTF8("other-feature blink-css-enabled another-feature"), 
                     exception_state);
  
  // Add to document
  auto* head = GetDocument()->head();
  if (!head) {
    auto* html = GetDocument()->documentElement();
    if (!html) {
      html = MakeGarbageCollected<HTMLHtmlElement>(*GetDocument());
      GetDocument()->appendChild(html, exception_state);
    }
    head = MakeGarbageCollected<HTMLHeadElement>(*GetDocument());
    html->appendChild(head, exception_state);
  }
  
  head->appendChild(meta, exception_state);
  
  // Blink engine should be enabled even with multiple features
  EXPECT_TRUE(GetExecutingContext()->isBlinkEnabled());
}

TEST_F(HTMLMetaElementTest, NoEnableWithoutCorrectMetaTag) {
  // Initially, Blink engine should be disabled
  EXPECT_FALSE(GetExecutingContext()->isBlinkEnabled());
  
  // Create a MemberMutationScope for garbage collected objects
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create a meta element with different name
  auto* meta = MakeGarbageCollected<HTMLMetaElement>(*GetDocument());
  
  ExceptionState exception_state;
  meta->setAttribute(AtomicString::CreateFromUTF8("name"), 
                     AtomicString::CreateFromUTF8("viewport"), 
                     exception_state);
  meta->setAttribute(AtomicString::CreateFromUTF8("content"), 
                     AtomicString::CreateFromUTF8("width=device-width"), 
                     exception_state);
  
  // Add to document
  auto* head = GetDocument()->head();
  if (!head) {
    auto* html = GetDocument()->documentElement();
    if (!html) {
      html = MakeGarbageCollected<HTMLHtmlElement>(*GetDocument());
      GetDocument()->appendChild(html, exception_state);
    }
    head = MakeGarbageCollected<HTMLHeadElement>(*GetDocument());
    html->appendChild(head, exception_state);
  }
  
  head->appendChild(meta, exception_state);
  
  // Blink engine should remain disabled
  EXPECT_FALSE(GetExecutingContext()->isBlinkEnabled());
}

TEST_F(HTMLMetaElementTest, EnableViaAttributeChange) {
  // Initially, Blink engine should be disabled
  EXPECT_FALSE(GetExecutingContext()->isBlinkEnabled());
  
  // Create a MemberMutationScope for garbage collected objects
  MemberMutationScope mutation_scope{GetExecutingContext()};
  
  // Create a meta element without the correct attributes
  auto* meta = MakeGarbageCollected<HTMLMetaElement>(*GetDocument());
  
  ExceptionState exception_state;
  meta->setAttribute(AtomicString::CreateFromUTF8("name"), 
                     AtomicString::CreateFromUTF8("other"), 
                     exception_state);
  
  // Add to document
  auto* head = GetDocument()->head();
  if (!head) {
    auto* html = GetDocument()->documentElement();
    if (!html) {
      html = MakeGarbageCollected<HTMLHtmlElement>(*GetDocument());
      GetDocument()->appendChild(html, exception_state);
    }
    head = MakeGarbageCollected<HTMLHeadElement>(*GetDocument());
    html->appendChild(head, exception_state);
  }
  
  head->appendChild(meta, exception_state);
  
  // Should still be disabled
  EXPECT_FALSE(GetExecutingContext()->isBlinkEnabled());
  
  // Now change attributes to enable Blink - set content first, then name
  meta->setAttribute(AtomicString::CreateFromUTF8("content"), 
                     AtomicString::CreateFromUTF8("blink-css-enabled"), 
                     exception_state);
  meta->setAttribute(AtomicString::CreateFromUTF8("name"), 
                     AtomicString::CreateFromUTF8("webf-feature"), 
                     exception_state);
  
  // Now Blink engine should be enabled
  EXPECT_TRUE(GetExecutingContext()->isBlinkEnabled());
}

}  // namespace webf