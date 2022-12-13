#include "gtest/gtest.h"
#include <quickjs/quickjs.h>
#include "debugger.h"

TEST(Debugger, helloworld) {
  JSRuntime* runtime = JS_NewRuntime();
  JSContext* ctx = JS_NewContext(runtime);

  auto on_read = [](void* udata, char* buffer, size_t length) -> size_t {
    std::cout << "read " << buffer << std::endl;
    return strlen(buffer);
  };
  auto on_write = [](void* udata, const char* buffer, size_t length) -> size_t {
    std::cout << "write " << buffer << "\n";
    return 1;
  };

  auto on_peek = [](void* udata) -> size_t {
    std::cout << "peak\n";
    return 0;
  };

  auto on_close = [](JSRuntime* rt, void* udata) -> void {
    std::cout << "close\n";
  };

  js_debugger_attach(ctx, on_read, on_write, on_peek, on_close, nullptr);

  std::string code = R"(
function f(value) {
  debugger;
  return 1 + value;
}

f(1);
)";
  JS_Eval(ctx, code.c_str(), code.size(), "demo://", JS_EVAL_TYPE_GLOBAL);
}