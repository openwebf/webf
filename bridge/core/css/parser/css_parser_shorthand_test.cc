/*
 * Copyright (C) 2024 The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include <cstring>
#include "core/css/css_primitive_value.h"
#include "core/css/parser/css_parser.h"
#include "core/css/parser/css_parser_context.h"
#include "core/css/style_sheet_contents.h"
#include "core/css/style_rule.h"
#include "core/css/css_property_value_set.h"
#include "core/css/css_value.h"
#include "foundation/casting.h"
#include "test/webf_test_env.h"

namespace webf {

class CSSParserShorthandTest : public ::testing::Test {
 protected:
  void SetUp() override {
    env_ = TEST_init();
    context_ = std::make_shared<CSSParserContext>(kHTMLStandardMode);
  }
  
  void TearDown() override {
    context_.reset();
    env_.reset();
  }

  std::unique_ptr<WebFTestEnv> env_;
  std::shared_ptr<CSSParserContext> context_;
};

}  // namespace webf
