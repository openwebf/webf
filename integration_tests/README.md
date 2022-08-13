# WebF integration tests

## Dart Unit test

1. Simply use flutter test command.
2. More to see https://flutter.dev/docs/cookbook/testing/unit/introduction
3. Package test usage: https://pub.dev/packages/test

## JS API Unit Test

1. An JS wrapper of dart unit test framework.
2. Similar to jest framework usage.
3. Support most jest framework apis: `describe`, `it`, `beforeEach`, `afterEach`, `beforeAll`, `afterAll`.
4. Support async operation by return a promise object from `it`.

## Integration test

1. We use flutter integration test to inject a running app.dart.
2. Each js file in fixtures is a test case payload.
3. Each case executed in serial.
4. app_test.dart will drive app.dart to run the test.
5. Compare detection screenshot content.
6. More to see https://flutter.dev/docs/cookbook/testing/integration/introduction

### How to write

The easist way is copy test case from [wpt](https://github.com/web-platform-tests/wpt).

You also write test case script if wpt is not suitable.

1. Create typescript file in `specs` folder.
2. Use describe and it to write test case like jasmine.
3. Use `snapshot()` at the end of `it` to assert.

Tips:

1. You can use `xit` to skip current test or `fit` to focus current test.
2. Every snapshot file is stored at `snapshots` folder. Plases commit those file.
3. You can use `WEBF_TEST_FILTER` shell env to filter test to run. Like `WEBF_TEST_FILTER="foo" npm run integration`.

## Usage

+ **intergration test**: npm run test

### For MacBook Pro 16 inc Users (with dedicated AMD GPU)

Use the following commands to switch your GPU into Intel's integration GPU.

```
sudo pmset -a gpuswitch 0
```

+ 0: Intel's GPU only
+ 1: AMD GPU only
+ 2: dynamic switch

### Run single spec

this above command will execute which spec's name contains "synthesized-baseline-flexbox-001"
```
 WEBF_TEST_FILTER="synthesized-baseline-flexbox-001" npm run integration
```
