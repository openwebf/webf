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
