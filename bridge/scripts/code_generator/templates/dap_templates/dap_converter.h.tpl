/*
* Copyright (C) 2022-present The WebF authors. All rights reserved.
 */

#ifndef QUICKJS_DAP_CONVERTER_H
#define QUICKJS_DAP_CONVERTER_H

#include <quickjs/quickjs.h>
#include "dap_protocol.h"

const char* copy_string(const char* string, size_t len);
int parse_request(JSContext* ctx, Request* request, const char* buf, size_t length);
const char* stringify_event(JSContext* ctx, Event* event, size_t* length);
void* initialize_event(JSContext* ctx, const char* type);
void* initialize_response(JSContext* ctx, const Request* corresponding_request, const char* type);
const char* stringify_response(JSContext* ctx, Response* response);

#endif