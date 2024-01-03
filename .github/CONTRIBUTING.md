# OpenWebf Contributing Guide

0. Prerequisites
    * [Node.js](https://nodejs.org/) v12.0 or later
    * [Flutter](https://flutter.dev/docs/get-started/install) version in the `webf/pubspec.yaml`
    * [CMake](https://cmake.org/) v3.10.0 or later
    * [Xcode](https://developer.apple.com/xcode/) (10.12) or later (Running on macOS or iOS)
    * [Android NDK](https://developer.android.com/studio/projects/install-ndk) version `22.1.7171670` (Running on Android)]
    * [Visual Studio 2019 or above](https://visualstudio.microsoft.com/) (Running on Windows)

   Get the code:
   ```
   git clone git@github.com:openwebf/webf.git
   git submodule update --init --recursive
   ```

1. Install

    ```shell
    $ npm install
    ```

2. Building bridge

    Building bridge for all supported platform (macOS, linux, iOS, Android)
    
    > Debug is the default build type, if you want to have a release build, please add `:release` after your command.
    > 
    > Exp: Execute `npm run build:bridge:macos:release` to build a release bridge for the macOS platform.

    ```shell
    $ npm run build:bridge:all:release
    ```

    Building bridge for one platform
    
    
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

3. Start example
    ```shell
    $ cd webf/example
    $ flutter run
    ```

4. Test (Unit Test and Integration Test)
    ```shell
    $ npm test
    ```

