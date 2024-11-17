/*
 * Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef BRIDGE_FOUNDATION_FUNCTION_H_
#define BRIDGE_FOUNDATION_FUNCTION_H_

namespace webf {

class Function {
 public:
  virtual bool IsQJSFunction() const { return false; }
  virtual bool IsWebFNativeFunction() const { return false; }
};

}  // namespace webf

#endif  // BRIDGE_FOUNDATION_FUNCTION_H_
