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
#include "element_data.h"
#include "legacy/bounding_client_rect.h"
#include "legacy/element_attributes.h"
#include "parent_node.h"
#include "qjs_scroll_to_options.h"
#include "gfx/geometry/vector2d_f.h"

namespace webf {

class ShadowRoot;

enum class ElementFlags {
  kTabIndexWasSetExplicitly = 1 << 0,
  kStyleAffectedByEmpty = 1 << 1,
  kIsInCanvasSubtree = 1 << 2,
  kContainsFullScreenElement = 1 << 3,
  kIsInTopLayer = 1 << 4,
  kContainsPersistentVideo = 1 << 5,
  kIsEligibleForElementCapture = 1 << 6,
  kHasCheckedElementCaptureEligibility = 1 << 7,

  kNumberOfElementFlags = 8,  // Size of bitfield used to store the flags.
};

using ScrollOffset = gfx::Vector2dF;

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

  bool hasAttributes() const;
  bool hasAttribute(const AtomicString&, ExceptionState& exception_state);
  AtomicString getAttribute(const AtomicString&, ExceptionState& exception_state) const;

  // Passing null as the second parameter removes the attribute when
  // calling either of these set methods.
  void setAttribute(const AtomicString&, const AtomicString& value);
  void setAttribute(const AtomicString&, const AtomicString& value, ExceptionState&);
  void removeAttribute(const AtomicString&, ExceptionState& exception_state);
  BoundingClientRect* getBoundingClientRect(ExceptionState& exception_state);
  std::vector<BoundingClientRect*> getClientRects(ExceptionState& exception_state);
  void click(ExceptionState& exception_state);
  void scroll(ExceptionState& exception_state);
  void scroll(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scroll(double x, double y, ExceptionState& exception_state);
  void scrollTo(ExceptionState& exception_state);
  void scrollTo(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);
  void scrollTo(double x, double y, ExceptionState& exception_state);
  void scrollBy(ExceptionState& exception_state);
  void scrollBy(double x, double y, ExceptionState& exception_state);
  void scrollBy(const std::shared_ptr<ScrollToOptions>& options, ExceptionState& exception_state);

  ScriptPromise toBlob(double device_pixel_ratio, ExceptionState& exception_state);
  ScriptPromise toBlob(ExceptionState& exception_state);

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

  virtual void AttributeChanged(const AttributeModificationParams& params);
  // |ParseAttribute()| is called by |AttributeChanged()|. If an element
  // implementation needs to check an attribute update, override this function.
  // This function is called before Element handles the change. This means
  // changes like `kSlotAttr` will not have been processed. Subclasses should
  // take care to avoid any processing that needs Element to have handled the
  // change. For example, flat-tree-travesal could be problematic. In such
  // cases subclasses should override AttributeChanged() and do the processing
  // after calling Element::AttributeChanged().
  //
  // While the owner document is parsed, this function is called after all
  // attributes in a start tag were added to the element.
  virtual void ParseAttribute(const AttributeModificationParams&);

  void StyleAttributeChanged(const AtomicString& new_style_string, AttributeModificationReason modification_reason);
  void SetInlineStyleFromString(const AtomicString&);

  std::string outerHTML();
  std::string innerHTML();
  AtomicString TextFromChildren();
  void setInnerHTML(const AtomicString& value, ExceptionState& exception_state);

  bool HasTagName(const AtomicString&) const;
  AtomicString nodeValue() const override;
  const QualifiedName& TagQName() const { return tag_name_; }
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
  virtual void FinishParsingChildren();
  void BeginParsingChildren() { SetIsFinishedParsingChildren(false); }

  void Trace(GCVisitor* visitor) const override;

  // add for invalidation begin
  bool IsDocumentElement() const;

  // NOTE: This shadows Node::GetComputedStyle().
  const ComputedStyle* GetComputedStyle() const {
    //return computed_style_.Get();
    return nullptr;
  }
  // const ComputedStyle& ComputedStyleRef() const {
  //   assert(computed_style_);
  //   return *computed_style_;
  // }

  void SetComputedStyle(const ComputedStyle* computed_style) {
    //computed_style_ = computed_style;
  }

  // ElementRareDataVector* GetElementRareData() const;
  // ElementRareDataVector& EnsureElementRareData();

  // Returns the shadow root attached to this element if it is a shadow host.
  ShadowRoot* GetShadowRoot() const;
  // ShadowRoot* OpenShadowRoot() const;
  // ShadowRoot* ClosedShadowRoot() const;
  // ShadowRoot* AuthorShadowRoot() const;
  // ShadowRoot* UserAgentShadowRoot() const;

  virtual const AtomicString& ShadowPseudoId() const;
  // The specified string must start with "-webkit-" or "-internal-". The
  // former can be used as a selector in any places, and the latter can be
  // used only in UA stylesheet.
  void SetShadowPseudoId(const AtomicString&);

  AtomicString LocalNameForSelectorMatching() const;

  // Call this to get the value of the id attribute for style resolution
  // purposes.  The value will already be lowercased if the document is in
  // compatibility mode, so this function is not suitable for non-style uses.
  const AtomicString& IdForStyleResolution() const;

  bool HasID() const;
  bool HasClass() const;
  const SpaceSplitString& ClassNames() const;
  bool HasClassName(const AtomicString& class_name) const;

  // Returns true if the element has 1 or more part names.
  bool HasPart() const;
  // Returns the list of part names if it has ever been created.
  DOMTokenList* GetPart() const;
  // IDL method.
  // Returns the list of part names, creating it if it doesn't exist.
  //DOMTokenList& part();

  // Ignores namespace.
  bool HasAttributeIgnoringNamespace(const AtomicString& local_name) const;

  void SetAnimationStyleChange(bool);
  void SetNeedsAnimationStyleRecalc();

  bool ChildStyleRecalcBlockedByDisplayLock() const;

  //void SetNeedsCompositingUpdate();

  // add for invalidation end
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

  QualifiedName tag_name_;
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

inline bool Element::hasAttributes() const {
  //return !Attributes().IsEmpty();

  return !EnsureElementAttributes().hasAttributes();
}

inline const AtomicString& Element::IdForStyleResolution() const {
  assert(HasID());
  return GetElementData()->IdForStyleResolution();
}

inline const SpaceSplitString& Element::ClassNames() const {
  assert(HasClass());
  assert(HasElementData());
  return GetElementData()->ClassNames();
}

inline bool Element::HasClassName(const AtomicString& class_name) const {
  return HasElementData() && GetElementData()->ClassNames().Contains(class_name);
}

inline bool Element::HasID() const {
  return HasElementData() && GetElementData()->HasID();
}

inline bool Element::HasClass() const {
  return HasElementData() && GetElementData()->HasClass();
}


}  // namespace webf

#endif  // BRIDGE_ELEMENT_H
