/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "style_engine.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"
#include "core/html/html_style_element.h"
#include "core/dom/document.h"
#include "core/platform/text/text_position.h"
#include "bindings/qjs/atomic_string.h"

using namespace webf;

TEST(StyleEngine, CreateSheet) {
  auto env = TEST_init([](double contextId, const char* errmsg) {});
  auto context = env->page()->executingContext();
  auto* document = MakeGarbageCollected<Document>(context);
  auto* element = MakeGarbageCollected<HTMLStyleElement>(*document);
  std::string code = R"(
    .test {
      margin: 10px;
    }
  )";
  AtomicString sheet_text(context->ctx(), code);

  document->GetStyleEngine().CreateSheet(*element, sheet_text, TextPosition::MinimumPosition());
}


