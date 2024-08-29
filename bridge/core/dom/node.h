/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_NODE_H
#define BRIDGE_NODE_H

#include <set>
#include <utility>

#include "events/event_target.h"
#include "foundation/macros.h"
#include "mutation_observer.h"
#include "mutation_observer_registration.h"
#include "core/dom/node_rare_data.h"
#include "qjs_union_dom_stringnode.h"
#include "tree_scope.h"
#include "core/css/style_change_reason.h"

namespace webf {

using MutationObserverOptionsMap = std::unordered_map<MutationObserver*, MutationRecordDeliveryOptions>;

const int kDOMNodeTypeShift = 2;
const int kElementNamespaceTypeShift = 4;
const int kNodeStyleChangeShift = 15;
const int kNodeCustomElementShift = 17;

class ComputedStyle;
class Element;
class Document;
class DocumentFragment;
class ContainerNode;
class NodeList;
class EventTargetDataObject;
class QJSUnionDomStringNode;
class ShadowRoot;

// Values for kChildNeedsStyleRecalcFlag, controlling whether a node gets its
// style recalculated.
enum StyleChangeType : uint32_t {
  // This node does not need style recalculation.
  kNoStyleChange = 0,
  // This node needs style recalculation, but the changes are of
  // a very limited set:
  //
  //  1. They only touch the node's inline style (style="" attribute).
  //  2. They don't add or remove any properties.
  //  3. They only touch independent properties.
  //
  // If all changes are of this type, we can do incremental style
  // recalculation by reusing the previous style and just applying
  // any modified inline style, which is cheaper than a full recalc.
  // See CanApplyInlineStyleIncrementally() and comments on
  // StyleResolver::ApplyBaseStyle() for more details.
  kInlineIndependentStyleChange = 1 << kNodeStyleChangeShift,
  // This node needs (full) style recalculation.
  kLocalStyleChange = 2 << kNodeStyleChangeShift,
  // This node and all of its flat-tree descendeants need style recalculation.
  kSubtreeStyleChange = 3 << kNodeStyleChangeShift,
};

enum class CustomElementState : uint32_t {
  // https://dom.spec.whatwg.org/#concept-element-custom-element-state
  kUncustomized = 0,
  kCustom = 1 << kNodeCustomElementShift,
  kPreCustomized = 2 << kNodeCustomElementShift,
  kUndefined = 3 << kNodeCustomElementShift,
  kFailed = 4 << kNodeCustomElementShift,
};

enum class CloneChildrenFlag { kSkip, kClone, kCloneWithShadows };

// A Node is a base class for all objects in the DOM tree.
// The spec governing this interface can be found here:
// https://dom.spec.whatwg.org/#interface-node
class Node : public EventTarget {
  DEFINE_WRAPPERTYPEINFO();
  friend class TreeScope;

 public:
  enum NodeType {
    kElementNode = 1,
    kAttributeNode = 2,
    kTextNode = 3,
    kCommentNode = 8,
    kDocumentNode = 9,
    kDocumentTypeNode = 10,
    kDocumentFragmentNode = 11,
  };

  // Constant properties.
  static int ELEMENT_NODE;
  static int ATTRIBUTE_NODE;
  static int TEXT_NODE;
  static int COMMENT_NODE;
  static int DOCUMENT_NODE;
  static int DOCUMENT_TYPE_NODE;
  static int DOCUMENT_FRAGMENT_NODE;

  using ImplType = Node*;
  static Node* Create(ExecutingContext* context, ExceptionState& exception_state);

  Node* ToNode() override;

  // DOM methods & attributes for Node
  virtual std::string nodeName() const = 0;
  virtual AtomicString nodeValue() const = 0;
  virtual void setNodeValue(const AtomicString&, ExceptionState&);
  virtual NodeType nodeType() const = 0;

  [[nodiscard]] ContainerNode* parentNode() const;
  [[nodiscard]] Element* parentElement() const;
  [[nodiscard]] Node* previousSibling() const { return previous_.Get(); }
  [[nodiscard]] Node* nextSibling() const { return next_.Get(); }
  NodeList* childNodes();
  [[nodiscard]] Node* firstChild() const;
  [[nodiscard]] Node* lastChild() const;
  [[nodiscard]] Node& TreeRoot() const;
  void remove(ExceptionState&);

  Node* insertBefore(Node* new_child, Node* ref_child, ExceptionState&);
  Node* replaceChild(Node* new_child, Node* old_child, ExceptionState&);
  Node* removeChild(Node* child, ExceptionState&);
  Node* appendChild(Node* new_child, ExceptionState&);

  bool hasChildNodes(ExceptionState& exception_state) const { return firstChild(); }
  bool hasChildren() const { return firstChild(); }
  Node* cloneNode(bool deep, ExceptionState&) const;
  Node* cloneNode(ExceptionState&) const;

  void prepend(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state);
  void prepend(ExceptionState& exception_state);
  void append(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state);
  void append(ExceptionState& exception_state);
  void before(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state);
  void before(ExceptionState& exception_state);
  void after(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state);
  void after(ExceptionState& exception_state);

  // https://dom.spec.whatwg.org/#concept-node-clone
  virtual Node* Clone(Document&, CloneChildrenFlag) const = 0;

  bool isEqualNode(Node*, ExceptionState& exception_state) const;
  bool isEqualNode(Node*) const;
  bool isSameNode(const Node* other, ExceptionState& exception_state) const { return this == other; }

  [[nodiscard]] AtomicString textContent(bool convert_brs_to_newlines = false) const;
  virtual void setTextContent(const AtomicString&, ExceptionState& exception_state);

  // Other methods (not part of DOM)
  [[nodiscard]] FORCE_INLINE bool IsTextNode() const { return GetDOMNodeType() == DOMNodeType::kText; }
  [[nodiscard]] FORCE_INLINE bool IsOtherNode() const { return GetDOMNodeType() == DOMNodeType::kOther; }
  [[nodiscard]] FORCE_INLINE bool IsContainerNode() const { return GetFlag(kIsContainerFlag); }
  [[nodiscard]] FORCE_INLINE bool IsElementNode() const { return GetDOMNodeType() == DOMNodeType::kElement; }
  [[nodiscard]] FORCE_INLINE bool IsDocumentFragment() const {
    return GetDOMNodeType() == DOMNodeType::kDocumentFragment;
  }

  [[nodiscard]] FORCE_INLINE bool IsHTMLElement() const {
    return GetElementNamespaceType() == ElementNamespaceType::kHTML;
  }
  [[nodiscard]] FORCE_INLINE bool IsMathMLElement() const {
    return GetElementNamespaceType() == ElementNamespaceType::kMathML;
  }
  [[nodiscard]] FORCE_INLINE bool IsSVGElement() const {
    return GetElementNamespaceType() == ElementNamespaceType::kSVG;
  }

  [[nodiscard]] CustomElementState GetCustomElementState() const {
    return static_cast<CustomElementState>(node_flags_ & kCustomElementStateMask);
  }
  bool IsCustomElement() const { return GetCustomElementState() != CustomElementState::kUncustomized; }
  void SetCustomElementState(CustomElementState);

  [[nodiscard]] virtual bool IsPseudoElement() const { return false; }
  [[nodiscard]] virtual bool IsMediaElement() const { return false; }
  [[nodiscard]] virtual bool IsAttributeNode() const { return false; }
  [[nodiscard]] virtual bool IsCharacterDataNode() const { return false; }

  // StyledElements allow inline style (style="border: 1px"), presentational
  // attributes (ex. color), class names (ex. class="foo bar") and other
  // non-basic styling features. They also control if this element can
  // participate in style sharing.
  [[nodiscard]] bool IsStyledElement() const { return IsHTMLElement() || IsSVGElement() || IsMathMLElement(); }

  [[nodiscard]] bool IsDocumentNode() const;

  // Node's parent, shadow tree host.
  [[nodiscard]] ContainerNode* ParentOrShadowHostNode() const;
  [[nodiscard]] Element* ParentOrShadowHostElement() const;
  void SetParentOrShadowHostNode(ContainerNode*);

  // ---------------------------------------------------------------------------
  // Notification of document structure changes (see container_node.h for more
  // notification methods)
  //
  // At first, notifies the node that it has been inserted into the
  // document. This is called during document parsing, and also when a node is
  // added through the DOM methods insertBefore(), appendChild() or
  // replaceChild(). The call happens _after_ the node has been added to the
  // tree.  This is similar to the DOMNodeInsertedIntoDocument DOM event, but
  // does not require the overhead of event dispatching.
  //
  // notifies this callback regardless if the subtree of the node is a
  // document tree or a floating subtree.  Implementation can determine the type
  // of subtree by seeing insertion_point->isConnected().  For performance
  // reasons, notifications are delivered only to ContainerNode subclasses if
  // the insertion_point is not in a document tree.
  //
  // There is another callback, DidNotifySubtreeInsertionsToDocument(),
  // which is called after all the descendants are notified, if this node was
  // inserted into the document tree. Only a few subclasses actually need
  // this. To utilize this, the node should return
  // kInsertionShouldCallDidNotifySubtreeInsertions from InsertedInto().
  //
  // InsertedInto() implementations must not modify the DOM tree, and must not
  // dispatch synchronous events. On the other hand,
  // DidNotifySubtreeInsertionsToDocument() may modify the DOM tree, and may
  // dispatch synchronous events.
  enum InsertionNotificationRequest {
    kInsertionDone,
    kInsertionShouldCallDidNotifySubtreeInsertions
  };

  virtual InsertionNotificationRequest InsertedInto(ContainerNode& insertion_point);

  // Notifies the node that it is no longer part of the tree.
  //
  // This is a dual of InsertedInto(), but does not require the overhead of
  // event dispatching, and is called _after_ the node is removed from the tree.
  //
  // RemovedFrom() implementations must not modify the DOM tree, and must not
  // dispatch synchronous events.
  virtual void RemovedFrom(ContainerNode& insertion_point);

  // Returns the parent node, but nullptr if the parent node is a ShadowRoot.
  [[nodiscard]] ContainerNode* NonShadowBoundaryParentNode() const;

  // These low-level calls give the caller responsibility for maintaining the
  // integrity of the tree.
  void SetPreviousSibling(Node* previous) { previous_ = previous; }
  void SetNextSibling(Node* next) { next_ = next; }

  [[nodiscard]] bool HasEventTargetData() const { return GetFlag(kHasEventTargetDataFlag); }
  void SetHasEventTargetData(bool flag) { SetFlag(flag, kHasEventTargetDataFlag); }

  [[nodiscard]] unsigned NodeIndex() const;

  // Returns the DOM ownerDocument attribute. This method never returns null,
  // except in the case of a Document node.
  [[nodiscard]] Document* ownerDocument() const;

  // Returns the document associated with this node. A Document node returns
  // itself.
  [[nodiscard]] Document& GetDocument() const { return GetTreeScope().GetDocument(); }

  [[nodiscard]] TreeScope& GetTreeScope() const {
    assert(tree_scope_);
    return *tree_scope_;
  };

  // Returns true if this node is connected to a document, false otherwise.
  // See https://dom.spec.whatwg.org/#connected for the definition.
  [[nodiscard]] bool isConnected() const { return GetFlag(kIsConnectedFlag); }

  [[nodiscard]] bool IsInDocumentTree() const { return isConnected(); }
  [[nodiscard]] bool IsInTreeScope() const { return GetFlag(static_cast<NodeFlags>(kIsConnectedFlag)); }

  [[nodiscard]] bool IsDocumentTypeNode() const { return nodeType() == kDocumentTypeNode; }
  [[nodiscard]] virtual bool ChildTypeAllowed(NodeType) const { return false; }
  [[nodiscard]] unsigned CountChildren() const;

  bool IsNode() const override;
  bool IsDescendantOf(const Node*) const;
  bool contains(const Node*, ExceptionState&) const;
  [[nodiscard]] bool ContainsIncludingHostElements(const Node&) const;
  Node* CommonAncestor(const Node&, ContainerNode* (*parent)(const Node&)) const;

  enum ShadowTreesTreatment { kTreatShadowTreesAsDisconnected, kTreatShadowTreesAsComposed };

  EventTargetData* GetEventTargetData() override;
  EventTargetData& EnsureEventTargetData() override;

  [[nodiscard]] bool IsFinishedParsingChildren() const { return GetFlag(kIsFinishedParsingChildrenFlag); }

  void SetHasDuplicateAttributes() { SetFlag(kHasDuplicateAttributes); }
  [[nodiscard]] bool HasDuplicateAttribute() const { return GetFlag(kHasDuplicateAttributes); }

  [[nodiscard]] bool SelfOrAncestorHasDirAutoAttribute() const { return GetFlag(kSelfOrAncestorHasDirAutoAttribute); }
  void SetSelfOrAncestorHasDirAutoAttribute() { SetFlag(kSelfOrAncestorHasDirAutoAttribute); }
  void ClearSelfOrAncestorHasDirAutoAttribute() { ClearFlag(kSelfOrAncestorHasDirAutoAttribute); }

  void GetRegisteredMutationObserversOfType(MutationObserverOptionsMap&,
                                            MutationType,
                                            const AtomicString* attribute_name);
  void RegisterMutationObserver(MutationObserver&,
                                MutationObserverOptions,
                                const std::unordered_set<AtomicString, AtomicString::KeyHasher>& attribute_filter);
  void UnregisterMutationObserver(MutationObserverRegistration*);
  void RegisterTransientMutationObserver(MutationObserverRegistration*);
  void UnregisterTransientMutationObserver(MutationObserverRegistration*);
  void NotifyMutationObserversNodeWillDetach();

  // Used exclusively by |EnsureRareData|.
  NodeRareData& CreateRareData();
  [[nodiscard]] bool HasNodeData() const { return GetFlag(kHasDataFlag); }
  // |RareData| cannot be replaced or removed once assigned.
  NodeRareData* RareData() const { return data_.get(); }
  NodeRareData& EnsureRareData() { return data_ ? *data_ : CreateRareData(); }

  const MutationObserverRegistrationVector* MutationObserverRegistry();
  const MutationObserverRegistrationSet* TransientMutationObserverRegistry();
  void SetIsFinishedParsingChildren(bool value) {
    SetFlag(value, kIsFinishedParsingChildrenFlag);
  }

  void Trace(GCVisitor*) const override;

  NodeListsNodeData* NodeLists();
  void ClearNodeLists();

  FlatTreeNodeData* GetFlatTreeNodeData() const;
  FlatTreeNodeData& EnsureFlatTreeNodeData();
  void ClearFlatTreeNodeData();
  void ClearFlatTreeNodeDataIfHostChanged(const ContainerNode& parent);

  void SetStyleChange(StyleChangeType change_type) {
    node_flags_ = (node_flags_ & ~kStyleChangeMask) | change_type;
  }

  Element* FlatTreeParentForChildDirty() const;
  Element* GetStyleRecalcParent() const {
    return FlatTreeParentForChildDirty();
  }
  Element* GetReattachParent() const { return FlatTreeParentForChildDirty(); }

  bool IsTreeScope() const;
  bool IsShadowRoot() const { return IsDocumentFragment() && IsTreeScope(); }

  bool InActiveDocument() const;

  // True if the style recalc process should recalculate style for this node.
  bool NeedsStyleRecalc() const {
    return GetStyleChangeType() != kNoStyleChange;
  }
  StyleChangeType GetStyleChangeType() const {
    return static_cast<StyleChangeType>(node_flags_ & kStyleChangeMask);
  }
  // True if the style recalculation process should traverse this node's
  // children when looking for nodes that need recalculation.
  bool ChildNeedsStyleRecalc() const {
    return GetFlag(kChildNeedsStyleRecalcFlag);
  }

  // Mark node for forced layout tree re-attach during next lifecycle update.
  // This is to trigger layout tree re-attachment when we cannot detect that we
  // need to re-attach based on the computed style changes. This can happen when
  // re-slotting shadow host children, for instance.
  void SetForceReattachLayoutTree();
  bool GetForceReattachLayoutTree() const {
    return GetFlag(kForceReattachLayoutTree);
  }

  bool NeedsLayoutSubtreeUpdate() const;
  bool NeedsWhitespaceChildrenUpdate() const;
  bool IsDirtyForStyleRecalc() const {
    return NeedsStyleRecalc() || GetForceReattachLayoutTree() ||
           NeedsLayoutSubtreeUpdate();
  }
  bool IsDirtyForRebuildLayoutTree() const {
    return NeedsReattachLayoutTree() || NeedsLayoutSubtreeUpdate();
  }

  bool NeedsReattachLayoutTree() const {
    return GetFlag(kNeedsReattachLayoutTree);
  }

  void SetChildNeedsStyleRecalc() { SetFlag(kChildNeedsStyleRecalcFlag); }
  void ClearChildNeedsStyleRecalc() { ClearFlag(kChildNeedsStyleRecalcFlag); }

  // Sets the flag for the current node and also calls
  // MarkAncestorsWithChildNeedsStyleRecalc
  void SetNeedsStyleRecalc(StyleChangeType, const StyleChangeReasonForTracing& = StyleChangeReasonForTracing::Create(""));
  void ClearNeedsStyleRecalc();

  // Propagates a dirty bit breadcrumb for this element up the ancestor chain.
  void MarkAncestorsWithChildNeedsStyleRecalc();

  // True if there are pending invalidations against this node.
  bool NeedsStyleInvalidation() const {
    return GetFlag(kNeedsStyleInvalidationFlag);
  }
  void ClearNeedsStyleInvalidation() { ClearFlag(kNeedsStyleInvalidationFlag); }
  // Sets the flag for the current node and also calls
  // MarkAncestorsWithChildNeedsStyleInvalidation
  void SetNeedsStyleInvalidation();

  // ---------------------------------------------------------------------------
  // Inline ComputedStyle accessor
  //
  // Note that the following 'inline' function is not defined in this header,
  // but in node_computed_style.h. Please include that file if you want to use
  // this function.
  inline const ComputedStyle* GetComputedStyle() const;
  bool ShouldSkipMarkingStyleDirty() const;

  // True if the style invalidation process should traverse this node's children
  // when looking for pending invalidations.
  bool ChildNeedsStyleInvalidation() const {
    return GetFlag(kChildNeedsStyleInvalidationFlag);
  }
  void SetChildNeedsStyleInvalidation() {
    SetFlag(kChildNeedsStyleInvalidationFlag);
  }
  void ClearChildNeedsStyleInvalidation() {
    ClearFlag(kChildNeedsStyleInvalidationFlag);
  }
  void MarkAncestorsWithChildNeedsStyleInvalidation();

  // crbug.com/569532: containingShadowRoot() can return nullptr even if
  // isInShadowTree() returns true.
  // This can happen when handling queued events (e.g. during execCommand())
  ShadowRoot* ContainingShadowRoot() const;
  ShadowRoot* GetShadowRoot() const;
  bool IsInUserAgentShadowRoot() const;

 private:
  enum NodeFlags : uint32_t {
    kHasDataFlag = 1,

    // Node type flags. These never change once created.
    kIsContainerFlag = 1 << 1,
    kDOMNodeTypeMask = 0x3 << kDOMNodeTypeShift,
    kElementNamespaceTypeMask = 0x3 << kElementNamespaceTypeShift,

    // Tree state flags. These change when the element is added/removed
    // from a DOM tree.
    kIsConnectedFlag = 1 << 8,

    // Set by the parser when the children are done parsing.
    kIsFinishedParsingChildrenFlag = 1 << 10,
    // Flags related to recalcStyle.
    kHasCustomStyleCallbacksFlag = 1u << 12,
    kChildNeedsStyleInvalidationFlag = 1u << 13,
    kNeedsStyleInvalidationFlag = 1u << 14,
    kChildNeedsStyleRecalcFlag = 1u << 15,
    kStyleChangeMask = 0x3u << kNodeStyleChangeShift,

    kCustomElementStateMask = 0x7 << kNodeCustomElementShift,
    kHasNameOrIsEditingTextFlag = 1 << 20,
    kHasEventTargetDataFlag = 1 << 21,
    kNeedsReattachLayoutTree = 1u << 22,

    kHasDuplicateAttributes = 1 << 24,
    kIsWidgetElement = 1 << 25,

    kForceReattachLayoutTree = 1u << 25,

    kSelfOrAncestorHasDirAutoAttribute = 1 << 27,
    kDefaultNodeFlags = kIsFinishedParsingChildrenFlag,
    // 2 bits remaining.
  };

  [[nodiscard]] FORCE_INLINE bool GetFlag(NodeFlags mask) const { return node_flags_ & mask; }
  void SetFlag(bool f, NodeFlags mask) { node_flags_ = (node_flags_ & ~mask) | (-(int32_t)f & mask); }
  void SetFlag(NodeFlags mask) { node_flags_ |= mask; }
  void ClearFlag(NodeFlags mask) { node_flags_ &= ~mask; }

  enum class DOMNodeType : uint32_t {
    kElement = 0,
    kText = 1 << kDOMNodeTypeShift,
    kDocumentFragment = 2 << kDOMNodeTypeShift,
    kOther = 3 << kDOMNodeTypeShift,
  };

  [[nodiscard]] FORCE_INLINE DOMNodeType GetDOMNodeType() const {
    return static_cast<DOMNodeType>(node_flags_ & kDOMNodeTypeMask);
  }

  enum class ElementNamespaceType : uint32_t {
    kHTML = 0,
    kMathML = 1 << kElementNamespaceTypeShift,
    kSVG = 2 << kElementNamespaceTypeShift,
    kOther = 3 << kElementNamespaceTypeShift,
  };
  [[nodiscard]] FORCE_INLINE ElementNamespaceType GetElementNamespaceType() const {
    return static_cast<ElementNamespaceType>(node_flags_ & kElementNamespaceTypeMask);
  }

 protected:
  enum ConstructionType {
    kCreateOther = kDefaultNodeFlags | static_cast<NodeFlags>(DOMNodeType::kOther) |
                   static_cast<NodeFlags>(ElementNamespaceType::kOther),
    kCreateText = kDefaultNodeFlags | static_cast<NodeFlags>(DOMNodeType::kText) |
                  static_cast<NodeFlags>(ElementNamespaceType::kOther),
    kCreateContainer = kDefaultNodeFlags | kIsContainerFlag | static_cast<NodeFlags>(DOMNodeType::kOther) |
                       static_cast<NodeFlags>(ElementNamespaceType::kOther),
    kCreateElement = kDefaultNodeFlags | kIsContainerFlag | static_cast<NodeFlags>(DOMNodeType::kElement) |
                     static_cast<NodeFlags>(ElementNamespaceType::kOther),
    kCreateDocumentFragment = kDefaultNodeFlags | kIsContainerFlag |
                              static_cast<NodeFlags>(DOMNodeType::kDocumentFragment) |
                              static_cast<NodeFlags>(ElementNamespaceType::kOther),
    kCreateHTMLElement = kDefaultNodeFlags | kIsContainerFlag | static_cast<NodeFlags>(DOMNodeType::kElement) |
                         static_cast<NodeFlags>(ElementNamespaceType::kHTML),
    kCreateWidgetElement = kDefaultNodeFlags | kIsContainerFlag | static_cast<NodeFlags>(DOMNodeType::kElement) |
                           static_cast<NodeFlags>(ElementNamespaceType::kHTML) | kIsWidgetElement,
    kCreateMathMLElement = kDefaultNodeFlags | kIsContainerFlag | static_cast<NodeFlags>(DOMNodeType::kElement) |
                           static_cast<NodeFlags>(ElementNamespaceType::kMathML),
    kCreateSVGElement = kDefaultNodeFlags | kIsContainerFlag | static_cast<NodeFlags>(DOMNodeType::kElement) |
                        static_cast<NodeFlags>(ElementNamespaceType::kSVG),
    kCreateDocument = kCreateContainer | kIsConnectedFlag,
  };

  void SetTreeScope(TreeScope* scope) { tree_scope_ = scope; }

  Node(ExecutingContext* context, TreeScope*, ConstructionType);
  Node() = delete;
  ~Node();

 private:
  uint32_t node_flags_;
  Member<Node> parent_or_shadow_host_node_;
  Member<Node> previous_;
  Member<Node> next_;
  TreeScope* tree_scope_;
  std::unique_ptr<EventTargetDataObject> event_target_data_{nullptr};
  std::unique_ptr<NodeRareData> data_{nullptr};
};

// Allow equality comparisons of Nodes by reference or pointer, interchangeably.
DEFINE_COMPARISON_OPERATORS_WITH_REFERENCES(Node)

template <>
struct DowncastTraits<Node> {
  static bool AllowFrom(const EventTarget& event_target) { return event_target.IsNode(); }
};

inline ContainerNode* Node::ParentOrShadowHostNode() const {
  return reinterpret_cast<ContainerNode*>(parent_or_shadow_host_node_.Get());
}

inline void Node::SetParentOrShadowHostNode(ContainerNode* parent) {
  parent_or_shadow_host_node_ = reinterpret_cast<Node*>(parent);
}

}  // namespace webf

#endif  // BRIDGE_NODE_H
