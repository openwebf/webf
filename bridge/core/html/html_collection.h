/*
 * Copyright (C) 1999 Lars Knoll (knoll@kde.org)
 *           (C) 1999 Antti Koivisto (koivisto@kde.org)
 * Copyright (C) 2003, 2004, 2005, 2006, 2007, 2008, 2011, 2012 Apple Inc. All
 * rights reserved.
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

#ifndef WEBF_HTML_COLLECTION_H
#define WEBF_HTML_COLLECTION_H

#include "bindings/qjs/script_wrappable.h"
#include "core/dom/collection_items_cache.h"
#include "core/dom/live_node_list_base.h"
#include "foundation/macros.h"

namespace webf {

// A simple iterator based on an index number in an HTMLCollection.
// This doesn't work if the HTMLCollection is updated during iteration.
template <class CollectionType, class NodeType>
class HTMLCollectionIterator {
  WEBF_STACK_ALLOCATED();

 public:
  explicit HTMLCollectionIterator(const CollectionType* collection) : collection_(collection) {}
  NodeType* operator*() { return collection_->item(index_); }

  void operator++() {
    if (index_ < collection_->length())
      ++index_;
  }

  bool operator!=(const HTMLCollectionIterator& other) const {
    return collection_ != other.collection_ || index_ != other.index_;
  }

  static HTMLCollectionIterator CreateEnd(const CollectionType* collection) {
    HTMLCollectionIterator iterator(collection);
    iterator.index_ = collection->length();
    return iterator;
  }

 private:
  const CollectionType* collection_;
  unsigned index_ = 0;
};

// blink::HTMLCollection implements HTMLCollection IDL interface.
class HTMLCollection : public ScriptWrappable, public LiveNodeListBase {
  DEFINE_WRAPPERTYPEINFO();

 public:
  using ImplType = HTMLCollection*;
  enum ItemAfterOverrideType {
    kOverridesItemAfter,
    kDoesNotOverrideItemAfter,
  };

  HTMLCollection(ContainerNode& base, CollectionType, ItemAfterOverrideType = kDoesNotOverrideItemAfter);
  ~HTMLCollection() override;
  void InvalidateCache(Document* old_document = nullptr) const override;

  // DOM API
  unsigned length() const;
  Element* item(unsigned offset, ExceptionState& exceptionState) const;
  virtual Element* namedItem(const AtomicString& name) const;
  bool NamedPropertyQuery(const AtomicString&, ExceptionState&);
  void NamedPropertyEnumerator(std::vector<AtomicString>& names, ExceptionState&);

  // Non-DOM API
  bool IsEmpty() const { return collection_items_cache_.IsEmpty(*this); }
  bool HasExactlyOneItem() const { return collection_items_cache_.HasExactlyOneNode(*this); }
  bool ElementMatches(const Element&) const;

  // CollectionIndexCache API.
  bool CanTraverseBackward() const { return !OverridesItemAfter(); }
  Element* TraverseToFirst() const;
  Element* TraverseToLast() const;
  Element* TraverseForwardToOffset(unsigned offset, Element& current_element, unsigned& current_offset) const;
  Element* TraverseBackwardToOffset(unsigned offset, Element& current_element, unsigned& current_offset) const;

  using Iterator = HTMLCollectionIterator<HTMLCollection, Element>;
  Iterator begin() const { return Iterator(this); }
  Iterator end() const { return Iterator::CreateEnd(this); }

  void Trace(GCVisitor*) const override;

 protected:
  bool OverridesItemAfter() const { return overrides_item_after_; }
  virtual Element* VirtualItemAfter(Element*) const;
  bool ShouldOnlyIncludeDirectChildren() const { return should_only_include_direct_children_; }

 private:
  const unsigned overrides_item_after_ : 1;
  const unsigned should_only_include_direct_children_ : 1;
  mutable CollectionItemsCache<HTMLCollection, Element> collection_items_cache_;
};

template <>
struct DowncastTraits<HTMLCollection> {
  static bool AllowFrom(const LiveNodeListBase& collection) { return IsHTMLCollectionType(collection.GetType()); }
};

}  // namespace webf

#endif  // WEBF_HTML_COLLECTION_H
