/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#include "bindings/qjs/sync_iterator.h"
#include "bindings/qjs/iterable.h"

namespace webf {

ScriptValue SyncIterator::value() {
  return iteration_source_->Value();
}

SyncIterator* SyncIterator::Symbol_iterator() {
  return this;
}

bool SyncIterator::done() {
  return iteration_source_->Done();
}

void SyncIterator::Trace(GCVisitor* visitor) const {
  iteration_source_->Trace(visitor);
  ScriptWrappable::Trace(visitor);
}

ScriptValue SyncIterator::next(ExceptionState& exception_state) {
  return iteration_source_->Next(exception_state);
}

}