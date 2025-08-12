/*
 * Copyright (C) 2020 Google Inc. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "core/css/resolver/cascade_map.h"
#include "gtest/gtest.h"

namespace webf {

class CascadeMapTest : public ::testing::Test {
 protected:
  CascadeMap map_;
};

TEST_F(CascadeMapTest, AddAndFind) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  CascadePriority priority(StyleStyleCascadeOrigin::kAuthor, false, 0, 10);

  map_.Add(color_prop, priority);
  
  const CascadePriority* found = map_.Find(color_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetOrigin(), StyleStyleCascadeOrigin::kAuthor);
  EXPECT_EQ(found->GetPosition(), 10u);
}

TEST_F(CascadeMapTest, HigherPriorityWins) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  CascadePriority low_priority(StyleStyleCascadeOrigin::kUserAgent, false, 0, 5);
  CascadePriority high_priority(StyleStyleCascadeOrigin::kAuthor, false, 0, 10);

  map_.Add(color_prop, low_priority);
  map_.Add(color_prop, high_priority);
  
  const CascadePriority* found = map_.Find(color_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetOrigin(), StyleStyleCascadeOrigin::kAuthor);
}

TEST_F(CascadeMapTest, ImportantDeclarations) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  CascadePriority normal(StyleCascadeOrigin::kAuthor, false, 0, 5);
  CascadePriority important(StyleCascadeOrigin::kImportantAuthor, false, 0, 10);

  map_.Add(color_prop, normal);
  map_.Add(color_prop, important);
  
  const CascadePriority* found = map_.Find(color_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetOrigin(), StyleCascadeOrigin::kImportantAuthor);
  EXPECT_TRUE(found->IsImportant());
}

TEST_F(CascadeMapTest, CustomProperties) {
  CSSPropertyName custom_prop(AtomicString::CreateFromUTF8("--my-color"));
  CascadePriority priority(StyleCascadeOrigin::kAuthor, false, 0, 10);

  map_.Add(custom_prop, priority);
  
  const CascadePriority* found = map_.Find(custom_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetOrigin(), StyleCascadeOrigin::kAuthor);
  EXPECT_EQ(found->GetPosition(), 10u);
}

TEST_F(CascadeMapTest, InlineStyleTracking) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  CSSPropertyName width_prop(CSSPropertyID::kWidth);
  
  // Inline style that loses
  CascadePriority inline_style(StyleCascadeOrigin::kAuthor, true, 0, 5);
  CascadePriority important(StyleCascadeOrigin::kImportantAuthor, false, 0, 10);
  
  // Inline style that wins
  CascadePriority inline_wins(StyleCascadeOrigin::kAuthor, true, 0, 15);
  CascadePriority normal(StyleCascadeOrigin::kAuthor, false, 0, 10);

  // Color: inline style loses to important
  map_.Add(color_prop, inline_style);
  map_.Add(color_prop, important);
  
  // Width: inline style wins
  map_.Add(width_prop, normal);
  map_.Add(width_prop, inline_wins);
  
  EXPECT_TRUE(map_.InlineStyleLost().Test(CSSPropertyID::kColor));
  EXPECT_FALSE(map_.InlineStyleLost().Test(CSSPropertyID::kWidth));
}

TEST_F(CascadeMapTest, FindRevertLayer) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  
  // Same origin and tree order, different layers
  CascadePriority layer0(StyleCascadeOrigin::kAuthor, false, 0, 10);
  CascadePriority layer1(StyleCascadeOrigin::kAuthor, false, 1, 20);
  CascadePriority layer2(StyleCascadeOrigin::kAuthor, false, 2, 30);
  
  map_.Add(color_prop, layer0);
  map_.Add(color_prop, layer1);
  map_.Add(color_prop, layer2);
  
  // Find should return highest priority (layer2)
  const CascadePriority* found = map_.Find(color_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetLayerOrder(), 2u);
  
  // FindRevertLayer from layer2 should find layer1
  const CascadePriority* reverted = map_.FindRevertLayer(color_prop, layer2);
  ASSERT_NE(reverted, nullptr);
  EXPECT_EQ(reverted->GetLayerOrder(), 1u);
  
  // FindRevertLayer from layer1 should find layer0
  reverted = map_.FindRevertLayer(color_prop, layer1);
  ASSERT_NE(reverted, nullptr);
  EXPECT_EQ(reverted->GetLayerOrder(), 0u);
}

TEST_F(CascadeMapTest, Reset) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  CSSPropertyName custom_prop(AtomicString::CreateFromUTF8("--my-var"));
  
  CascadePriority priority(StyleCascadeOrigin::kAuthor, false, 0, 10);
  
  map_.Add(color_prop, priority);
  map_.Add(custom_prop, priority);
  
  EXPECT_NE(map_.Find(color_prop), nullptr);
  EXPECT_NE(map_.Find(custom_prop), nullptr);
  
  map_.Reset();
  
  EXPECT_EQ(map_.Find(color_prop), nullptr);
  EXPECT_EQ(map_.Find(custom_prop), nullptr);
}

TEST_F(CascadeMapTest, TransitionPriority) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  
  // Transitions have highest priority
  CascadePriority important(StyleCascadeOrigin::kImportantAuthor, false, 0, 10);
  CascadePriority transition = CascadePriority::ForTransition();
  
  map_.Add(color_prop, important);
  map_.Add(color_prop, transition);
  
  const CascadePriority* found = map_.Find(color_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetOrigin(), StyleCascadeOrigin::kTransition);
}

TEST_F(CascadeMapTest, AnimationPriority) {
  CSSPropertyName color_prop(CSSPropertyID::kColor);
  
  // Animations are between author and important author
  CascadePriority author(StyleCascadeOrigin::kAuthor, false, 0, 10);
  CascadePriority animation = CascadePriority::ForAnimation();
  CascadePriority important_author(StyleCascadeOrigin::kImportantAuthor, false, 0, 20);
  
  map_.Add(color_prop, author);
  map_.Add(color_prop, animation);
  
  const CascadePriority* found = map_.Find(color_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetOrigin(), StyleCascadeOrigin::kAnimation);
  
  // Important author beats animation
  map_.Add(color_prop, important_author);
  found = map_.Find(color_prop);
  ASSERT_NE(found, nullptr);
  EXPECT_EQ(found->GetOrigin(), StyleCascadeOrigin::kImportantAuthor);
}

}  // namespace webf