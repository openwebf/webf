/*
 * Copyright (C) 2020-present The Kraken authors. All rights reserved.
 */

#ifndef KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H
#define KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H

namespace kraken::debugger {
class ProtocolHandler {
public:
  virtual ~ProtocolHandler() {}
  virtual void handlePageReload() = 0;
};
} // namespace kraken

#endif // KRAKEN_DEBUGGER_PROTOCOL_HANDLER_H
