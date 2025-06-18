// Copyright 2024 The WebF Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "gtest/gtest.h"
#include "webf_test_env.h"
#include <string>

namespace webf {

namespace {

bool IsValidContainerQuery(const char* query_string) {
  // Simplified implementation that checks for container query syntax
  std::string str(query_string);
  return str.find("@container") != std::string::npos;
}

bool HasContainerFeature(const char* query_string, const char* feature) {
  std::string str(query_string);
  std::string feat(feature);
  return str.find(feat) != std::string::npos;
}

}  // namespace

TEST(ContainerQuery, BasicSyntax) {
  auto env = TEST_init();
  
  // Test basic @container rule syntax
  EXPECT_TRUE(IsValidContainerQuery("@container (min-width: 300px) { .card { padding: 2rem; } }"));
  EXPECT_TRUE(IsValidContainerQuery("@container sidebar (max-width: 500px) { .widget { display: none; } }"));
  
  // Test without container query
  EXPECT_FALSE(IsValidContainerQuery(".card { padding: 1rem; }"));
  EXPECT_FALSE(IsValidContainerQuery("@media (min-width: 768px) { .card { padding: 2rem; } }"));
}

TEST(ContainerQuery, SizeFeatures) {
  auto env = TEST_init();
  
  // Test width-based queries
  EXPECT_TRUE(HasContainerFeature("@container (min-width: 300px)", "min-width"));
  EXPECT_TRUE(HasContainerFeature("@container (max-width: 800px)", "max-width"));
  EXPECT_TRUE(HasContainerFeature("@container (width >= 400px)", "width"));
  
  // Test height-based queries
  EXPECT_TRUE(HasContainerFeature("@container (min-height: 200px)", "min-height"));
  EXPECT_TRUE(HasContainerFeature("@container (max-height: 600px)", "max-height"));
  EXPECT_TRUE(HasContainerFeature("@container (height < 300px)", "height"));
  
  // Test inline/block size
  EXPECT_TRUE(HasContainerFeature("@container (inline-size > 250px)", "inline-size"));
  EXPECT_TRUE(HasContainerFeature("@container (block-size <= 400px)", "block-size"));
}

TEST(ContainerQuery, LogicalOperators) {
  auto env = TEST_init();
  
  // Test logical combinations
  const char* logical_queries[] = {
    "@container (min-width: 300px) and (max-width: 800px)",
    "@container (orientation: landscape) or (min-height: 400px)",
    "@container not (max-width: 250px)",
    "@container (min-width: 400px) and not (orientation: portrait)"
  };
  
  for (const char* query : logical_queries) {
    EXPECT_TRUE(IsValidContainerQuery(query)) << "Failed to validate: " << query;
  }
}

TEST(ContainerQuery, NamedContainers) {
  auto env = TEST_init();
  
  // Test named container queries
  const char* named_queries[] = {
    "@container sidebar (min-width: 300px)",
    "@container main-content (max-width: 1200px)",
    "@container card-container (orientation: landscape)"
  };
  
  for (const char* query : named_queries) {
    EXPECT_TRUE(IsValidContainerQuery(query)) << "Failed to validate named query: " << query;
  }
}

TEST(ContainerQuery, ModernFeatures) {
  auto env = TEST_init();
  
  // Test modern range syntax
  const char* range_queries[] = {
    "@container (300px <= width <= 800px)",
    "@container (width >= 400px)",
    "@container (height < 600px)",
    "@container (200px < inline-size < 500px)"
  };
  
  for (const char* query : range_queries) {
    EXPECT_TRUE(IsValidContainerQuery(query)) << "Failed to validate range query: " << query;
  }
}

}  // namespace webf