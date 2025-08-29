package com.openwebf.webf;

import android.content.Context;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * WebFPlugin
 */
public class WebFPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  public MethodChannel channel;
  private FlutterEngine flutterEngine;
  private Context mContext;
  private WebF mWebF;



  @Override
  public void onAttachedToEngine(FlutterPluginBinding flutterPluginBinding) {
    loadLibrary();
    mContext = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "webf");
    flutterEngine = flutterPluginBinding.getFlutterEngine();
    channel.setMethodCallHandler(this);
  }

  WebF getWebF() {
    if (mWebF == null) {
      mWebF = WebF.get(flutterEngine);
    }
    return mWebF;
  }

  private static boolean isLibraryLoaded = false;
  private static void loadLibrary() {
    if (isLibraryLoaded) {
      return;
    }
    // Loads `libwebf.so`.
    System.loadLibrary("webf");
    // Loads `libquickjs.so`.
    System.loadLibrary("quickjs");
    isLibraryLoaded = true;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "getDynamicLibraryPath": {
        WebF webf = getWebF();
        result.success(webf == null ? "" : webf.getDynamicLibraryPath());
        break;
      }
      case "getTemporaryDirectory":
        result.success(getTemporaryDirectory());
        break;
      default:
        result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    WebF webf = WebF.get(flutterEngine);
    if (webf == null) return;
    webf.destroy();
    flutterEngine = null;
  }

  private String getTemporaryDirectory() {
    return mContext.getCacheDir().getPath() + "/WebF";
  }
}
