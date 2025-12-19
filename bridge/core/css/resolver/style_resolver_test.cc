/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_resolver.h"

#include "bindings/qjs/cppgc/mutation_scope.h"
#include "core/css/css_default_style_sheets.h"
#include "core/css/css_style_sheet.h"
#include "core/css/style_engine.h"
#include "core/css/style_recalc_context.h"
#include "core/css/style_request.h"
#include "core/css/style_sheet_contents.h"
#include "core/dart_isolate_context.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/html/html_body_element.h"
#include "core/html/html_element.h"
#include "core/html/html_div_element.h"
#include "core/html/html_paragraph_element.h"
#include "html_names.h"
#include "core/style/computed_style.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {

class StyleResolverTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Initialize test environment
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    // Use the document from the page instead of creating a new one
    document_ = context_->document();
    
    // Ensure core globals are initialized (including html_names)
    InitializeCoreGlobals();
  }

  void TearDown() override {
    // Force cleanup following WebF ExecutingContext destructor pattern
    if (context_ && context_->IsCtxValid()) {
      // Check for any pending exceptions and handle them like WebF does
      JSValue exception = JS_GetException(context_->ctx());
      if (JS_IsObject(exception) || JS_IsException(exception)) {
        // Report and clear the exception like WebF does
        context_->ReportError(exception);
        JS_FreeValue(context_->ctx(), exception);
      }
      
      // Drain microtasks to complete any pending operations
      context_->DrainMicrotasks();
      
      // Force garbage collection before releasing references
      auto* runtime = context_->dartIsolateContext()->runtime();
      if (runtime) {
        JS_RunGC(runtime);
        JS_RunGC(runtime);
      }
    }
    
    // Reset UA stylesheets to avoid memory leaks
    CSSDefaultStyleSheets::Reset();
    
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

TEST_F(StyleResolverTest, InitialStyle) {
  StyleResolver resolver(*GetDocument());
  
  const ComputedStyle& initial_style = resolver.InitialStyle();
  
  // Test some initial values
  EXPECT_EQ(initial_style.Display(), EDisplay::kInline);
  EXPECT_EQ(initial_style.Position(), EPosition::kStatic);
  EXPECT_EQ(initial_style.GetDirection(), TextDirection::kLtr);
}

TEST_F(StyleResolverTest, StyleForDocument) {
  auto document_style = StyleResolver::StyleForDocument(*GetDocument());
  
  ASSERT_NE(document_style, nullptr);
  EXPECT_EQ(document_style->Display(), EDisplay::kBlock);
  EXPECT_EQ(document_style->Position(), EPosition::kAbsolute);
  EXPECT_EQ(document_style->OverflowX(), EOverflow::kAuto);
  EXPECT_EQ(document_style->OverflowY(), EOverflow::kAuto);
}

TEST_F(StyleResolverTest, CreateAnonymousStyleWithDisplay) {
  StyleResolver resolver(*GetDocument());
  const ComputedStyle& parent_style = resolver.InitialStyle();
  
  auto block_style = resolver.CreateAnonymousStyleWithDisplay(parent_style, EDisplay::kBlock);
  ASSERT_NE(block_style, nullptr);
  EXPECT_EQ(block_style->Display(), EDisplay::kBlock);
  
  auto flex_style = resolver.CreateAnonymousStyleWithDisplay(parent_style, EDisplay::kFlex);
  ASSERT_NE(flex_style, nullptr);
  EXPECT_EQ(flex_style->Display(), EDisplay::kFlex);
}

TEST_F(StyleResolverTest, ComputedStyleBuilder) {
  StyleResolver resolver(*GetDocument());
  
  // Test creating a builder from initial style
  auto builder = resolver.CreateComputedStyleBuilder();
  builder.SetDisplay(EDisplay::kFlex);
  builder.SetPosition(EPosition::kRelative);
  
  auto style = builder.TakeStyle();
  ASSERT_NE(style, nullptr);
  EXPECT_EQ(style->Display(), EDisplay::kFlex);
  EXPECT_EQ(style->Position(), EPosition::kRelative);
}

TEST_F(StyleResolverTest, ComputedStyleBuilderInheritingFrom) {
  StyleResolver resolver(*GetDocument());
  
  // Create parent style
  auto parent_builder = resolver.CreateComputedStyleBuilder();
  parent_builder.SetColor(Color(255, 0, 0)); // Red
  parent_builder.SetFontSize(16);
  auto parent_style = parent_builder.TakeStyle();
  
  // Create child style inheriting from parent
  auto child_builder = resolver.CreateComputedStyleBuilderInheritingFrom(*parent_style);
  auto child_style = child_builder.TakeStyle();
  
  ASSERT_NE(child_style, nullptr);
  // Color should be inherited
  EXPECT_EQ(child_style->Color(), Color(255, 0, 0));
  // Font size should be inherited
  EXPECT_EQ(child_style->GetFontSize(), 16);
}

TEST_F(StyleResolverTest, MediaTypeUpdate) {
  StyleResolver resolver(*GetDocument());
  
  // This should not crash
  resolver.UpdateMediaType();
}

TEST_F(StyleResolverTest, ViewportUnits) {
  StyleResolver resolver(*GetDocument());
  
  // Test viewport unit methods don't crash
  resolver.SetResizedForViewportUnits();
  resolver.ClearResizedForViewportUnits();
}
}  // namespace webf