// Copyright 2017 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "core/css/invalidation/pending_invalidations.h"

#include <memory>

#include "bindings/qjs/cppgc/mutation_scope.h"
#include "bindings/qjs/exception_state.h"
#include "core/css/element_rule_collector.h"
#include "core/css/style_engine.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/resolver/style_cascade.h"
#include "core/css/resolver/style_resolver.h"
#include "core/css/resolver/style_resolver_state.h"
#include "core/css/rule_set.h"
#include "core/dom/document.h"
#include "core/dom/element_traversal.h"
#include "core/html/html_body_element.h"
#include "core/html/html_style_element.h"
#include "html_names.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

namespace webf {
namespace {

class PendingInvalidationsTest : public testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = env_->page()->executingContext();
    context_->EnableBlinkEngine();
    document_ = context_->document();
  }

  Document& GetDocument() { return *document_; }
  StyleEngine& GetStyleEngine() { return GetDocument().EnsureStyleEngine(); }
  PendingInvalidations& GetPendingNodeInvalidations() { return GetStyleEngine().GetPendingNodeInvalidations(); }

 private:
  std::unique_ptr<WebFTestEnv> env_;
  ExecutingContext* context_ = nullptr;
  Document* document_ = nullptr;
};

TEST_F(PendingInvalidationsTest, ScheduleOnDocumentNode) {
  MemberMutationScope mutation_scope{GetDocument().GetExecutingContext()};

  ExceptionState exception_state;
  GetDocument().body()->setInnerHTML(
      AtomicString::CreateFromUTF8("<div id='d'></div><i id='i'></i><span></span>"), exception_state);
  ASSERT_FALSE(exception_state.HasException());

  GetDocument().UpdateStyleForThisDocument();

  Element* div = DynamicTo<Element>(GetDocument().body()->firstChild());
  ASSERT_TRUE(div);
  Element* i = DynamicTo<Element>(div->nextSibling());
  ASSERT_TRUE(i);
  Element* span = DynamicTo<Element>(i->nextSibling());
  ASSERT_TRUE(span);

  EXPECT_FALSE(div->NeedsStyleRecalc());
  EXPECT_FALSE(i->NeedsStyleRecalc());
  EXPECT_FALSE(span->NeedsStyleRecalc());

  std::shared_ptr<DescendantInvalidationSet> set = DescendantInvalidationSet::Create();
  set->AddTagName(AtomicString::CreateFromUTF8("div"));
  set->AddTagName(AtomicString::CreateFromUTF8("span"));

  InvalidationLists lists;
  lists.descendants.push_back(set);
  GetPendingNodeInvalidations().ScheduleInvalidationSetsForNode(lists, GetDocument());

  EXPECT_TRUE(GetDocument().NeedsStyleInvalidation());
  EXPECT_FALSE(GetDocument().ChildNeedsStyleInvalidation());

  GetStyleEngine().InvalidateStyle();

  EXPECT_FALSE(GetDocument().NeedsStyleInvalidation());
  EXPECT_FALSE(GetDocument().ChildNeedsStyleInvalidation());
  EXPECT_FALSE(GetDocument().NeedsStyleRecalc());
  EXPECT_TRUE(div->NeedsStyleRecalc());
  EXPECT_FALSE(i->NeedsStyleRecalc());
  EXPECT_TRUE(span->NeedsStyleRecalc());

  GetDocument().UpdateStyle();

  EXPECT_FALSE(div->NeedsStyleRecalc());
  EXPECT_FALSE(i->NeedsStyleRecalc());
  EXPECT_FALSE(span->NeedsStyleRecalc());
}

TEST_F(PendingInvalidationsTest, DescendantInvalidationOnDisplayNone) {
  MemberMutationScope mutation_scope{GetDocument().GetExecutingContext()};

  ExceptionState exception_state;
  constexpr const char kInnerHTML[] = R"HTML(
    <style>
      #a { display: none }
      .a .b { color: green }
    </style>
    <div id="a">
      <div class="b"></div>
      <div class="b"></div>
    </div>
  )HTML";
  static const AtomicString kInnerHTMLAtom =
      AtomicString::CreateFromUTF8(kInnerHTML, sizeof(kInnerHTML) - 1);
  GetDocument().body()->setInnerHTML(kInnerHTMLAtom, exception_state);
  ASSERT_FALSE(exception_state.HasException());

  GetDocument().UpdateStyleForThisDocument();

  Element* target = nullptr;
  for (Element* child = ElementTraversal::FirstChild(*GetDocument().body()); child;
       child = ElementTraversal::NextSibling(*child)) {
    ExceptionState attr_exception;
    AtomicString id_value = child->getAttribute(AtomicString::CreateFromUTF8("id"), attr_exception);
    if (!attr_exception.HasException() && id_value == AtomicString::CreateFromUTF8("a")) {
      target = child;
      break;
    }
  }
  ASSERT_TRUE(target);
  auto build_debug_trace = [&]() -> ::testing::Message {
    ::testing::Message msg;
    msg << "\n[DescendantInvalidationOnDisplayNone debug]\n";

    msg << "target: tag=" << target->localName().ToUTF8String()
        << " id_attr=" << target->id().ToUTF8String()
        << " HasID=" << target->HasID();
    if (target->HasID()) {
      msg << " IdForStyleResolution=" << target->IdForStyleResolution().ToUTF8String();
    }
    msg << " class_attr=" << target->className().ToUTF8String()
        << " HasClass=" << target->HasClass()
        << " isConnected=" << target->isConnected()
        << " NeedsStyleRecalc=" << target->NeedsStyleRecalc()
        << " display_none_flag=" << target->IsDisplayNoneForStyleInvalidation() << "\n";

    msg << "document: NeedsStyleInvalidation=" << GetDocument().NeedsStyleInvalidation()
        << " ChildNeedsStyleInvalidation=" << GetDocument().ChildNeedsStyleInvalidation() << "\n";

    const auto& author_sheets = GetStyleEngine().AuthorSheets();
    msg << "StyleEngine::AuthorSheets count=" << author_sheets.size() << "\n";
    MediaQueryEvaluator evaluator(GetDocument().GetExecutingContext());
    unsigned sheet_index = 0;
    for (const auto& contents : author_sheets) {
      msg << "  sheet[" << sheet_index++ << "] contents=" << contents.get();
      if (!contents) {
        msg << " <null>\n";
        continue;
      }
      msg << " rule_count=" << contents->RuleCount()
          << " child_rules=" << contents->ChildRules().size()
          << " base_url=" << contents->BaseURL().GetString();
      std::shared_ptr<RuleSet> rule_set = contents->EnsureRuleSet(evaluator);
      if (rule_set) {
        AtomicString id_a = AtomicString::CreateFromUTF8("a");
        msg << " id_rules(#a)=" << rule_set->IdRules(id_a).size();
      } else {
        msg << " rule_set=<null>";
      }
      msg << "\n";
    }

    Element* style_element = nullptr;
    if (GetDocument().body()) {
      for (Element* child = ElementTraversal::FirstChild(*GetDocument().body()); child;
           child = ElementTraversal::NextSibling(*child)) {
        if (child->HasTagName(html_names::kStyle)) {
          style_element = child;
          break;
        }
      }
    }
    msg << "<style> element in body: " << (style_element != nullptr) << "\n";
    if (style_element) {
      msg << "  style.innerHTML='" << style_element->innerHTML().ToUTF8String() << "'\n";
      auto* html_style = DynamicTo<HTMLStyleElement>(style_element);
      msg << "  DynamicTo<HTMLStyleElement>=" << (html_style != nullptr) << "\n";
      if (html_style) {
        CSSStyleSheet* sheet = html_style->sheet();
        msg << "  style.sheet=" << sheet << "\n";
        if (sheet && sheet->Contents()) {
          msg << "  style.sheet.contents=" << sheet->Contents().get()
              << " rule_count=" << sheet->Contents()->RuleCount()
              << " base_url=" << sheet->Contents()->BaseURL().GetString() << "\n";
        }
      }
    }

    Element* style_in_document = nullptr;
    if (GetDocument().documentElement()) {
      Element* stay_within = GetDocument().documentElement();
      for (Element* el = ElementTraversal::InclusiveFirstWithin(*stay_within); el;
           el = ElementTraversal::Next(*el, stay_within)) {
        if (el->HasTagName(html_names::kStyle)) {
          style_in_document = el;
          break;
        }
      }
    }
    msg << "<style> element in document: " << (style_in_document != nullptr) << "\n";
    if (style_in_document) {
      Element* parent_el = DynamicTo<Element>(style_in_document->parentNode());
      msg << "  style.parent=" << (parent_el ? parent_el->localName().ToUTF8String() : std::string("<null>"))
          << " isConnected=" << style_in_document->isConnected() << "\n";
    }

    // Recompute the declared winners for |target| the same way StyleEngine does.
    StyleResolver& resolver = GetStyleEngine().EnsureStyleResolver();
    StyleResolverState state(GetDocument(), *target);
    ElementRuleCollector collector(state, SelectorChecker::kResolvingStyle);
    resolver.CollectAllRules(state, collector, /*include_smil_properties*/ false);
    collector.SortAndTransferMatchedRules();

    const auto& matched = collector.GetMatchResult().GetMatchedProperties();
    msg << "matched property blocks=" << matched.size() << "\n";
    unsigned block = 0;
    for (const auto& entry : matched) {
      msg << "  block[" << block++ << "] origin=" << static_cast<int>(entry.origin)
          << " inline=" << entry.is_inline_style
          << " layer=" << entry.layer_level;
      if (entry.properties) {
        msg << " decls={" << entry.properties->AsText().ToUTF8String() << "}";
      } else {
        msg << " decls=<null>";
      }
      msg << "\n";
    }

    StyleCascade cascade(state);
    for (const auto& entry : matched) {
      if (!entry.properties) {
        continue;
      }
      if (entry.is_inline_style) {
        cascade.MutableMatchResult().AddInlineStyleProperties(entry.properties);
      } else {
        cascade.MutableMatchResult().AddMatchedProperties(entry.properties, entry.origin, entry.layer_level);
      }
    }
    std::shared_ptr<MutableCSSPropertyValueSet> winners = cascade.ExportWinningPropertySet();
    msg << "winning decls=" << (winners ? winners->AsText().ToUTF8String() : std::string("<null>")) << "\n";
    if (winners) {
      String display_value = winners->GetPropertyValue(CSSPropertyID::kDisplay);
      msg << "winning display='" << display_value.ToUTF8String() << "'\n";
    }

    return msg;
  };

  SCOPED_TRACE(build_debug_trace());
  EXPECT_TRUE(target->IsDisplayNoneForStyleInvalidation());

  target->setAttribute(AtomicString::CreateFromUTF8("class"), AtomicString::CreateFromUTF8("a"), exception_state);
  ASSERT_FALSE(exception_state.HasException());

  EXPECT_FALSE(GetDocument().NeedsStyleInvalidation());
  EXPECT_FALSE(GetDocument().ChildNeedsStyleInvalidation());
}

}  // namespace
}  // namespace webf
