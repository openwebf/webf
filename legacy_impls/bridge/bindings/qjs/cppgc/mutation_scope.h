/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_
#define BRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_

#include <quickjs/quickjs.h>
#include <unordered_map>
#include "foundation/macros.h"

namespace webf {

class ExecutingContext;
class ScriptWrappable;

/**
 * A stack-allocated class that record all members mutations in stack scope.
 */
class MemberMutationScope {
  WEBF_DISALLOW_NEW();

 public:
  MemberMutationScope() = delete;
  explicit MemberMutationScope(ExecutingContext* context);
  ~MemberMutationScope();

  void SetParent(MemberMutationScope* parent_scope);
  [[nodiscard]] MemberMutationScope* Parent() const;

  void RecordFree(ScriptWrappable* wrappable);

 private:
  void ApplyRecord();

  MemberMutationScope* parent_scope_{nullptr};
  ExecutingContext* context_;
  JSRuntime* runtime_{nullptr};
  std::unordered_map<ScriptWrappable*, int> mutation_records_;
};

}  // namespace webf

#endif  // BRIDGE_BINDINGS_QJS_CPPGC_MUTATION_SCOPE_H_
