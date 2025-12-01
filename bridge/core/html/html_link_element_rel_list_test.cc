/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <gtest/gtest.h>
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/exception_state.h"
#include "core/dom/document.h"
#include "core/dom/dom_token_list.h"
#include "core/html/html_link_element.h"
#include "html_names.h"
#include "webf_test_env.h"

namespace webf {

class HTMLLinkElementRelListTest : public testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    document_ = context_->document();
  }
  void TearDown() override { env_.reset(); }

  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_ = nullptr;
  Document* document_ = nullptr;
};

TEST_F(HTMLLinkElementRelListTest, RelListBasicOperations) {
  MemberMutationScope mutation_scope(context_);

  ExceptionState exception_state;
  // Create <link>
  HTMLElement* elem = document_->createElement(AtomicString::CreateFromUTF8("link"), exception_state);
  ASSERT_FALSE(exception_state.HasException());
  ASSERT_NE(elem, nullptr);

  HTMLLinkElement* link = DynamicTo<HTMLLinkElement>(elem);
  ASSERT_NE(link, nullptr);

  // Acquire relList
  DOMTokenList* rel_list = link->relList();
  ASSERT_NE(rel_list, nullptr);
  EXPECT_EQ(rel_list->length(), 0u);

  // Add a token and verify attribute synchronization
  rel_list->Add(AtomicString::CreateFromUTF8("stylesheet"));
  AtomicString rel_value = link->getAttribute(html_names::kRelAttr, exception_state);
  ASSERT_FALSE(exception_state.HasException());
  EXPECT_STREQ(rel_value.ToUTF8String().c_str(), "stylesheet");

  // Contains should reflect token presence
  EXPECT_TRUE(rel_list->contains(AtomicString::CreateFromUTF8("stylesheet"), exception_state));
  ASSERT_FALSE(exception_state.HasException());
}

TEST_F(HTMLLinkElementRelListTest, DOMTokenListSupportsForRelList) {
  MemberMutationScope mutation_scope(context_);
  ExceptionState exception_state;

  HTMLElement* elem = document_->createElement(AtomicString::CreateFromUTF8("link"), exception_state);
  ASSERT_FALSE(exception_state.HasException());
  ASSERT_NE(elem, nullptr);

  HTMLLinkElement* link = DynamicTo<HTMLLinkElement>(elem);
  ASSERT_NE(link, nullptr);

  DOMTokenList* rel_list = link->relList();
  ASSERT_NE(rel_list, nullptr);

  // Known token (case-insensitive)
  EXPECT_TRUE(rel_list->supports(AtomicString::CreateFromUTF8("stylesheet"), exception_state));
  ASSERT_FALSE(exception_state.HasException());
  EXPECT_TRUE(rel_list->supports(AtomicString::CreateFromUTF8("StyleSheet"), exception_state));
  ASSERT_FALSE(exception_state.HasException());

  // Unknown token -> false, no exception
  EXPECT_FALSE(rel_list->supports(AtomicString::CreateFromUTF8("foo"), exception_state));
  ASSERT_FALSE(exception_state.HasException());
}

TEST_F(HTMLLinkElementRelListTest, DOMTokenListSupportsThrowsForClassList) {
  MemberMutationScope mutation_scope(context_);
  ExceptionState exception_state;

  // Create <div> and access classList
  HTMLElement* div = document_->createElement(AtomicString::CreateFromUTF8("div"), exception_state);
  ASSERT_FALSE(exception_state.HasException());
  ASSERT_NE(div, nullptr);

  DOMTokenList* class_list = div->classList();
  ASSERT_NE(class_list, nullptr);

  // supports() on classList should throw TypeError (no supported tokens)
  bool result = class_list->supports(AtomicString::CreateFromUTF8("foo"), exception_state);
  EXPECT_FALSE(result);
  EXPECT_TRUE(exception_state.HasException());
  JS_GetException(context_->ctx());
}

}  // namespace webf

