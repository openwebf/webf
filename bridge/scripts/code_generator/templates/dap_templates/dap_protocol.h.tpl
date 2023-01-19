// Generated from template:
//   code_generator/templates/dap_templates/dap_protocol.h.tpl
/*
 * Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef QUICKJS_DAP_PROTOCOL_H
#define QUICKJS_DAP_PROTOCOL_H

#include <inttypes.h>

// The Debug Adapter Protocol defines.
// https://microsoft.github.io/debug-adapter-protocol/specification#Base_Protocol_ProtocolMessage

<% _.forEach(blob.objects, (object) => { %>
typedef struct <%= object.name %> {
<%= generateProtocolMembers(object, dapInfoCollector) %>
} <%= object.name %>;
<% }) %>
#endif