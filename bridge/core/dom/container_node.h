/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_CONTAINER_NODE_H_
#define BRIDGE_CORE_DOM_CONTAINER_NODE_H_

#include <vector>
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "bindings/qjs/heap_vector.h"
#include "core/dom/node.h"
#include "core/html/collection_type.h"
#include "plugin_api/container_node.h"

namespace webf {

class HTMLCollection;

// This constant controls how much buffer is initially allocated
// for a Node Vector that is used to store child Nodes of a given Node.
const int kInitialNodeVectorSize = 11;
using NodeVector = std::vector<Node*>;

enum class DynamicRestyleFlags {
  kChildrenOrSiblingsAffectedByFocus = 1 << 0,
  kChildrenOrSiblingsAffectedByHover = 1 << 1,
  kChildrenOrSiblingsAffectedByActive = 1 << 2,
  kChildrenOrSiblingsAffectedByDrag = 1 << 3,
  kChildrenAffectedByFirstChildRules = 1 << 4,
  kChildrenAffectedByLastChildRules = 1 << 5,
  kChildrenAffectedByDirectAdjacentRules = 1 << 6,
  kChildrenAffectedByIndirectAdjacentRules = 1 << 7,
  kChildrenAffectedByForwardPositionalRules = 1 << 8,
  kChildrenAffectedByBackwardPositionalRules = 1 << 9,
  kAffectedByFirstChildRules = 1 << 10,
  kAffectedByLastChildRules = 1 << 11,
  kChildrenOrSiblingsAffectedByFocusWithin = 1 << 12,
  kChildrenOrSiblingsAffectedByFocusVisible = 1 << 13,

  kNumberOfDynamicRestyleFlags = 14,

  kChildrenAffectedByStructuralRules =
      kChildrenAffectedByFirstChildRules | kChildrenAffectedByLastChildRules | kChildrenAffectedByDirectAdjacentRules |
      kChildrenAffectedByIndirectAdjacentRules | kChildrenAffectedByForwardPositionalRules |
      kChildrenAffectedByBackwardPositionalRules
};

class ContainerNode : public Node {
 public:
  Node* firstChild() const { return first_child_.Get(); }
  Node* lastChild() const { return last_child_.Get(); }
  bool hasChildren() const { return first_child_.Get(); }
  bool HasChildren() const { return first_child_.Get(); }

  bool HasOneChild() const { return first_child_ && !first_child_->nextSibling(); }
  bool HasOneTextChild() const { return HasOneChild() && first_child_->IsTextNode(); }
  bool HasChildCount(unsigned) const;

  HTMLCollection* Children();

  unsigned CountChildren() const;

  Element* QuerySelector(const AtomicString& selectors, ExceptionState&);
  Element* QuerySelector(const AtomicString& selectors);

  Node* InsertBefore(Node* new_child, Node* ref_child, ExceptionState&);
  Node* ReplaceChild(Node* new_child, Node* old_child, ExceptionState&);
  Node* RemoveChild(Node* child, ExceptionState&);
  Node* AppendChild(Node* new_child, ExceptionState&);
  Node* AppendChild(Node* new_child);
  void WillRemoveChildren();
  void WillRemoveChild(Node& child);
  bool EnsurePreInsertionValidity(const Node& new_child,
                                  const Node* next,
                                  const Node* old_child,
                                  ExceptionState&) const;

  void RemoveChildren();

  void CloneChildNodesFrom(const ContainerNode&, CloneChildrenFlag);

  // These methods are only used during parsing.
  // They don't send DOM mutation events or accept DocumentFragments.
  void ParserAppendChild(Node*);

  // Called when the parser adds a child to a DocumentFragment as the result
  // of parsing inner/outer html.
  void ParserAppendChildInDocumentFragment(Node* new_child);
  // Called when the parser has finished building a DocumentFragment. This is
  // not called if the parser fails parsing (if parsing fails, the
  // DocumentFragment is orphaned and will eventually be gc'd).
  void ParserFinishedBuildingDocumentFragment();
  void ParserRemoveChild(Node&);
  void ParserInsertBefore(Node* new_child, Node& ref_child);
  void ParserTakeAllChildrenFrom(ContainerNode&);

  AtomicString nodeValue() const override;

  // -----------------------------------------------------------------------------
  // Notification of document structure changes (see core/dom/node.h for more
  // notification methods)
  enum class ChildrenChangeType : uint8_t {
    kElementInserted,
    kNonElementInserted,
    kElementRemoved,
    kNonElementRemoved,
    kAllChildrenRemoved,
    kTextChanged,
    // When the parser builds nodes (because of inner/outer-html or
    // parseFromString) a single ChildrenChange event is sent at the end.
    kFinishedBuildingDocumentFragmentTree,
  };
  enum class ChildrenChangeSource : uint8_t { kAPI, kParser };
  enum class ChildrenChangeAffectsElements : uint8_t { kNo, kYes };
  struct ChildrenChange {
    WEBF_STACK_ALLOCATED();

   public:
    static ChildrenChange ForFinishingBuildingDocumentFragmentTree() {
      return ChildrenChange{
          .type = ChildrenChangeType::kFinishedBuildingDocumentFragmentTree,
          .by_parser = ChildrenChangeSource::kParser,
          .affects_elements = ChildrenChangeAffectsElements::kYes,
      };
    }
    static ChildrenChange ForInsertion(Node& node,
                                       Node* unchanged_previous,
                                       Node* unchanged_next,
                                       ChildrenChangeSource by_parser) {
      ChildrenChange change = {
          .type = node.IsElementNode() ? ChildrenChangeType::kElementInserted : ChildrenChangeType::kNonElementInserted,
          .by_parser = by_parser,
          .affects_elements =
              node.IsElementNode() ? ChildrenChangeAffectsElements::kYes : ChildrenChangeAffectsElements::kNo,
          .sibling_changed = &node,
          .sibling_before_change = unchanged_previous,
          .sibling_after_change = unchanged_next,
      };
      return change;
    }

    static ChildrenChange ForRemoval(Node& node,
                                     Node* previous_sibling,
                                     Node* next_sibling,
                                     ChildrenChangeSource by_parser) {
      ChildrenChange change = {
          .type = node.IsElementNode() ? ChildrenChangeType::kElementRemoved : ChildrenChangeType::kNonElementRemoved,
          .by_parser = by_parser,
          .affects_elements =
              node.IsElementNode() ? ChildrenChangeAffectsElements::kYes : ChildrenChangeAffectsElements::kNo,
          .sibling_changed = &node,
          .sibling_before_change = previous_sibling,
          .sibling_after_change = next_sibling,
      };
      return change;
    }

    bool IsChildInsertion() const {
      return type == ChildrenChangeType::kElementInserted || type == ChildrenChangeType::kNonElementInserted;
    }
    bool IsChildRemoval() const {
      return type == ChildrenChangeType::kElementRemoved || type == ChildrenChangeType::kNonElementRemoved;
    }
    bool IsChildElementChange() const {
      return type == ChildrenChangeType::kElementInserted || type == ChildrenChangeType::kElementRemoved;
    }

    bool ByParser() const { return by_parser == ChildrenChangeSource::kParser; }

    const ChildrenChangeType type;
    const ChildrenChangeSource by_parser;
    const ChildrenChangeAffectsElements affects_elements;
    Node* const sibling_changed = nullptr;
    // |siblingBeforeChange| is
    //  - siblingChanged.previousSibling before node removal
    //  - siblingChanged.previousSibling after single node insertion
    //  - previousSibling of the first inserted node after multiple node
    //    insertion
    Node* const sibling_before_change = nullptr;
    // |siblingAfterChange| is
    //  - siblingChanged.nextSibling before node removal
    //  - siblingChanged.nextSibling after single node insertion
    //  - nextSibling of the last inserted node after multiple node insertion.
    Node* const sibling_after_change = nullptr;
    // List of removed nodes for ChildrenChangeType::kAllChildrenRemoved.
    // Only populated if ChildrenChangedAllChildrenRemovedNeedsList() returns
    // true.
    const HeapVector<Member<Node>> removed_nodes;
    // Non-null if and only if |type| is ChildrenChangeType::kTextChanged.
    const AtomicString old_text = AtomicString::Empty();
  };

  // Notifies the node that it's list of children have changed (either by adding
  // or removing child nodes), or a child node that is of the type
  // kCdataSectionNode, kTextNode or kCommentNode has changed its value.
  //
  // ChildrenChanged() implementations may modify the DOM tree, and may dispatch
  // synchronous events.
  virtual void ChildrenChanged(const ChildrenChange&);

  void Trace(GCVisitor* visitor) const override;
  const ContainerNodePublicMethods* containerNodePublicMethods();

  bool HasRestyleFlag(DynamicRestyleFlags mask) const {
    if (const NodeRareData* data = RareData()) {
      return data->HasRestyleFlag(mask);
    }
    return false;
  }

  bool ChildrenAffectedByForwardPositionalRules() const {
    return HasRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByForwardPositionalRules);
  }
  void SetChildrenAffectedByForwardPositionalRules() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByForwardPositionalRules);
  }
  void SetChildrenAffectedByDirectAdjacentRules() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByDirectAdjacentRules);
  }

  void SetChildrenAffectedByIndirectAdjacentRules() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByIndirectAdjacentRules);
  }

  bool ChildrenAffectedByBackwardPositionalRules() const {
    return HasRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByBackwardPositionalRules);
  }
  void SetChildrenAffectedByBackwardPositionalRules() {
    SetRestyleFlag(DynamicRestyleFlags::kChildrenAffectedByBackwardPositionalRules);
  }

  Element* querySelector(const AtomicString& selectors, ExceptionState& exception_state);

  // If this node is in a shadow tree, returns its shadow host. Otherwise,
  // returns nullptr.
  Element* OwnerShadowHost() const;

 protected:
  ContainerNode(TreeScope* tree_scope, ConstructionType = kCreateContainer);
  ContainerNode(ExecutingContext* context, Document* document, ConstructionType = kCreateContainer);

  // Called from ParserFinishedBuildingDocumentFragment() to notify `node` that
  // it was inserted.
  void NotifyNodeAtEndOfBuildingFragmentTree(Node& node, const ChildrenChange& change, bool may_contain_shadow_roots);

  // |attr_name| and |owner_element| are only used for element attribute
  // modifications. |ChildrenChange| is either nullptr or points to a
  // ChildNode::ChildrenChange structure that describes the changes in the tree.
  // If non-null, blink may preserve caches that aren't affected by the change.
  void InvalidateNodeListCachesInAncestors(const QualifiedName* attr_name,
                                           Element* attribute_owner_element,
                                           const ChildrenChange*);

  void SetFirstChild(Node* child) { first_child_ = child; }
  void SetLastChild(Node* child) { last_child_ = child; }

  // Utility functions for NodeListsNodeData API.
  template <typename Collection>
  Collection* EnsureCachedCollection(CollectionType);
  template <typename Collection>
  Collection* EnsureCachedCollection(CollectionType, const AtomicString& name);
  template <typename Collection>
  Collection* EnsureCachedCollection(CollectionType, const AtomicString& namespace_uri, const AtomicString& local_name);
  template <typename Collection>
  Collection* CachedCollection(CollectionType);

 private:
  bool IsContainerNode() const = delete;  // This will catch anyone doing an unnecessary check.
  bool IsTextNode() const = delete;       // This will catch anyone doing an unnecessary check.
  void RemoveBetween(Node* previous_child, Node* next_child, Node& old_child);

  NodeListsNodeData& EnsureNodeLists();

  // Inserts the specified nodes before |next|.
  // |next| may be nullptr.
  // |post_insertion_notification_targets| must not be nullptr.
  template <typename Functor>
  void InsertNodeVector(const NodeVector&, Node* next, const Functor&, NodeVector* post_insertion_notification_targets);
  void DidInsertNodeVector(const NodeVector&, Node* next, const NodeVector& post_insertion_notification_targets);
  class AdoptAndInsertBefore;
  class AdoptAndAppendChild;
  friend class AdoptAndInsertBefore;
  friend class AdoptAndAppendChild;

  void InsertBeforeCommon(Node& next_child, Node& new_child);
  void AppendChildCommon(Node& child);

  void NotifyNodeInserted(Node&, ChildrenChangeSource = ChildrenChangeSource::kAPI);
  void NotifyNodeInsertedInternal(Node&, NodeVector& post_insertion_notification_targets);
  void NotifyNodeRemoved(Node&);

  inline bool IsChildTypeAllowed(const Node& child) const;
  inline bool IsHostIncludingInclusiveAncestorOfThis(const Node&, ExceptionState&) const;

  bool HasRestyleFlags() const {
    if (const NodeRareData* data = RareData()) {
      return data->HasRestyleFlags();
    }
    return false;
  }
  void SetRestyleFlag(DynamicRestyleFlags);

  Member<Node> first_child_;
  Member<Node> last_child_;
};

inline Node* Node::firstChild() const {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node)
    return nullptr;
  return this_node->firstChild();
}

inline Node* Node::lastChild() const {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node) {
    return nullptr;
  }
  return this_node->lastChild();
}

inline bool ContainerNode::HasChildCount(unsigned count) const {
  Node* child = first_child_.Get();
  while (count && child) {
    child = child->nextSibling();
    --count;
  }
  return !count && !child;
}

inline bool Node::IsTreeScope() const {
  return &GetTreeScope().RootNode() == this;
}

template <>
struct DowncastTraits<ContainerNode> {
  static bool AllowFrom(const Node& node) { return node.IsContainerNode(); }
  static bool AllowFrom(const EventTarget& event_target) {
    return event_target.IsNode() && To<Node>(event_target).IsContainerNode();
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_CONTAINER_NODE_H_
