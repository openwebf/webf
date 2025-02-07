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

#include "mutation_observer.h"
#include <algorithm>
#include <unordered_set>
#include "bindings/qjs/converter_impl.h"
#include "mutation_observer_registration.h"
#include "mutation_record.h"
#include "node.h"

namespace webf {

class MutationObserverAgent;

static unsigned g_observer_priority = 0;
static thread_local std::unordered_map<ExecutingContext*, std::shared_ptr<MutationObserverAgent>> agent_map_;

class MutationObserverAgent {
 public:
  MutationObserverAgent() = delete;
  explicit MutationObserverAgent(ExecutingContext* context) : context_(context){};

  static std::shared_ptr<MutationObserverAgent> From(ExecutingContext* context) {
    if (agent_map_.count(context) == 0) {
      agent_map_[context] = std::make_shared<MutationObserverAgent>(context);
    }
    return agent_map_[context];
  }

  void ActivateObserver(MutationObserver* observer) {
    if (!isContextValid(context_->contextId()))
      return;

    EnsureEnqueueMicrotask();
    active_mutation_observers_.insert(observer);
  }

 private:
  void DeliverMutations() {
    MemberMutationScope scopes{context_};
    // These steps are defined in DOM Standard's "notify mutation observers".
    // https://dom.spec.whatwg.org/#notify-mutation-observers
    MutationObserverVector observers(active_mutation_observers_.begin(), active_mutation_observers_.end());
    active_mutation_observers_.clear();
    std::sort(observers.begin(), observers.end(), MutationObserver::ObserverLessThan());
    for (const auto& observer : observers)
      observer->Deliver();
  }

  void EnsureEnqueueMicrotask() {
    if (active_mutation_observers_.empty() && context_->IsContextValid()) {
      context_->EnqueueMicrotask(
          [](void* p) {
            auto* agent = static_cast<MutationObserverAgent*>(p);
            agent->DeliverMutations();
          },
          this);
    }
  }

  MutationObserverSet active_mutation_observers_;
  ExecutingContext* context_;
};

static void ActivateObserver(MutationObserver* observer) {
  if (!observer->GetExecutingContext())
    return;

  ExecutingContext* context = observer->GetExecutingContext();
  auto agent = MutationObserverAgent::From(context);
  agent->ActivateObserver(observer);
}

MutationObserver* MutationObserver::Create(ExecutingContext* context,
                                           const std::shared_ptr<QJSFunction>& function,
                                           ExceptionState& exception_state) {
  return MakeGarbageCollected<MutationObserver>(context, function);
}

MutationObserver::MutationObserver(ExecutingContext* context, const std::shared_ptr<QJSFunction>& function)
    : ScriptWrappable(context->ctx()), function_(function) {
  priority_ = g_observer_priority++;
}

MutationObserver::~MutationObserver() {}

void MutationObserver::observe(Node* node,
                               const std::shared_ptr<MutationObserverInit>& observer_init,
                               ExceptionState& exception_state) {
  assert(node != nullptr);

  MutationObserverOptions options = 0;

  if (observer_init->hasAttributeOldValue() && observer_init->attributeOldValue())
    options |= kAttributeOldValue;

  std::unordered_set<AtomicString, AtomicString::KeyHasher> attribute_filter;
  if (observer_init->hasAttributeFilter()) {
    for (const auto& name : observer_init->attributeFilter())
      attribute_filter.insert(AtomicString(name));
    options |= kAttributeFilter;
  }

  bool attributes = observer_init->hasAttributes() && observer_init->attributes();
  if (attributes || (!observer_init->hasAttributes() &&
                     (observer_init->hasAttributeOldValue() || observer_init->hasAttributeFilter())))
    options |= kMutationTypeAttributes;

  if (observer_init->hasCharacterDataOldValue() && observer_init->characterDataOldValue())
    options |= kCharacterDataOldValue;

  bool character_data = observer_init->hasCharacterData() && observer_init->characterData();
  if (character_data || (!observer_init->hasCharacterData() && observer_init->hasCharacterDataOldValue()))
    options |= kMutationTypeCharacterData;

  if (observer_init->hasChildList() && observer_init->childList())
    options |= kMutationTypeChildList;

  if (observer_init->hasSubtree() && observer_init->subtree())
    options |= kSubtree;

  if (!(options & kMutationTypeAttributes)) {
    if (options & kAttributeOldValue) {
      exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                     "The options object may only set 'attributeOldValue' to true when "
                                     "'attributes' is true or not present.");
      return;
    }
    if (options & kAttributeFilter) {
      exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                     "The options object may only set 'attributeFilter' when 'attributes' "
                                     "is true or not present.");
      return;
    }
  }
  if (!((options & kMutationTypeCharacterData) || !(options & kCharacterDataOldValue))) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "The options object may only set 'characterDataOldValue' to true when "
                                   "'characterData' is true or not present.");
    return;
  }

  if (!(options & kMutationTypeAll)) {
    exception_state.ThrowException(ctx(), ErrorType::TypeError,
                                   "The options object must set at least one of 'attributes', "
                                   "'characterData', or 'childList' to true.");
    return;
  }

  node->RegisterMutationObserver(*this, options, attribute_filter);
}

void MutationObserver::observe(Node* node, ExceptionState& exception_state) {
  observe(node, MutationObserverInit::Create(), exception_state);
}

MutationRecordVector MutationObserver::takeRecords(ExceptionState& exception_state) {
  MutationRecordVector records;
  std::swap(records_, records);
  return records;
}

void MutationObserver::disconnect(ExceptionState& exception_state) {
  records_.clear();
  MutationObserverRegistrationSet registrations(registrations_);
  for (auto& registration : registrations) {
    // The registration may be already unregistered while iteration.
    // Only call unregister if it is still in the original set.
    if (registrations_.count(registration) > 0)
      registration->Unregister();
  }
  assert(registrations_.empty());
}

void MutationObserver::ObservationStarted(MutationObserverRegistration* registration) {
  assert(registrations_.count(registration) == 0);
  registrations_.insert(registration);
}

void MutationObserver::ObservationEnded(MutationObserverRegistration* registration) {
  assert(registrations_.count(registration) > 0);
  registrations_.erase(registration);
}

void MutationObserver::EnqueueMutationRecord(MutationRecord* mutation) {
  records_.emplace_back(mutation);
  ActivateObserver(this);
}

void MutationObserver::Deliver() {
  if (!GetExecutingContext() || !GetExecutingContext()->IsContextValid())
    return;

  // Calling ClearTransientRegistrations() can modify registrations_, so it's
  // necessary to make a copy of the transient registrations before operating on
  // them.
  std::vector<Member<MutationObserverRegistration>> transient_registrations;
  for (auto& registration : registrations_) {
    if (registration->HasTransientRegistrations())
      transient_registrations.push_back(registration);
  }
  for (const auto& registration : transient_registrations)
    registration->ClearTransientRegistrations();

  if (records_.empty())
    return;

  MutationRecordVector records;
  swap(records_, records);

  assert(function_ != nullptr);
  JSValue v = Converter<IDLSequence<MutationRecord>>::ToValue(ctx(), records);
  ScriptValue arguments[] = {ScriptValue(ctx(), v), ToValue()};

  JS_FreeValue(ctx(), v);
  ScriptValue result = function_->Invoke(ctx(), ToValue(), 2, arguments);
  if (result.IsException()) {
    GetExecutingContext()->HandleException(&result);
  }
}

void MutationObserver::SetHasTransientRegistration() {
  ActivateObserver(this);
}

std::unordered_set<Member<Node>, Member<Node>::KeyHasher> MutationObserver::GetObservedNodes() const {
  std::unordered_set<Member<Node>, Member<Node>::KeyHasher> observed_nodes;
  for (const auto& registration : registrations_)
    registration->AddRegistrationNodesToSet(observed_nodes);
  return observed_nodes;
}

void MutationObserver::Trace(GCVisitor* visitor) const {
  for (auto& record : records_) {
    visitor->TraceMember(record);
  }

  for (auto& re : registrations_) {
    visitor->TraceMember(re);
  }
  function_->Trace(visitor);
}

}  // namespace webf