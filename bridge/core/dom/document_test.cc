/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "gtest/gtest.h"
#include "core/dom/document.h"
#include "webf_test_env.h"

using namespace webf;

TEST(Document, createElement) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<div/>");
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "let div = document.createElement('div');"
      "console.log(div);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, body) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<body/>");
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code = "console.log(document.body)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, querySelectorUsesBlinkWhenEnabled) {
  bool static errorCalled = false;
  bool static logCalled = false;
  std::string static logMessage;
  errorCalled = false;
  logCalled = false;
  logMessage = "";

  webf::WebFPage::consoleMessageHandler = [](void*, const std::string& message, int) {
    logCalled = true;
    logMessage = message;
  };

  auto env = TEST_init([](double, const char*) { errorCalled = true; }, nullptr, 0, /*enable_blink=*/1);
  auto* context = env->page()->executingContext();
  TEST_runLoop(context);

  // Ensure querySelector/querySelectorAll do not fall back to Dart bindings.
  context->document()->bindingObject()->invoke_bindings_methods_from_native = nullptr;

  const char* code =
      "let div = document.createElement('div');"
      "div.id = 'a';"
      "let span = document.createElement('span');"
      "span.className = 'b';"
      "div.appendChild(span);"
      "document.body.appendChild(div);"
      "let ok1 = document.querySelector('#a') === div;"
      "let ok2 = document.querySelector('#a .b') === span;"
      "let ok3 = document.querySelectorAll('span').length === 1;"
      "let ok4 = div.querySelector('.b') === span;"
      "let ok5 = div.querySelectorAll('.b').length === 1;"
      "let errorName = '';"
      "try { document.querySelector('['); } catch (e) { errorName = e.name; }"
      "console.log(ok1 + ' ' + ok2 + ' ' + ok3 + ' ' + ok4 + ' ' + ok5 + ' ' + errorName);";

  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  TEST_runLoop(context);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
  EXPECT_STREQ(logMessage.c_str(), "true true true true true SyntaxError");
}

TEST(Document, querySelectorAllUsesBlinkWhenEnabledAndKeepsOrder) {
  bool static errorCalled = false;
  bool static logCalled = false;
  std::string static logMessage;
  errorCalled = false;
  logCalled = false;
  logMessage = "";

  webf::WebFPage::consoleMessageHandler = [](void*, const std::string& message, int) {
    logCalled = true;
    logMessage = message;
  };

  auto env = TEST_init([](double, const char*) { errorCalled = true; }, nullptr, 0, /*enable_blink=*/1);
  auto* context = env->page()->executingContext();
  TEST_runLoop(context);

  // Ensure querySelector/querySelectorAll do not fall back to Dart bindings.
  context->document()->bindingObject()->invoke_bindings_methods_from_native = nullptr;

  const char* code =
      "let d1 = document.createElement('div');"
      "d1.id = 'd1';"
      "let s1 = document.createElement('span');"
      "s1.id = 's1';"
      "let d2 = document.createElement('div');"
      "d2.id = 'd2';"
      "let s2 = document.createElement('span');"
      "s2.id = 's2';"
      "document.body.appendChild(d1);"
      "document.body.appendChild(s1);"
      "document.body.appendChild(d2);"
      "document.body.appendChild(s2);"
      "let list = document.querySelectorAll('div, #s2');"
      "let ids = '';"
      "for (let i = 0; i < list.length; i++) { ids += (i ? ',' : '') + list[i].id; }"
      "let dedup = document.querySelectorAll('div, #d1').length === 2;"
      "console.log(ids + '|' + dedup);";

  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  TEST_runLoop(context);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
  EXPECT_STREQ(logMessage.c_str(), "d1,d2,s2|true");
}

TEST(Document, querySelectorSupportsPseudoClassesAndCombinatorsWhenBlinkEnabled) {
  bool static errorCalled = false;
  bool static logCalled = false;
  std::string static logMessage;
  errorCalled = false;
  logCalled = false;
  logMessage = "";

  webf::WebFPage::consoleMessageHandler = [](void*, const std::string& message, int) {
    logCalled = true;
    logMessage = message;
  };

  auto env = TEST_init([](double, const char*) { errorCalled = true; }, nullptr, 0, /*enable_blink=*/1);
  auto* context = env->page()->executingContext();
  TEST_runLoop(context);

  // Ensure querySelector/querySelectorAll do not fall back to Dart bindings.
  context->document()->bindingObject()->invoke_bindings_methods_from_native = nullptr;

  const char* code =
      "let root = document.createElement('div');"
      "root.id = 'root';"
      "let p1 = document.createElement('p');"
      "p1.setAttribute('data-x', '1');"
      "let p2 = document.createElement('p');"
      "p2.setAttribute('data-x', '2');"
      "let s = document.createElement('span');"
      "s.className = 'c';"
      "root.appendChild(p1);"
      "root.appendChild(p2);"
      "root.appendChild(s);"
      "document.body.appendChild(root);"
      "let ok1 = document.querySelector('#root > p[data-x=\"1\"]') === p1;"
      "let ok2 = document.querySelector('#root > p[data-x=\"1\"] + p[data-x=\"2\"]') === p2;"
      "let ok3 = document.querySelector('#root > p:not([data-x=\"1\"])') === p2;"
      "let ok4 = document.querySelector('#root > p:nth-child(2)') === p2;"
      "let ok5 = root.querySelector(':scope > span.c') === s;"
      "let ok6 = root.querySelectorAll(':scope > p').length === 2;"
      "let ok7 = document.querySelector('#nope') === null;"
      "let ok8 = document.querySelectorAll('#nope').length === 0;"
      "console.log(ok1 + ' ' + ok2 + ' ' + ok3 + ' ' + ok4 + ' ' + ok5 + ' ' + ok6 + ' ' + ok7 + ' ' + ok8);";

  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  TEST_runLoop(context);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
  EXPECT_STREQ(logMessage.c_str(), "true true true true true true true true");
}

TEST(Document, appendParentWillFail) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto env = TEST_init([](double contextId, const char* errmsg) { errorCalled = true; });
  auto context = env->page()->executingContext();
  const char* code = "document.body.appendChild(document.documentElement)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, true);
  EXPECT_EQ(logCalled, false);
}

TEST(Document, createTextNode) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<div>");
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "let div = document.createElement('div');"
      "div.setAttribute('hello', 1234);"
      "document.body.appendChild(div);"
      "let text = document.createTextNode('1234');"
      "div.appendChild(text);"
      "console.log(div);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, createComment) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "<div>");
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "let div = document.createElement('div');"
      "div.setAttribute('hello', 1234);"
      "document.body.appendChild(div);"
      "let comment = document.createComment('');"
      "div.appendChild(comment);"
      "console.log(div);";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, instanceofNode) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "console.log(document instanceof Node, document instanceof Document, document instanceof EventTarget)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Document, FreedByOutOfScope) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = false;
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code = "(() => { let img = document.createElement('div');  })();";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, false);
}

TEST(Document, createElementShouldWorkWithMultipleContext) {
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};

  WebFTestEnv* env_1;

  const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";

  {
    auto env = TEST_init([](double contextId, const char* errmsg) {});
    auto context = env->page()->executingContext();
    env->page()->evaluateScript(code, strlen(code), "vm://", 0);
    env_1 = env.release();
  }

  {
    auto env = TEST_init([](double contextId, const char* errmsg) {});
    auto context = env->page()->executingContext();
    const char* code = "(() => { let img = document.createElement('img'); document.body.appendChild(img);  })();";
    env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  }

  env_1->page()->evaluateScript(code, strlen(code), "vm://", 0);

  delete env_1;
}

TEST(document, all) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "3 <html>");
  };
  auto env = TEST_init([](double contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = env->page()->executingContext();
  const char* code =
      "console.log(document.all.length, document.all[0]);"
      "document.body.appendChild(document.createElement('div'));"
      "console.assert(document.all.length == 4);"
      "document.body.appendChild(document.createTextNode('1111'));"
      "console.assert(document.all.length == 4);"
      "document.body.removeChild(document.body.firstChild);"
      "console.assert(document.all.length == 3)";
  env->page()->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}
