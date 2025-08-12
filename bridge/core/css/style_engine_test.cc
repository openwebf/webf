/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_engine.h"

#include "bindings/qjs/cppgc/mutation_scope.h"
#include "core/css/css_style_sheet.h"
#include "core/css/resolver/style_resolver.h"
#include "core/dom/document.h"
#include "core/html/html_body_element.h"
#include "core/html/html_style_element.h"
#include "core/platform/text/text_position.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class StyleEngineTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    // Use the document from the page instead of creating a new one
    document_ = context_->document();
  }

  void TearDown() override {
    // Force garbage collection before cleanup
    if (context_ && context_->dartIsolateContext()) {
      context_->DrainMicrotasks();
    }
    
    document_ = nullptr;
    context_ = nullptr;
    env_.reset();
  }

  Document* GetDocument() { return document_; }
  ExecutingContext* GetExecutingContext() { return context_; }
  StyleEngine& GetStyleEngine() { return document_->EnsureStyleEngine(); }

 private:
  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_ = nullptr;
  Document* document_ = nullptr;
};

TEST_F(StyleEngineTest, CreateSheet) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  GetExecutingContext()->EnableBlinkEngine();
  
  auto* element = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  element->setAttribute(AtomicString::CreateFromUTF8("type"), AtomicString::CreateFromUTF8("text/css"));
  
  // Connect element to document
  GetDocument()->body()->appendChild(element, ASSERT_NO_EXCEPTION());
  
  std::string css_text = R"(
    .test {
      margin: 10px;
      color: red;
    }
  )";
  
  CSSStyleSheet* sheet = GetStyleEngine().CreateSheet(*element, css_text);
  
  ASSERT_NE(sheet, nullptr);
  EXPECT_EQ(sheet->ownerNode(), element);
}

TEST_F(StyleEngineTest, ParseSheet) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  GetExecutingContext()->EnableBlinkEngine();
  
  auto* element = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  
  // Connect element to document
  GetDocument()->body()->appendChild(element, ASSERT_NO_EXCEPTION());
  
  std::string css_text = R"(
    body {
      font-size: 16px;
    }
    div {
      display: block;
    }
  )";
  
  CSSStyleSheet* sheet = GetStyleEngine().ParseSheet(*element, css_text);
  
  ASSERT_NE(sheet, nullptr);
  EXPECT_EQ(sheet->ownerNode(), element);
}

TEST_F(StyleEngineTest, StyleResolver) {
  StyleResolver* resolver = GetStyleEngine().GetStyleResolver();
  
  ASSERT_NE(resolver, nullptr);
  EXPECT_EQ(&resolver->GetDocument(), GetDocument());
}

TEST_F(StyleEngineTest, EnsureStyleResolver) {
  StyleResolver& resolver = GetStyleEngine().EnsureStyleResolver();
  
  // Should return the same instance
  EXPECT_EQ(&resolver, GetStyleEngine().GetStyleResolver());
  EXPECT_EQ(&resolver.GetDocument(), GetDocument());
}

// TODO: Fix RuleFeatureSet methods
// TEST_F(StyleEngineTest, RuleFeatureSet) {
//   const RuleFeatureSet& features = GetStyleEngine().GetRuleFeatureSet();
//   
//   // Initial state should have no features
//   EXPECT_FALSE(features.UsesFirstLineRules());
//   EXPECT_FALSE(features.UsesWindowInactiveSelector());
//   EXPECT_FALSE(features.UsesAnimationAffectingSelectors());
// }

TEST_F(StyleEngineTest, MarkStyleDirtyAllowed) {
  // Initially should be allowed
  EXPECT_TRUE(GetStyleEngine().MarkStyleDirtyAllowed());
  
  // TODO: Test with different states when InStyleRecalc, etc.
}

TEST_F(StyleEngineTest, MarkReattachAllowed) {
  // Initially should be allowed
  EXPECT_TRUE(GetStyleEngine().MarkReattachAllowed());
  
  // TODO: Test with different states when InRebuildLayoutTree, etc.
}

TEST_F(StyleEngineTest, InApplyAnimationUpdateScope) {
  EXPECT_FALSE(GetStyleEngine().InApplyAnimationUpdate());
  
  {
    StyleEngine::InApplyAnimationUpdateScope scope(GetStyleEngine());
    EXPECT_TRUE(GetStyleEngine().InApplyAnimationUpdate());
  }
  
  EXPECT_FALSE(GetStyleEngine().InApplyAnimationUpdate());
}

TEST_F(StyleEngineTest, InEnsureComputedStyleScope) {
  EXPECT_FALSE(GetStyleEngine().InEnsureComputedStyle());
  
  {
    StyleEngine::InEnsureComputedStyleScope scope(GetStyleEngine());
    EXPECT_TRUE(GetStyleEngine().InEnsureComputedStyle());
  }
  
  EXPECT_FALSE(GetStyleEngine().InEnsureComputedStyle());
}

TEST_F(StyleEngineTest, CachedSheet) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  GetExecutingContext()->EnableBlinkEngine();
  auto* element1 = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  auto* element2 = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  
  // Connect elements to document
  GetDocument()->body()->appendChild(element1, ASSERT_NO_EXCEPTION());
  GetDocument()->body()->appendChild(element2, ASSERT_NO_EXCEPTION());
  
  std::string css_text = R"(
    .cached-test {
      width: 100px;
      height: 100px;
    }
  )";
  
  // First sheet should create new
  CSSStyleSheet* sheet1 = GetStyleEngine().CreateSheet(*element1, css_text);
  ASSERT_NE(sheet1, nullptr);
  
  // Second sheet with same text should use cached contents
  CSSStyleSheet* sheet2 = GetStyleEngine().CreateSheet(*element2, css_text);
  ASSERT_NE(sheet2, nullptr);
  
  // They should share the same contents
  EXPECT_EQ(sheet1->Contents(), sheet2->Contents());
  // TODO: Fix IsUsedFromTextCache method
  // EXPECT_TRUE(sheet1->Contents()->IsUsedFromTextCache());
}

TEST_F(StyleEngineTest, LargeSheetCaching) {
  MemberMutationScope mutation_scope{GetExecutingContext()};
  GetExecutingContext()->EnableBlinkEngine();
  auto* element = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  
  // Connect element to document
  ASSERT_NE(GetDocument()->body(), nullptr) << "Document should have a body";
  GetDocument()->body()->appendChild(element, ASSERT_NO_EXCEPTION());
  
  // Verify element is connected
  ASSERT_TRUE(element->isConnected()) << "element should be connected after appendChild";
  
  // Create a large CSS text (> 1024 chars)
  std::string large_css_text;
  for (int i = 0; i < 100; ++i) {
    large_css_text += ".large-class-" + std::to_string(i) + " { margin: 10px; padding: 20px; } ";
  }
  
  EXPECT_GT(large_css_text.length(), 1024u);
  
  CSSStyleSheet* sheet = GetStyleEngine().CreateSheet(*element, large_css_text);
  ASSERT_NE(sheet, nullptr);
  
  // Create another element with same large CSS
  auto* element2 = MakeGarbageCollected<HTMLStyleElement>(*GetDocument());
  // Make sure we have a body before appending
  ASSERT_NE(GetDocument()->body(), nullptr);
  GetDocument()->body()->appendChild(element2, ASSERT_NO_EXCEPTION());
  
  // Verify element2 is connected
  ASSERT_TRUE(element2->isConnected()) << "element2 should be connected after appendChild";
  
  CSSStyleSheet* sheet2 = GetStyleEngine().CreateSheet(*element2, large_css_text);
  
  // Should use cached version based on hash
  EXPECT_EQ(sheet->Contents(), sheet2->Contents());
}

}  // namespace webf
