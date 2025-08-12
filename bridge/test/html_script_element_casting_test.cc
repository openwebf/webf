/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

/**
 * This test file verifies that the casting chain from void* to HTMLScriptElement works correctly.
 *
 * The casting sequence being tested is:
 * void* script_element_ -> NativeBindingObject* -> BindingObject* -> HTMLScriptElement*
 *
 * This sequence is used in WebF when a void* parameter (containing a NativeBindingObject pointer)
 * needs to be cast back to a specific DOM element type like HTMLScriptElement.
 *
 * The test verifies:
 * 1. The casting chain works for valid HTMLScriptElements
 * 2. Null pointer handling works correctly
 * 3. The final cast result matches the original element
 */

#include <gtest/gtest.h>
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "core/binding_object.h"
#include "core/dom/document.h"
#include "core/html/html_script_element.h"
#include "core/executing_context.h"
#include "foundation/casting.h"
#include "bindings/qjs/exception_state.h"
#include "webf_test_env.h"
#include "code_gen/html_element_type_helper.h"

namespace webf {

class HTMLScriptElementCastingTest : public testing::Test {
 protected:
  void SetUp() override {
    webf_test_env_ = TEST_init();
    executing_context_ = webf_test_env_->page()->executingContext();
    document_ = executing_context_->document();
  }

  void TearDown() override {
    webf_test_env_.reset();
  }

  std::unique_ptr<WebFTestEnv> webf_test_env_;
  ExecutingContext* executing_context_;
  Document* document_;
};

TEST_F(HTMLScriptElementCastingTest, VoidPointerToHTMLScriptElementCasting) {
  MemberMutationScope mutation_scope(executing_context_);

  // Create an HTMLScriptElement through the document
  ExceptionState exception_state;
  AtomicString script_tag = AtomicString::CreateFromUTF8("script");
  HTMLElement* html_element = document_->createElement(script_tag, exception_state);
  ASSERT_FALSE(exception_state.HasException());
  ASSERT_NE(html_element, nullptr);

  // Cast to HTMLScriptElement - should work since we created it with "script" tag
  // Note: Using static_cast since generated DowncastTraits might not handle all cases
  HTMLScriptElement* original_script_element = DynamicTo<HTMLScriptElement>(html_element);
  ASSERT_NE(original_script_element, nullptr);

  // Get the NativeBindingObject from the HTMLScriptElement
  NativeBindingObject* native_binding_object = original_script_element->bindingObject();
  ASSERT_NE(native_binding_object, nullptr);

  // Cast to void* (simulating the script_element_ parameter)
  void* script_element_ = native_binding_object;

  // Test the casting chain from the user's code
  auto script_element_native_binding_object =
      reinterpret_cast<webf::NativeBindingObject*>(script_element_);
  ASSERT_NE(script_element_native_binding_object, nullptr);

  auto binding_object = BindingObject::From(script_element_native_binding_object);
  ASSERT_NE(binding_object, nullptr);

  // Test the main casting chain - this is what we're actually testing
  // The key point is that this casting sequence works: void* -> NativeBindingObject* -> BindingObject -> HTMLScriptElement
  HTMLScriptElement* script_element = DynamicTo<HTMLScriptElement>(binding_object);
  ASSERT_NE(script_element, nullptr);

  // Verify that the final cast result is the same as the original
  EXPECT_EQ(script_element, original_script_element);
}

TEST_F(HTMLScriptElementCastingTest, InvalidCastingReturnsNull) {
  MemberMutationScope mutation_scope(executing_context_);

  // Create a different type of element (not script)
  ExceptionState exception_state;
  AtomicString div_tag = AtomicString::CreateFromUTF8("div");
  HTMLElement* html_element = document_->createElement(div_tag, exception_state);
  ASSERT_FALSE(exception_state.HasException());
  ASSERT_NE(html_element, nullptr);

  // Get the NativeBindingObject
  NativeBindingObject* native_binding_object = html_element->bindingObject();
  ASSERT_NE(native_binding_object, nullptr);

  // Cast to void*
  void* script_element_ = static_cast<void*>(native_binding_object);

  // Test the casting chain with invalid element type
  auto script_element_native_binding_object =
      reinterpret_cast<webf::NativeBindingObject*>(script_element_);
  ASSERT_NE(script_element_native_binding_object, nullptr);

  auto binding_object = BindingObject::From(script_element_native_binding_object);
  ASSERT_NE(binding_object, nullptr);

  // The casting chain still works mechanically, but it's not type-safe
  // In production code, DynamicTo would return null for wrong types
  auto script_element = DynamicTo<HTMLScriptElement>(binding_object);
  // Expect null since we created a div, not a script element
  EXPECT_EQ(script_element, nullptr);
}

TEST_F(HTMLScriptElementCastingTest, NullPointerHandling) {
  MemberMutationScope mutation_scope(executing_context_);

  // Test with null void pointer
  void* script_element_ = nullptr;

  auto script_element_native_binding_object =
      reinterpret_cast<webf::NativeBindingObject*>(script_element_);
  EXPECT_EQ(script_element_native_binding_object, nullptr);

  auto binding_object = BindingObject::From(script_element_native_binding_object);
  EXPECT_EQ(binding_object, nullptr);

  auto script_element = DynamicTo<HTMLScriptElement>(binding_object);
  EXPECT_EQ(script_element, nullptr);
}

}  // namespace webf
