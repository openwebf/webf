/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#include <benchmark/benchmark.h>
#include "webf_test_env.h"

using namespace webf;

auto env = TEST_init();

static void CreateRawJavaScriptObjects(benchmark::State& state) {
  auto context = env->page()->executingContext();
  uint8_t bytes[] = {1, 2, 2, 97, 12, 97, 97,  97, 46, 106, 115, 14, 0,   6, 0, 160, 1,  0,  1,
                     0, 1, 0, 0,  20, 1,  162, 1,  0,  0,   0,   63, 210, 0, 0, 0,   0,  62, 210,
                     0, 0, 0, 0,  11, 57, 210, 0,  0,  0,   195, 40, 166, 3, 1, 2,   31, 33};
  // Perform setup here
  for (auto _ : state) {
    context->EvaluateByteCode(bytes, sizeof(bytes));
  }
}

static void CreateDivElement(benchmark::State& state) {
  auto context = env->page()->executingContext();
  std::string code = R"(
(() => {
let container = document.createElement('div');
for(let i = 0; i < 1000; i ++) {
    let child = document.createElement('div');
    for(let j = 0; j < 10; j ++) {
        let span = document.createElement('span');
        let text = document.createElement('helloworld');
        span.appendChild(text);
        child.appendChild(span);
    }
    container.appendChild(child);
}
})();
)";
  // Perform setup here
  for (auto _ : state) {
    context->EvaluateJavaScript(code.c_str(), code.size(), "internal://", 0);
  }
}

static void InsertElement(benchmark::State& state) {
  auto context = env->page()->executingContext();
  std::string code = R"(
(() => {
let container = document.createElement('div');
let child = document.createElement('div');
let span = document.createElement('span');
let text = document.createElement('helloworld');
span.appendChild(text);
container.appendChild(child);

for(let i = 0; i < 1000; i ++) {
    let span = document.createElement('span');
    let text = document.createElement('helloworld');
    span.appendChild(text);
    child.insertBefore(span, child.firstChild);
}
})();
)";
  // Perform setup here
  for (auto _ : state) {
    context->EvaluateJavaScript(code.c_str(), code.size(), "internal://", 0);
  }
}

BENCHMARK(CreateRawJavaScriptObjects)->Threads(1);
BENCHMARK(CreateDivElement)->Threads(1);
BENCHMARK(InsertElement)->Threads(1);

// Run the benchmark
BENCHMARK_MAIN();
