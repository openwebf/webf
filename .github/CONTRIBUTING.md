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
* [Visual Studio 2019 or later](https://visualstudio.microsoft.com/) (Running on Windows)
* [Rust](https://www.rust-lang.org/) (For building Rust example apps.)

## Get the code:

**Additional configuration for Windows users**

```
git config --global core.symlinks true
git config --global core.autocrlf false
```


```
git clone git@github.com:openwebf/webf.git
git submodule update --init --recursive
```

## Install

```shell
$ npm install
```

## Prepare

**Windows, Linux, Android**

The current C/C++ code build process has been integrated into Flutter's compilation and build pipeline for Windows, Linux, and Android.

Run the following script to generate C/C++ binding code using the code generator:

```shell
npm run generate_binding_code
```

---

**iOS and macOS**

> The default build type is Debug. To create a release build, add `:release` to your command.  
>  
> Example: Execute `npm run build:bridge:macos:release` to build a release bridge for macOS.

```shell
$ npm run build:bridge:ios:release    # iOS
$ npm run build:bridge:macos:release  # macOS
```

--- 


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

