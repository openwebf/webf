/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef WEBF_CORE_CORE_INITIALIZER_H_
#define WEBF_CORE_CORE_INITIALIZER_H_

namespace webf {

class CoreInitializer {
 public:

  // Should be called by clients before trying to create Frames.
  static void Initialize();

};

}

#endif  // WEBF_CORE_CORE_INITIALIZER_H_
