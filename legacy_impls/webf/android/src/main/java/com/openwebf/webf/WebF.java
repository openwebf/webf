package com.openwebf.webf;

import android.os.Handler;
import android.os.Looper;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.PluginRegistry;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class WebF {
  private String dynamicLibraryPath;
  private FlutterEngine flutterEngine;

  private MethodChannel.MethodCallHandler handler;
  private static Map<FlutterEngine, WebF> sdkMap = new HashMap<>();

  public WebF(FlutterEngine flutterEngine) {
    if (flutterEngine != null) {
      this.flutterEngine = flutterEngine;
      sdkMap.put(flutterEngine, this);
    } else {
      throw new IllegalArgumentException("flutter engine must not be null.");
    }
  }

  public static WebF get(FlutterEngine engine) {
    return sdkMap.get(engine);
  }

  public void registerMethodCallHandler(MethodChannel.MethodCallHandler handler) {
    this.handler = handler;
  }

  /**
   * Set the dynamic library path.
   * @param value
   */
  public void setDynamicLibraryPath(String value) {
    this.dynamicLibraryPath = value;
  }
  public String getDynamicLibraryPath() {
    return dynamicLibraryPath != null ? dynamicLibraryPath : "";
  }

  public void destroy() {
    sdkMap.remove(flutterEngine);
    flutterEngine = null;
  }
}
