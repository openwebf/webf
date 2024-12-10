/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_SELF_KEEP_ALIVE_H
#define WEBF_SELF_KEEP_ALIVE_H

#include "foundation/macros.h"
#include "persistent.h"

namespace webf {

// SelfKeepAlive<Object> is the idiom to use for objects that have to keep
// themselves temporarily alive and cannot rely on there being some
// external reference in that interval:
//
//  class Opener : public GarbageCollected<Opener> {
//   public:
//    ...
//    void Open() {
//      // Retain a self-reference while in an opened state:
//      keep_alive_ = this;
//      ....
//    }
//
//    void Close() {
//      // Clear self-reference that ensured we were kept alive while opened.
//      keep_alive_.Clear();
//      ....
//    }
//
//   private:
//    ...
//    SelfKeepAlive<Opener> keep_alive_;
//  };
//
// The responsibility to call Clear() in a timely fashion resides with the
// implementation of the object.
template <typename Self>
class SelfKeepAlive final {
  WEBF_DISALLOW_NEW();

 public:
  explicit SelfKeepAlive(const PersistentLocation& loc = PersistentLocation()) : keep_alive_(loc) {}
  explicit SelfKeepAlive(Self* self, const PersistentLocation& loc = PersistentLocation()) : keep_alive_(self, loc) {}

  SelfKeepAlive& operator=(Self* self) {
    DCHECK(!keep_alive_ || keep_alive_.Get() == self);
    keep_alive_ = self;
    return *this;
  }

  void Clear() { keep_alive_.Clear(); }

  explicit operator bool() const { return keep_alive_; }

 private:
  /*TODO support GC_PLUGIN_IGNORE
  GC_PLUGIN_IGNORE("Allowed to temporarily introduce non reclaimable memory.")
   */
  Persistent<Self> keep_alive_;
};

}  // namespace webf

#endif  // WEBF_SELF_KEEP_ALIVE_H
