/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 *           (C) 2001 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2013 Apple Inc. All rights
 * reserved.
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public License
 * along with this library; see the file COPYING.LIB.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301, USA.
 */

/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "container_node.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "core/dom/child_list_mutation_scope.h"
#include "core/dom/child_node_list.h"
#include "core/dom/node_lists_node_data.h"
#include "core/html/html_all_collection.h"
#include "core/script_forbidden_scope.h"
#include "core/dom/events/event_dispatch_forbidden_scope.h"
#include "document.h"
#include "document_fragment.h"
#include "node_traversal.h"

namespace webf {

// Legacy impls due to limited time, should remove this func in the future.
HTMLCollection* ContainerNode::Children() {
  return EnsureCachedCollection<HTMLCollection>(CollectionType::kNodeChildren);
}

unsigned ContainerNode::CountChildren() const {
  unsigned count = 0;
  for (Node* node = firstChild(); node; node = node->nextSibling())
    count++;
  return count;
}

inline void GetChildNodes(ContainerNode& node, NodeVector& nodes) {
  assert(!nodes.size());
  for (Node* child = node.firstChild(); child; child = child->nextSibling())
    nodes.push_back(child);
}

class ContainerNode::AdoptAndInsertBefore {
 public:
  inline void operator()(ContainerNode& container, Node& child, Node* next) const {
    assert(next);
    assert(next->parentNode() == &container);
    container.InsertBeforeCommon(*next, child);
  }
};

class ContainerNode::AdoptAndAppendChild {
 public:
  inline void operator()(ContainerNode& container, Node& child, Node*) const { container.AppendChildCommon(child); }
};

bool ContainerNode::IsChildTypeAllowed(const Node& child) const {
  auto* child_fragment = DynamicTo<DocumentFragment>(child);
  if (!child_fragment)
    return ChildTypeAllowed(child.nodeType());

  for (Node* node = child_fragment->firstChild(); node; node = node->nextSibling()) {
    if (!ChildTypeAllowed(node->nodeType()))
      return false;
  }
  return true;
}

// Returns true if |new_child| contains this node. In that case,
// |exception_state| has an exception.
// https://dom.spec.whatwg.org/#concept-tree-host-including-inclusive-ancestor
bool ContainerNode::IsHostIncludingInclusiveAncestorOfThis(const Node& new_child,
                                                           ExceptionState& exception_state) const {
  // Non-ContainerNode can contain nothing.
  if (!new_child.IsContainerNode())
    return false;

  bool child_contains_parent = false;
  const Node& root = TreeRoot();
  auto* fragment = DynamicTo<DocumentFragment>(root);
  if (fragment && fragment->IsTemplateContent()) {
    child_contains_parent = new_child.ContainsIncludingHostElements(*this);
  } else {
    child_contains_parent = new_child.contains(this, exception_state);
  }
  if (child_contains_parent) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "The new child element contains the parent.");
  }
  return child_contains_parent;
}

inline bool CheckReferenceChildParent(const Node& parent,
                                      const Node* next,
                                      const Node* old_child,
                                      ExceptionState& exception_state) {
  if (next && next->parentNode() != &parent) {
    exception_state.ThrowException(next->ctx(), ErrorType::TypeError,
                                   "The node before which the new node is "
                                   "to be inserted is not a child of this "
                                   "node.");
    return false;
  }
  if (old_child && old_child->parentNode() != &parent) {
    exception_state.ThrowException(old_child->ctx(), ErrorType::TypeError,
                                   "The node to be replaced is not a child of this node.");
    return false;
  }
  return true;
}

// This dispatches various events; DOM mutation events, blur events, IFRAME
// unload events, etc.
// Returns true if DOM mutation should be proceeded.
static inline bool CollectChildrenAndRemoveFromOldParent(Node& node,
                                                         NodeVector& nodes,
                                                         ExceptionState& exception_state) {
  if (auto* fragment = DynamicTo<DocumentFragment>(node)) {
    GetChildNodes(*fragment, nodes);
    fragment->RemoveChildren();
    return !nodes.empty();
  }
  nodes.push_back(&node);
  if (ContainerNode* old_parent = node.parentNode())
    old_parent->RemoveChild(&node, exception_state);
  return !exception_state.HasException() && !nodes.empty();
}

Node* ContainerNode::InsertBefore(Node* new_child, Node* ref_child, ExceptionState& exception_state) {
  assert(new_child);
  // https://dom.spec.whatwg.org/#concept-node-pre-insert

  // insertBefore(node, null) is equivalent to appendChild(node)
  if (!ref_child)
    return AppendChild(new_child, exception_state);

  // 1. Ensure pre-insertion validity of node into parent before child.
  if (!EnsurePreInsertionValidity(*new_child, ref_child, nullptr, exception_state))
    return new_child;

  // 2. Let reference child be child.
  // 3. If reference child is node, set it to node’s next sibling.
  if (ref_child == new_child) {
    ref_child = new_child->nextSibling();
    if (!ref_child)
      return AppendChild(new_child, exception_state);
  }

  // 4. Adopt node into parent’s node document.
  NodeVector targets;
  targets.reserve(kInitialNodeVectorSize);
  if (!CollectChildrenAndRemoveFromOldParent(*new_child, targets, exception_state))
    return new_child;

  // 5. Insert node into parent before reference child.
  NodeVector post_insertion_notification_targets;
  {
    ChildListMutationScope scope{*this};
    InsertNodeVector(targets, ref_child, AdoptAndInsertBefore(), &post_insertion_notification_targets);
  }
  DidInsertNodeVector(targets, ref_child, post_insertion_notification_targets);
  return new_child;
}

Node* ContainerNode::ReplaceChild(Node* new_child, Node* old_child, ExceptionState& exception_state) {
  assert(new_child);
  // https://dom.spec.whatwg.org/#concept-node-replace

  if (!old_child) {
    exception_state.ThrowException(new_child->ctx(), ErrorType::TypeError, "The node to be replaced is null.");
    return nullptr;
  }

  // Step 2 to 6.
  if (!EnsurePreInsertionValidity(*new_child, nullptr, old_child, exception_state))
    return old_child;

  // 7. Let reference child be child’s next sibling.
  Node* next = old_child->nextSibling();
  // 8. If reference child is node, set it to node’s next sibling.
  if (next == new_child)
    next = new_child->nextSibling();

  // 10. Adopt node into parent’s node document.
  // Though the following CollectChildrenAndRemoveFromOldParent() also calls
  // RemoveChild(), we'd like to call RemoveChild() here to make a separated
  // MutationRecord.
  if (ContainerNode* new_child_parent = new_child->parentNode()) {
    new_child_parent->RemoveChild(new_child, exception_state);
    if (exception_state.HasException())
      return nullptr;
  }

  NodeVector targets;
  targets.reserve(kInitialNodeVectorSize);
  NodeVector post_insertion_notification_targets;
  post_insertion_notification_targets.reserve(kInitialNodeVectorSize);
  {
    ChildListMutationScope scope{*this};
    // 9. Let previousSibling be child’s previous sibling.
    // 11. Let removedNodes be the empty list.
    // 15. Queue a mutation record of "childList" for target parent with
    // addedNodes nodes, removedNodes removedNodes, nextSibling reference child,
    // and previousSibling previousSibling.

    // 12. If child’s parent is not null, run these substeps:
    //    1. Set removedNodes to a list solely containing child.
    //    2. Remove child from its parent with the suppress observers flag set.
    if (ContainerNode* old_child_parent = old_child->parentNode()) {
      old_child_parent->RemoveChild(old_child, exception_state);
      if (exception_state.HasException())
        return nullptr;
    }

    // 13. Let nodes be node’s children if node is a DocumentFragment node, and
    // a list containing solely node otherwise.
    if (!CollectChildrenAndRemoveFromOldParent(*new_child, targets, exception_state))
      return old_child;
    // 10. Adopt node into parent’s node document.
    // 14. Insert node into parent before reference child with the suppress
    // observers flag set.
    if (next) {
      InsertNodeVector(targets, next, AdoptAndInsertBefore(), &post_insertion_notification_targets);
    } else {
      InsertNodeVector(targets, nullptr, AdoptAndAppendChild(), &post_insertion_notification_targets);
    }
  }
  DidInsertNodeVector(targets, next, post_insertion_notification_targets);

  // 16. Return child.
  return old_child;
}

Node* ContainerNode::RemoveChild(Node* old_child, ExceptionState& exception_state) {
  // NotFoundError: Raised if oldChild is not a child of this node.
  if (!old_child || old_child->parentNode() != this) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "The node to be removed is not a child of this node.");
    return nullptr;
  }

  Node* child = old_child;

  // Events fired when blurring currently focused node might have moved this
  // child into a different parent.
  if (child->parentNode() != this) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "The node to be removed is no longer a "
                                   "child of this node. Perhaps it was moved "
                                   "in a 'blur' event handler?");
    return nullptr;
  }

  WillRemoveChild(*child);

  {
    Node* prev = child->previousSibling();
    Node* next = child->nextSibling();
    {
      RemoveBetween(prev, next, *child);
      NotifyNodeRemoved(*child);
    }
    ChildrenChanged(ChildrenChange::ForRemoval(*child, prev, next, ChildrenChangeSource::kAPI));
  }
  return child;
}

Node* ContainerNode::AppendChild(Node* new_child, ExceptionState& exception_state) {
  assert(new_child);
  // Make sure adding the new child is ok
  if (!EnsurePreInsertionValidity(*new_child, nullptr, nullptr, exception_state))
    return new_child;

  NodeVector targets;
  targets.reserve(kInitialNodeVectorSize);
  if (!CollectChildrenAndRemoveFromOldParent(*new_child, targets, exception_state))
    return new_child;

  NodeVector post_insertion_notification_targets;
  post_insertion_notification_targets.reserve(kInitialNodeVectorSize);
  {
    ChildListMutationScope mutation_scope(*this);
    InsertNodeVector(targets, nullptr, AdoptAndAppendChild(), &post_insertion_notification_targets);
  }
  DidInsertNodeVector(targets, nullptr, post_insertion_notification_targets);
  return new_child;
}

Node* ContainerNode::AppendChild(Node* new_child) {
  return AppendChild(new_child, ASSERT_NO_EXCEPTION());
}

void ContainerNode::WillRemoveChild(Node& child) {
  assert(child.parentNode() == this);
  ChildListMutationScope(*this).WillRemoveChild(child);
  child.NotifyMutationObserversNodeWillDetach();
  if (&GetDocument() != &child.GetDocument()) {
    // |child| was moved to another document by the DOM mutation event handler.
    return;
  }
}

void ContainerNode::WillRemoveChildren() {
  NodeVector children;
  GetChildNodes(*this, children);

  ChildListMutationScope mutation(*this);
  for (const auto& node : children) {
    assert(node);
    Node& child = *node;
    mutation.WillRemoveChild(child);
    child.NotifyMutationObserversNodeWillDetach();
  }
}

bool ContainerNode::EnsurePreInsertionValidity(const Node& new_child,
                                               const Node* next,
                                               const Node* old_child,
                                               ExceptionState& exception_state) const {
  assert(!(next && old_child));

  // Use common case fast path if possible.
  if ((new_child.IsElementNode() || new_child.IsTextNode()) && IsElementNode()) {
    assert(IsChildTypeAllowed(new_child));
    // 2. If node is a host-including inclusive ancestor of parent, throw a
    // HierarchyRequestError.
    if (IsHostIncludingInclusiveAncestorOfThis(new_child, exception_state))
      return false;
    // 3. If child is not null and its parent is not parent, then throw a
    // NotFoundError.
    return CheckReferenceChildParent(*this, next, old_child, exception_state);
  }

  //  if (auto* document = DynamicTo<Document>(this)) {
  //    // Step 2 is unnecessary. No one can have a Document child.
  //    // Step 3:
  //    if (!CheckReferenceChildParent(*this, next, old_child, exception_state))
  //      return false;
  //    // Step 4-6.
  //    return document->CanAcceptChild(new_child, next, old_child, exception_state);
  //  }

  // 2. If node is a host-including inclusive ancestor of parent, throw a
  // HierarchyRequestError.
  if (IsHostIncludingInclusiveAncestorOfThis(new_child, exception_state))
    return false;

  // 3. If child is not null and its parent is not parent, then throw a
  // NotFoundError.
  if (!CheckReferenceChildParent(*this, next, old_child, exception_state))
    return false;

  // 4. If node is not a DocumentFragment, DocumentType, Element, Text,
  // ProcessingInstruction, or Comment node, throw a HierarchyRequestError.
  // 5. If either node is a Text node and parent is a document, or node is a
  // doctype and parent is not a document, throw a HierarchyRequestError.
  if (!IsChildTypeAllowed(new_child)) {
    exception_state.ThrowException(
        ctx(), ErrorType::TypeError,
        "Nodes of type '" + new_child.nodeName() + "' may not be inserted inside nodes of type '" + nodeName() + "'.");
    return false;
  }

  // Step 6 is unnecessary for non-Document nodes.
  return true;
}

void ContainerNode::RemoveChildren() {
  if (!first_child_)
    return;

  // Do any prep work needed before actually starting to detach
  // and remove... e.g. stop loading frames, fire unload events.
  WillRemoveChildren();

  bool has_element_child = false;

  while (Node* child = first_child_) {
    if (child->IsElementNode()) {
      has_element_child = true;
    }
    RemoveBetween(nullptr, child->nextSibling(), *child);
    NotifyNodeRemoved(*child);
  }

  ChildrenChange change = {
      .type = ChildrenChangeType::kAllChildrenRemoved,
      .by_parser = ChildrenChangeSource::kAPI,
      .affects_elements = has_element_child ? ChildrenChangeAffectsElements::kYes : ChildrenChangeAffectsElements::kNo};
  ChildrenChanged(change);
}

void ContainerNode::CloneChildNodesFrom(const ContainerNode& node, CloneChildrenFlag flag) {
  assert(flag != CloneChildrenFlag::kSkip);
  for (const Node& child : NodeTraversal::ChildrenOf(node)) {
    AppendChild(child.Clone(GetDocument(), flag));
  }
}

void ContainerNode::ParserAppendChild(Node* new_child) {
  assert(new_child);
  assert(!new_child->IsDocumentFragment());
  assert(!IsA<HTMLTemplateElement>(this));

  // FIXME: parserRemoveChild can run script which could then insert the
  // newChild back into the page. Loop until the child is actually removed.
  // See: fast/parser/execute-script-during-adoption-agency-removal.html
  while (ContainerNode* parent = new_child->parentNode())
    parent->ParserRemoveChild(*new_child);

  {
    EventDispatchForbiddenScope assert_no_event_dispatch;
    ScriptForbiddenScope forbid_script;

    AdoptAndAppendChild()(*this, *new_child, nullptr);
    ChildListMutationScope(*this).ChildAdded(*new_child);
  }

  NotifyNodeInserted(*new_child, ChildrenChangeSource::kParser);
}

void ContainerNode::ParserAppendChildInDocumentFragment(Node* new_child) {
  assert(new_child);
  assert(!new_child->IsDocumentFragment());
  assert(!IsA<HTMLTemplateElement>(this));
  assert(new_child->GetDocument() == GetDocument());
  assert(&new_child->GetTreeScope() == &GetTreeScope());
  assert(new_child->parentNode() == nullptr);
  EventDispatchForbiddenScope assert_no_event_dispatch;
  ScriptForbiddenScope forbid_script;
  AppendChildCommon(*new_child);
  ChildListMutationScope(*this).ChildAdded(*new_child);
}

void ContainerNode::ParserFinishedBuildingDocumentFragment() {
  EventDispatchForbiddenScope assert_no_event_dispatch;
  ScriptForbiddenScope forbid_script;
  const ChildrenChange change =
      ChildrenChange::ForFinishingBuildingDocumentFragmentTree();

  for (Node& node : NodeTraversal::DescendantsOf(*this)) {
    NotifyNodeAtEndOfBuildingFragmentTree(node, change,
                                          false);
  }

//  if (GetDocument().ShouldInvalidateNodeListCaches(nullptr)) {
//    GetDocument().InvalidateNodeListCaches(nullptr);
//  }
}

void ContainerNode::ParserRemoveChild(Node& old_child) {
  assert(old_child.parentNode() == this);
  assert(!old_child.IsDocumentFragment());

  if (old_child.parentNode() != this)
    return;

  ChildListMutationScope(*this).WillRemoveChild(old_child);
  old_child.NotifyMutationObserversNodeWillDetach();

//  HTMLFrameOwnerElement::PluginDisposeSuspendScope suspend_plugin_dispose;
//  TreeOrderedMap::RemoveScope tree_remove_scope;
//  StyleEngine& engine = GetDocument().GetStyleEngine();
//  StyleEngine::DetachLayoutTreeScope detach_scope(engine);

  Node* prev = old_child.previousSibling();
  Node* next = old_child.nextSibling();
  {
//    StyleEngine::DOMRemovalScope style_scope(engine);
    RemoveBetween(prev, next, old_child);
    NotifyNodeRemoved(old_child);
  }
  ChildrenChanged(ChildrenChange::ForRemoval(old_child, prev, next,
                                             ChildrenChangeSource::kParser));
}

void ContainerNode::ParserInsertBefore(Node* new_child, Node& next_child) {
  assert(new_child);
  assert(next_child.parentNode() == this ||
         (DynamicTo<DocumentFragment>(this) &&
          DynamicTo<DocumentFragment>(this)->IsTemplateContent()));
  assert(!new_child->IsDocumentFragment());
  assert(!IsA<HTMLTemplateElement>(this));

  if (next_child.previousSibling() == new_child ||
      &next_child == new_child)  // nothing to do
    return;

  // FIXME: parserRemoveChild can run script which could then insert the
  // newChild back into the page. Loop until the child is actually removed.
  // See: fast/parser/execute-script-during-adoption-agency-removal.html
  while (ContainerNode* parent = new_child->parentNode())
    parent->ParserRemoveChild(*new_child);

  // This can happen if foster parenting moves nodes into a template
  // content document, but next_child is still a "direct" child of the
  // template.
  if (next_child.parentNode() != this)
    return;

  {
    EventDispatchForbiddenScope assert_no_event_dispatch;
    ScriptForbiddenScope forbid_script;

    AdoptAndInsertBefore()(*this, *new_child, &next_child);
    ChildListMutationScope(*this).ChildAdded(*new_child);
  }

  NotifyNodeInserted(*new_child, ChildrenChangeSource::kParser);
}

void ContainerNode::ParserTakeAllChildrenFrom(webf::ContainerNode& old_parent) {
  while (Node* child = old_parent.firstChild()) {
    // Explicitly remove since appending can fail, but this loop shouldn't be
    // infinite.
    old_parent.ParserRemoveChild(*child);
    ParserAppendChild(child);
  }
}

AtomicString ContainerNode::nodeValue() const {
  return AtomicString::Null();
}

ContainerNode::ContainerNode(TreeScope* tree_scope, ConstructionType type)
    : ContainerNode(tree_scope->GetDocument().GetExecutingContext(), &tree_scope->GetDocument(), type) {}
ContainerNode::ContainerNode(ExecutingContext* context, Document* document, ConstructionType type)
    : Node(context, document, type), first_child_(nullptr), last_child_(nullptr) {}

void ContainerNode::NotifyNodeAtEndOfBuildingFragmentTree(webf::Node& node,
                                                          const webf::ContainerNode::ChildrenChange& change,
                                                          bool may_contain_shadow_roots) {
  // Fast path parser only creates disconnected nodes.
  assert(!node.isConnected());

  // NotifyNodeInserted() keeps a list of nodes to call
  // DidNotifySubtreeInsertionsToDocument() on if InsertedInto() returns
  // kInsertionShouldCallDidNotifySubtreeInsertions, but only if the node
  // is connected. None of the nodes are connected at this point, so it's
  // not needed here.
  node.InsertedInto(*this);

  // No node-lists should have been created at this (otherwise
  // InvalidateNodeListCaches() would need to be called).
  assert(!RareData() || !RareData()->NodeLists());

  if (node.IsContainerNode()) {
    DynamicTo<ContainerNode>(node)->ChildrenChanged(change);
  }
}

void ContainerNode::RemoveBetween(Node* previous_child, Node* next_child, Node& old_child) {
  assert(old_child.parentNode() == this);

  if (next_child)
    next_child->SetPreviousSibling(previous_child);
  if (previous_child)
    previous_child->SetNextSibling(next_child);
  if (first_child_ == &old_child)
    SetFirstChild(next_child);
  if (last_child_ == &old_child)
    SetLastChild(previous_child);

  old_child.SetPreviousSibling(nullptr);
  old_child.SetNextSibling(nullptr);
  old_child.SetParentOrShadowHostNode(nullptr);

  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kRemoveNode, nullptr, old_child.bindingObject(),
                                                       nullptr);
}

NodeListsNodeData& ContainerNode::EnsureNodeLists() {
  return EnsureRareData().EnsureNodeLists();
}

template <typename Functor>
void ContainerNode::InsertNodeVector(const NodeVector& targets,
                                     Node* next,
                                     const Functor& mutator,
                                     NodeVector* post_insertion_notification_targets) {
  assert(post_insertion_notification_targets);
  {
    for (const auto& target_node : targets) {
      assert(target_node);
      assert(!target_node->parentNode());
      Node& child = *target_node;
      mutator(*this, child, next);
      ChildListMutationScope(*this).ChildAdded(child);
      NotifyNodeInsertedInternal(child, *post_insertion_notification_targets);
    }
  }
}

void ContainerNode::DidInsertNodeVector(const webf::NodeVector& targets,
                                        webf::Node* next,
                                        const webf::NodeVector& post_insertion_notification_targets) {
  Node* unchanged_previous = targets.size() > 0 ? targets[0]->previousSibling() : nullptr;
  for (const auto& target_node : targets) {
    ChildrenChanged(ChildrenChange::ForInsertion(*target_node, unchanged_previous, next, ChildrenChangeSource::kAPI));
  }
}

void ContainerNode::InsertBeforeCommon(Node& next_child, Node& new_child) {
  // Use insertBefore if you need to handle reparenting (and want DOM mutation
  // events).
  assert(!new_child.parentNode());
  assert(!new_child.nextSibling());
  assert(!new_child.previousSibling());

  Node* prev = next_child.previousSibling();
  assert(last_child_ != prev);
  next_child.SetPreviousSibling(&new_child);
  if (prev) {
    assert(firstChild() != &next_child);
    assert(prev->nextSibling() == &next_child);
    prev->SetNextSibling(&new_child);
  } else {
    assert(firstChild() == &next_child);
    SetFirstChild(&new_child);
  }
  new_child.SetParentOrShadowHostNode(this);
  new_child.SetPreviousSibling(prev);
  new_child.SetNextSibling(&next_child);

  std::unique_ptr<SharedNativeString> args_01 = stringToNativeString("beforebegin");
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kInsertAdjacentNode, std::move(args_01),
                                                       next_child.bindingObject(), new_child.bindingObject());
}

void ContainerNode::AppendChildCommon(Node& child) {
  child.SetParentOrShadowHostNode(this);
  if (last_child_) {
    child.SetPreviousSibling(last_child_);
    last_child_->SetNextSibling(&child);
  } else {
    SetFirstChild(&child);
  }
  SetLastChild(&child);

  std::unique_ptr<SharedNativeString> args_01 = stringToNativeString("beforeend");
  GetExecutingContext()->uiCommandBuffer()->AddCommand(UICommand::kInsertAdjacentNode, std::move(args_01),
                                                       bindingObject(), child.bindingObject());
}

void ContainerNode::NotifyNodeInserted(Node& root, webf::ContainerNode::ChildrenChangeSource source) {
  assert(!EventDispatchForbiddenScope::IsEventDispatchForbidden());

  NodeVector post_insertion_notification_targets;
  NotifyNodeInsertedInternal(root, post_insertion_notification_targets);

  ChildrenChanged(ChildrenChange::ForInsertion(root, root.previousSibling(),
                                               root.nextSibling(), source));
}

void ContainerNode::NotifyNodeInsertedInternal(Node& root, NodeVector& post_insertion_notification_targets) {
  EventDispatchForbiddenScope assert_no_event_dispatch;
  ScriptForbiddenScope forbid_script;

  for (Node& node : NodeTraversal::InclusiveDescendantsOf(root)) {
    // As an optimization we don't notify leaf nodes when inserting
    // into detached subtrees that are not in a shadow tree.
    if (!isConnected() && !node.IsContainerNode())
      continue;

    // Only tag the target as one that we need to call post-insertion steps on
    // if it is being *fully* inserted, and not re-inserted as part of a
    // state-preserving atomic move. That's because the post-insertion steps can
    // run script and modify the frame tree, neither of which are allowed in a
    // state-preserving atomic move.
    if (Node::kInsertionShouldCallDidNotifySubtreeInsertions ==
            node.InsertedInto(*this)) {
      post_insertion_notification_targets.push_back(&node);
    }
  }
}

void ContainerNode::NotifyNodeRemoved(Node& root) {
  for (Node& node : NodeTraversal::InclusiveDescendantsOf(root)) {
    // As an optimization we skip notifying Text nodes and other leaf nodes
    // of removal when they're not in the Document tree and not in a shadow root
    // since the virtual call to removedFrom is not needed.
    if (!node.IsContainerNode() && !node.IsInTreeScope())
      continue;
    node.RemovedFrom(*this);
  }
}

void ContainerNode::ChildrenChanged(const webf::ContainerNode::ChildrenChange& change) {
  InvalidateNodeListCachesInAncestors(nullptr, nullptr, &change);
}

void ContainerNode::InvalidateNodeListCachesInAncestors(
    const QualifiedName* attr_name,
    Element* attribute_owner_element,
    const ChildrenChange* change) {
  // This is a performance optimization, NodeList cache invalidation is
  // not necessary for a text change.
  if (change && change->type == ChildrenChangeType::kTextChanged)
    return;

  if (!attr_name || IsAttributeNode()) {
    if (const NodeRareData* data = RareData()) {
      if (NodeListsNodeData* lists = data->NodeLists()) {
        if (ChildNodeList* child_node_list = lists->GetChildNodeList(*this)) {
          if (change) {
            child_node_list->ChildrenChanged(*change);
          } else {
            child_node_list->InvalidateCache();
          }
        }
      }
    }
  }

  // This is a performance optimization, NodeList cache invalidation is
  // not necessary for non-element nodes.
  if (change && change->affects_elements == ChildrenChangeAffectsElements::kNo)
    return;

  // Modifications to attributes that are not associated with an Element can't
  // invalidate NodeList caches.
  if (attr_name && !attribute_owner_element)
    return;

  if (!GetDocument().ShouldInvalidateNodeListCaches(attr_name))
    return;

  GetDocument().InvalidateNodeListCaches(attr_name);

  for (ContainerNode* node = this; node; node = node->parentNode()) {
    if (NodeListsNodeData* lists = node->NodeLists())
      lists->InvalidateCaches(attr_name);
  }
}
/* // TODO(guopengfei)：webf old impl
void ContainerNode::InvalidateNodeListCachesInAncestors(const webf::ContainerNode::ChildrenChange* change) {
  // This is a performance optimization, NodeList cache invalidation is
  // not necessary for a text change.
  if (change && change->type == ChildrenChangeType::kTextChanged)
    return;

  if (HasNodeData()) {
    if (NodeList* lists = RareData()->NodeLists()) {
      if (lists != nullptr && lists->IsChildNodeList()) {
        auto* child_node_list = static_cast<ChildNodeList*>(lists);
        if (change) {
          child_node_list->ChildrenChanged(*change);
        } else {
          child_node_list->InvalidateCache();
        }
      }
    }
  }

  // This is a performance optimization, NodeList cache invalidation is
  // not necessary for non-element nodes.
  if (change && change->affects_elements == ChildrenChangeAffectsElements::kNo)
    return;

  for (ContainerNode* node = this; node; node = node->parentNode()) {
    NodeList* lists = node->childNodes();
    if (lists->IsChildNodeList()) {
      reinterpret_cast<ChildNodeList*>(lists)->InvalidateCache();
    }
  }
}*/

void ContainerNode::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(first_child_);
  visitor->TraceMember(last_child_);

  Node::Trace(visitor);
}

void ContainerNode::SetRestyleFlag(DynamicRestyleFlags mask) {
  assert(IsElementNode() || IsShadowRoot());
  EnsureRareData().SetRestyleFlag(mask);
}

}  // namespace webf
