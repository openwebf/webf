/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/
#ifndef KRAKENBRIDGE_BINDINGS_QJS_PENDING_PROMISES_H_
#define KRAKENBRIDGE_BINDINGS_QJS_PENDING_PROMISES_H_

#include <quickjs/quickjs.h>
#include <vector>
#include "script_promise.h"

namespace kraken {

class PendingPromises {
 public:
  PendingPromises() = default;
  void TrackPendingPromises(ScriptPromise&& promise);

 private:
  std::vector<ScriptPromise> promises_;
};

}  // namespace kraken

#endif  // KRAKENBRIDGE_BINDINGS_QJS_PENDING_PROMISES_H_
