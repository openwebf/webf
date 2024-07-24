# OpenWebf Contributing Guide

## Prerequisites


**Install gperf**

**macOS**
```bash
brew install gperf
```

**Linux**
```bash
apt-get install gperf
```

**Windows**
```bash
choco install gperf
```

* [Node.js](https://nodejs.org/) v12.0 or later
* [Flutter](https://flutter.dev/docs/get-started/install) version in the `webf/pubspec.yaml`
* [CMake](https://cmake.org/) v3.10.0 or later
* [Xcode](https://developer.apple.com/xcode/) (10.12) or later (Running on macOS or iOS)
* [Android NDK](https://developer.android.com/studio/projects/install-ndk) version `22.1.7171670` (Running on Android)]
* [Visual Studio 2019 or above](https://visualstudio.microsoft.com/) (Running on Windows)

## Get the code:

```
git clone git@github.com:openwebf/webf.git
git submodule update --init --recursive
```

## Install

```shell
$ npm install
```

## Building bridge

> Debug is the default build type, if you want to have a release build, please add `:release` after your command.
>
> Exp: Execute `npm run build:bridge:macos:release` to build a release bridge for the macOS platform.

**Windows**

```shell
$ npm run build:bridge:windows:release
```

**macOS**

```shell
$ npm run build:bridge:macos:release
```

**linux**

```shell
$ npm run build:bridge:linux:release
```

**iOS**

```shell
$ npm run build:bridge:ios:release
```

**Android**

```shell
$ npm run build:bridge:android:release
```

### Run Example

```shell
$ cd webf/example
$ flutter run -d <platform>
```

## Run integration Test

```shell
cd integration_tests
npm run integration
```

### Run specific group of test specs in integration test

To run specify groups of test specs:

```shell
SPEC_SCOPE=DOM npm run integration // match pattern is located in `spec_group.json`
```

### Run integration test without build test apps

> Quicker start up if you changed the test specs only.

```shell
npm run integration -- --skip-build
```

### Run one test spec only

Change the `it` into `fit` to running this test spec only.

```typescript
fit('document.all', () => { 
  expect(document.all).not.toBeUndefined();
  expect(document.all.length).toBeGreaterThan(0);
});
```

