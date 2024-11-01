// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/style/anchor_specifier_value.h"

#include "core/style/scoped_css_name.h"
//#include "third_party/blink/renderer/platform/heap/persistent.h"
#include "core/platform/hash_functions.h"

namespace webf {

// static
AnchorSpecifierValue* AnchorSpecifierValue::Default() {
  // TODO(guopengfei)：使用智能指针替换
  //DEFINE_STATIC_LOCAL(
  //   Persistent<AnchorSpecifierValue>, instance,
  //    {MakeGarbageCollected<AnchorSpecifierValue>(
  //       webf::PassKey<AnchorSpecifierValue>(), Type::kDefault)});
  //return instance;

   thread_local static std::shared_ptr<AnchorSpecifierValue> instance =
   std::make_shared<AnchorSpecifierValue>(webf::PassKey<AnchorSpecifierValue>(), Type::kDefault);
  return instance.get();
}

AnchorSpecifierValue::AnchorSpecifierValue(webf::PassKey<AnchorSpecifierValue>,
                                           Type type)
    : type_(type) {
  assert(type != Type::kNamed);
}

AnchorSpecifierValue::AnchorSpecifierValue(std::shared_ptr<const ScopedCSSName>& name)
    : type_(Type::kNamed), name_(name) {}

bool AnchorSpecifierValue::operator==(const AnchorSpecifierValue& other) const {
  return type_ == other.type_ && webf::ValuesEquivalent(name_, other.name_);
}

unsigned AnchorSpecifierValue::GetHash() const {
  unsigned hash = 0;
  WTF::AddIntToHash(hash, WTF::HashInt(type_));
  WTF::AddIntToHash(hash, name_ ? name_->GetHash() : 0);
  return hash;
}
/*
//TODO::代码迁移 by guopengfei
void AnchorSpecifierValue::Trace(Visitor* visitor) const {
  visitor->Trace(name_);
}
*/

}  // namespace webf
