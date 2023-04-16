/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
#include "event_target.h"
#include "core/dom/container_node.h"
#include "core/dom/events/event.h"
#include "event_type_names.h"
#include "gtest/gtest.h"
#include "webf_test_env.h"

using namespace webf;

TEST(EventTarget, addEventListener) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    EXPECT_STREQ(message.c_str(), "1234");
    logCalled = true;
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div'); function f(){ console.log(1234); }; div.addEventListener('click', f); "
      "div.dispatchEvent(new Event('click'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, removeEventListener) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div'); function f(){ console.log(1234); }; div.addEventListener('click', f);"
      "div.removeEventListener('click', f); div.dispatchEvent(new Event('click'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);

  EXPECT_EQ(logCalled, false);
}

TEST(EventTarget, setNoEventTargetProperties) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "{name: 1}");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });

  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div'); div._a = { name: 1}; console.log(div._a); "
      "document.body.appendChild(div);";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, propertyEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "ƒ () 1234");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div'); "
      "div.onclick = function() { return 1234; };"
      "document.body.appendChild(div);"
      "let f = div.onclick;"
      "console.log(f, div.onclick());";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, overwritePropertyEventHandler) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {};
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  const char* code =
      "let div = document.createElement('div'); "
      "div.onclick = function() { return 1234; };"
      "div.onclick = null;"
      "console.log(div.onclick)";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, propertyEventOnWindow) {
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
      "window.onclick = function() { console.log(1234); };"
      "window.dispatchEvent(new Event('click'));";
  bridge->evaluateScript(code, strlen(code), "vm://", 0);
  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, asyncFunctionCallback) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "done");
  };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  std::string code = R"(
    const img = document.createElement('img');
    img.style.width = '100px';
    img.style.height = '100px';
    document.body.appendChild(img);
    const img2 = img.cloneNode(false);
    document.body.appendChild(img2);

    let anotherImgHasLoad = false;
    async function loadImg() {
      if (anotherImgHasLoad) {
        console.log('done');
      } else {
        anotherImgHasLoad = true;
      }
    }

    img.addEventListener('load', loadImg);
    img2.addEventListener('load', loadImg);

    img.dispatchEvent(new Event('load'));
    img2.dispatchEvent(new Event('load'));
)";
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, ClassInheritEventTarget) {
  bool static errorCalled = false;
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) { logCalled = true; };
  auto bridge = TEST_init([](int32_t contextId, const char* errmsg) {
    WEBF_LOG(VERBOSE) << errmsg;
    errorCalled = true;
  });
  auto context = bridge->GetExecutingContext();
  std::string code = std::string(R"(
 class Sample extends EventTarget {
  constructor() {
    super();
  }

  addEvent(event, fn) {
    this.addEventListener(event, fn);
  }

  removeEvent(event, fn) {
    this.removeEventListener(event, fn);
  }

  triggerEvent(event) {
    this.dispatchEvent(event);
  }
}

let s = new Sample();
let clickCount = 0;
let f = () => clickCount++;
s.addEvent('click', f);
s.triggerEvent(new Event('click'));
s.removeEvent('click', f);
s.triggerEvent(new Event('click'));
console.assert(clickCount == 1);
)");
  bridge->evaluateScript(code.c_str(), code.size(), "vm://", 0);

  EXPECT_EQ(errorCalled, false);
}

TEST(EventTarget, wontLeakWithStringProperty) {
  auto bridge = TEST_init();
  std::string code =
      "var img = new Image();\n"
      "img.any = '1234'";
  bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
}

TEST(EventTarget, globalBindListener) {
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "clicked");
  };
  auto bridge = TEST_init();
  std::string code = "addEventListener('click', () => {console.log('clicked'); }); dispatchEvent(new Event('click'))";
  bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, shouldKeepAtom) {
  auto bridge = TEST_init();
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "2");
  };
  std::string code = "addEventListener('click', () => {console.log(1)});";
  bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);
  JS_RunGC(JS_GetRuntime(bridge->GetExecutingContext()->ctx()));

  std::string code2 = "addEventListener('appear', () => {console.log(2)});";
  bridge->evaluateScript(code2.c_str(), code2.size(), "internal://", 0);

  JS_RunGC(JS_GetRuntime(bridge->GetExecutingContext()->ctx()));

  std::string code3 = "(function() { var eeee = new Event('appear'); dispatchEvent(eeee); } )();";
  bridge->evaluateScript(code3.c_str(), code3.size(), "internal://", 0);
  EXPECT_EQ(logCalled, true);
}

TEST(EventTarget, shouldWorksWithProxy) {
  auto bridge = TEST_init();
  bool static logCalled = false;
  webf::WebFPage::consoleMessageHandler = [](void* ctx, const std::string& message, int logLevel) {
    logCalled = true;
    EXPECT_STREQ(message.c_str(), "11");
  };
  std::string code = R"(
let div = document.createElement('div');
document.body.appendChild(div);
const proxy = new Proxy(div, {});

proxy.addEventListener('click', (e) => {
  console.log(11);
});

proxy.dispatchEvent(new Event('click'));

)";
  bridge->evaluateScript(code.c_str(), code.size(), "internal://", 0);

  JS_RunGC(JS_GetRuntime(bridge->GetExecutingContext()->ctx()));
  EXPECT_EQ(logCalled, true);
}