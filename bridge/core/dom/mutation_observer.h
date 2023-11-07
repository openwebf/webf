/*
 * Copyright (C) 2011 Google Inc. All rights reserved.
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

#ifndef WEBF_MUTATION_OBSERVER_H
#define WEBF_MUTATION_OBSERVER_H

#include "bindings/qjs/exception_state.h"
#include "bindings/qjs/script_wrappable.h"
#include "bindings/qjs/cppgc/member.h"
#include "qjs_mutation_observer_init.h"
#include "mutation_record.h"

namespace webf {

class Node;
class MutationObserver;
class MutationObserverInit;
class MutationObserverRegistration;
class MutationRecord;

using MutationObserverSet = std::set<Member<MutationObserver>>;
using MutationObserverRegistrationSet =
    std::set<std::shared_ptr<MutationObserverRegistration>>;
using MutationObserverVector = std::vector<Member<MutationObserver>>;
using MutationRecordVector = std::vector<Member<MutationRecord>>;

class MutationObserver final : public ScriptWrappable {
  DEFINE_WRAPPERTYPEINFO();
 public:
  enum ObservationFlags { kSubtree = 1 << 3, kAttributeFilter = 1 << 4 };
  enum DeliveryFlags {
    kAttributeOldValue = 1 << 5,
    kCharacterDataOldValue = 1 << 6,
  };

  static MutationObserver* Create(ExecutingContext* context,
                                  const std::shared_ptr<QJSFunction>& function,
                                  ExceptionState& exception_state);

  MutationObserver(ExecutingContext*, const std::shared_ptr<QJSFunction>& function);
  ~MutationObserver() override;

  void observe(Node*, const std::shared_ptr<MutationObserverInit>& init, ExceptionState&);
  void observe(Node*, ExceptionState&);
  MutationRecordVector takeRecords(ExceptionState&);
  void disconnect(ExceptionState& exception_state);
  void ObservationStarted(const std::shared_ptr<MutationObserverRegistration>&);
  void ObservationEnded(const std::shared_ptr<MutationObserverRegistration>&);
  void EnqueueMutationRecord(MutationRecord*);

  std::set<Member<Node>> GetObservedNodes() const;

  bool HasPendingActivity() const { return !records_.empty(); }

  void Trace(webf::GCVisitor *visitor) const override;

 private:
  MutationRecordVector records_;
  MutationObserverRegistrationSet registrations_;
  unsigned priority_;
};

}  // namespace webf

#endif  // WEBF_MUTATION_OBSERVER_H
