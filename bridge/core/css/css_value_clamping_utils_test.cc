// Copyright 2018 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/*
 * Copyright (C) 2024-present The WebF authors. All rights reserved.
 */

#include "core/css/css_value_clamping_utils.h"

#include <limits>
#include "gtest/gtest.h"

namespace webf {

TEST(CSSValueClampingTest, IsLengthNotClampedZeroValue) {
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(0.0), 0.0);
}

TEST(CSSValueClampingTest, IsLengthNotClampedPositiveFiniteValue) {
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(10.0), 10.0);
}

TEST(CSSValueClampingTest, IsLengthNotClampedNegativeFiniteValue) {
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(-10.0), -10.0);
}

TEST(CSSValueClampingTest, IsLengthClampedPositiveInfinity) {
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(
                std::numeric_limits<double>::infinity()),
            std::numeric_limits<double>::max());
}

TEST(CSSValueClampingTest, IsLengthClampedNaN) {
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(
                std::numeric_limits<double>::quiet_NaN()),
            0.0);
}

TEST(CSSValueClampingTest, IsLengthClampedNegativeInfinity) {
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(
                -std::numeric_limits<double>::infinity()),
            std::numeric_limits<double>::lowest());
}

// Additional tests for other clamping utilities

TEST(CSSValueClampingTest, ClampTimeValues) {
  // Test positive finite values
  EXPECT_EQ(CSSValueClampingUtils::ClampTime(5.0), 5.0);
  EXPECT_EQ(CSSValueClampingUtils::ClampTime(0.0), 0.0);
  
  // Test infinity handling
  EXPECT_EQ(CSSValueClampingUtils::ClampTime(
                std::numeric_limits<double>::infinity()),
            std::numeric_limits<double>::max());
  EXPECT_EQ(CSSValueClampingUtils::ClampTime(
                -std::numeric_limits<double>::infinity()),
            std::numeric_limits<double>::lowest());
            
  // Test NaN handling
  EXPECT_EQ(CSSValueClampingUtils::ClampTime(
                std::numeric_limits<double>::quiet_NaN()),
            0.0);
}

TEST(CSSValueClampingTest, ClampAngleValues) {
  // Test normal angle values
  EXPECT_EQ(CSSValueClampingUtils::ClampAngle(90.0), 90.0);
  EXPECT_EQ(CSSValueClampingUtils::ClampAngle(-45.0), -45.0);
  EXPECT_EQ(CSSValueClampingUtils::ClampAngle(0.0), 0.0);
  
  // WebF uses a special constant for angle clamping (kApproxDoubleInfinityAngle = 2867080569122160)
  constexpr double kApproxDoubleInfinityAngle = 2867080569122160;
  
  // Test infinity handling - WebF clamps angles to a special range
  EXPECT_EQ(CSSValueClampingUtils::ClampAngle(
                std::numeric_limits<double>::infinity()),
            kApproxDoubleInfinityAngle);
  EXPECT_EQ(CSSValueClampingUtils::ClampAngle(
                -std::numeric_limits<double>::infinity()),
            -kApproxDoubleInfinityAngle);
            
  // Test NaN handling - WebF converts NaN to kApproxDoubleInfinityAngle for angles
  EXPECT_EQ(CSSValueClampingUtils::ClampAngle(
                std::numeric_limits<double>::quiet_NaN()),
            kApproxDoubleInfinityAngle);
}

TEST(CSSValueClampingTest, ClampDoubleValues) {
  // Test normal double values
  EXPECT_EQ(CSSValueClampingUtils::ClampDouble(50.0), 50.0);
  EXPECT_EQ(CSSValueClampingUtils::ClampDouble(0.0), 0.0);
  EXPECT_EQ(CSSValueClampingUtils::ClampDouble(-25.5), -25.5);
  
  // Test infinity handling
  EXPECT_EQ(CSSValueClampingUtils::ClampDouble(
                std::numeric_limits<double>::infinity()),
            std::numeric_limits<double>::max());
  EXPECT_EQ(CSSValueClampingUtils::ClampDouble(
                -std::numeric_limits<double>::infinity()),
            std::numeric_limits<double>::lowest());
            
  // Test NaN handling
  EXPECT_EQ(CSSValueClampingUtils::ClampDouble(
                std::numeric_limits<double>::quiet_NaN()),
            0.0);
}

TEST(CSSValueClampingTest, ClampLengthFloat) {
  // Test float version of ClampLength
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(10.5f), 10.5f);
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(0.0f), 0.0f);
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(-5.25f), -5.25f);
  
  // Test infinity handling
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(
                std::numeric_limits<float>::infinity()),
            std::numeric_limits<float>::max());
  EXPECT_EQ(CSSValueClampingUtils::ClampLength(
                -std::numeric_limits<float>::infinity()),
            std::numeric_limits<float>::lowest());
}

}  // namespace webf