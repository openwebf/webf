/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "mutation_record.h"
#include "bindings/qjs/cppgc/gc_visitor.h"
#include "built_in_string.h"
#include "mutation_record_types.h"
#include "node.h"

namespace webf {

MutationRecord::MutationRecord(JSContext* ctx) : ScriptWrappable(ctx) {}

class ChildListRecord : public MutationRecord {
 public:
  explicit ChildListRecord(Node* target,
                           std::vector<Member<Node>>& added,
                           std::vector<Member<Node>>& removed,
                           Node* previous_sibling,
                           Node* next_sibling)
      : target_(target),
        added_nodes_(added),
        removed_nodes_(removed),
        previous_sibling_(previous_sibling),
        next_sibling_(next_sibling),
        MutationRecord(target->ctx()) {}

  void Trace(GCVisitor* visitor) const override {
    visitor->TraceMember(target_);

    for (auto& entry : added_nodes_) {
      visitor->TraceMember(entry);
    }

    for (auto& entry : removed_nodes_) {
      visitor->TraceMember(entry);
    }

    visitor->TraceMember(previous_sibling_);
    visitor->TraceMember(next_sibling_);
    MutationRecord::Trace(visitor);
  }

 private:
  const AtomicString& type() override;
  Node* target() override { return target_.Get(); }
  StaticNodeList* addedNodes() override { return &added_nodes_; }
  StaticNodeList* removedNodes() override { return &removed_nodes_; }
  Node* previousSibling() override { return previous_sibling_.Get(); }
  Node* nextSibling() override { return next_sibling_.Get(); }

  Member<Node> target_;
  Member<StaticNodeList> added_nodes_;
  Member<StaticNodeList> removed_nodes_;
  Member<Node> previous_sibling_;
  Member<Node> next_sibling_;
};

class RecordWithEmptyNodeLists : public MutationRecord {
 public:
  RecordWithEmptyNodeLists(Node* target, const AtomicString& old_value)
      : target_(target), old_value_(old_value), MutationRecord(target->ctx()) {}

  void Trace(GCVisitor* visitor) const override {
    visitor->TraceMember(target_);

    for (auto& entry : added_nodes_) {
      visitor->TraceMember(entry);
    }

    for (auto& entry : removed_nodes_) {
      visitor->TraceMember(entry);
    }

    MutationRecord::Trace(visitor);
  }

 private:
  Node* target() override { return target_.Get(); }
  AtomicString oldValue() override { return old_value_; }
  StaticNodeList* addedNodes() override { return LazilyInitializeEmptyNodeList(added_nodes_); }
  StaticNodeList* removedNodes() override { return LazilyInitializeEmptyNodeList(removed_nodes_); }

  StaticNodeList* LazilyInitializeEmptyNodeList(Member<StaticNodeList>& node_list) {
    if (!node_list) {
      node_list = MakeGarbageCollected<StaticNodeList>(ctx());
    }
    return node_list.Get();
  }

  Member<Node> target_;
  AtomicString old_value_;
  Member<StaticNodeList> added_nodes_;
  Member<StaticNodeList> removed_nodes_;
};

class AttributesRecord : public RecordWithEmptyNodeLists {
 public:
  AttributesRecord(Node* target,
                   const AtomicString& name,
                   const AtomicString& attribute_namespace,
                   const AtomicString& old_value)
      : RecordWithEmptyNodeLists(target, old_value), attribute_name_(name), attribute_namespace_(attribute_namespace) {}

 private:
  const AtomicString& type() override;
  const AtomicString attributeName() override { return attribute_name_; }
  const AtomicString attributeNamespace() override { return attribute_namespace_; }

  AtomicString attribute_name_;
  AtomicString attribute_namespace_;
};

class CharacterDataRecord : public RecordWithEmptyNodeLists {
 public:
  CharacterDataRecord(Node* target, const AtomicString& old_value) : RecordWithEmptyNodeLists(target, old_value) {}

 private:
  const AtomicString& type() override;
};

class MutationRecordWithNullOldValue : public MutationRecord {
 public:
  MutationRecordWithNullOldValue(MutationRecord* record) : record_(record), MutationRecord(record->ctx()) {}

  void Trace(GCVisitor* visitor) const override {
    visitor->TraceMember(record_);
    MutationRecord::Trace(visitor);
  }

 private:
  const AtomicString& type() override { return record_->type(); }
  Node* target() override { return record_->target(); }
  StaticNodeList* addedNodes() override { return record_->addedNodes(); }
  StaticNodeList* removedNodes() override { return record_->removedNodes(); }
  Node* previousSibling() override { return record_->previousSibling(); }
  Node* nextSibling() override { return record_->nextSibling(); }
  const AtomicString attributeName() override { return record_->attributeName(); }
  const AtomicString attributeNamespace() override { return record_->attributeNamespace(); }

  AtomicString oldValue() override { return AtomicString::Empty(); }

  Member<MutationRecord> record_;
};

const AtomicString& ChildListRecord::type() {
  return mutation_record_types::kchildList;
}

const AtomicString& AttributesRecord::type() {
  return mutation_record_types::kattributes;
}

const AtomicString& CharacterDataRecord::type() {
  return mutation_record_types::kcharacterData;
}

MutationRecord* MutationRecord::CreateChildList(Node* target,
                                                std::vector<Member<Node>>&& added,
                                                std::vector<Member<Node>>&& removed,
                                                Node* previous_sibling,
                                                Node* next_sibling) {
  return MakeGarbageCollected<ChildListRecord>(target, added, removed, previous_sibling, next_sibling);
}

MutationRecord* MutationRecord::CreateAttributes(Node* target,
                                                 const AtomicString& new_value,
                                                 const AtomicString& old_value) {

}

}  // namespace webf