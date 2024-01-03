#include "include/webf/webf_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

// For getPlatformVersion; remove unless needed for your plugin implementation.
#include <VersionHelpers.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <map>
#include <memory>
#include <sstream>

namespace {

class WebfPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WebfPlugin();

  virtual ~WebfPlugin();

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void WebfPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows *registrar) {
  auto channel =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          registrar->messenger(), "webf",
          &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<WebfPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto &call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

WebfPlugin::WebfPlugin() {}

WebfPlugin::~WebfPlugin() {}

std::string tcharVecToString(const std::vector<TCHAR>& tcharVec) {
#if defined(UNICODE) || defined(_UNICODE)
    int requiredSize = WideCharToMultiByte(CP_UTF8, 0, tcharVec.data(), -1, nullptr, 0, nullptr, nullptr);
    std::string result(requiredSize, '\0');
    WideCharToMultiByte(CP_UTF8, 0, tcharVec.data(), -1, &result[0], requiredSize, nullptr, nullptr);
    result.resize(requiredSize - 1); // Remove null terminator
#else
    std::string result(tcharVec.begin(), tcharVec.end());
#endif
    return result;
}

void WebfPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue> &method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("getTemporaryDirectory") == 0) {
     // Get the required buffer size for the temporary directory path
    DWORD bufferSize = GetTempPath(0, nullptr);
    
    // Allocate a buffer to store the temporary directory path
    std::vector<TCHAR> tempDirPath(bufferSize);

    // Get the temporary directory path
    GetTempPath(bufferSize, (TCHAR*) tempDirPath.data());
    result->Success(flutter::EncodableValue(tcharVecToString(tempDirPath)));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void WebfPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  WebfPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
