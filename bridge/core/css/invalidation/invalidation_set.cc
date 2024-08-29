/*
 * Copyright (C) 2014 Google Inc. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above
 * copyright notice, this list of conditions and the following disclaimer
 * in the documentation and/or other materials provided with the
 * distribution.
 *     * Neither the name of Google Inc. nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

 /*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/css/invalidation/invalidation_set.h"
#include <memory>
#include <utility>
#include "core/base/memory/values_equivalent.h"
//#include "third_party/blink/renderer/core/css/resolver/style_resolver.h"
#include "core/dom/element.h"
#include "core/inspector/invalidation_set_to_selector_map.h"
//#include "third_party/blink/renderer/platform/wtf/text/string_builder.h"

namespace webf {

namespace {

template <InvalidationSet::BackingType type>
bool BackingEqual(const InvalidationSet::BackingFlags& a_flags,
                  const InvalidationSet::Backing<type>& a,
                  const InvalidationSet::BackingFlags& b_flags,
                  const InvalidationSet::Backing<type>& b) {
  if (a.Size(a_flags) != b.Size(b_flags)) {
    return false;
  }
  for (const AtomicString& value : a.Items(a_flags)) {
    if (!b.Contains(b_flags, value)) {
      return false;
    }
  }
  return true;
}

const unsigned char* GetCachedTracingFlags() {
  /*DEFINE_STATIC_LOCAL(
      const unsigned char*, tracing_enabled,
      (TRACE_EVENT_API_GET_CATEGORY_GROUP_ENABLED(TRACE_DISABLED_BY_DEFAULT(
          "devtools.timeline.invalidationTracking"))));
  return tracing_enabled;*/
  return nullptr;
}

}  // namespace

/* // TODO(guopengfei)：
#define TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED( \
    element, reason, invalidationSet, singleSelectorPart)             \
  if (UNLIKELY(*GetCachedTracingFlags()))                             \
    TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART(                \
        element, reason, invalidationSet, singleSelectorPart);

// static
void InvalidationSetDeleter::Destruct(const InvalidationSet* obj) {
  obj->Destroy();
}
 */

bool InvalidationSet::operator==(const InvalidationSet& other) const {
  if (GetType() != other.GetType()) {
    return false;
  }

  if (GetType() == InvalidationType::kInvalidateSiblings) {
    const auto& this_sibling = To<SiblingInvalidationSet>(*this);
    const auto& other_sibling = To<SiblingInvalidationSet>(other);
    if ((this_sibling.MaxDirectAdjacentSelectors() !=
         other_sibling.MaxDirectAdjacentSelectors()) ||
        !webf::ValuesEquivalent(this_sibling.Descendants(),
                                other_sibling.Descendants()) ||
        !webf::ValuesEquivalent(this_sibling.SiblingDescendants(),
                                other_sibling.SiblingDescendants())) {
      return false;
    }
  }

  if (invalidation_flags_ != other.invalidation_flags_) {
    return false;
  }
  if (invalidates_self_ != other.invalidates_self_) {
    return false;
  }

  return BackingEqual(backing_flags_, classes_, other.backing_flags_,
                      other.classes_) &&
         BackingEqual(backing_flags_, ids_, other.backing_flags_, other.ids_) &&
         BackingEqual(backing_flags_, tag_names_, other.backing_flags_,
                      other.tag_names_) &&
         BackingEqual(backing_flags_, attributes_, other.backing_flags_,
                      other.attributes_);
}

InvalidationSet::InvalidationSet(InvalidationType type)
    : type_(static_cast<unsigned>(type)),
      invalidates_self_(false),
      invalidates_nth_(false),
      is_alive_(true) {}

bool InvalidationSet::InvalidatesElement(Element& element) const {
  if (invalidation_flags_.WholeSubtreeInvalid()) {
  /*
    TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED(
        element, kInvalidationSetInvalidatesSubtree, *this, g_empty_atom);

   */
    return true;
  }

  if (HasTagNames() && HasTagName(element.LocalNameForSelectorMatching())) {
  /*
    TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED(
        element, kInvalidationSetMatchedTagName, *this,
        element.LocalNameForSelectorMatching());

   */
    return true;
  }

  if (element.HasID() && HasIds() && HasId(element.IdForStyleResolution())) {
  /*
    TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED(
        element, kInvalidationSetMatchedId, *this,
        element.IdForStyleResolution());

   */
    return true;
  }

  if (element.HasClass() && HasClasses()) {
    if (const AtomicString* class_name = FindAnyClass(element)) {
    /*
      TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED(
          element, kInvalidationSetMatchedClass, *this, *class_name);

     */
      return true;
    }
  }

  if (element.hasAttributes() && HasAttributes()) {
    if (const AtomicString* attribute = FindAnyAttribute(element)) {
    /*
      TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED(
          element, kInvalidationSetMatchedAttribute, *this, *attribute);

     */
      return true;
    }
  }

  if (element.HasPart() && invalidation_flags_.InvalidatesParts()) {
  /*
    TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED(
        element, kInvalidationSetMatchedPart, *this, g_empty_atom);

   */
    return true;
  }

  return false;
}

bool InvalidationSet::InvalidatesTagName(Element& element) const {
  if (HasTagNames() && HasTagName(element.LocalNameForSelectorMatching())) {
  /*
    TRACE_STYLE_INVALIDATOR_INVALIDATION_SELECTORPART_IF_ENABLED(
        element, kInvalidationSetMatchedTagName, *this,
        element.LocalNameForSelectorMatching());

   */
    return true;
  }

  return false;
}

void InvalidationSet::Combine(const InvalidationSet& other) {
  assert(is_alive_);
  assert(other.is_alive_);
  assert(GetType() == other.GetType());

  if (IsSelfInvalidationSet()) {
    // We should never modify the SelfInvalidationSet singleton. When
    // aggregating the contents from another invalidation set into an
    // invalidation set which only invalidates self, we instantiate a new
    // DescendantInvalidation set before calling Combine(). We still may end up
    // here if we try to combine two references to the singleton set.
    assert(other.IsSelfInvalidationSet());
    return;
  }

  assert(&other != this);
  InvalidationSetToSelectorMap::CombineScope combine_scope(this, &other);

  if (auto* invalidation_set = DynamicTo<SiblingInvalidationSet>(this)) {
    SiblingInvalidationSet& siblings = *invalidation_set;
    const SiblingInvalidationSet& other_siblings =
        To<SiblingInvalidationSet>(other);

    siblings.UpdateMaxDirectAdjacentSelectors(
        other_siblings.MaxDirectAdjacentSelectors());
    if (other_siblings.SiblingDescendants()) {
      siblings.EnsureSiblingDescendants().Combine(
          *other_siblings.SiblingDescendants());
    }
    if (other_siblings.Descendants()) {
      siblings.EnsureDescendants().Combine(*other_siblings.Descendants());
    }
  }

  if (other.InvalidatesNth()) {
    SetInvalidatesNth();
  }

  if (other.InvalidatesSelf()) {
    SetInvalidatesSelf();
    if (other.IsSelfInvalidationSet()) {
      return;
    }
  }

  // No longer bother combining data structures, since the whole subtree is
  // deemed invalid.
  if (WholeSubtreeInvalid()) {
    return;
  }

  if (other.WholeSubtreeInvalid()) {
    SetWholeSubtreeInvalid();
    return;
  }

  if (other.CustomPseudoInvalid()) {
    SetCustomPseudoInvalid();
  }

  if (other.TreeBoundaryCrossing()) {
    SetTreeBoundaryCrossing();
  }

  if (other.InsertionPointCrossing()) {
    SetInsertionPointCrossing();
  }

  if (other.InvalidatesSlotted()) {
    SetInvalidatesSlotted();
  }

  if (other.InvalidatesParts()) {
    SetInvalidatesParts();
  }

  for (const auto& class_name : other.Classes()) {
    AddClass(class_name);
  }

  for (const auto& id : other.Ids()) {
    AddId(id);
  }

  for (const auto& tag_name : other.TagNames()) {
    AddTagName(tag_name);
  }

  for (const auto& attribute : other.Attributes()) {
    AddAttribute(attribute);
  }
}

void InvalidationSet::Destroy() const {
  if (auto* invalidation_set = DynamicTo<DescendantInvalidationSet>(this)) {
    delete invalidation_set;
  } else {
    delete To<SiblingInvalidationSet>(this);
  }
}

void InvalidationSet::ClearAllBackings() {
  classes_.Clear(backing_flags_);
  ids_.Clear(backing_flags_);
  tag_names_.Clear(backing_flags_);
  attributes_.Clear(backing_flags_);
}

bool InvalidationSet::HasEmptyBackings() const {
  return classes_.IsEmpty(backing_flags_) && ids_.IsEmpty(backing_flags_) &&
         tag_names_.IsEmpty(backing_flags_) &&
         attributes_.IsEmpty(backing_flags_);
}

const AtomicString* InvalidationSet::FindAnyClass(Element& element) const {
  const SpaceSplitString& class_names = element.ClassNames();
  uint32_t size = class_names.size();
  if (const AtomicString* string = classes_.GetString(backing_flags_)) {
    for (uint32_t i = 0; i < size; ++i) {
      if (*string == class_names[i]) {
        return string;
      }
    }
  }

  if (const std::unordered_set<AtomicString, AtomicString::KeyHasher>* set = classes_.GetHashSet(backing_flags_)) {
    for (uint32_t i = 0; i < size; ++i) {
      auto item = set->find(class_names[i]);
      if (item != set->end()) {
        return &(*item); // Return the address of the element
      }
    }
  }
  return nullptr;
}

const AtomicString* InvalidationSet::FindAnyAttribute(Element& element) const {
  if (const AtomicString* string = attributes_.GetString(backing_flags_)) {
    if (element.HasAttributeIgnoringNamespace(*string)) {
      return string;
    }
  }
  if (const std::unordered_set<AtomicString, AtomicString::KeyHasher>* set =
          attributes_.GetHashSet(backing_flags_)) {
    for (const auto& attribute : *set) {
      if (element.HasAttributeIgnoringNamespace(attribute)) {
        return &attribute;
      }
    }
  }
  return nullptr;
}

void InvalidationSet::AddClass(const AtomicString& class_name) {
  if (WholeSubtreeInvalid()) {
    return;
  }
  assert(!class_name.IsEmpty());
  InvalidationSetToSelectorMap::RecordInvalidationSetEntry(
      this, InvalidationSetToSelectorMap::SelectorFeatureType::kClass,
      class_name);
  classes_.Add(backing_flags_, class_name);
}

void InvalidationSet::AddId(const AtomicString& id) {
  if (WholeSubtreeInvalid()) {
    return;
  }
  assert(!id.IsEmpty());
  InvalidationSetToSelectorMap::RecordInvalidationSetEntry(
      this, InvalidationSetToSelectorMap::SelectorFeatureType::kId, id);
  ids_.Add(backing_flags_, id);
}

void InvalidationSet::AddTagName(const AtomicString& tag_name) {
  if (WholeSubtreeInvalid()) {
    return;
  }
  assert(!tag_name.IsEmpty());
  InvalidationSetToSelectorMap::RecordInvalidationSetEntry(
      this, InvalidationSetToSelectorMap::SelectorFeatureType::kTagName,
      tag_name);
  tag_names_.Add(backing_flags_, tag_name);
}

void InvalidationSet::AddAttribute(const AtomicString& attribute) {
  if (WholeSubtreeInvalid()) {
    return;
  }
  assert(!attribute.IsEmpty());
  InvalidationSetToSelectorMap::RecordInvalidationSetEntry(
      this, InvalidationSetToSelectorMap::SelectorFeatureType::kAttribute,
      attribute);
  attributes_.Add(backing_flags_, attribute);
}

void InvalidationSet::SetWholeSubtreeInvalid() {
  if (invalidation_flags_.WholeSubtreeInvalid()) {
    return;
  }

  InvalidationSetToSelectorMap::RecordInvalidationSetEntry(
      this, InvalidationSetToSelectorMap::SelectorFeatureType::kWholeSubtree,
      g_empty_atom);
  invalidation_flags_.SetWholeSubtreeInvalid(true);
  invalidation_flags_.SetInvalidateCustomPseudo(false);
  invalidation_flags_.SetTreeBoundaryCrossing(false);
  invalidation_flags_.SetInsertionPointCrossing(false);
  invalidation_flags_.SetInvalidatesSlotted(false);
  invalidation_flags_.SetInvalidatesParts(false);
  ClearAllBackings();
}

namespace {

std::shared_ptr<DescendantInvalidationSet> CreateSelfInvalidationSet() {
  auto new_set = DescendantInvalidationSet::Create();
  new_set->SetInvalidatesSelf();
  return new_set;
}

std::shared_ptr<DescendantInvalidationSet> CreatePartInvalidationSet() {
  auto new_set = DescendantInvalidationSet::Create();
  new_set->SetInvalidatesParts();
  new_set->SetTreeBoundaryCrossing();
  return new_set;
}

}  // namespace

std::shared_ptr<InvalidationSet> InvalidationSet::SelfInvalidationSet() {
  //DEFINE_STATIC_REF(InvalidationSet, singleton_, CreateSelfInvalidationSet());
  thread_local std::shared_ptr<InvalidationSet> singleton_ = CreateSelfInvalidationSet();
  return singleton_;
}

std::shared_ptr<InvalidationSet> InvalidationSet::PartInvalidationSet() {
  //DEFINE_STATIC_REF(InvalidationSet, singleton_, CreatePartInvalidationSet());
  thread_local std::shared_ptr<InvalidationSet> singleton_ = CreatePartInvalidationSet();
  return singleton_;
}
/*
void InvalidationSet::WriteIntoTrace(perfetto::TracedValue context) const {
  auto dict = std::move(context).WriteDictionary();

  dict.Add("id", DescendantInvalidationSetToIdString(*this));

  if (invalidation_flags_.WholeSubtreeInvalid()) {
    dict.Add("allDescendantsMightBeInvalid", true);
  }
  if (invalidation_flags_.InvalidateCustomPseudo()) {
    dict.Add("customPseudoInvalid", true);
  }
  if (invalidation_flags_.TreeBoundaryCrossing()) {
    dict.Add("treeBoundaryCrossing", true);
  }
  if (invalidation_flags_.InsertionPointCrossing()) {
    dict.Add("insertionPointCrossing", true);
  }
  if (invalidation_flags_.InvalidatesSlotted()) {
    dict.Add("invalidatesSlotted", true);
  }
  if (invalidation_flags_.InvalidatesParts()) {
    dict.Add("invalidatesParts", true);
  }

  if (HasIds()) {
    dict.Add("ids", Ids());
  }

  if (HasClasses()) {
    dict.Add("classes", Classes());
  }

  if (HasTagNames()) {
    dict.Add("tagNames", TagNames());
  }

  if (HasAttributes()) {
    dict.Add("attributes", Attributes());
  }
}
*/
std::string InvalidationSet::ToString() const {
  auto format_backing = [](auto range, const char* prefix, const char* suffix) {
    std::string builder;

    // TODO(guopengfei)：将AtomicString经StringView转成std::string;
    std::vector<std::string> names;
    for (const auto& str : range) {
      names.push_back(str.ToStringView().Characters8ToStdString());
    }
    //std::sort(names.begin(), names.end(), WTF::CodeUnitCompareLessThan);
    std::sort(names.begin(), names.end());

    for (const auto& name : names) {
      if (!builder.empty()) {
        builder.append(" ");
      }
      builder.append(prefix);
      builder.append(name);
      builder.append(suffix);
    }

    return builder;
  };

  std::string features;

  if (HasIds()) {
    features.append(format_backing(Ids(), "#", ""));
  }
  if (HasClasses()) {
    features.append(!features.empty() ? " " : "");
    features.append(format_backing(Classes(), ".", ""));
  }
  if (HasTagNames()) {
    features.append(!features.empty() ? " " : "");
    features.append(format_backing(TagNames(), "", ""));
  }
  if (HasAttributes()) {
    features.append(!features.empty() ? " " : "");
    features.append(format_backing(Attributes(), "[", "]"));
  }

  auto format_max_direct_adjancent = [](const InvalidationSet* set) -> std::string {
    const auto* sibling = DynamicTo<SiblingInvalidationSet>(set);
    if (!sibling) {
      return "";
    }
    unsigned max = sibling->MaxDirectAdjacentSelectors();
    if (max == SiblingInvalidationSet::kDirectAdjacentMax) {
      return "~";
    }
    if (max != 1) {
      return std::to_string(max);
    }
    return "";
  };

  std::string metadata;
  metadata.append(InvalidatesSelf() ? "$" : "");
  metadata.append(InvalidatesNth() ? "N" : "");
  metadata.append(invalidation_flags_.WholeSubtreeInvalid() ? "W" : "");
  metadata.append(invalidation_flags_.InvalidateCustomPseudo() ? "C" : "");
  metadata.append(invalidation_flags_.TreeBoundaryCrossing() ? "T" : "");
  metadata.append(invalidation_flags_.InsertionPointCrossing() ? "I" : "");
  metadata.append(invalidation_flags_.InvalidatesSlotted() ? "S" : "");
  metadata.append(invalidation_flags_.InvalidatesParts() ? "P" : "");
  metadata.append(format_max_direct_adjancent(this));

  std::string main;
  main.append("{");
  if (!features.empty()) {
    main.append(" ");
    main.append(features);
  }
  if (!metadata.empty()) {
    main.append(" ");
    main.append(metadata);
  }
  main.append(" }");

  return main;
}

SiblingInvalidationSet::SiblingInvalidationSet(
    const std::shared_ptr<DescendantInvalidationSet>& descendants)
    : InvalidationSet(InvalidationType::kInvalidateSiblings),
      max_direct_adjacent_selectors_(1),
      descendant_invalidation_set_(std::move(descendants)) {}

SiblingInvalidationSet::SiblingInvalidationSet()
    : InvalidationSet(InvalidationType::kInvalidateNthSiblings),
      max_direct_adjacent_selectors_(kDirectAdjacentMax) {}

DescendantInvalidationSet& SiblingInvalidationSet::EnsureSiblingDescendants() {
  if (!sibling_descendant_invalidation_set_) {
    sibling_descendant_invalidation_set_ = DescendantInvalidationSet::Create();
  }
  return *sibling_descendant_invalidation_set_;
}

DescendantInvalidationSet& SiblingInvalidationSet::EnsureDescendants() {
  if (!descendant_invalidation_set_) {
    descendant_invalidation_set_ = DescendantInvalidationSet::Create();
  }
  return *descendant_invalidation_set_;
}

std::ostream& operator<<(std::ostream& ostream, const InvalidationSet& set) {
  return ostream << set.ToString();
}

}  // namespace blink