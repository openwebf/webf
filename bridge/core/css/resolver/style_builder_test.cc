/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_builder.h"

#include <gtest/gtest.h>
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/resolver/element_resolve_context.h"
#include "core/style/computed_style.h"
#include "core/style/computed_style_constants.h"
#include "core/dom/element.h"
#include "core/html/html_div_element.h"
#include "core/html/html_body_element.h"
#include "core/dom/document.h"
#include "core/dart_isolate_context.h"
#include "foundation/logging.h"
#include "webf_test_env.h"
#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/cppgc/member.h"
#include "core/css/css_default_style_sheets.h"

namespace webf {

class StyleBuilderTest : public ::testing::Test {
 protected:
  void SetUp() override {
    // Initialize test environment
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    document_ = context_->document();
    
    // Ensure core globals are initialized
    InitializeCoreGlobals();
  }

  void TearDown() override {
    // Clear elements
    test_elements_.clear();
    
    // Force cleanup following WebF ExecutingContext destructor pattern
    if (context_ && context_->IsCtxValid()) {
      JSValue exception = JS_GetException(context_->ctx());
      if (JS_IsObject(exception) || JS_IsException(exception)) {
        context_->ReportError(exception);
        JS_FreeValue(context_->ctx(), exception);
      }
      
      context_->DrainMicrotasks();
      
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

  // Create an element and keep it alive for the test
  HTMLDivElement* CreateTestElement() {
    auto* element = MakeGarbageCollected<HTMLDivElement>(*document_);
    // Append to body to establish proper parent relationship
    document_->body()->appendChild(element, ASSERT_NO_EXCEPTION());
    // Keep a reference to prevent GC
    test_elements_.push_back(Member<HTMLDivElement>(element));
    return element;
  }

  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_ = nullptr;
  Document* document_ = nullptr;
  std::vector<Member<HTMLDivElement>> test_elements_;
};

TEST_F(StyleBuilderTest, ApplyInitialProperty_Color) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  // Create parent style
  ComputedStyleBuilder parent_builder;
  parent_builder.SetColor(Color(255, 0, 0)); // Red
  auto parent_style = parent_builder.TakeStyle();
  
  // Create StyleResolverState
  StyleResolverState state(*document_, *element);
  state.SetParentStyle(parent_style.get());
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetColor(Color(255, 0, 0)); // Red
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property for color
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kColor, state);
  
  // Color should be reset to initial (black)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->Color(), Color::kBlack);
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_BackgroundColor) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetBackgroundColor(Color(0, 255, 0)); // Green
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kBackgroundColor, state);
  
  // Background color should be reset to initial (transparent)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->BackgroundColor(), Color::kTransparent);
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_Display) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetDisplay(EDisplay::kBlock);
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kDisplay, state);
  
  // Display should be reset to initial (inline)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->Display(), EDisplay::kInline);
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_Position) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetPosition(EPosition::kAbsolute);
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kPosition, state);
  
  // Position should be reset to initial (static)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->Position(), EPosition::kStatic);
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_Width) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetWidth(Length::Fixed(100));
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kWidth, state);
  
  // Width should be reset to initial (auto)
  auto style = state.TakeComputedStyle();
  EXPECT_TRUE(style->Width().IsAuto());
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_Margins) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetMarginTop(Length::Fixed(10));
  builder.SetMarginRight(Length::Fixed(20));
  builder.SetMarginBottom(Length::Fixed(30));
  builder.SetMarginLeft(Length::Fixed(40));
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial properties
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kMarginTop, state);
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kMarginRight, state);
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kMarginBottom, state);
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kMarginLeft, state);
  
  // All margins should be reset to initial (0)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->MarginTop(), Length::Fixed(0));
  EXPECT_EQ(style->MarginRight(), Length::Fixed(0));
  EXPECT_EQ(style->MarginBottom(), Length::Fixed(0));
  EXPECT_EQ(style->MarginLeft(), Length::Fixed(0));
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_Opacity) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetOpacity(0.5f);
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kOpacity, state);
  
  // Opacity should be reset to initial (1.0)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->Opacity(), 1.0f);
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_ZIndex) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetZIndex(100);
  builder.SetHasAutoZIndex(false);
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kZIndex, state);
  
  // Z-index should be reset to initial (0, auto)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->ZIndex(), 0);
  EXPECT_TRUE(style->HasAutoZIndex());
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_FlexDirection) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  builder.SetFlexDirection(EFlexDirection::kColumn);
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kFlexDirection, state);
  
  // Flex-direction should be reset to initial (row)
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->FlexDirection(), EFlexDirection::kRow);
}

TEST_F(StyleBuilderTest, ApplyInitialProperty_FontSize) {
  MemberMutationScope mutation_scope{context_};
  auto* element = CreateTestElement();
  
  StyleResolverState state(*document_, *element);
  
  // Initialize the style builder
  const ComputedStyle& initial_style = ComputedStyle::GetInitialStyle();
  ComputedStyleBuilder builder(initial_style);
  state.SetComputedStyleBuilder(std::move(builder));
  
  // Set a custom font size
  state.GetFontBuilder().SetFontSize(24.0f);
  
  // Apply initial property
  StyleBuilder::ApplyInitialProperty(CSSPropertyID::kFontSize, state);
  
  // Font size should be reset to initial (16px)
  state.GetFontBuilder().CreateFont(state.StyleBuilder(), nullptr);
  auto style = state.TakeComputedStyle();
  EXPECT_EQ(style->GetFontSize(), 16.0f);
}

}  // namespace webf
