// Copyright 2022 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef WEBF_CORE_STYLE_ANCHOR_SPECIFIER_VALUE_H_
#define WEBF_CORE_STYLE_ANCHOR_SPECIFIER_VALUE_H_

#include <cassert>
#include <memory>
#include "core/style/scoped_css_name.h"
#include "core/base/types/pass_key.h"

namespace webf {

class ScopedCSSName;

//TODO::代码迁移，删除继承GarbageCollected，by guopengfei

// Represents an anchor specifier: default | auto | <dashed-ident>
// https://drafts4.csswg.org/css-anchor-1/#target-anchor-element
class AnchorSpecifierValue {
 public:
  enum class Type {
    kDefault,
    kNamed,
  };

  // Creates a named value.
  explicit AnchorSpecifierValue(std::shared_ptr<const ScopedCSSName>& name);

  // Gets or creates the default keyword value.
  static AnchorSpecifierValue* Default();

  // For creating the keyword values only.
  explicit AnchorSpecifierValue(webf::PassKey<AnchorSpecifierValue>, Type type);

  bool IsDefault() const { return type_ == Type::kDefault; }
  bool IsNamed() const { return type_ == Type::kNamed; }
  const ScopedCSSName& GetName() const {
    assert(IsNamed());
    assert(name_);
    return *name_;
  }

  bool operator==(const AnchorSpecifierValue&) const;
  bool operator!=(const AnchorSpecifierValue& other) const {
    return !operator==(other);
  }

  unsigned GetHash() const;
  //TODO::代码迁移 by guopengfei
  //void Trace(Visitor*) const;

 private:
  Type type_;
  std::shared_ptr<const ScopedCSSName> name_;
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_ANCHOR_SPECIFIER_VALUE_H_
