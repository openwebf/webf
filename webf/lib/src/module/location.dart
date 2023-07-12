/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */
import 'package:webf/module.dart';

class LocationModule extends BaseModule {
  @override
  String get name => 'Location';

  LocationModule(ModuleManager? moduleManager) : super(moduleManager);

  String get href => moduleManager!.controller.url;

  String get origin => moduleManager?.controller.uri?.origin ?? '';
  String get protocol => moduleManager?.controller.uri?.scheme ?? '';
  String get port => moduleManager?.controller.uri?.port.toString() ?? '';
  String get hostname => moduleManager?.controller.uri?.host ?? '';
  String get host => hostname + ':' + port;
  String get pathname => moduleManager?.controller.uri?.path ?? '';
  String get search => moduleManager?.controller.uri?.query ?? '';
  String get hash => moduleManager?.controller.uri?.fragment ?? '';

  @override
  String invoke(String method, params, InvokeModuleCallback callback) {
    switch (method) {
      case 'href':
        return href;
      case 'origin':
        return origin;
      case 'protocol':
        return protocol;
      case 'host':
        return host;
      case 'hostname':
        return hostname;
      case 'port':
        return port;
      case 'pathname':
        return pathname;
      case 'search':
        return search;
      case 'hash':
        return hash;
      default:
        return '';
    }
  }

  @override
  void dispose() {}
}
