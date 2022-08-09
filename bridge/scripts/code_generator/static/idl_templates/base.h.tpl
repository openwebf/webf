/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef KRAKENBRIDGE_<%= blob.filename.toUpperCase() %>_H
#define KRAKENBRIDGE_<%= blob.filename.toUpperCase() %>_H

#include <quickjs/quickjs.h>
#include "bindings/qjs/wrapper_type_info.h"
#include "bindings/qjs/generated_code_helper.h"

<%= content %>

#endif //KRAKENBRIDGE_<%= blob.filename.toUpperCase() %>T_H
