/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "html_style_element.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(HTMLStyleElement, appendStyleToDocument) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "1234");
    logCalled = true;
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code = R"(
  const style = document.createElement('style');
  style.innerHTML = `
.container {
  width: 20px;
  height: 20px;
  border: 1px solid #000;
}
`;
  document.head.appendChild(style);

  const div = document.createElement('div');
  div.className = 'container';
  document.body.appendChild(div);
)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(HTMLStyleElement, documentStyleSheetsInsertRule) {
  bool static errorCalled = false;
  errorCalled = false;
  auto env = TEST_init(
      [](double contextId, const char* errmsg) {
        WEBF_LOG(VERBOSE) << errmsg;
        errorCalled = true;
      },
      nullptr, 0,
      /*enable_blink=*/1);

  const char* code = R"(
  const style = document.createElement('style');
  style.innerHTML = `.a { color: red; } .b { color: blue; }`;
  document.head.appendChild(style);

  if (!document.styleSheets || document.styleSheets.length !== 1) {
    throw new Error('document.styleSheets is not available');
  }

  const sheet = document.styleSheets[0];
  if (!sheet) {
    throw new Error('document.styleSheets[0] is null');
  }

  // Access one existing rule to ensure CSSOM wrapper cache contains gaps.
  // This used to crash when insertRule shifted a vector of Member<CSSRule>
  // that contained null entries.
  const firstRule = sheet.cssRules[0];
  if (!firstRule) {
    throw new Error('sheet.cssRules[0] is null');
  }

  const before = sheet.cssRules.length;
  sheet.insertRule(`.b { color: blue; }`, 0);
  const after = sheet.cssRules.length;

  if (after !== before + 1) {
    throw new Error('insertRule did not insert a rule');
  }
)";

  env->page()->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(HTMLStyleElement, documentStyleSheetsInsertRuleCopyOnWrite) {
  bool static errorCalled = false;
  errorCalled = false;
  auto env = TEST_init(
      [](double contextId, const char* errmsg) {
        WEBF_LOG(VERBOSE) << errmsg;
        errorCalled = true;
      },
      nullptr, 0,
      /*enable_blink=*/1);

  auto* context = env->page()->executingContext();
  const char* code = R"(
  // Two empty <style> elements share the same cached StyleSheetContents. This
  // forces CSSStyleSheet::insertRule to take the copy-on-write path.
  const styleA = document.createElement('style');
  const styleB = document.createElement('style');
  document.head.appendChild(styleA);
  document.head.appendChild(styleB);

  if (!document.styleSheets || document.styleSheets.length !== 2) {
    throw new Error('document.styleSheets is not available');
  }

  const sheetA = document.styleSheets[0];
  const sheetB = document.styleSheets[1];
  if (!sheetA || !sheetB) {
    throw new Error('document.styleSheets contains null entries');
  }

  // Mutate both sheets; each must safely detach from the shared cached contents.
  sheetA.insertRule(`.cow-a { color: red; }`, 0);
  sheetB.insertRule(`.cow-b { color: blue; }`, 0);
)";

  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  TEST_runLoop(context);

  EXPECT_EQ(errorCalled, false);
}

TEST(HTMLStyleElement, documentStyleSheetsInsertRuleAsyncMicrotask) {
  bool static errorCalled = false;
  errorCalled = false;
  auto env = TEST_init(
      [](double contextId, const char* errmsg) {
        WEBF_LOG(VERBOSE) << errmsg;
        errorCalled = true;
      },
      nullptr, 0,
      /*enable_blink=*/1);

  auto* context = env->page()->executingContext();
  const char* code = R"(
  (async () => {
    const style = document.createElement('style');
    style.innerHTML = `.a { color: red; } .b { color: blue; }`;
    document.head.appendChild(style);

    await new Promise((resolve) => requestAnimationFrame(resolve));

    if (!document.styleSheets || document.styleSheets.length !== 1) {
      throw new Error('document.styleSheets is not available');
    }

    const sheet = document.styleSheets[0];
    if (!sheet) {
      throw new Error('document.styleSheets[0] is null');
    }

    // Create a gapped wrapper cache, then mutate rules from an async continuation.
    const firstRule = sheet.cssRules[0];
    if (!firstRule) {
      throw new Error('sheet.cssRules[0] is null');
    }

    await Promise.resolve();

    sheet.insertRule(`.b { color: blue; }`, 0);
  })();
)";

  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  TEST_runLoop(context);

  EXPECT_EQ(errorCalled, false);
}

TEST(HTMLStyleElement, documentStyleSheetsComputedStyleAfterStyleRemoval) {
  bool static errorCalled = false;
  errorCalled = false;
  auto env = TEST_init(
      [](double contextId, const char* errmsg) {
        WEBF_LOG(VERBOSE) << errmsg;
        errorCalled = true;
      },
      nullptr, 0,
      /*enable_blink=*/1);

  auto* context = env->page()->executingContext();
  const char* code = R"(
  (async () => {
    const styleA = document.createElement('style');
    const styleB = document.createElement('style');
    document.head.appendChild(styleA);
    document.head.appendChild(styleB);

    await new Promise((resolve) => requestAnimationFrame(resolve));

    if (!document.styleSheets || document.styleSheets.length !== 2) {
      throw new Error('document.styleSheets is not available');
    }

    const sheetA = document.styleSheets[0];
    const sheetB = document.styleSheets[1];

    sheetA.insertRule(`.sheet-order-target { color: rgb(255, 0, 0); }`, 0);
    sheetB.insertRule(`.sheet-order-target { color: rgb(0, 128, 0); }`, 0);

    const target = document.createElement('div');
    target.className = 'sheet-order-target';
    target.textContent = 'target';
    document.body.appendChild(target);

    await new Promise((resolve) => requestAnimationFrame(resolve));
    void getComputedStyle(target).color;

    styleB.remove();
    await new Promise((resolve) => requestAnimationFrame(resolve));
    void getComputedStyle(target).color;

    styleA.remove();
    target.remove();
    await new Promise((resolve) => requestAnimationFrame(resolve));
  })();
)";

  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  TEST_runLoop(context);

  EXPECT_EQ(errorCalled, false);
}
