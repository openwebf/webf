/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 *           (C) 2001 Dirk Mueller (mueller@kde.org)
 * Copyright (C) 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011 Apple Inc. All
 * rights reserved.
 * Copyright (C) 2008 Nokia Corporation and/or its subsidiary(-ies)
 * Copyright (C) 2009 Torch Mobile Inc. All rights reserved.
 * (http://www.torchmobile.com/)
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

#include "node.h"
#include <unordered_map>
#include "character_data.h"
#include "child_list_mutation_scope.h"
#include "child_node_list.h"
#include "core/script_forbidden_scope.h"
#include "document.h"
#include "document_fragment.h"
#include "element.h"
#include "empty_node_list.h"
#include "node_traversal.h"
#include "qjs_node.h"
#include "text.h"
#include "core/dom/node_lists_node_data.h"
#include "core/svg/svg_element.h"
#include "core/dom/element_rare_data_vector.h"

namespace webf {

int Node::ELEMENT_NODE = kElementNode;
int Node::ATTRIBUTE_NODE = kAttributeNode;
int Node::TEXT_NODE = kTextNode;
int Node::COMMENT_NODE = kCommentNode;
int Node::DOCUMENT_NODE = kDocumentNode;
int Node::DOCUMENT_TYPE_NODE = kDocumentTypeNode;
int Node::DOCUMENT_FRAGMENT_NODE = kDocumentFragmentNode;

Node* Node::Create(ExecutingContext* context, ExceptionState& exception_state) {
  exception_state.ThrowException(context->ctx(), ErrorType::TypeError, "Illegal constructor");
  return nullptr;
}

Node* Node::ToNode() {
  return this;
}

void Node::setNodeValue(const AtomicString& value, ExceptionState& exception_state) {
  // By default, setting nodeValue has no effect.
}

ContainerNode* Node::parentNode() const {
  return ParentOrShadowHostNode();
}

NodeList* Node::childNodes() {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node) {
    return EnsureRareData().EnsureNodeLists().EnsureChildNodeList(*this_node);
  }
  return EnsureRareData().EnsureNodeLists().EnsureEmptyChildNodeList(*this);
}

//// Helper object to allocate EventTargetData which is otherwise only used
//// through EventTargetWithInlineData.
class EventTargetDataObject final {
 public:
  void Trace(GCVisitor* visitor) const { data_.Trace(visitor); }
  EventTargetData& GetEventTargetData() { return data_; }

 private:
  EventTargetData data_;
};

EventTargetData* Node::GetEventTargetData() {
  return HasEventTargetData() ? &event_target_data_->GetEventTargetData() : nullptr;
}

EventTargetData& Node::EnsureEventTargetData() {
  if (HasEventTargetData())
    return event_target_data_->GetEventTargetData();
  assert(event_target_data_ == nullptr);
  event_target_data_ = std::make_unique<EventTargetDataObject>();
  SetHasEventTargetData(true);
  return event_target_data_->GetEventTargetData();
}

template <typename Registry>
static inline void CollectMatchingObserversForMutation(MutationObserverOptionsMap& observers,
                                                       Registry* registry,
                                                       Node& target,
                                                       MutationType type,
                                                       const AtomicString* attribute_name) {
  if (!registry)
    return;

  for (const auto& registration : *registry) {
    if (registration->ShouldReceiveMutationFrom(target, type, attribute_name)) {
      MutationRecordDeliveryOptions delivery_options = registration->DeliveryOptions();
      MutationObserver* ob = registration->Observer();

      bool inserted = false;
      auto position = observers.end();
      std::tie(position, inserted) = observers.insert(std::make_pair(ob, delivery_options));
      if (inserted) {
        position->second |= delivery_options;
      } else {
        position->second = delivery_options;
      }
    }
  }
}

void Node::GetRegisteredMutationObserversOfType(MutationObserverOptionsMap& observers,
                                                MutationType type,
                                                const AtomicString* attribute_name) {
  assert((type == kMutationTypeAttributes && attribute_name) || !attribute_name);
  CollectMatchingObserversForMutation(observers, MutationObserverRegistry(), *this, type, attribute_name);
  CollectMatchingObserversForMutation(observers, TransientMutationObserverRegistry(), *this, type, attribute_name);
  ScriptForbiddenScope forbid_script_during_raw_iteration;
  for (Node* node = parentNode(); node; node = node->parentNode()) {
    CollectMatchingObserversForMutation(observers, node->MutationObserverRegistry(), *this, type, attribute_name);
    CollectMatchingObserversForMutation(observers, node->TransientMutationObserverRegistry(), *this, type,
                                        attribute_name);
  }
}

void Node::RegisterMutationObserver(MutationObserver& observer,
                                    MutationObserverOptions options,
                                    const std::unordered_set<AtomicString, AtomicString::KeyHasher>& attribute_filter) {
  MutationObserverRegistration* registration = nullptr;
  for (const auto& item : EnsureRareData().EnsureMutationObserverData().Registry()) {
    if (item->Observer() == &observer) {
      registration = item.Get();
      registration->ResetObservation(options, attribute_filter);
    }
  }

  if (!registration) {
    registration = MakeGarbageCollected<MutationObserverRegistration>(observer, this, options, attribute_filter);
    observer.ObservationStarted(registration);
    EnsureRareData().EnsureMutationObserverData().AddRegistration(registration);
  }

  GetDocument().AddMutationObserverTypes(registration->MutationTypes());
}

void Node::UnregisterMutationObserver(MutationObserverRegistration* registration) {
  const std::vector<Member<MutationObserverRegistration>>* registry = MutationObserverRegistry();
  assert(registry);
  if (!registry)
    return;

  registration->Dispose();
  EnsureRareData().EnsureMutationObserverData().RemoveRegistration(registration);
}

void Node::RegisterTransientMutationObserver(MutationObserverRegistration* registration) {
  EnsureRareData().EnsureMutationObserverData().AddTransientRegistration(registration);
}

void Node::UnregisterTransientMutationObserver(MutationObserverRegistration* registration) {
  const MutationObserverRegistrationSet* transient_registry = TransientMutationObserverRegistry();
  assert(transient_registry != nullptr);
  if (!transient_registry)
    return;

  EnsureRareData().EnsureMutationObserverData().RemoveTransientRegistration(registration);
}

void Node::NotifyMutationObserversNodeWillDetach() {
  if (!GetDocument().HasMutationObservers())
    return;

  ScriptForbiddenScope forbid_script_during_raw_iteration;
  for (Node* node = parentNode(); node; node = node->parentNode()) {
    if (const MutationObserverRegistrationVector* registry = node->MutationObserverRegistry()) {
      for (const auto& registration : *registry)
        registration->ObservedSubtreeNodeWillDetach(*this);
    }

    if (const MutationObserverRegistrationSet* transient_registry = node->TransientMutationObserverRegistry()) {
      for (auto& registration : *transient_registry)
        registration->ObservedSubtreeNodeWillDetach(*this);
    }
  }
}

NodeRareData& Node::CreateRareData() {
  if (IsElementNode()) {
    data_ = std::make_unique<ElementRareDataVector>();
  } else {
    data_ = std::make_unique<NodeRareData>();
  }
  SetFlag(kHasDataFlag);
  return *data_;
}

const std::vector<Member<MutationObserverRegistration>>* Node::MutationObserverRegistry() {
  if (!HasNodeData())
    return nullptr;
  NodeMutationObserverData* data = EnsureRareData().MutationObserverData();
  if (!data) {
    return nullptr;
  }
  return &data->Registry().ToStdVector();
}

const MutationObserverRegistrationSet* Node::TransientMutationObserverRegistry() {
  if (!HasNodeData())
    return nullptr;
  NodeMutationObserverData* data = EnsureRareData().MutationObserverData();
  if (!data) {
    return nullptr;
  }
  return &data->TransientRegistry();
}

Node& Node::TreeRoot() const {
  const Node* node = this;
  while (node->parentNode())
    node = node->parentNode();
  return const_cast<Node&>(*node);
}

void Node::remove(ExceptionState& exception_state) {
  if (ContainerNode* parent = parentNode())
    parent->RemoveChild(this, exception_state);
}

Node* Node::insertBefore(Node* new_child, Node* ref_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return this_node->InsertBefore(new_child, ref_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::replaceChild(Node* new_child, Node* old_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return this_node->ReplaceChild(new_child, old_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::removeChild(Node* old_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (this_node)
    return this_node->RemoveChild(old_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::appendChild(Node* new_child, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (LIKELY(this_node))
    return this_node->AppendChild(new_child, exception_state);

  exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
  return nullptr;
}

Node* Node::cloneNode(ExceptionState& exception_state) const {
  return cloneNode(false, exception_state);
}

Node* Node::cloneNode(bool deep, ExceptionState&) const {
  // https://dom.spec.whatwg.org/#dom-node-clonenode

  // 2. Return a clone of this, with the clone children flag set if deep is
  // true, and the clone shadows flag set if this is a DocumentFragment whose
  // host is an HTML template element.
  auto* fragment = DynamicTo<DocumentFragment>(this);
  bool clone_shadows_flag = fragment && fragment->IsTemplateContent();
  Node* new_node = Clone(GetDocument(),
                         deep ? (clone_shadows_flag ? CloneChildrenFlag::kCloneWithShadows : CloneChildrenFlag::kClone)
                              : CloneChildrenFlag::kSkip);
  return new_node;
}

static Node* NodeOrStringToNode(const std::shared_ptr<QJSUnionDomStringNode>& node_or_string,
                                Document& document,
                                bool needs_trusted_types_check,
                                ExceptionState& exception_state) {
  if (!needs_trusted_types_check) {
    // Without trusted type checks, we simply extract the string from whatever
    // constituent type we find.
    switch (node_or_string->GetContentType()) {
      case QJSUnionDomStringNode::ContentType::kNode:
        return node_or_string->GetAsNode();
      case QJSUnionDomStringNode::ContentType::kDomString:
        return Text::Create(document, node_or_string->GetAsDomString());
    }
    assert(false);
    return nullptr;
  }

  // With trusted type checks, we can process trusted script or non-text nodes
  // directly. Strings or text nodes need to be checked.
  if (node_or_string->IsNode() && !node_or_string->GetAsNode()->IsTextNode())
    return node_or_string->GetAsNode();

  AtomicString string_value =
      node_or_string->IsDomString() ? node_or_string->GetAsDomString() : node_or_string->GetAsNode()->textContent();

  return Text::Create(document, string_value);
}

// Returns nullptr if an exception was thrown.
static Node* ConvertNodesIntoNode(const Node* parent,
                                  const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes,
                                  Document& document,
                                  ExceptionState& exception_state) {
  if (nodes.size() == 1)
    return NodeOrStringToNode(nodes[0], document, false, exception_state);

  Node* fragment = DocumentFragment::Create(document);
  for (const auto& node_or_string : nodes) {
    Node* node = NodeOrStringToNode(node_or_string, document, false, exception_state);
    if (node)
      fragment->appendChild(node, exception_state);
    if (exception_state.HasException())
      return nullptr;
  }
  return fragment;
}

void Node::prepend(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
    return;
  }

  if (Node* node = ConvertNodesIntoNode(this, nodes, GetDocument(), exception_state))
    this_node->InsertBefore(node, this_node->firstChild(), exception_state);
}

void Node::append(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state) {
  auto* this_node = DynamicTo<ContainerNode>(this);
  if (!this_node) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError, "This node type does not support this method.");
    return;
  }

  if (Node* node = ConvertNodesIntoNode(this, nodes, GetDocument(), exception_state))
    this_node->AppendChild(node, exception_state);
}

void Node::append(ExceptionState& exception_state) {
  append(std::vector<std::shared_ptr<QJSUnionDomStringNode>>(), exception_state);
}

void Node::before(ExceptionState& exception_state) {
  before(std::vector<std::shared_ptr<QJSUnionDomStringNode>>(), exception_state);
}

void Node::after(ExceptionState& exception_state) {
  after(std::vector<std::shared_ptr<QJSUnionDomStringNode>>(), exception_state);
}

static bool IsNodeInNodes(const Node* const node, const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes) {
  for (const std::shared_ptr<QJSUnionDomStringNode>& node_or_string : nodes) {
    if (node_or_string->IsNode() && node_or_string->GetAsNode() == node)
      return true;
  }
  return false;
}

static Node* FindViablePreviousSibling(const Node& node,
                                       const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes) {
  for (Node* sibling = node.previousSibling(); sibling; sibling = sibling->previousSibling()) {
    if (!IsNodeInNodes(sibling, nodes))
      return sibling;
  }
  return nullptr;
}

static Node* FindViableNextSibling(const Node& node, const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes) {
  for (Node* sibling = node.nextSibling(); sibling; sibling = sibling->nextSibling()) {
    if (!IsNodeInNodes(sibling, nodes))
      return sibling;
  }
  return nullptr;
}

void Node::before(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state) {
  ContainerNode* parent = parentNode();
  if (!parent)
    return;
  Node* viable_previous_sibling = FindViablePreviousSibling(*this, nodes);
  if (Node* node = ConvertNodesIntoNode(parent, nodes, GetDocument(), exception_state)) {
    parent->InsertBefore(node, viable_previous_sibling ? viable_previous_sibling->nextSibling() : parent->firstChild(),
                         exception_state);
  }
}

void Node::after(const std::vector<std::shared_ptr<QJSUnionDomStringNode>>& nodes, ExceptionState& exception_state) {
  ContainerNode* parent = parentNode();
  if (!parent)
    return;
  Node* viable_next_sibling = FindViableNextSibling(*this, nodes);
  if (Node* node = ConvertNodesIntoNode(parent, nodes, GetDocument(), exception_state))
    parent->InsertBefore(node, viable_next_sibling, exception_state);
}

bool Node::isEqualNode(Node* other, ExceptionState& exception_state) const {
  if (!other)
    return false;

  NodeType node_type = nodeType();
  if (node_type != other->nodeType())
    return false;

  if (nodeValue() != other->nodeValue())
    return false;

  //  if (auto* this_attr = DynamicTo<Attr>(this)) {
  //    auto* other_attr = To<Attr>(other);
  //    if (this_attr->localName() != other_attr->localName())
  //      return false;
  //
  //    if (this_attr->namespaceURI() != other_attr->namespaceURI())
  //      return false;
  //  } else

  if (auto* this_element = DynamicTo<Element>(this)) {
    auto* other_element = DynamicTo<Element>(other);
    if (this_element->tagName() != other_element->tagName())
      return false;

    if (!this_element->HasEquivalentAttributes(*other_element))
      return false;
  } else if (nodeName() != other->nodeName()) {
    return false;
  }

  Node* child = firstChild();
  Node* other_child = other->firstChild();

  while (child) {
    if (!child->isEqualNode(other_child))
      return false;

    child = child->nextSibling();
    other_child = other_child->nextSibling();
  }

  if (other_child)
    return false;

  return true;
}

bool Node::isEqualNode(Node* other) const {
  ExceptionState exception_state;
  return isEqualNode(other, exception_state);
}

AtomicString Node::textContent(bool convert_brs_to_newlines) const {
  // This covers ProcessingInstruction and Comment that should return their
  // value when .textContent is accessed on them, but should be ignored when
  // iterated over as a descendant of a ContainerNode.
  if (auto* character_data = DynamicTo<CharacterData>(this))
    return character_data->data();

  // Attribute nodes have their attribute values as textContent.
  //  if (auto* attr = DynamicTo<Attr>(this))
  //    return attr->value();

  // Documents and non-container nodes (that are not CharacterData)
  // have null textContent.
  if (IsDocumentNode() || !IsContainerNode())
    return AtomicString::Null();

  std::string content;
  for (const Node& node : NodeTraversal::InclusiveDescendantsOf(*this)) {
    if (auto* text_node = DynamicTo<Text>(node)) {
      content.append(text_node->data().ToStdString(ctx()));
    }
  }
  return AtomicString(ctx(), content);
}

void Node::setTextContent(const AtomicString& text, ExceptionState& exception_state) {
  switch (nodeType()) {
    case kAttributeNode:
    case kTextNode:
    case kCommentNode:
      setNodeValue(text, exception_state);
      return;
    case kElementNode:
    case kDocumentFragmentNode: {
      // FIXME: Merge this logic into replaceChildrenWithText.
      auto* container = To<ContainerNode>(this);

      // Note: This is an intentional optimization.
      // See crbug.com/352836 also.
      // No need to do anything if the text is identical.
      if (container->HasOneTextChild() && To<Text>(container->firstChild())->data() == text && !text.IsEmpty())
        return;

      ChildListMutationScope mutation(*this);

      // Note: This API will not insert empty text nodes:
      // https://dom.spec.whatwg.org/#dom-node-textcontent
      if (text.IsEmpty()) {
        container->RemoveChildren();
      } else {
        container->RemoveChildren();
        container->AppendChild(GetDocument().createTextNode(text, exception_state), exception_state);
      }
      return;
    }
    case kDocumentNode:
    case kDocumentTypeNode:
      // Do nothing.
      return;
  }
}

void Node::SetCustomElementState(CustomElementState new_state) {
  CustomElementState old_state = GetCustomElementState();

  switch (new_state) {
    case CustomElementState::kUncustomized:
      return;

    case CustomElementState::kUndefined:
      assert(CustomElementState::kUncustomized == old_state);
      break;

    case CustomElementState::kCustom:
      assert(old_state == CustomElementState::kUndefined || old_state == CustomElementState::kFailed ||
             old_state == CustomElementState::kPreCustomized);
      break;

    case CustomElementState::kFailed:
      assert(CustomElementState::kFailed != old_state);
      break;

    case CustomElementState::kPreCustomized:
      assert(CustomElementState::kFailed == old_state);
      break;
  }

  assert(IsHTMLElement());

  auto* element = To<Element>(this);
  node_flags_ = (node_flags_ & ~kCustomElementStateMask) | static_cast<NodeFlags>(new_state);
  assert(new_state == GetCustomElementState());
}

bool Node::IsDocumentNode() const {
  return this == &GetDocument();
}

Element* Node::ParentOrShadowHostElement() const {
  ContainerNode* parent = ParentOrShadowHostNode();
  if (!parent)
    return nullptr;

  return DynamicTo<Element>(parent);
}

Node::InsertionNotificationRequest Node::InsertedInto(ContainerNode& insertion_point) {
  assert(insertion_point.isConnected() || IsContainerNode());
//  DCHECK(!ChildNeedsStyleInvalidation());
//  DCHECK(!NeedsStyleInvalidation());
  if (insertion_point.isConnected()) {
    SetFlag(kIsConnectedFlag);
    insertion_point.GetDocument().IncrementNodeCount();
  }
  return Node::InsertionNotificationRequest::kInsertionDone;
}

void Node::RemovedFrom(ContainerNode& insertion_point) {
  assert(insertion_point.isConnected() || IsContainerNode());
  if (insertion_point.isConnected()) {
    ClearFlag(kIsConnectedFlag);
    insertion_point.GetDocument().DecrementNodeCount();
  }
}

ContainerNode* Node::NonShadowBoundaryParentNode() const {
  return parentNode();
}

unsigned int Node::NodeIndex() const {
  const Node* temp_node = previousSibling();
  unsigned count = 0;
  for (count = 0; temp_node; count++)
    temp_node = temp_node->previousSibling();
  return count;
}

NodeListsNodeData* Node::NodeLists() {
  return data_ ? data_->NodeLists() : nullptr;
}

void Node::ClearNodeLists() {
  RareData()->ClearNodeLists();
}

Document* Node::ownerDocument() const {
  Document* doc = &GetDocument();
  return doc == this ? nullptr : doc;
}

bool Node::IsNode() const {
  return true;
}

bool Node::IsDescendantOf(const Node* other) const {
  // Return true if other is an ancestor of this, otherwise false
  if (!other || isConnected() != other->isConnected())
    return false;
  if (&other->GetDocument() != &GetDocument())
    return false;
  for (const ContainerNode* n = parentNode(); n; n = n->parentNode()) {
    if (n == other)
      return true;
  }
  return false;
}

bool Node::contains(const Node* node, ExceptionState& exception_state) const {
  if (!node)
    return false;
  return this == node || node->IsDescendantOf(this);
}

bool Node::ContainsIncludingHostElements(const Node& node) const {
  const Node* current = &node;
  do {
    if (current == this)
      return true;
    auto* curr_fragment = DynamicTo<DocumentFragment>(current);
    current = current->ParentOrShadowHostNode();
  } while (current);
  return false;
}

Node* Node::CommonAncestor(const Node& other, ContainerNode* (*parent)(const Node&)) const {
  if (this == &other)
    return const_cast<Node*>(this);
  if (&GetDocument() != &other.GetDocument())
    return nullptr;
  int this_depth = 0;
  for (const Node* node = this; node; node = parent(*node)) {
    if (node == &other)
      return const_cast<Node*>(node);
    this_depth++;
  }
  int other_depth = 0;
  for (const Node* node = &other; node; node = parent(*node)) {
    if (node == this)
      return const_cast<Node*>(this);
    other_depth++;
  }
  const Node* this_iterator = this;
  const Node* other_iterator = &other;
  if (this_depth > other_depth) {
    for (int i = this_depth; i > other_depth; --i)
      this_iterator = parent(*this_iterator);
  } else if (other_depth > this_depth) {
    for (int i = other_depth; i > this_depth; --i)
      other_iterator = parent(*other_iterator);
  }
  while (this_iterator) {
    if (this_iterator == other_iterator)
      return const_cast<Node*>(this_iterator);
    this_iterator = parent(*this_iterator);
    other_iterator = parent(*other_iterator);
  }
  assert(!other_iterator);
  return nullptr;
}

Node::Node(ExecutingContext* context, TreeScope* tree_scope, ConstructionType type)
    : EventTarget(context),
      node_flags_(type),
      parent_or_shadow_host_node_(nullptr),
      previous_(nullptr),
      tree_scope_(tree_scope),
      next_(nullptr),
      data_(nullptr) {}

Node::~Node() {}

void Node::Trace(GCVisitor* visitor) const {
  visitor->TraceMember(previous_);
  visitor->TraceMember(next_);
  visitor->TraceMember(parent_or_shadow_host_node_);
  if (data_ != nullptr)
    data_->Trace(visitor);
  if (event_target_data_ != nullptr) {
    event_target_data_->Trace(visitor);
  }
  EventTarget::Trace(visitor);
}

FlatTreeNodeData& Node::EnsureFlatTreeNodeData() {
  return EnsureRareData().EnsureFlatTreeNodeData();
}

FlatTreeNodeData* Node::GetFlatTreeNodeData() const {
  if (!data_) {
    return nullptr;
  }
  return RareData()->GetFlatTreeNodeData();
}

void Node::ClearFlatTreeNodeData() {
  // TODO(guopengfei)：FlatTreeNodeData not support
  // if (FlatTreeNodeData* data = GetFlatTreeNodeData())
  //   data->Clear();
}

void Node::ClearFlatTreeNodeDataIfHostChanged(const ContainerNode& parent) {
  /*
  // TODO(guopengfei)：HTMLSlotElement not support
  if (FlatTreeNodeData* data = GetFlatTreeNodeData()) {
    if (data->AssignedSlot() &&
        data->AssignedSlot()->OwnerShadowHost() != &parent) {
      data->Clear();
        }
  }
  */
}

bool Node::InActiveDocument() const {
//  return isConnected() && GetDocument().IsActive();
return false;
}

void Node::SetNeedsStyleRecalc(StyleChangeType change_type,
                               const StyleChangeReasonForTracing& reason) {
//  assert(GetDocument().GetStyleEngine().MarkStyleDirtyAllowed());
////  assert(!GetDocument().InvalidationDisallowed());
//  assert(change_type != kNoStyleChange);
//  assert(IsElementNode() || IsTextNode());
//
//  if (!InActiveDocument())
//    return;
////  if (ShouldSkipMarkingStyleDirty())
////    return;
///*
//  DEVTOOLS_TIMELINE_TRACE_EVENT_INSTANT_WITH_CATEGORIES(
//      TRACE_DISABLED_BY_DEFAULT("devtools.timeline.invalidationTracking"),
//      "StyleRecalcInvalidationTracking",
//      inspector_style_recalc_invalidation_tracking_event::Data, this,
//      change_type, reason);*/
//
//  StyleChangeType existing_change_type = GetStyleChangeType();
//  if (change_type > existing_change_type)
//    SetStyleChange(change_type);
//
//  if (existing_change_type == kNoStyleChange)
//    MarkAncestorsWithChildNeedsStyleRecalc();
//
//  // NOTE: If we are being called from SetNeedsAnimationStyleRecalc(), the
//  // AnimationStyleChange bit may be reset to 'true'.
//  if (auto* this_element = DynamicTo<Element>(this)) {
//    this_element->SetAnimationStyleChange(false);
//    /*
//    // TODO(guopengfei)：PseudoElement not support
//    // The style walk for the pseudo tree created for a ViewTransition is
//    // done after resolving style for the author DOM. See
//    // StyleEngine::RecalcTransitionPseudoStyle.
//    // Since the dirty bits from the originating element (root element) are not
//    // propagated to these pseudo elements during the default walk, we need to
//    // invalidate style for these elements here.
//    if (this_element->IsDocumentElement()) {
//      auto update_style_change = [](PseudoElement* pseudo_element) {
//        pseudo_element->SetNeedsStyleRecalc(
//            kLocalStyleChange, StyleChangeReasonForTracing::Create(
//                                   style_change_reason::kViewTransition));
//      };
//      ViewTransitionUtils::ForEachTransitionPseudo(GetDocument(),
//                                                   update_style_change);
//    }*/
//  }
//
//  if (auto* svg_element = DynamicTo<SVGElement>(this))
//    svg_element->SetNeedsStyleRecalcForInstances(change_type, reason);
}

void Node::ClearNeedsStyleRecalc() {
  node_flags_ &= ~kStyleChangeMask;
  ClearFlag(kForceReattachLayoutTree);
  if (!data_) {
    return;
  }
  if (auto* element = DynamicTo<Element>(this)) {
    element->SetAnimationStyleChange(false);
  }
}

void Node::MarkAncestorsWithChildNeedsStyleRecalc() {
//  Element* style_parent = GetStyleRecalcParent();
//  bool parent_dirty = style_parent && style_parent->IsDirtyForStyleRecalc();
//  Element* ancestor = style_parent;
//  for (; ancestor && !ancestor->ChildNeedsStyleRecalc();
//       ancestor = ancestor->GetStyleRecalcParent()) {
//    if (!ancestor->isConnected())
//      return;
//    ancestor->SetChildNeedsStyleRecalc();
//    if (ancestor->IsDirtyForStyleRecalc())
//      break;
//
//    // If we reach a locked ancestor, we should abort since the ancestor marking
//    // will be done when the lock is committed.
//    if (ancestor->ChildStyleRecalcBlockedByDisplayLock())
//      break;
//  }
//  if (!isConnected())
//    return;
//  // If the parent node is already dirty, we can keep the same recalc root. The
//  // early return here is a performance optimization.
//  if (parent_dirty)
//    return;
//  /*
//  // TODO(guopengfei)：DisplayLockDocumentState not support
//  // If we are outside the flat tree we should not update the recalc root
//  // because we should not traverse those nodes from StyleEngine::RecalcStyle().
//  const ComputedStyle* current_style = nullptr;
//  if (Element* element = DynamicTo<Element>(this)) {
//    current_style = element->GetComputedStyle();
//  }
//  if (!current_style && style_parent) {
//    current_style = style_parent->GetComputedStyle();
//  }
//  if (current_style && current_style->IsEnsuredOutsideFlatTree()) {
//    return;
//  }
//
//  // TODO(guopengfei)：DisplayLockDocumentState not support
//  // If we're in a locked subtree, then we should not update the style recalc
//  // roots. These would be updated when we commit the lock. If we have locked
//  // display locks somewhere in the document, we iterate up the ancestor chain
//  // to check if we're in one such subtree.
//  if (GetDocument().GetDisplayLockDocumentState().LockedDisplayLockCount() >
//      0) {
//    for (Element* ancestor_copy = ancestor; ancestor_copy;
//         ancestor_copy = ancestor_copy->GetStyleRecalcParent()) {
//      if (ancestor_copy->ChildStyleRecalcBlockedByDisplayLock())
//        return;
//    }
//  }*/
//
//  GetDocument().GetStyleEngine().UpdateStyleRecalcRoot(ancestor, this);
//  GetDocument().ScheduleLayoutTreeUpdateIfNeeded();
}

void Node::SetNeedsStyleInvalidation() {
  assert(IsContainerNode());
//  assert(!GetDocument().InvalidationDisallowed());
  SetFlag(kNeedsStyleInvalidationFlag);
  MarkAncestorsWithChildNeedsStyleInvalidation();
}

void Node::MarkAncestorsWithChildNeedsStyleInvalidation() {
  ScriptForbiddenScope forbid_script_during_raw_iteration;
  ContainerNode* ancestor = ParentOrShadowHostNode();
  bool parent_dirty = ancestor && ancestor->NeedsStyleInvalidation();
  for (; ancestor && !ancestor->ChildNeedsStyleInvalidation();
       ancestor = ancestor->ParentOrShadowHostNode()) {
    if (!ancestor->isConnected())
      return;
    ancestor->SetChildNeedsStyleInvalidation();
    if (ancestor->NeedsStyleInvalidation())
      break;
       }
  if (!isConnected())
    return;
  // If the parent node is already dirty, we can keep the same invalidation
  // root. The early return here is a performance optimization.
  if (parent_dirty)
    return;
  GetDocument().GetStyleEngine().UpdateStyleInvalidationRoot(ancestor, this);
  // TODO(guopengfei)：暂时忽略Layout
  //GetDocument().ScheduleLayoutTreeUpdateIfNeeded();
}

Element* Node::FlatTreeParentForChildDirty() const {
  if (IsPseudoElement())
    return ParentOrShadowHostElement();
  // TODO(guopengfei)：忽略Shadow
  // if (IsChildOfShadowHost()) {
  //   if (auto* data = GetFlatTreeNodeData())
  //     return data->AssignedSlot();
  //   return nullptr;
  // }
  Element* parent = ParentOrShadowHostElement();
  // TODO(guopengfei)：HTMLSlotElement
  // if (HTMLSlotElement* slot = DynamicTo<HTMLSlotElement>(parent)) {
  //   if (slot->HasAssignedNodesNoRecalc())
  //     return nullptr;
  // }
  return parent;
}

}  // namespace webf
