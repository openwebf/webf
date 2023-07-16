/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 * Copyright (C) 2003-2008, 2011, 2012, 2014 Apple Inc. All rights reserved.
 * Copyright (C) 2014 Samsung Electronics. All rights reserved.
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
 *
 */

#include "html_collection.h"

namespace webf {

static bool ShouldTypeOnlyIncludeDirectChildren(CollectionType type) {
  switch (type) {
    case kClassCollectionType:
    case kTagCollectionType:
    case kTagCollectionNSType:
    case kHTMLTagCollectionType:
    case kDocAll:
    case kDocAnchors:
    case kDocApplets:
    case kDocEmbeds:
    case kDocForms:
    case kDocImages:
    case kDocLinks:
    case kDocScripts:
    case kDocumentNamedItems:
    case kDocumentAllNamedItems:
    case kMapAreas:
    case kTableRows:
    case kSelectOptions:
    case kSelectedOptions:
    case kDataListOptions:
    case kWindowNamedItems:
    case kFormControls:
      return false;
    case kNodeChildren:
    case kTRCells:
    case kTSectionRows:
    case kTableTBodies:
      return true;
    case kNameNodeListType:
    case kRadioNodeListType:
    case kRadioImgNodeListType:
    case kLabelsNodeListType:
      break;
  }
  assert(false);
  return false;
}

static NodeListSearchRoot SearchRootFromCollectionType(const ContainerNode& owner, CollectionType type) {
  switch (type) {
    case kDocImages:
    case kDocApplets:
    case kDocEmbeds:
    case kDocForms:
    case kDocLinks:
    case kDocAnchors:
    case kDocScripts:
    case kDocAll:
    case kWindowNamedItems:
    case kDocumentNamedItems:
    case kDocumentAllNamedItems:
    case kClassCollectionType:
    case kTagCollectionType:
    case kTagCollectionNSType:
    case kHTMLTagCollectionType:
    case kNodeChildren:
    case kTableTBodies:
    case kTSectionRows:
    case kTableRows:
    case kTRCells:
    case kSelectOptions:
    case kSelectedOptions:
    case kDataListOptions:
    case kMapAreas:
      return NodeListSearchRoot::kOwnerNode;
    case kNameNodeListType:
    case kRadioNodeListType:
    case kRadioImgNodeListType:
    case kLabelsNodeListType:
    case kFormControls:
      break;
  }
  assert(false);
  return NodeListSearchRoot::kOwnerNode;
}

HTMLCollection::HTMLCollection(ContainerNode& owner_node,
                               CollectionType type,
                               ItemAfterOverrideType item_after_override_type)
    : LiveNodeListBase(owner_node,
                       SearchRootFromCollectionType(owner_node, type),
                       type),
      overrides_item_after_(item_after_override_type == kOverridesItemAfter),
      should_only_include_direct_children_(ShouldTypeOnlyIncludeDirectChildren(type)),
      ScriptWrappable(owner_node.ctx()) {
  // Keep this in the child class because |registerNodeList| requires wrapper
  // tracing and potentially calls virtual methods which is not allowed in a
  // base class constructor.
//  GetDocument().RegisterNodeList(this);
}

HTMLCollection::~HTMLCollection() = default;

void HTMLCollection::InvalidateCache(Document* old_document) const {
  collection_items_cache_.Invalidate();
}

unsigned HTMLCollection::length() const {
  return collection_items_cache_.NodeCount(*this);
}

Element* HTMLCollection::item(unsigned offset, ExceptionState& exceptionState) const {
  return collection_items_cache_.NodeAt(*this, offset);
}

inline bool HTMLCollection::ElementMatches(const Element& element) const {
  // These collections apply to any kind of Elements, not just HTMLElements.
  switch (GetType()) {
    case kDocAll:
    case kNodeChildren:
      return true;
    default:
      break;
  }

  // The following only applies to HTMLElements.
  auto* html_element = DynamicTo<HTMLElement>(element);
  return html_element;
}

namespace {

template <class HTMLCollectionType>
class IsMatch {
  WEBF_STACK_ALLOCATED();

 public:
  IsMatch(const HTMLCollectionType& list) : list_(&list) {}

  bool operator()(const Element& element) const { return list_->ElementMatches(element); }

 private:
  const HTMLCollectionType* list_;
};

}  // namespace

template <class HTMLCollectionType>
static inline IsMatch<HTMLCollectionType> MakeIsMatch(const HTMLCollectionType& list) {
  return IsMatch<HTMLCollectionType>(list);
}

Element* HTMLCollection::VirtualItemAfter(Element*) const {
  assert(false);
  return nullptr;
}

Element* HTMLCollection::TraverseToFirst() const {
  if (OverridesItemAfter())
    return VirtualItemAfter(nullptr);
  if (ShouldOnlyIncludeDirectChildren())
    return ElementTraversal::FirstChild(RootNode(), MakeIsMatch(*this));
  return ElementTraversal::FirstWithin(RootNode(), MakeIsMatch(*this));
}

Element* HTMLCollection::TraverseToLast() const {
  assert(CanTraverseBackward());
  if (ShouldOnlyIncludeDirectChildren())
    return ElementTraversal::LastChild(RootNode(), MakeIsMatch(*this));
  return ElementTraversal::LastWithin(RootNode(), MakeIsMatch(*this));
}

Element* HTMLCollection::TraverseForwardToOffset(unsigned offset,
                                                 Element& current_element,
                                                 unsigned& current_offset) const {
  assert(current_offset < offset);
  if (OverridesItemAfter()) {
    for (Element* next = VirtualItemAfter(&current_element); next; next = VirtualItemAfter(next)) {
      if (++current_offset == offset)
        return next;
    }
    return nullptr;
  }
  if (ShouldOnlyIncludeDirectChildren()) {
    IsMatch<HTMLCollection> is_match(*this);
    for (Element* next = ElementTraversal::NextSibling(current_element, is_match); next;
         next = ElementTraversal::NextSibling(*next, is_match)) {
      if (++current_offset == offset)
        return next;
    }
    return nullptr;
  }
  return TraverseMatchingElementsForwardToOffset(current_element, &RootNode(), offset, current_offset,
                                                 MakeIsMatch(*this));
}

Element* HTMLCollection::TraverseBackwardToOffset(unsigned offset,
                                                  Element& current_element,
                                                  unsigned& current_offset) const {
  assert(current_offset > offset);
  assert(CanTraverseBackward());
  if (ShouldOnlyIncludeDirectChildren()) {
    IsMatch<HTMLCollection> is_match(*this);
    for (Element* previous = ElementTraversal::PreviousSibling(current_element, is_match); previous;
         previous = ElementTraversal::PreviousSibling(*previous, is_match)) {
      if (--current_offset == offset)
        return previous;
    }
    return nullptr;
  }
  return TraverseMatchingElementsBackwardToOffset(current_element, &RootNode(), offset, current_offset,
                                                  MakeIsMatch(*this));
}

Element* HTMLCollection::namedItem(const AtomicString& name) const {
  int32_t index = std::stoi(name.ToStdString(ctx()));
  return collection_items_cache_.NodeAt(*this, index);
}

bool HTMLCollection::NamedPropertyQuery(const AtomicString& name, ExceptionState&) {
  return namedItem(name);
}

void HTMLCollection::NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&) {
  uint32_t size = collection_items_cache_.NodeCount(*this);
  for (int i = 0; i < size; i++) {
    names.emplace_back(AtomicString(ctx(), std::to_string(i)));
  }
}

void HTMLCollection::Trace(GCVisitor* visitor) const {
  ScriptWrappable::Trace(visitor);
  LiveNodeListBase::Trace(visitor);
  collection_items_cache_.Trace(visitor);
}

}  // namespace webf
