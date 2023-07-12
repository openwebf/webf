/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_CORE_DOM_CONTAINER_NODE_H_
#define BRIDGE_CORE_DOM_CONTAINER_NODE_H_

#include <vector>
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "bindings/qjs/heap_vector.h"
#include "node.h"
#include "node_list.h"

namespace webf {

class HTMLAllCollection;

// This constant controls how much buffer is initially allocated
// for a Node Vector that is used to store child Nodes of a given Node.
const int kInitialNodeVectorSize = 11;
using NodeVector = std::vector<Node*>;

class ContainerNode : public Node {
 public:
  Node* firstChild() const { return first_child_.Get(); }
  Node* lastChild() const { return last_child_.Get(); }
  bool hasChildren() const { return first_child_.Get(); }
  bool HasChildren() const { return first_child_.Get(); }

  bool HasOneChild() const { return first_child_ && !first_child_->nextSibling(); }
  bool HasOneTextChild() const { return HasOneChild() && first_child_->IsTextNode(); }
  bool HasChildCount(unsigned) const;

  std::vector<Element*> Children();

  unsigned CountChildren() const;

  Node* InsertBefore(Node* new_child, Node* ref_child, ExceptionState&);
  Node* ReplaceChild(Node* new_child, Node* old_child, ExceptionState&);
  Node* RemoveChild(Node* child, ExceptionState&);
  Node* AppendChild(Node* new_child, ExceptionState&);
  Node* AppendChild(Node* new_child);
  bool EnsurePreInsertionValidity(const Node& new_child,
                                  const Node* next,
                                  const Node* old_child,
                                  ExceptionState&) const;

  void RemoveChildren();

  void CloneChildNodesFrom(const ContainerNode&, CloneChildrenFlag);

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
    kTextChanged
  };
  enum class ChildrenChangeSource : uint8_t { kAPI, kParser };
  enum class ChildrenChangeAffectsElements : uint8_t { kNo, kYes };
  struct ChildrenChange {
    WEBF_STACK_ALLOCATED();

   public:
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

 protected:
  ContainerNode(TreeScope* tree_scope, ConstructionType = kCreateContainer);
  ContainerNode(ExecutingContext* context, Document* document, ConstructionType = kCreateContainer);

  // |attr_name| and |owner_element| are only used for element attribute
  // modifications. |ChildrenChange| is either nullptr or points to a
  // ChildNode::ChildrenChange structure that describes the changes in the tree.
  // If non-null, blink may preserve caches that aren't affected by the change.
  void InvalidateNodeListCachesInAncestors(const ChildrenChange*);

  void SetFirstChild(Node* child) { first_child_ = child; }
  void SetLastChild(Node* child) { last_child_ = child; }

 private:
  bool IsContainerNode() const = delete;  // This will catch anyone doing an unnecessary check.
  bool IsTextNode() const = delete;       // This will catch anyone doing an unnecessary check.
  void RemoveBetween(Node* previous_child, Node* next_child, Node& old_child);
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

  void NotifyNodeInsertedInternal(Node&);
  void NotifyNodeRemoved(Node&);

  inline bool IsChildTypeAllowed(const Node& child) const;
  inline bool IsHostIncludingInclusiveAncestorOfThis(const Node&, ExceptionState&) const;

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

template <>
struct DowncastTraits<ContainerNode> {
  static bool AllowFrom(const Node& node) { return node.IsContainerNode(); }
  static bool AllowFrom(const EventTarget& event_target) {
    return event_target.IsNode() && To<Node>(event_target).IsContainerNode();
  }
};

}  // namespace webf

#endif  // BRIDGE_CORE_DOM_CONTAINER_NODE_H_
