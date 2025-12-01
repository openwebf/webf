/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
// Copyright 2015 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef WEBF_CORE_STYLE_STYLE_CONTENT_ALIGNMENT_DATA_H_
#define WEBF_CORE_STYLE_STYLE_CONTENT_ALIGNMENT_DATA_H_

#include "core/style/computed_style_constants.h"
#include "foundation/macros.h"

namespace webf {

class StyleContentAlignmentData {
  WEBF_DISALLOW_NEW();

 public:
  // Style data for Content-Distribution properties: align-content,
  // justify-content.
  // <content-distribution> || [ <overflow-position>? && <content-position> ]
  StyleContentAlignmentData(
      ContentPosition position,
      ContentDistributionType distribution,
      OverflowAlignment overflow = OverflowAlignment::kDefault)
      : position_(static_cast<unsigned>(position)),
        distribution_(static_cast<unsigned>(distribution)),
        overflow_(static_cast<unsigned>(overflow)) {}

  void SetPosition(ContentPosition position) {
    position_ = static_cast<unsigned>(position);
  }
  void SetDistribution(ContentDistributionType distribution) {
    distribution_ = static_cast<unsigned>(distribution);
  }
  void SetOverflow(OverflowAlignment overflow) {
    overflow_ = static_cast<unsigned>(overflow);
  }

  ContentPosition GetPosition() const {
    return static_cast<ContentPosition>(position_);
  }
  ContentDistributionType Distribution() const {
    return static_cast<ContentDistributionType>(distribution_);
  }
  OverflowAlignment Overflow() const {
    return static_cast<OverflowAlignment>(overflow_);
  }

  bool operator==(const StyleContentAlignmentData& o) const {
    return position_ == o.position_ && distribution_ == o.distribution_ &&
           overflow_ == o.overflow_;
  }

  bool operator!=(const StyleContentAlignmentData& o) const {
    return !(*this == o);
  }

 private:
  unsigned position_ : 4;      // ContentPosition
  unsigned distribution_ : 3;  // ContentDistributionType
  unsigned overflow_ : 2;      // OverflowAlignment
};

}  // namespace webf

#endif  // WEBF_CORE_STYLE_STYLE_CONTENT_ALIGNMENT_DATA_H_