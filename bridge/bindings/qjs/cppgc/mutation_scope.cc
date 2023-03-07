/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "mutation_scope.h"
#include "bindings/qjs/script_wrappable.h"
#include "core/executing_context.h"

namespace webf {

MemberMutationScope::MemberMutationScope(ExecutingContext* context) : context_(context) {
  context->SetMutationScope(*this);
}

MemberMutationScope::~MemberMutationScope() {
  ApplyRecord();
  context_->ClearMutationScope();
}

void MemberMutationScope::SetParent(MemberMutationScope* parent_scope) {
  assert(parent_scope_ == nullptr);
  parent_scope_ = parent_scope;
}

MemberMutationScope* MemberMutationScope::Parent() const {
  return parent_scope_;
}

void MemberMutationScope::RecordFree(ScriptWrappable* wrappable) {
  if (mutation_records_.count(wrappable) == 0) {
    mutation_records_.insert(std::make_pair(wrappable, 0));
  }
  mutation_records_[wrappable]--;
}

void MemberMutationScope::ApplyRecord() {
  JSRuntime* runtime = context_->GetScriptState()->runtime();
  for (auto& entry : mutation_records_) {
    for (int i = 0; i < -entry.second; i++) {
      JS_FreeValueRT(runtime, entry.first->ToQuickJSUnsafe());
    }
  }
}

}  // namespace webf
