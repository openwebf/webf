//
// Created by 谢作兵 on 07/06/24.
//

#ifndef WEBF_STYLE_SHEET_H
#define WEBF_STYLE_SHEET_H

#include "bindings/qjs/script_wrappable.h"

namespace webf {

class Node;
class CSSRule; // TODO(xiezuobing)

class StyleSheet: public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();

 public:
  StyleSheet() = delete;
  explicit StyleSheet(JSContext* ctx);
  ~StyleSheet() override;

//    virtual bool disabled() const = 0;
//    virtual void setDisabled(bool) = 0;
    virtual Node* ownerNode() const = 0;
    virtual StyleSheet* parentStyleSheet() const { return nullptr; }
//    virtual AtomicString href() const = 0;
//    virtual AtomicString title() const = 0;
//    virtual MediaList* media() { return nullptr; }
//    virtual AtomicString type() const = 0;

//    virtual CSSRule* ownerRule() const { return nullptr; }
//    virtual void ClearOwnerNode() = 0;
//    virtual AtomicString BaseURL() const = 0;
//    virtual bool IsLoading() const = 0;
//    virtual bool IsCSSStyleSheet() const { return false; }

};

}  // namespace webf

#endif  // WEBF_STYLE_SHEET_H
