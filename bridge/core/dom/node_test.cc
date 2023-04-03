/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(Node, appendChild) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "true true true");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "document.body.appendChild(div);"
      "console.log(document.body.firstChild === div, document.body.lastChild === div, div.parentNode === "
      "document.body);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, nodeName) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "DIV #text #document-fragment #comment #document");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "let text = document.createTextNode('helloworld');"
      "let fragment = document.createDocumentFragment();"
      "let comment = document.createComment('');"
      "console.log(div.nodeName, text.nodeName, fragment.nodeName, comment.nodeName, document.nodeName)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, childNodes) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "true true true true");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  MemberMutationScope scope{context};
  const char* code =
      "let div1 = document.createElement('div');"
      "let div2 = document.createElement('div');"
      "document.body.appendChild(div1);"
      "document.body.appendChild(div2);"
      "console.log("
      "document.body.childNodes[0] === div1,"
      "document.body.childNodes[1] === div2,"
      "div1.nextSibling === div2,"
      "div2.previousSibling === div1)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, textNodeHaveEmptyChildNodes) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let text = document.createTextNode('helloworld');"
      "console.log(text.childNodes);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, textContent) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "1234helloworld");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let text1 = document.createTextNode('1234');"
      "let text2 = document.createTextNode('helloworld');"
      "let div = document.createElement('div');"
      "div.appendChild(text1);"
      "div.appendChild(text2);"
      "console.log(div.textContent)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, setTextContent) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "1234");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "div.textContent = '1234';"
      "console.log(div.textContent);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, ensureDetached) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "true true");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) { errorCalled = true; });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div');"
      "document.body.appendChild(div);"
      "let container = document.createElement('div');"
      "container.appendChild(div);"
      "document.body.appendChild(container);"
      "console.log(document.body.firstChild === container, container.firstChild === div);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, replaceBody) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  //  const char* code = "let newbody = document.createElement('body'); document.documentElement.replaceChild(newbody,
  //  document.body)";
  const char* code = "document.body = document.createElement('body');";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(Node, cloneNode) {
  std::string code = R"(
 const div = document.createElement('div');
 div.style.width = '100px';
 div.style.height = '100px';
 div.style.backgroundColor = 'yellow';
 let str = '1234';
 div.setAttribute('id', str);
 document.body.appendChild(div);

 const div2 = div.cloneNode(true);
 document.body.appendChild(div2);

 div2.setAttribute('id', '456');

 console.log(div.style.width == div2.style.height, div.getAttribute('id') == '1234', div2.getAttribute('id') ==
 '456');
)";

  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, nestedNode) {
  std::string code = R"(
 const div = document.createElement('div');
 div.style.width = '100px';
 div.style.height = '100px';
 div.style.backgroundColor = 'green';
 div.setAttribute('id', '123');
 document.body.appendChild(div)

 const child = document.createElement('div');
 child.style.width = '10px';
 child.style.height = '10px';
 child.style.backgroundColor = 'blue';
 child.setAttribute('id', 'child123');
 div.appendChild(child);

 const child2 = document.createElement('div');
 child2.style.width = '10px';
 child2.style.height = '10px';
 child2.style.backgroundColor = 'yellow';
 child2.setAttribute('id', 'child123');
 div.appendChild(child2);

 const div2 = div.cloneNode(true);
 document.body.appendChild(div2);

 console.log(
  div2.firstChild.getAttribute('id') === 'child123', div2.firstChild.style.width === '10px',
  div2.firstChild.style.height === '10px'
);
)";

  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(Node, isConnected) {
  std::string code = R"(
const el = document.createElement('div');
console.assert(el.isConnected == false);
document.body.appendChild(el);
console.assert(el.isConnected == true);

const child_0 = document.createTextNode('first child');
el.appendChild(child_0);
console.assert(el.firstChild === child_0);
console.assert(el.lastChild === child_0);

const child_1 = document.createTextNode('second child');
el.appendChild(child_1);
console.assert(child_1.previousSibling === child_0);
console.assert(child_0.nextSibling === child_1);

el.removeChild(child_0);
const child_2 = document.createTextNode('third child');

el.insertBefore(child_2, child_1);
const child_3 = document.createTextNode('fourth child');
el.replaceChild(child_3, child_1);
)";

  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, false);
}

TEST(Node, isConnectedWhenRemove) {
  std::string code = R"(
const el = document.createElement('div');
document.body.appendChild(el);
console.assert(el.isConnected);
el.remove();
console.assert(el.isConnected == false);
)";

  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "true true true");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, false);
}