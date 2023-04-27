/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "core/dom/legacy/bounding_client_rect.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"
using namespace webf;

TEST(Element, setAttribute) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "1234");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "div.setAttribute('hello', 1234);"
      "document.body.appendChild(div);"
      "console.log(div.getAttribute('hello'))";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Element, getAttribute) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "helloworld");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "let string = 'helloworld';"
      "let string2 = 'helloworld';"
      "div.setAttribute('hello', '456');"
      "div.setAttribute('hello', string);"
      "let otherDiv = div.cloneNode(true);"
      "otherDiv.setAttribute('hello', string2);"
      "document.body.appendChild(div);"
      "console.log(div.getAttribute('hello'));"
      "console.log(otherDiv.getAttribute('hello'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Element, setAttributeWithHTML) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "100%");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "div.innerHTML = '<img src=\"https://miniapp-nikestore-demo.oss-cn-beijing.aliyuncs.com/white_shoes_v1.png\" "
      "style=\"width:100%;height:auto;\">';"
      "console.log(div.firstChild.style.width);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(Element, outerHTML) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
#if WIN32
    EXPECT_STREQ(message.c_str(),
                 "<div attr-key=\"attr-value\" style=\"width: 100px;height: 100px;\"></div>  <div "
                 "attr-key=\"attr-value\" style=\"width: 100px;height: 100px;\"></div>");
#else
    EXPECT_STREQ(message.c_str(),
                 "<div attr-key=\"attr-value\" style=\"height: 100px;width: 100px;\"></div>  <div "
                 "attr-key=\"attr-value\" style=\"height: 100px;width: 100px;\"></div>");
#endif
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  std::string code = R"(
const div = document.createElement('div');
div.style.width = '100px';
div.style.height = '100px';
div.setAttribute('attr-key', 'attr-value');

document.body.appendChild(div);
console.log(div.outerHTML, div.innerHTML, document.body.innerHTML);
)";
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(Element, style) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true false");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  const char* code = "console.log('borderTop' in document.body.style, 'borderXXX' in document.body.style)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(Element, instanceofNode) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "console.log(div instanceof Node)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Element, instanceofEventTarget) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "console.log(div instanceof EventTarget)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}