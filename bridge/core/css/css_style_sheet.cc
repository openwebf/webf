/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "css_style_sheet.h"
#include "bindings/qjs/script_promise_resolver.h"
#include "core/css/css_import_rule.h"
#include "core/css/css_rule.h"
#include "core/css/css_rule_list.h"
#include "core/css/media_list.h"
#include "core/css/media_query_evaluator.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/parser/css_parser_impl.h"
#include "core/css/style_sheet_contents.h"
#include "core/dom/document.h"
#include "core/html/html_link_element.h"
#include "core/html/html_style_element.h"
#include "core/svg/svg_style_element.h"
#include "html_element_type_helper.h"
#include "qjs_union_dom_stringmedia_list.h"

#include <utility>
#include "css_rule.h"
#include "style_sheet_contents.h"

namespace webf {

class StyleSheetCSSRuleList final : public CSSRuleList {
 public:
  StyleSheetCSSRuleList(CSSStyleSheet* sheet) : style_sheet_(sheet), CSSRuleList(sheet->ctx()) {}

  void Trace(GCVisitor* visitor) const override {
    visitor->TraceMember(style_sheet_);
    CSSRuleList::Trace(visitor);
  }

 private:
  unsigned length() const override { return style_sheet_->length(); }
  CSSRule* Item(unsigned index, bool trigger_use_counters) const override {
    return style_sheet_->item(index, trigger_use_counters);
  }

  CSSStyleSheet* GetStyleSheet() const override { return style_sheet_.Get(); }

  Member<CSSStyleSheet> style_sheet_;
};

#if DCHECK_IS_ON()
static bool IsAcceptableCSSStyleSheetParent(const Node& parent_node) {
  // Only these nodes can be parents of StyleSheets, and they need to call
  // clearOwnerNode() when moved out of document. Note that destructor of
  // the nodes don't call clearOwnerNode() with Oilpan.
  return parent_node.IsDocumentNode() || IsA<HTMLLinkElement>(parent_node) || IsA<HTMLStyleElement>(parent_node) ||
         IsA<SVGStyleElement>(parent_node);
}
#endif

// static
const Document* CSSStyleSheet::SingleOwnerDocument(const CSSStyleSheet* style_sheet) {
  if (style_sheet) {
    return StyleSheetContents::SingleOwnerDocument(style_sheet->Contents().get());
  }
  return nullptr;
}

CSSStyleSheet* CSSStyleSheet::Create(Document& document,
                                     const CSSStyleSheetInit* options,
                                     ExceptionState& exception_state) {
  return CSSStyleSheet::Create(document, document.BaseURL(), options, exception_state);
}

CSSStyleSheet* CSSStyleSheet::Create(Document& document,
                                     const KURL& base_url,
                                     const CSSStyleSheetInit* options,
                                     ExceptionState& exception_state) {
  auto parser_context = std::make_shared<CSSParserContext>(document, base_url);

  auto contents = std::make_shared<StyleSheetContents>(parser_context);
  return MakeGarbageCollected<CSSStyleSheet>(document.GetExecutingContext(), contents, document, options);
}

CSSStyleSheet* CSSStyleSheet::CreateInline(ExecutingContext* context,
                                           std::shared_ptr<StyleSheetContents> sheet,
                                           Node& owner_node,
                                           const TextPosition& start_position) {
  DCHECK(sheet);
  return MakeGarbageCollected<CSSStyleSheet>(context, std::move(sheet), owner_node, true, start_position);
}

CSSStyleSheet* CSSStyleSheet::CreateInline(Node& owner_node, const KURL& base_url, const TextPosition& start_position) {
  Document& owner_node_document = owner_node.GetDocument();
  auto parser_context =
      std::make_shared<CSSParserContext>(owner_node_document, owner_node_document.BaseURL().GetString());
  auto sheet = std::make_shared<StyleSheetContents>(parser_context, base_url.GetString());
  return MakeGarbageCollected<CSSStyleSheet>(owner_node.GetExecutingContext(), sheet, owner_node, true, start_position);
}

CSSStyleSheet::CSSStyleSheet(ExecutingContext* context,
                             std::shared_ptr<StyleSheetContents> contents,
                             CSSImportRule* owner_rule)
    : contents_(std::move(contents)),
      owner_rule_(owner_rule),
      start_position_(TextPosition::MinimumPosition()),
      StyleSheet(context->ctx()) {
  contents_->RegisterClient(this);
}

CSSStyleSheet::CSSStyleSheet(ExecutingContext* context,
                             std::shared_ptr<StyleSheetContents> contents,
                             Document& document,
                             std::shared_ptr<const CSSStyleSheetInit> options)
    : CSSStyleSheet(context, contents, nullptr) {
  // Following steps at spec draft
  // https://wicg.github.io/construct-stylesheets/#dom-cssstylesheet-cssstylesheet
  SetConstructorDocument(document);
  SetTitle(options->title());
  ClearOwnerNode();
  ClearOwnerRule();
  Contents()->RegisterClient(this);
  switch (options->media()->GetContentType()) {
    case QJSUnionDomStringMediaList::ContentType::kMediaList:
      media_queries_ = options->media()->GetAsMediaList()->Queries();
      break;
    case QJSUnionDomStringMediaList::ContentType::kDomString:
      media_queries_ =
          MediaQuerySet::Create(options->media()->GetAsDomString().ToStdString(ctx()), document.GetExecutingContext());
      break;
  }
  if (options->alternate()) {
    SetAlternateFromConstructor(true);
  }
  if (options->disabled()) {
    setDisabled(true);
  }
}

CSSStyleSheet::CSSStyleSheet(ExecutingContext* context,
                             std::shared_ptr<StyleSheetContents> contents,
                             Node& owner_node,
                             bool is_inline_stylesheet,
                             const TextPosition& start_position)
    : contents_(std::move(contents)),
      owner_node_(&owner_node),
      owner_parent_or_shadow_host_element_(owner_node.ParentOrShadowHostElement()),
      start_position_(start_position),
      is_inline_stylesheet_(is_inline_stylesheet),
      StyleSheet(context->ctx()) {
#if DCHECK_IS_ON()
  DCHECK(IsAcceptableCSSStyleSheetParent(owner_node));
#endif
  contents_->RegisterClient(this);
}

CSSStyleSheet::~CSSStyleSheet() = default;

void CSSStyleSheet::WillMutateRules() {
  // If we are the only client it is safe to mutate.
  if (!contents_->IsUsedFromTextCache()) {
    contents_->StartMutation();
    assert(false);
    //    contents_->ClearRuleSet();
    return;
  }
  // Only cacheable stylesheets should have multiple clients.
  DCHECK(contents_->IsCacheableForStyleElement() || contents_->IsCacheableForResource());

  // Copy-on-write. Note that this eagerly parses any rules that were
  // lazily parsed.
  contents_->UnregisterClient(this);
  contents_ = contents_->Copy();
  contents_->RegisterClient(this);

  contents_->StartMutation();

  assert(false);
  // Any existing CSSOM wrappers need to be connected to the copied child rules.
  //  ReattachChildRuleCSSOMWrappers();
}

void CSSStyleSheet::DidMutate(Mutation mutation) {
  //  if (mutation == Mutation::kRules) {
  //    DCHECK(contents_->IsMutable());
  //    DCHECK_LE(contents_->ClientSize(), 1u);
  //  }
  //  Document* document = OwnerDocument();
  //  if (!document || !document->IsActive()) {
  //    return;
  //  }
  //  if (!custom_element_tag_names_.empty()) {
  //    document->GetStyleEngine().ScheduleCustomElementInvalidations(custom_element_tag_names_);
  //  }
  //  bool invalidate_matched_properties_cache = false;
  //  if (ownerNode() && ownerNode()->isConnected()) {
  //    document->GetStyleEngine().SetNeedsActiveStyleUpdate(ownerNode()->GetTreeScope());
  //    invalidate_matched_properties_cache = true;
  //  } else if (!adopted_tree_scopes_.empty()) {
  //    for (auto tree_scope : adopted_tree_scopes_.Keys()) {
  //      // It is currently required that adopted sheets can not be moved between
  //      // documents.
  //      DCHECK(tree_scope->GetDocument() == document);
  //      if (!tree_scope->RootNode().isConnected()) {
  //        continue;
  //      }
  //      document->GetStyleEngine().SetNeedsActiveStyleUpdate(*tree_scope);
  //      invalidate_matched_properties_cache = true;
  //    }
  //  }
  //  if (mutation == Mutation::kRules) {
  //    if (invalidate_matched_properties_cache) {
  //      document->GetStyleResolver().InvalidateMatchedPropertiesCache();
  //    }
  //    probe::DidMutateStyleSheet(document, this);
  //  }
}

void CSSStyleSheet::EnableRuleAccessForInspector() {
  enable_rule_access_for_inspector_ = true;
}
void CSSStyleSheet::DisableRuleAccessForInspector() {
  enable_rule_access_for_inspector_ = false;
}

CSSStyleSheet::InspectorMutationScope::InspectorMutationScope(CSSStyleSheet* sheet) : style_sheet_(sheet) {
  style_sheet_->EnableRuleAccessForInspector();
}

CSSStyleSheet::InspectorMutationScope::~InspectorMutationScope() {
  style_sheet_->DisableRuleAccessForInspector();
}

// void CSSStyleSheet::ReattachChildRuleCSSOMWrappers() {
//   for (unsigned i = 0; i < child_rule_cssom_wrappers_.size(); ++i) {
//     if (!child_rule_cssom_wrappers_[i]) {
//       continue;
//     }
//     child_rule_cssom_wrappers_[i]->Reattach(contents_->RuleAt(i));
//   }
// }

void CSSStyleSheet::setDisabled(bool disabled) {
  if (disabled == is_disabled_) {
    return;
  }
  is_disabled_ = disabled;

  DidMutate(Mutation::kSheet);
}

bool CSSStyleSheet::MatchesMediaQueries(const MediaQueryEvaluator& evaluator) {
  media_query_result_flags_.Clear();

  if (!media_queries_) {
    return true;
  }
  return evaluator.Eval(*media_queries_, &media_query_result_flags_);
}

void CSSStyleSheet::AddedAdoptedToTreeScope(TreeScope& tree_scope) {
  bool is_new_entry = adopted_tree_scopes_.count(&tree_scope) == 0;
  adopted_tree_scopes_.insert(std::make_pair(&tree_scope, 1u));
  if (!is_new_entry) {
    adopted_tree_scopes_[&tree_scope]++;
  }
}

void CSSStyleSheet::RemovedAdoptedFromTreeScope(TreeScope& tree_scope) {
  auto it = adopted_tree_scopes_.find(&tree_scope);
  if (it != adopted_tree_scopes_.end()) {
    CHECK_GT(it->second, 0u);
    if (--it->second == 0) {
      adopted_tree_scopes_.erase(&tree_scope);
    }
  }
}

bool CSSStyleSheet::IsAdoptedByTreeScope(TreeScope& tree_scope) {
  return adopted_tree_scopes_.count(&tree_scope) > 0;
}

bool CSSStyleSheet::HasViewportDependentMediaQueries() const {
  return media_query_result_flags_.is_viewport_dependent;
}

bool CSSStyleSheet::HasDynamicViewportDependentMediaQueries() const {
  return media_query_result_flags_.unit_flags & MediaQueryExpValue::UnitFlags::kDynamicViewport;
}

unsigned CSSStyleSheet::length() const {
  return contents_->RuleCount();
}

CSSRule* CSSStyleSheet::item(unsigned index, bool trigger_use_counters) {
  unsigned rule_count = length();
  if (index >= rule_count) {
    return nullptr;
  }

  if (child_rule_cssom_wrappers_.empty()) {
    child_rule_cssom_wrappers_.resize(rule_count);
  }
  DCHECK_EQ(child_rule_cssom_wrappers_.size(), rule_count);

  Member<CSSRule>& css_rule = child_rule_cssom_wrappers_[index];
  if (!css_rule) {
    css_rule = contents_->RuleAt(index)->CreateCSSOMWrapper(index, this, trigger_use_counters);
  }
  return css_rule.Get();
}

void CSSStyleSheet::ClearOwnerNode() {
  DidMutate(Mutation::kSheet);
  if (owner_node_) {
    contents_->UnregisterClient(this);
  }
  owner_node_ = nullptr;
}

CSSRuleList* CSSStyleSheet::rules(ExceptionState& exception_state) {
  return cssRules(exception_state);
}

unsigned CSSStyleSheet::insertRule(const AtomicString& rule_string, unsigned index, ExceptionState& exception_state) {
  DCHECK(child_rule_cssom_wrappers_.empty() || child_rule_cssom_wrappers_.size() == contents_->RuleCount());

  if (index > length()) {
    exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                   "The index provided (" + std::to_string(index) +
                                       ") is larger than the maximum index (" + std::to_string(length()) + ").");
    return 0;
  }

  const auto context = std::make_shared<CSSParserContext>(kHTMLStandardMode);

  std::shared_ptr<StyleRuleBase> rule =
      CSSParser::ParseRule(context, contents_, CSSNestingType::kNone,
                           /*parent_rule_for_nesting=*/nullptr, rule_string.ToStdString(ctx()));

  if (!rule) {
    return 0;
    exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                   "Failed to parse the rule '" + rule_string.ToStdString(ctx()) + "'.");
  }
  RuleMutationScope mutation_scope(this);
  if (rule->IsImportRule() && IsConstructed()) {
    exception_state.ThrowException(ctx(), ErrorType::InternalError,
                                   "Can't insert @import rules into a constructed stylesheet.");
    return 0;
  }
  bool success = contents_->WrapperInsertRule(rule.get(), index);
  if (!success) {
    if (rule->IsNamespaceRule()) {
      exception_state.ThrowException(ctx(), ErrorType::InternalError, "Failed to insert the rule");
    } else {
      exception_state.ThrowException(ctx(), ErrorType::InternalError, "Failed to insert the rule.");
    }
    return 0;
  }
  if (!child_rule_cssom_wrappers_.empty()) {
    child_rule_cssom_wrappers_.insert(child_rule_cssom_wrappers_.begin() + index, Member<CSSRule>(nullptr));
  }

  return index;
}

void CSSStyleSheet::deleteRule(unsigned index, ExceptionState& exception_state) {
  DCHECK(child_rule_cssom_wrappers_.empty() || child_rule_cssom_wrappers_.size() == contents_->RuleCount());

  if (index >= length()) {
    if (length()) {
      exception_state.ThrowException(ctx(), ErrorType::RangeError,
                                     "The index provided (" + std::to_string(index) +
                                         ") is larger than the maximum index (" + std::to_string(length() - 1) + ").");
    } else {
      exception_state.ThrowException(ctx(), ErrorType::RangeError, "Style sheet is empty (length 0).");
    }
    return;
  }

  RuleMutationScope mutation_scope(this);

  bool success = contents_->WrapperDeleteRule(index);
  if (!success) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "Failed to delete rule");
    return;
  }

  if (!child_rule_cssom_wrappers_.empty()) {
    if (child_rule_cssom_wrappers_[index]) {
      child_rule_cssom_wrappers_[index]->SetParentStyleSheet(nullptr);
    }
    child_rule_cssom_wrappers_.erase(child_rule_cssom_wrappers_.begin() + index);
  }
}

int CSSStyleSheet::addRule(const AtomicString& selector,
                           const AtomicString& style,
                           int index,
                           ExceptionState& exception_state) {
  StringBuilder text;
  text.Append(selector.ToStdString(ctx()));
  text.Append(" { ");
  text.Append(style.ToStdString(ctx()));
  if (!style.IsEmpty()) {
    text.Append(' ');
  }
  text.Append('}');
  insertRule(AtomicString(ctx(), text.ReleaseString()), index, exception_state);

  // As per Microsoft documentation, always return -1.
  return -1;
}

int CSSStyleSheet::addRule(const AtomicString& selector, const AtomicString& style, ExceptionState& exception_state) {
  return addRule(selector, style, length(), exception_state);
}

ScriptPromise CSSStyleSheet::replace(ScriptState* script_state,
                                     const AtomicString& text,
                                     ExceptionState& exception_state) {
  //  if (!IsConstructed()) {
  //    exception_state.ThrowException(ctx(), ErrorType::RangeError,
  //                                   "Can't call replace on non-constructed CSSStyleSheets.");
  //    return EmptyPromise();
  //  }
  //  SetText(text, CSSImportRules::kIgnoreWithWarning);
  //  probe::DidReplaceStyleSheetText(OwnerDocument(), this, text);
  //  // We currently parse synchronously, and since @import support was removed,
  //  // nothing else happens asynchronously. This API is left as-is, so that future
  //  // async parsing can still be supported here.
  //  return ToResolvedPromise<CSSStyleSheet>(script_state, this);
  auto resolver = ScriptPromiseResolver::Create(GetExecutingContext());
  return resolver->Promise();
}

void CSSStyleSheet::replaceSync(const AtomicString& text, ExceptionState& exception_state) {
  //  if (!IsConstructed()) {
  //    return exception_state.ThrowException(ctx(), ErrorType::TypeError,
  //                                             "Can't call replaceSync on non-constructed CSSStyleSheets.");
  //  }
  //  SetText(text, CSSImportRules::kIgnoreWithWarning);
  //  probe::DidReplaceStyleSheetText(OwnerDocument(), this, text);
}

CSSRuleList* CSSStyleSheet::cssRules(ExceptionState& exception_state) {
  if (!rule_list_cssom_wrapper_) {
    rule_list_cssom_wrapper_ = MakeGarbageCollected<StyleSheetCSSRuleList>(this);
  }
  return rule_list_cssom_wrapper_.Get();
}

AtomicString CSSStyleSheet::href() const {
  return AtomicString(ctx(), contents_->OriginalURL());
}

KURL CSSStyleSheet::BaseURL() const {
  return contents_->BaseURL();
}

bool CSSStyleSheet::IsLoading() const {
  return contents_->IsLoading();
}

MediaList* CSSStyleSheet::media() {
  if (!media_queries_) {
    media_queries_ = MediaQuerySet::Create();
  }
  if (!media_cssom_wrapper_) {
    media_cssom_wrapper_ = MakeGarbageCollected<MediaList>(this);
  }
  return media_cssom_wrapper_.Get();
}

CSSStyleSheet* CSSStyleSheet::parentStyleSheet() const {
  return owner_rule_ ? owner_rule_->parentStyleSheet() : nullptr;
}

Document* CSSStyleSheet::OwnerDocument() const {
  if (CSSStyleSheet* parent = parentStyleSheet()) {
    return parent->OwnerDocument();
  }
  if (IsConstructed()) {
    DCHECK(!ownerNode());
    return ConstructorDocument();
  }
  return ownerNode() ? &ownerNode()->GetDocument() : nullptr;
}

bool CSSStyleSheet::SheetLoaded() {
  DCHECK(owner_node_);
  assert(false);
  //  SetLoadCompleted(owner_node_->SheetLoaded());
  return load_completed_;
}

void CSSStyleSheet::SetToPendingState() {
  SetLoadCompleted(false);
  //  owner_node_->SetToPendingState();
  assert(false);
}

void CSSStyleSheet::SetLoadCompleted(bool completed) {
  if (completed == load_completed_) {
    return;
  }

//  load_completed_ = completed;
//
//  if (completed) {
//    contents_->ClientLoadCompleted(this);
//  } else {
//    contents_->ClientLoadStarted(this);
//  }
}

void CSSStyleSheet::SetText(const AtomicString& text, CSSImportRules import_rules) {
  child_rule_cssom_wrappers_.clear();

  CSSStyleSheet::RuleMutationScope mutation_scope(this);
  contents_->ClearRules();
  bool allow_imports = import_rules == CSSImportRules::kAllow;
  if (contents_->ParseString(text.ToStdString(ctx()), allow_imports) == ParseSheetResult::kHasUnallowedImportRule &&
      import_rules == CSSImportRules::kIgnoreWithWarning) {
    WEBF_LOG(VERBOSE) << "@import rules are not allowed here. See "
                         "https://github.com/WICG/construct-stylesheets/issues/"
                         "119#issuecomment-588352418.";
  }
}

void CSSStyleSheet::SetAlternateFromConstructor(bool alternate_from_constructor) {
  alternate_from_constructor_ = alternate_from_constructor;
}

bool CSSStyleSheet::IsAlternate() const {
  assert(false);
//  if (owner_node_) {
//    auto* owner_element = DynamicTo<Element>(owner_node_.Get());
//    return owner_element && owner_element->FastGetAttribute(html_names::kRelAttr).Contains("alternate");
//  }
//  return alternate_from_constructor_;
  return false;
}

bool CSSStyleSheet::CanBeActivated(const AtomicString& current_preferrable_name) const {
  if (disabled()) {
    return false;
  }

//  if (owner_node_ && owner_node_->IsInShadowTree()) {
//    if (IsA<HTMLStyleElement>(owner_node_.Get()) || IsA<SVGStyleElement>(owner_node_.Get())) {
//      return true;
//    }
//  }

//  auto* html_link_element = DynamicTo<HTMLLinkElement>(owner_node_.Get());
//  if (!owner_node_ || !html_link_element ||
//      !html_link_element->IsEnabledViaScript()) {
//    if (!title_.empty() && title_ != current_preferrable_name) {
//      return false;
//    }
//  }

//  if (IsAlternate() && title_.empty()) {
//    return false;
//  }

  return true;
}

void CSSStyleSheet::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(owner_node_);
  visitor->TraceMember(owner_rule_);
  visitor->TraceMember(media_cssom_wrapper_);

  for(auto&& wrapper : child_rule_cssom_wrappers_) {
    visitor->TraceMember(wrapper);
  }
  visitor->TraceMember(rule_list_cssom_wrapper_);
  visitor->TraceMember(constructor_document_);
  contents_->Trace(visitor);
  StyleSheet::Trace(visitor);
}

}  // namespace webf
