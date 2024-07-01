//
// Created by 谢作兵 on 17/06/24.
//

#ifndef WEBF_CSS_RULE_H
#define WEBF_CSS_RULE_H

#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/cppgc/member.h"

namespace webf {

class CSSParserContext;
class CSSRuleList;
class CSSStyleSheet;
class StyleRuleBase;
class MediaQuerySetOwner;
enum class SecureContextMode;
class ExecutingContext;
class ExceptionState;


class  CSSRule : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  ~CSSRule() override = default;

  enum Type {
    // Web-exposed values, see css_rule.idl:
    kStyleRule = 1,
    kCharsetRule = 2,
    kImportRule = 3,
    kMediaRule = 4,
    kFontFaceRule = 5,
    kPageRule = 6,
    kKeyframesRule = 7,
    kKeyframeRule = 8,
    kNamespaceRule = 10,
    kCounterStyleRule = 11,
    kSupportsRule = 12,
    kFontFeatureValuesRule = 14,
    kViewportRule = 15,
    // CSSOM constants are deprecated [1], and there will be no new
    // web-exposed values.
    //
    // [1] https://wiki.csswg.org/spec/cssom-constants

    // Values for internal use, not web-exposed:
    kPropertyRule,
    kContainerRule,
    kLayerBlockRule,
    kLayerStatementRule,
    kFontPaletteValuesRule,
    kScopeRule,
    kFontFeatureRule,
    kStartingStyleRule,
    kViewTransitionRule,
    kPositionTryRule,
  };

  virtual Type GetType() const = 0;

  // https://drafts.csswg.org/cssom/#dom-cssrule-type
  int type() const {
    Type type = GetType();
    return type > Type::kViewportRule ? 0 : static_cast<int>(type);
  }

  virtual AtomicString cssText() const = 0;
  virtual void Reattach(StyleRuleBase*) = 0;

  virtual CSSRuleList* cssRules() const { return nullptr; }
  virtual MediaQuerySetOwner* GetMediaQuerySetOwner() { return nullptr; }

  void SetParentStyleSheet(CSSStyleSheet*);

  void SetParentRule(CSSRule*);

  void Trace(GCVisitor*) const override;

  CSSStyleSheet* parentStyleSheet() const {
    if (parent_is_rule_) {
      return parent_ ? ParentAsCSSRule()->parentStyleSheet() : nullptr;
    }
    return ParentAsCSSStyleSheet();
  }

  CSSRule* parentRule() const {
    return parent_is_rule_ ? ParentAsCSSRule() : nullptr;
  }

  // The CSSOM spec states that "setting the cssText attribute must do nothing."
  void setCSSText(const AtomicString&) {}

  virtual void UseCountForSignalAffected() {}

 protected:
  explicit CSSRule(CSSStyleSheet* parent);

  bool HasCachedSelectorText() const { return has_cached_selector_text_; }
  void SetHasCachedSelectorText(bool has_cached_selector_text) const {
    has_cached_selector_text_ = has_cached_selector_text;
  }

  const CSSParserContext* ParserContext(SecureContextMode) const;


 private:
  bool VerifyParentIsCSSRule() const;
  bool VerifyParentIsCSSStyleSheet() const;

  CSSRule* ParentAsCSSRule() const {
    assert(parent_is_rule_);
    assert(VerifyParentIsCSSRule());
    return reinterpret_cast<CSSRule*>(parent_.Get());
  }
  CSSStyleSheet* ParentAsCSSStyleSheet() const {
    assert(!parent_is_rule_);
    assert(VerifyParentIsCSSStyleSheet());
    return reinterpret_cast<CSSStyleSheet*>(parent_.Get());
  }

  mutable unsigned char has_cached_selector_text_ : 1;
  unsigned char parent_is_rule_ : 1;

  // parent_ should reference either CSSRule or CSSStyleSheet (both are
  // descendants of ScriptWrappable). This field should only be accessed
  // via the getters above (ParentAsCSSRule and ParentAsCSSStyleSheet).
  Member<ScriptWrappable> parent_;

  friend StyleRuleBase* ParseRuleForInsert(
      const ExecutingContext* execution_context,
      const AtomicString& rule_string,
      unsigned index,
      size_t num_child_rules,
      CSSRule& parent_rule,
      ExceptionState& exception_state);
};
}  // namespace webf

#endif  // WEBF_CSS_RULE_H
