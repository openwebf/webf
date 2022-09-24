/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <atomic>
#include <cassert>
#include <thread>

#include "bindings/qjs/native_string_utils.h"
#include "core/page.h"
#include "foundation/inspector_task_queue.h"
#include "foundation/logging.h"
#include "foundation/ui_command_buffer.h"
#include "foundation/ui_task_queue.h"
#include "include/webf_bridge.h"

#if defined(_WIN32)
#define SYSTEM_NAME "windows"  // Windows
#elif defined(_WIN64)
#define SYSTEM_NAME "windows"  // Windows
#elif defined(__CYGWIN__) && !defined(_WIN32)
#define SYSTEM_NAME "windows"  // Windows (Cygwin POSIX under Microsoft Window)
#elif defined(__ANDROID__)
#define SYSTEM_NAME "android"  // Android (implies Linux, so it must come first)
#elif defined(__linux__)
#define SYSTEM_NAME "linux"                    // Debian, Ubuntu, Gentoo, Fedora, openSUSE, RedHat, Centos and other
#elif defined(__APPLE__) && defined(__MACH__)  // Apple OSX and iOS (Darwin)
#include <TargetConditionals.h>
#if TARGET_IPHONE_SIMULATOR == 1
#define SYSTEM_NAME "ios"  // Apple iOS Simulator
#elif TARGET_OS_IPHONE == 1
#define SYSTEM_NAME "ios"  // Apple iOS
#elif TARGET_OS_MAC == 1
#define SYSTEM_NAME "macos"  // Apple macOS
#endif
#else
#define SYSTEM_NAME "unknown"
#endif

// this is not thread safe
std::atomic<bool> inited{false};
std::atomic<int32_t> poolIndex{0};
int maxPoolSize = 0;

namespace {

void disposeAllPages() {
  for (int i = 0; i <= poolIndex && i < maxPoolSize; i++) {
    disposePage(i);
  }
  poolIndex = 0;
  inited = false;
}

int32_t searchForAvailableContextId() {
  for (int i = 0; i < maxPoolSize; i++) {
    if (webf::WebFPage::pageContextPool[i] == nullptr) {
      return i;
    }
  }
  return -1;
}

}  // namespace

void initJSPagePool(int poolSize) {
  // When dart hot restarted, should dispose previous bridge and clear task message queue.
  if (inited) {
    disposeAllPages();
  };
  webf::WebFPage::pageContextPool = new webf::WebFPage*[poolSize];
  for (int i = 1; i < poolSize; i++) {
    webf::WebFPage::pageContextPool[i] = nullptr;
  }

  webf::WebFPage::pageContextPool[0] = new webf::WebFPage(0, nullptr);
  inited = true;
  maxPoolSize = poolSize;
}

void disposePage(int32_t contextId) {
  assert(contextId < maxPoolSize);
  if (webf::WebFPage::pageContextPool[contextId] == nullptr)
    return;

  auto* page = static_cast<webf::WebFPage*>(webf::WebFPage::pageContextPool[contextId]);
  delete page;
  webf::WebFPage::pageContextPool[contextId] = nullptr;
}

int32_t allocateNewPage(int32_t targetContextId) {
  if (targetContextId == -1) {
    targetContextId = ++poolIndex;
  }

  if (targetContextId >= maxPoolSize) {
    targetContextId = searchForAvailableContextId();
  }

  assert(webf::WebFPage::pageContextPool[targetContextId] == nullptr &&
         (std::string("can not Allocate page at index") + std::to_string(targetContextId) +
          std::string(": page have already exist."))
             .c_str());
  auto* page = new webf::WebFPage(targetContextId, nullptr);
  webf::WebFPage::pageContextPool[targetContextId] = page;
  return targetContextId;
}

void* getPage(int32_t contextId) {
  if (!checkPage(contextId))
    return nullptr;
  return webf::WebFPage::pageContextPool[contextId];
}

bool checkPage(int32_t contextId) {
  return inited && contextId < maxPoolSize && webf::WebFPage::pageContextPool[contextId] != nullptr;
}

bool checkPage(int32_t contextId, void* context) {
  if (webf::WebFPage::pageContextPool[contextId] == nullptr)
    return false;
  auto* page = static_cast<webf::WebFPage*>(getPage(contextId));
  return page->GetExecutingContext() == context;
}

void evaluateScripts(int32_t contextId, NativeString* code, const char* bundleFilename, int startLine) {
  assert(checkPage(contextId) && "evaluateScripts: contextId is not valid");
  auto context = static_cast<webf::WebFPage*>(getPage(contextId));
  context->evaluateScript(reinterpret_cast<webf::NativeString*>(code), bundleFilename, startLine);
}

void evaluateQuickjsByteCode(int32_t contextId, uint8_t* bytes, int32_t byteLen) {
  assert(checkPage(contextId) && "evaluateScripts: contextId is not valid");
  auto context = static_cast<webf::WebFPage*>(getPage(contextId));
  context->evaluateByteCode(bytes, byteLen);
}

void parseHTML(int32_t contextId, const char* code, int32_t length) {
  assert(checkPage(contextId) && "parseHTML: contextId is not valid");
  auto context = static_cast<webf::WebFPage*>(getPage(contextId));
  context->parseHTML(code, length);
}

void reloadJsContext(int32_t contextId) {
  assert(checkPage(contextId) && "reloadJSContext: contextId is not valid");
  auto bridgePtr = getPage(contextId);
  auto context = static_cast<webf::WebFPage*>(bridgePtr);
  auto newContext = new webf::WebFPage(contextId, nullptr);
  delete context;
  webf::WebFPage::pageContextPool[contextId] = newContext;
}

NativeValue* invokeModuleEvent(int32_t contextId,
                               NativeString* moduleName,
                               const char* eventType,
                               void* event,
                               NativeValue* extra) {
  assert(checkPage(contextId) && "invokeEventListener: contextId is not valid");
  auto context = static_cast<webf::WebFPage*>(getPage(contextId));
  auto* result = context->invokeModuleEvent(reinterpret_cast<webf::NativeString*>(moduleName), eventType, event,
                                            reinterpret_cast<webf::NativeValue*>(extra));
  return reinterpret_cast<NativeValue*>(result);
}

void registerDartMethods(int32_t contextId, uint64_t* methodBytes, int32_t length) {
  assert(checkPage(contextId) && "registerDartMethods: contextId is not valid");
  auto context = static_cast<webf::WebFPage*>(getPage(contextId));
  context->registerDartMethods(methodBytes, length);
}

static WebFInfo* webfInfo{nullptr};

WebFInfo* getWebFInfo() {
  if (webfInfo == nullptr) {
    webfInfo = new WebFInfo();
    webfInfo->app_name = "WebF";
    webfInfo->app_revision = APP_REV;
    webfInfo->app_version = APP_VERSION;
    webfInfo->system_name = SYSTEM_NAME;
  }

  return webfInfo;
}

void setConsoleMessageHandler(ConsoleMessageHandler handler) {
  webf::WebFPage::consoleMessageHandler = handler;
}

void dispatchUITask(int32_t contextId, void* context, void* callback) {
  auto* page = static_cast<webf::WebFPage*>(getPage(contextId));
  assert(std::this_thread::get_id() == page->currentThread());
  reinterpret_cast<void (*)(void*)>(callback)(context);
}

void flushUITask(int32_t contextId) {
  webf::UITaskQueue::instance(contextId)->flushTask();
}

void registerUITask(int32_t contextId, Task task, void* data) {
  webf::UITaskQueue::instance(contextId)->registerTask(task, data);
};

void* getUICommandItems(int32_t contextId) {
  auto* page = static_cast<webf::WebFPage*>(getPage(contextId));
  if (page == nullptr)
    return nullptr;
  return page->GetExecutingContext()->uiCommandBuffer()->data();
}

int64_t getUICommandItemSize(int32_t contextId) {
  auto* page = static_cast<webf::WebFPage*>(getPage(contextId));
  if (page == nullptr)
    return 0;
  return page->GetExecutingContext()->uiCommandBuffer()->size();
}

void clearUICommandItems(int32_t contextId) {
  auto* page = static_cast<webf::WebFPage*>(getPage(contextId));
  if (page == nullptr)
    return;
  page->GetExecutingContext()->uiCommandBuffer()->clear();
}

void registerContextDisposedCallbacks(int32_t contextId, Task task, void* data) {
  assert(checkPage(contextId));
  auto context = static_cast<webf::WebFPage*>(getPage(contextId));
}

void registerPluginByteCode(uint8_t* bytes, int32_t length, const char* pluginName) {
  webf::ExecutingContext::pluginByteCode[pluginName] = webf::NativeByteCode{bytes, length};
}

int32_t profileModeEnabled() {
#if ENABLE_PROFILE
  return 1;
#else
  return 0;
#endif
}
