/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';

export interface NavigatorInterface {
  readonly userAgent: string;
  readonly platform: string;
  readonly language: string;
  readonly languages: string[];
  readonly appName: string;
  readonly appVersion: string;
  readonly hardwareConcurrency: number;
  readonly clipboard: {
    readText(): Promise<string>;
    writeText(text: string): Promise<void>;
  };
}

export const navigator: NavigatorInterface = {
  // UA is read-only.
  get userAgent() {
    return webf.invokeModule('Navigator', 'getUserAgent');
  },
  get platform() {
    return webf.invokeModule('Navigator', 'getPlatform');
  },
  get language() {
    return webf.invokeModule('Navigator', 'getLanguage');
  },
  get languages() {
    return JSON.parse(webf.invokeModule('Navigator', 'getLanguages'));
  },
  get appName() {
    return webf.invokeModule('Navigator', 'getAppName');
  },
  get appVersion() {
    return webf.invokeModule('Navigator', 'getAppVersion');
  },
  get hardwareConcurrency() {
    const logicalProcessors = webf.invokeModule('Navigator', 'getHardwareConcurrency');
    return parseInt(logicalProcessors);
  },
  clipboard: {
    readText() {
      return webf.invokeModuleAsync('Clipboard', 'readText', null);
    },
    writeText(text: string) {
      return webf.invokeModuleAsync('Clipboard', 'writeText', String(text));
    }
  }
}
