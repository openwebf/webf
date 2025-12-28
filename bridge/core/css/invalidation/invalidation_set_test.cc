// Copyright 2014 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/invalidation/invalidation_set.h"

#include <algorithm>
#include <memory>
#include <vector>

#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/exception_state.h"
#include "core/dom/document.h"
#include "core/html/html_body_element.h"
#include "core/html/html_element.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {
namespace {

using BackingType = InvalidationSet::BackingType;
using BackingFlags = InvalidationSet::BackingFlags;
template <BackingType type>
using Backing = InvalidationSet::Backing<type>;

template <BackingType type>
bool HasAny(const Backing<type>& backing, const BackingFlags& flags, std::initializer_list<const char*> args) {
  for (const char* str : args) {
    if (backing.Contains(flags, AtomicString::CreateFromUTF8(str))) {
      return true;
    }
  }
  return false;
}

template <BackingType type>
bool HasAll(const Backing<type>& backing, const BackingFlags& flags, std::initializer_list<const char*> args) {
  for (const char* str : args) {
    if (!backing.Contains(flags, AtomicString::CreateFromUTF8(str))) {
      return false;
    }
  }
  return true;
}

TEST(InvalidationSetTest, Backing_Create) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;

  ASSERT_FALSE(backing.IsHashSet(flags));
}

TEST(InvalidationSetTest, Backing_Add) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;

  ASSERT_FALSE(backing.IsHashSet(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("test1"));
  ASSERT_FALSE(backing.IsHashSet(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("test2"));
  ASSERT_TRUE(backing.IsHashSet(flags));
  backing.Clear(flags);
}

TEST(InvalidationSetTest, Backing_AddSame) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;

  ASSERT_FALSE(backing.IsHashSet(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("test1"));
  ASSERT_FALSE(backing.IsHashSet(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("test1"));
  ASSERT_FALSE(backing.IsHashSet(flags));
  backing.Clear(flags);
}

TEST(InvalidationSetTest, Backing_Independence) {
  BackingFlags flags;

  Backing<BackingType::kClasses> classes;
  Backing<BackingType::kIds> ids;
  Backing<BackingType::kTagNames> tag_names;
  Backing<BackingType::kAttributes> attributes;

  classes.Add(flags, AtomicString::CreateFromUTF8("test1"));
  ids.Add(flags, AtomicString::CreateFromUTF8("test2"));
  tag_names.Add(flags, AtomicString::CreateFromUTF8("test3"));
  attributes.Add(flags, AtomicString::CreateFromUTF8("test4"));

  ASSERT_TRUE(classes.Contains(flags, AtomicString::CreateFromUTF8("test1")));
  ASSERT_FALSE(HasAny(classes, flags, {"test2", "test3", "test4"}));

  ASSERT_TRUE(ids.Contains(flags, AtomicString::CreateFromUTF8("test2")));
  ASSERT_FALSE(HasAny(ids, flags, {"test1", "test3", "test4"}));

  ASSERT_TRUE(tag_names.Contains(flags, AtomicString::CreateFromUTF8("test3")));
  ASSERT_FALSE(HasAny(tag_names, flags, {"test1", "test2", "test4"}));

  ASSERT_TRUE(attributes.Contains(flags, AtomicString::CreateFromUTF8("test4")));
  ASSERT_FALSE(HasAny(attributes, flags, {"test1", "test2", "test3"}));

  classes.Add(flags, AtomicString::CreateFromUTF8("test5"));
  tag_names.Add(flags, AtomicString::CreateFromUTF8("test6"));

  ASSERT_TRUE(HasAll(classes, flags, {"test1", "test5"}));
  ASSERT_FALSE(HasAny(classes, flags, {"test2", "test3", "test4", "test6"}));

  ASSERT_TRUE(ids.Contains(flags, AtomicString::CreateFromUTF8("test2")));
  ASSERT_FALSE(HasAny(ids, flags, {"test1", "test3", "test4", "test5", "test6"}));

  ASSERT_TRUE(HasAll(tag_names, flags, {"test3", "test6"}));
  ASSERT_FALSE(HasAny(tag_names, flags, {"test1", "test2", "test4", "test5"}));

  ASSERT_TRUE(attributes.Contains(flags, AtomicString::CreateFromUTF8("test4")));
  ASSERT_FALSE(HasAny(attributes, flags, {"test1", "test2", "test3"}));

  classes.Clear(flags);
  ids.Clear(flags);
  attributes.Clear(flags);

  auto all_test_strings = {"test1", "test2", "test3", "test4", "test5", "test6"};

  ASSERT_FALSE(HasAny(classes, flags, all_test_strings));
  ASSERT_FALSE(HasAny(ids, flags, all_test_strings));
  ASSERT_FALSE(HasAny(attributes, flags, all_test_strings));

  ASSERT_FALSE(classes.IsHashSet(flags));
  ASSERT_FALSE(ids.IsHashSet(flags));
  ASSERT_FALSE(attributes.IsHashSet(flags));

  ASSERT_TRUE(tag_names.IsHashSet(flags));
  ASSERT_TRUE(HasAll(tag_names, flags, {"test3", "test6"}));
  ASSERT_FALSE(HasAny(tag_names, flags, {"test1", "test2", "test4", "test5"}));
  tag_names.Clear(flags);
}

TEST(InvalidationSetTest, Backing_ClearContains) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;

  AtomicString test1 = AtomicString::CreateFromUTF8("test1");
  AtomicString test2 = AtomicString::CreateFromUTF8("test2");

  ASSERT_FALSE(backing.Contains(flags, test1));
  ASSERT_FALSE(backing.IsHashSet(flags));
  backing.Clear(flags);
  ASSERT_FALSE(backing.IsHashSet(flags));

  backing.Add(flags, test1);
  ASSERT_FALSE(backing.IsHashSet(flags));
  ASSERT_TRUE(backing.Contains(flags, test1));
  backing.Clear(flags);
  ASSERT_FALSE(backing.Contains(flags, test1));
  ASSERT_FALSE(backing.IsHashSet(flags));

  backing.Add(flags, test1);
  ASSERT_FALSE(backing.IsHashSet(flags));
  ASSERT_TRUE(backing.Contains(flags, test1));
  ASSERT_FALSE(backing.Contains(flags, test2));
  backing.Add(flags, test2);
  ASSERT_TRUE(backing.IsHashSet(flags));
  ASSERT_TRUE(backing.Contains(flags, test1));
  ASSERT_TRUE(backing.Contains(flags, test2));
  backing.Clear(flags);
  ASSERT_FALSE(backing.Contains(flags, test1));
  ASSERT_FALSE(backing.Contains(flags, test2));
  ASSERT_FALSE(backing.IsHashSet(flags));
}

TEST(InvalidationSetTest, Backing_BackingIsEmpty) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;

  ASSERT_TRUE(backing.IsEmpty(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("test1"));
  ASSERT_FALSE(backing.IsEmpty(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("test2"));
  backing.Clear(flags);
  ASSERT_TRUE(backing.IsEmpty(flags));
}

TEST(InvalidationSetTest, Backing_IsEmpty) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;

  ASSERT_TRUE(backing.IsEmpty(flags));

  backing.Add(flags, AtomicString::CreateFromUTF8("test1"));
  ASSERT_FALSE(backing.IsEmpty(flags));

  backing.Clear(flags);
  ASSERT_TRUE(backing.IsEmpty(flags));
}

TEST(InvalidationSetTest, Backing_Iterator) {
  AtomicString test1 = AtomicString::CreateFromUTF8("test1");
  AtomicString test2 = AtomicString::CreateFromUTF8("test2");
  AtomicString test3 = AtomicString::CreateFromUTF8("test3");
  {
    BackingFlags flags;
    Backing<BackingType::kClasses> backing;

    std::vector<AtomicString> strings;
    for (const AtomicString& str : backing.Items(flags)) {
      strings.push_back(str);
    }
    ASSERT_EQ(0u, strings.size());
  }

  {
    BackingFlags flags;
    Backing<BackingType::kClasses> backing;

    backing.Add(flags, test1);
    std::vector<AtomicString> strings;
    for (const AtomicString& str : backing.Items(flags)) {
      strings.push_back(str);
    }
    ASSERT_EQ(1u, strings.size());
    ASSERT_NE(strings.end(), std::find(strings.begin(), strings.end(), test1));
    backing.Clear(flags);
  }

  {
    BackingFlags flags;
    Backing<BackingType::kClasses> backing;

    backing.Add(flags, test1);
    backing.Add(flags, test2);
    backing.Add(flags, test3);
    std::vector<AtomicString> strings;
    for (const AtomicString& str : backing.Items(flags)) {
      strings.push_back(str);
    }
    ASSERT_EQ(3u, strings.size());
    ASSERT_NE(strings.end(), std::find(strings.begin(), strings.end(), test1));
    ASSERT_NE(strings.end(), std::find(strings.begin(), strings.end(), test2));
    ASSERT_NE(strings.end(), std::find(strings.begin(), strings.end(), test3));
    backing.Clear(flags);
  }
}

TEST(InvalidationSetTest, Backing_GetString) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;
  ASSERT_NE(nullptr, backing.GetString(flags));
  EXPECT_TRUE(backing.GetString(flags)->IsNull());
  backing.Add(flags, AtomicString::CreateFromUTF8("a"));
  EXPECT_EQ(AtomicString::CreateFromUTF8("a"), *backing.GetString(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("b"));
  EXPECT_EQ(nullptr, backing.GetString(flags));
  backing.Clear(flags);
}

TEST(InvalidationSetTest, Backing_GetHashSet) {
  BackingFlags flags;
  Backing<BackingType::kClasses> backing;
  EXPECT_EQ(nullptr, backing.GetHashSet(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("a"));
  EXPECT_EQ(nullptr, backing.GetHashSet(flags));
  backing.Add(flags, AtomicString::CreateFromUTF8("b"));
  EXPECT_NE(nullptr, backing.GetHashSet(flags));
  backing.Clear(flags);
}

TEST(InvalidationSetTest, ClassInvalidatesElement) {
  auto env = TEST_init();
  auto* context = env->page()->executingContext();
  MemberMutationScope mutation_scope{context};
  context->EnableBlinkEngine();

  Document* document = context->document();
  ASSERT_NE(nullptr, document);
  ASSERT_NE(nullptr, document->body());

  ExceptionState exception_state;
  HTMLElement* element = document->createElement(AtomicString::CreateFromUTF8("div"), exception_state);
  ASSERT_FALSE(exception_state.HasException());
  ASSERT_NE(nullptr, element);

  element->setAttribute(AtomicString::CreateFromUTF8("id"), AtomicString::CreateFromUTF8("test"));
  element->setAttribute(AtomicString::CreateFromUTF8("class"), AtomicString::CreateFromUTF8("a b"));
  document->body()->appendChild(element, ASSERT_NO_EXCEPTION());

  std::shared_ptr<InvalidationSet> set = DescendantInvalidationSet::Create();
  EXPECT_FALSE(set->InvalidatesElement(*element));
  set->AddClass(AtomicString::CreateFromUTF8("a"));
  EXPECT_TRUE(set->InvalidatesElement(*element));
  set->AddClass(AtomicString::CreateFromUTF8("c"));
  EXPECT_TRUE(set->InvalidatesElement(*element));

  set = DescendantInvalidationSet::Create();
  set->AddClass(AtomicString::CreateFromUTF8("c"));
  EXPECT_FALSE(set->InvalidatesElement(*element));
  set->AddClass(AtomicString::CreateFromUTF8("d"));
  EXPECT_FALSE(set->InvalidatesElement(*element));
}

TEST(InvalidationSetTest, AttributeInvalidatesElement) {
  auto env = TEST_init();
  auto* context = env->page()->executingContext();
  MemberMutationScope mutation_scope{context};
  context->EnableBlinkEngine();

  Document* document = context->document();
  ASSERT_NE(nullptr, document);
  ASSERT_NE(nullptr, document->body());

  ExceptionState exception_state;
  HTMLElement* element = document->createElement(AtomicString::CreateFromUTF8("div"), exception_state);
  ASSERT_FALSE(exception_state.HasException());
  ASSERT_NE(nullptr, element);

  element->setAttribute(AtomicString::CreateFromUTF8("id"), AtomicString::CreateFromUTF8("test"));
  element->setAttribute(AtomicString::CreateFromUTF8("a"), AtomicString::CreateFromUTF8(""));
  element->setAttribute(AtomicString::CreateFromUTF8("b"), AtomicString::CreateFromUTF8(""));
  document->body()->appendChild(element, ASSERT_NO_EXCEPTION());

  std::shared_ptr<InvalidationSet> set = DescendantInvalidationSet::Create();
  EXPECT_FALSE(set->InvalidatesElement(*element));
  set->AddAttribute(AtomicString::CreateFromUTF8("a"));
  EXPECT_TRUE(set->InvalidatesElement(*element));
  set->AddAttribute(AtomicString::CreateFromUTF8("c"));
  EXPECT_TRUE(set->InvalidatesElement(*element));

  set = DescendantInvalidationSet::Create();
  set->AddAttribute(AtomicString::CreateFromUTF8("c"));
  EXPECT_FALSE(set->InvalidatesElement(*element));
  set->AddAttribute(AtomicString::CreateFromUTF8("d"));
  EXPECT_FALSE(set->InvalidatesElement(*element));
}

TEST(InvalidationSetTest, SubtreeInvalid_AddBefore) {
  std::shared_ptr<InvalidationSet> set = DescendantInvalidationSet::Create();
  set->AddClass(AtomicString::CreateFromUTF8("a"));
  set->SetWholeSubtreeInvalid();

  ASSERT_TRUE(set->IsEmpty());
}

TEST(InvalidationSetTest, SubtreeInvalid_AddAfter) {
  std::shared_ptr<InvalidationSet> set = DescendantInvalidationSet::Create();
  set->SetWholeSubtreeInvalid();
  set->AddTagName(AtomicString::CreateFromUTF8("a"));

  ASSERT_TRUE(set->IsEmpty());
}

TEST(InvalidationSetTest, SubtreeInvalid_Combine_1) {
  std::shared_ptr<DescendantInvalidationSet> set1 = DescendantInvalidationSet::Create();
  std::shared_ptr<DescendantInvalidationSet> set2 = DescendantInvalidationSet::Create();

  set1->AddId(AtomicString::CreateFromUTF8("a"));
  set2->SetWholeSubtreeInvalid();

  set1->Combine(*set2);

  ASSERT_TRUE(set1->WholeSubtreeInvalid());
  ASSERT_TRUE(set1->IsEmpty());
}

TEST(InvalidationSetTest, SubtreeInvalid_Combine_2) {
  std::shared_ptr<DescendantInvalidationSet> set1 = DescendantInvalidationSet::Create();
  std::shared_ptr<DescendantInvalidationSet> set2 = DescendantInvalidationSet::Create();

  set1->SetWholeSubtreeInvalid();
  set2->AddAttribute(AtomicString::CreateFromUTF8("a"));

  set1->Combine(*set2);

  ASSERT_TRUE(set1->WholeSubtreeInvalid());
  ASSERT_TRUE(set1->IsEmpty());
}

TEST(InvalidationSetTest, SubtreeInvalid_AddCustomPseudoBefore) {
  std::shared_ptr<InvalidationSet> set = DescendantInvalidationSet::Create();
  set->SetCustomPseudoInvalid();
  ASSERT_FALSE(set->IsEmpty());

  set->SetWholeSubtreeInvalid();
  ASSERT_TRUE(set->IsEmpty());
}

TEST(InvalidationSetTest, SelfInvalidationSet_Combine) {
  std::shared_ptr<InvalidationSet> self_set = InvalidationSet::SelfInvalidationSet();

  EXPECT_TRUE(self_set->IsSelfInvalidationSet());
  self_set->Combine(*self_set);
  EXPECT_TRUE(self_set->IsSelfInvalidationSet());

  std::shared_ptr<InvalidationSet> set = DescendantInvalidationSet::Create();
  EXPECT_FALSE(set->InvalidatesSelf());
  set->Combine(*self_set);
  EXPECT_TRUE(set->InvalidatesSelf());
}

}  // namespace
}  // namespace webf
