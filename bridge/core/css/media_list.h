//
// Created by 谢作兵 on 18/06/24.
//

#ifndef WEBF_MEDIA_LIST_H
#define WEBF_MEDIA_LIST_H

#include "core/css/media_query.h"
#include "core/layout/geometry/axis.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/cppgc/member.h"

namespace webf {

class CSSRule;
class CSSStyleSheet;
class ExceptionState;
class ExecutingContext;
class MediaList;
class MediaQuery;
class MediaQuerySetOwner;

class MediaQuerySet {
 public:
  static std::shared_ptr<MediaQuerySet> Create() {
    return std::make_shared<MediaQuerySet>();
  }
  static MediaQuerySet* Create(const AtomicString& media_string,
                               const ExecutingContext*);

  MediaQuerySet();
  MediaQuerySet(const MediaQuerySet&);
  explicit MediaQuerySet(std::vector<std::shared_ptr<const MediaQuery>>);
  void Trace(GCVisitor*) const;

  const MediaQuerySet* CopyAndAdd(const AtomicString&, const ExecutingContext*) const;
  const MediaQuerySet* CopyAndRemove(const AtomicString&,
                                     const ExecutingContext*) const;

  const std::vector<std::shared_ptr<const MediaQuery>>& QueryVector() const {
    return queries_;
  }

  AtomicString MediaText() const;

 private:
  std::vector<std::shared_ptr<const MediaQuery>> queries_;
};

class MediaList final : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  explicit MediaList(CSSStyleSheet* parent_sheet);
  explicit MediaList(CSSRule* parent_rule);

  unsigned length() const { return Queries()->QueryVector().size(); }
  AtomicString item(unsigned index) const;
  void deleteMedium(const ExecutingContext*,
                    const AtomicString& old_medium,
                    ExceptionState&);
  void appendMedium(const ExecutingContext*, const AtomicString& new_medium);

  // Note that this getter doesn't require the ExecutingContext (except for
  // crbug.com/1268860 use-counting), but the attribute is marked as
  // [CallWith=ExecutingContext] so that the setter can have access to the
  // ExecutingContext.
  //
  // Prefer MediaTextInternal for internal use. (Avoids use-counter).
  AtomicString mediaText(ExecutingContext*) const;
  void setMediaText(const ExecutingContext*, const AtomicString&);
  AtomicString MediaTextInternal() const { return Queries()->MediaText(); }

  // Not part of CSSOM.
  CSSRule* ParentRule() const { return parent_rule_.Get(); }
  CSSStyleSheet* ParentStyleSheet() const { return parent_style_sheet_.Get(); }

  const MediaQuerySet* Queries() const;

  void Trace(GCVisitor*) const override;

 private:
  MediaQuerySetOwner* Owner() const;
  void NotifyMutation();

  Member<CSSStyleSheet> parent_style_sheet_;
  Member<CSSRule> parent_rule_;
};


}  // namespace webf

#endif  // WEBF_MEDIA_LIST_H
