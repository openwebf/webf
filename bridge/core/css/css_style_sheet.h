/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CSS_STYLE_SHEET_H
#define WEBF_CSS_STYLE_SHEET_H

#include "core/css/css_rule.h"
#include "core/css/media_query_set_owner.h"
#include "core/dom/document.h"
#include "core/dom/element.h"
#include "core/dom/node.h"
#include "qjs_union_dom_stringmedia_list.h"
#include "qjs_css_style_sheet_init.h"
#include "core/platform/text/text_position.h"
#include "style_sheet.h"

namespace webf {

class CSSRule;
class Document;
class StyleSheetContents;

class CSSImportRule;
class CSSRule;
class CSSRuleList;
class CSSStyleSheet;
class CSSStyleSheetInit;
class Document;
class Element;
class ExceptionState;
class MediaQuerySet;
class ScriptState;
class StyleSheetContents;
class MediaQueryEvaluator;
class TreeScope;

enum class CSSImportRules {
  kAllow,
  kIgnoreWithWarning,
};

class CSSStyleSheet final : public StyleSheet, public MediaQuerySetOwner {
  DEFINE_WRAPPERTYPEINFO();

 public:
  static const Document* SingleOwnerDocument(const CSSStyleSheet*);

  static CSSStyleSheet* Create(Document&, const CSSStyleSheetInit*, ExceptionState&);
  static CSSStyleSheet* Create(Document&, const KURL& base_url, const CSSStyleSheetInit*, ExceptionState&);
  static CSSStyleSheet* CreateInline(Node&,
                                     const KURL&,
                                     const TextPosition& start_position = TextPosition::MinimumPosition());
  static CSSStyleSheet* CreateInline(ExecutingContext* context,
                                     std::shared_ptr<StyleSheetContents>,
                                     Node& owner_node,
                                     const TextPosition& start_position = TextPosition::MinimumPosition());

  explicit CSSStyleSheet(ExecutingContext* context,
                         std::shared_ptr<StyleSheetContents>,
                         CSSImportRule* owner_rule = nullptr);
  CSSStyleSheet(ExecutingContext* context, std::shared_ptr<StyleSheetContents>, Document&, std::shared_ptr<const CSSStyleSheetInit>);
  CSSStyleSheet(ExecutingContext* context,
                std::shared_ptr<StyleSheetContents>,
                Node& owner_node,
                bool is_inline_stylesheet = false,
                const TextPosition& start_position = TextPosition::MinimumPosition());
  CSSStyleSheet(const CSSStyleSheet&) = delete;
  CSSStyleSheet& operator=(const CSSStyleSheet&) = delete;
  ~CSSStyleSheet() override;

  CSSStyleSheet* parentStyleSheet() const override;
  Node* ownerNode() const override { return owner_node_.Get(); }
  MediaList* media() override;
  AtomicString href() const override;
  AtomicString title() const { return title_; }
  bool disabled() const override { return is_disabled_; }
  void setDisabled(bool) override;

  CSSRuleList* cssRules(ExceptionState&);
  unsigned insertRule(const AtomicString& rule, unsigned index, ExceptionState&);
  void deleteRule(unsigned index, ExceptionState&);

  // IE Extensions
  CSSRuleList* rules(ExceptionState&);
  int addRule(const AtomicString& selector, const AtomicString& style, int index, ExceptionState&);
  int addRule(const AtomicString& selector, const AtomicString& style, ExceptionState&);
  void removeRule(unsigned index, ExceptionState& exception_state) { deleteRule(index, exception_state); }

  ScriptPromise replace(ScriptState* script_state, const AtomicString& text, ExceptionState&);
  void replaceSync(const AtomicString& text, ExceptionState&);

  // For CSSRuleList.
  unsigned length() const;
  CSSRule* item(unsigned index, bool trigger_use_counters = true);

  // Get an item, but signal that it's been requested internally from the
  // engine, and not directly from a script.
  CSSRule* ItemInternal(unsigned index) { return item(index, /*trigger_use_counters=*/false); }

  void ClearOwnerNode() override;

  CSSRule* ownerRule() const override { return owner_rule_.Get(); }

  // If the CSSStyleSheet was created with an owner node, this function
  // returns that owner node's parent element (or shadow host), if any.
  //
  // This is stored separately from `owner_node_`, because we need to access
  // this element even after ClearOwnerNode() has been called in order to
  // remove implicit scope triggers during ScopedStyleResolver::ResetStyle.
  //
  // Note that removing a <style> element from the document causes a call to
  // ClearOwnerNode to immediately, but the subsequent call to ResetStyle
  // happens during the next active style update.
  Element* OwnerParentOrShadowHostElement() const { return owner_parent_or_shadow_host_element_; }

  KURL BaseURL() const override;
  bool IsLoading() const override;

  void ClearOwnerRule() { owner_rule_ = nullptr; }
  Document* OwnerDocument() const;

  // MediaQuerySetOwner
  std::shared_ptr<const MediaQuerySet> MediaQueries() const override { return media_queries_; }
  void SetMediaQueries(std::shared_ptr<const MediaQuerySet> media_queries) override { media_queries_ = media_queries; }

  bool MatchesMediaQueries(const MediaQueryEvaluator&);
  const MediaQueryResultFlags& GetMediaQueryResultFlags() const { return media_query_result_flags_; }
  bool HasMediaQueryResults() const {
    return media_query_result_flags_.is_viewport_dependent || media_query_result_flags_.is_device_dependent;
  }
  bool HasViewportDependentMediaQueries() const;
  bool HasDynamicViewportDependentMediaQueries() const;
  void SetTitle(const AtomicString& title) { title_ = title; }

  void AddedAdoptedToTreeScope(TreeScope& tree_scope);
  void RemovedAdoptedFromTreeScope(TreeScope& tree_scope);

  // True when this stylesheet is among the TreeScope's adopted style sheets.
  //
  // https://drafts.csswg.org/cssom/#dom-documentorshadowroot-adoptedstylesheets
  bool IsAdoptedByTreeScope(TreeScope& tree_scope);

  // Associated document for constructed stylesheet. Always non-null for
  // constructed stylesheets, always null otherwise.
  Document* ConstructorDocument() const { return constructor_document_.Get(); }

  // Set constructor document for constructed stylesheet.
  void SetConstructorDocument(Document& document) { constructor_document_ = &document; }

  void AddToCustomElementTagNames(const AtomicString& local_tag_name) {
    custom_element_tag_names_.insert(local_tag_name);
  }

  class RuleMutationScope {
    WEBF_STACK_ALLOCATED();

   public:
    explicit RuleMutationScope(CSSStyleSheet*);
    explicit RuleMutationScope(CSSRule*);
    RuleMutationScope(const RuleMutationScope&) = delete;
    RuleMutationScope& operator=(const RuleMutationScope&) = delete;
    ~RuleMutationScope();

   private:
    CSSStyleSheet* style_sheet_;
  };

  void WillMutateRules();

  enum class Mutation {
    // Properties on the CSSStyleSheet object changed.
    kSheet,
    // Rules in the CSSStyleSheet changed.
    kRules,
  };
  void DidMutate(Mutation mutation);

  class InspectorMutationScope {
    WEBF_STACK_ALLOCATED();

   public:
    explicit InspectorMutationScope(CSSStyleSheet*);
    InspectorMutationScope(const InspectorMutationScope&) = delete;
    InspectorMutationScope& operator=(const InspectorMutationScope&) = delete;
    ~InspectorMutationScope();

   private:
    CSSStyleSheet* style_sheet_;
  };

  void EnableRuleAccessForInspector();
  void DisableRuleAccessForInspector();

  std::shared_ptr<StyleSheetContents> Contents() const { return contents_; }

  bool IsInline() const { return is_inline_stylesheet_; }
  TextPosition StartPositionInSource() const { return start_position_; }

  bool SheetLoaded();
  bool LoadCompleted() const { return load_completed_; }
  void SetToPendingState();
  void SetText(const AtomicString&, CSSImportRules);
  void SetAlternateFromConstructor(bool);
  bool CanBeActivated(const AtomicString& current_preferrable_name) const;
  bool IsConstructed() const { return ConstructorDocument(); }
  void SetIsForCSSModuleScript() { is_for_css_module_script_ = true; }
  bool IsForCSSModuleScript() const { return is_for_css_module_script_; }

  void Trace(GCVisitor*) const override;

 private:
  bool IsAlternate() const;
  bool IsCSSStyleSheet() const override { return true; }
  AtomicString type() const override { return AtomicString(ctx(), "text/css"); }

  void SetLoadCompleted(bool);

  bool AlternateFromConstructor() const { return alternate_from_constructor_; }

  std::shared_ptr<StyleSheetContents> contents_;
  std::shared_ptr<const MediaQuerySet> media_queries_;
  MediaQueryResultFlags media_query_result_flags_;
  AtomicString title_;

  Member<Node> owner_node_;
  Element* owner_parent_or_shadow_host_element_;
  Member<CSSRule> owner_rule_;
  // Used for knowing which TreeScopes to invalidate when an adopted stylesheet
  // is modified. The value is a count to keep track of the number of references
  // to the same sheet in the adoptedStyleSheets array.
  std::unordered_map<TreeScope*, size_t> adopted_tree_scopes_;
  // The Document this stylesheet was constructed for. Always non-null for
  // constructed stylesheets. Always null for other sheets.
  Member<Document> constructor_document_;
  std::set<AtomicString> custom_element_tag_names_;

  TextPosition start_position_;
  Member<MediaList> media_cssom_wrapper_;
  mutable std::vector<Member<CSSRule>> child_rule_cssom_wrappers_;
  mutable Member<CSSRuleList> rule_list_cssom_wrapper_;

  bool is_inline_stylesheet_ = false;
  bool is_for_css_module_script_ = false;
  bool is_disabled_ = false;
  bool load_completed_ = false;
  // This alternate variable is only used for constructed CSSStyleSheet.
  // For other CSSStyleSheet, consult the alternate attribute.
  bool alternate_from_constructor_ = false;
  bool enable_rule_access_for_inspector_ = false;
};

inline CSSStyleSheet::RuleMutationScope::RuleMutationScope(CSSStyleSheet* sheet) : style_sheet_(sheet) {
  style_sheet_->WillMutateRules();
}

inline CSSStyleSheet::RuleMutationScope::RuleMutationScope(CSSRule* rule)
    : style_sheet_(rule ? rule->parentStyleSheet() : nullptr) {
  if (style_sheet_) {
    style_sheet_->WillMutateRules();
  }
}

inline CSSStyleSheet::RuleMutationScope::~RuleMutationScope() {
  if (style_sheet_) {
    style_sheet_->DidMutate(Mutation::kRules);
  }
}

template <>
struct DowncastTraits<CSSStyleSheet> {
  static bool AllowFrom(const StyleSheet& sheet) { return sheet.IsCSSStyleSheet(); }
};

}  // namespace webf

#endif  // WEBF_CSS_STYLE_SHEET_H
