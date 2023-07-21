/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

import { webf } from './webf';
import { webfLocationReload } from './bridge';

class Location {
  get href() {
    return webf.invokeModule('Location', 'href');
  }
  set href(url: string) {
    webf.invokeModule('Navigation', 'goTo', url);
  }
  get origin() {
    return webf.invokeModule('Location', 'origin');
  }
  get protocol() {
    return webf.invokeModule('Location', 'protocol');
  }
  get host() {
    return webf.invokeModule('Location', 'host');
  }
  get hostname() {
    return webf.invokeModule('Location', 'hostname');
  }
  get port() {
    return webf.invokeModule('Location', 'port');
  }
  get pathname() {
    return webf.invokeModule('Location', 'pathname');
  }
  get search() {
    return webf.invokeModule('Location', 'search');
  }
  get hash() {
    return webf.invokeModule('Location', 'hash');
  }

  get assign() {
    return (assignURL: string) => {
      webf.invokeModule('Navigation', 'goTo', assignURL);
    };
  }
  get reload() {
    return webfLocationReload.bind(this);
  }
  get replace() {
    return (replaceURL: string) => {
      webf.invokeModule('Navigation', 'goTo', replaceURL);
    };
  }
  get toString() {
    return () => location.href;
  }

}

export const location = new Location();
