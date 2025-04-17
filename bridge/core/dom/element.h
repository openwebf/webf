/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#ifndef BRIDGE_ELEMENT_H
#define BRIDGE_ELEMENT_H

#include "bindings/qjs/cppgc/garbage_collected.h"
#include "bindings/qjs/script_promise.h"
#include "container_node.h"
#include "core/css/inline_css_style_declaration.h"
#include "core/native/native_function.h"
#include "element_data.h"
#include "legacy/bounding_client_rect.h"
#include "legacy/element_attributes.h"
#include "parent_node.h"
#include "plugin_api/element.h"
#include "qjs_scroll_to_options.h"

namespace webf {

class Element : public ContainerNode {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = Element*;

  enum class AttributeModificationReason {
    kDirectly,
    kByParser,
    kByCloning,
    kByMoveToNewDocument,
    kBySynchronizationOfLazyAttribute
  };

  struct AttributeModificationParams {
    WEBF_STACK_ALLOCATED();

   public:
    AttributeModificationParams(const AtomicString& qname,
                                const AtomicString& old_value,
                                const AtomicString& new_value,
                                AttributeModificationReason reason)
        : name(qname), old_value(old_value), new_value(new_value), reason(reason) {}

    const AtomicString& name;
    const AtomicString& old_value;
    const AtomicString& new_value;
    const AttributeModificationReason reason;
  };

  Element(const AtomicString& namespace_uri,
          const AtomicString& local_name,
          const AtomicString& prefix,
          Document* document,
          ConstructionType = kCreateElement);

  ElementAttributes* attributes() const { return &EnsureElementAttributes(); }
  ElementAttributes& EnsureElementAttributes() const;

  bool hasAttribute(const AtomicString&, ExceptionState& exception_state);
  AtomicString getAttribute(const AtomicString&, ExceptionState& exception_state) const;

  // Passing null as the second parameter removes the attribute when
  // calling either of these set methods.
  void setAttribute(const AtomicString&, const AtomicString& value);
  void setAttribute(const AtomicString&, const AtomicString& value, ExceptionState&);
  void removeAttribute(const AtomicString&, ExceptionState& exception_state);
  BoundingClientRect* getBoundingClientRect(ExceptionState& exception_state);
  std::vector<BoundingClientRect*> getClientRects(ExceptionState& exception_state);
  //  void click(ExceptionState& exception_state);
  void scroll(ExceptionState& exception_state);
  void scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll(double x, double y, ExceptionState& exception_state);
  void scroll_async(ExceptionState& exception_state);
  void scroll_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll_async(double x, double y, ExceptionState& exception_state);
  void scrollTo(ExceptionState& exception_state);
  void scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo(double x, double y, ExceptionState& exception_state);
  void scrollTo_async(ExceptionState& exception_state);
  void scrollTo_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo_async(double x, double y, ExceptionState& exception_state);
  void scrollBy(ExceptionState& exception_state);
  void scrollBy(double x, double y, ExceptionState& exception_state);
  void scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollBy_async(ExceptionState& exception_state);
  void scrollBy_async(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollBy_async(double x, double y, ExceptionState& exception_state);

  ScriptPromise toBlob(double device_pixel_ratio, ExceptionState& exception_state);
  ScriptPromise toBlob(ExceptionState& exception_state);
  void toBlob(double device_pixel_ratio,
              const std::shared_ptr<WebFNativeFunction>& callback,
              ExceptionState& exception_state);
  void toBlob(const std::shared_ptr<WebFNativeFunction>& callback, ExceptionState& exception_state);

  ScriptValue ___testGlobalToLocal__(double x, double y, ExceptionState& exception_state);

  void DidAddAttribute(const AtomicString&, const AtomicString&);
  void WillModifyAttribute(const AtomicString&, const AtomicString& old_value, const AtomicString& new_value);
  void DidModifyAttribute(const AtomicString&,
                          const AtomicString& old_value,
                          const AtomicString& new_value,
                          AttributeModificationReason reason);
  void DidRemoveAttribute(const AtomicString&, const AtomicString& old_value);

  void SynchronizeStyleAttributeInternal();
  void SynchronizeAttribute(const AtomicString& name);

  void InvalidateStyleAttribute();
  void AttributeChanged(const AttributeModificationParams& params);
  void StyleAttributeChanged(const AtomicString& new_style_string, AttributeModificationReason modification_reason);
  void SetInlineStyleFromString(const AtomicString&);

  std::string outerHTML();
  std::string innerHTML();
  void setInnerHTML(const AtomicString& value, ExceptionState& exception_state);

  bool HasTagName(const AtomicString&) const;
  AtomicString nodeValue() const override;
  AtomicString tagName() const { return getUppercasedQualifiedName(); }
  AtomicString prefix() const { return prefix_; }
  AtomicString localName() const { return local_name_; }
  AtomicString namespaceURI() const { return namespace_uri_; }
  std::string nodeName() const override;

  AtomicString className() const;
  void setClassName(const AtomicString& value, ExceptionState& exception_state);

  AtomicString id() const;
  void setId(const AtomicString& value, ExceptionState& exception_state);

  std::vector<Element*> getElementsByClassName(const AtomicString& class_name, ExceptionState& exception_state);
  std::vector<Element*> getElementsByTagName(const AtomicString& tag_name, ExceptionState& exception_state);

  Element* querySelector(const AtomicString& selectors, ExceptionState& exception_state);
  std::vector<Element*> querySelectorAll(const AtomicString& selectors, ExceptionState& exception_state);
  bool matches(const AtomicString& selectors, ExceptionState& exception_state);

  Element* closest(const AtomicString& selectors, ExceptionState& exception_state);

  InlineCssStyleDeclaration* style();
  InlineCssStyleDeclaration& EnsureCSSStyleDeclaration();
  DOMTokenList* classList();
  DOMStringMap* dataset();

  Element& CloneWithChildren(CloneChildrenFlag flag, Document* = nullptr) const;
  Element& CloneWithoutChildren(Document* = nullptr) const;

  NodeType nodeType() const override;
  bool ChildTypeAllowed(NodeType) const override;

  // Clones attributes only.
  void CloneAttributesFrom(const Element&);
  bool HasEquivalentAttributes(const Element& other) const;

  // Step 5 of https://dom.spec.whatwg.org/#concept-node-clone
  virtual void CloneNonAttributePropertiesFrom(const Element&, CloneChildrenFlag) {}
  virtual bool IsWidgetElement() const;
  virtual bool IsWebFTouchAreaElement() const;

  void Trace(GCVisitor* visitor) const override;
  const ElementPublicMethods* elementPublicMethods();

 protected:
  void SetAttributeInternal(const AtomicString&,
                            const AtomicString& value,
                            AttributeModificationReason reason,
                            ExceptionState& exception_state);

  const ElementData* GetElementData() const { return element_data_.get(); }
  bool HasElementData() const { return element_data_ != nullptr; }
  const AtomicString& getQualifiedName() const { return local_name_; }
  const AtomicString getUppercasedQualifiedName() const;
  ElementData& EnsureElementData();
  AtomicString namespace_uri_ = AtomicString::Null();
  AtomicString prefix_ = AtomicString::Null();
  AtomicString local_name_ = AtomicString::Empty();

 private:
  // Clone is private so that non-virtual CloneElementWithChildren and
  // CloneElementWithoutChildren are used inst
  Node* Clone(Document&, CloneChildrenFlag) const override;
  virtual Element& CloneWithoutAttributesAndChildren(Document& factory) const;

  void _notifyNodeRemoved(Node* node);
  void _notifyChildRemoved();
  void _notifyNodeInsert(Node* insertNode);
  void _notifyChildInsert();
  void _beforeUpdateId(JSValue oldIdValue, JSValue newIdValue);

  mutable std::unique_ptr<ElementData> element_data_;
  mutable Member<ElementAttributes> attributes_;
  Member<InlineCssStyleDeclaration> cssom_wrapper_;
};

template <typename T>
bool IsElementOfType(const Node&);
template <>
inline bool IsElementOfType<const Element>(const Node& node) {
  return node.IsElementNode();
}
template <typename T>
inline bool IsElementOfType(const Element& element) {
  return IsElementOfType<T>(static_cast<const Node&>(element));
}
template <>
inline bool IsElementOfType<const Element>(const Element&) {
  return true;
}

template <>
struct DowncastTraits<Element> {
  static bool AllowFrom(const Node& node) { return node.IsElementNode(); }
  static bool AllowFrom(const BindingObject& binding_object) {
    return binding_object.IsEventTarget() && To<EventTarget>(binding_object).IsNode() &&
           To<Node>(binding_object).IsElementNode();
  }
};

inline Element* Node::parentElement() const {
  return DynamicTo<Element>(parentNode());
}

}  // namespace webf

#endif  // BRIDGE_ELEMENT_H
