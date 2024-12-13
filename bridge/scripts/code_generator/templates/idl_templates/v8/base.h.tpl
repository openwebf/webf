/*
* Copyright (C) 2019-2022 The Kraken authors. All rights reserved.
* Copyright (C) 2022-present The WebF authors. All rights reserved.
*/

#ifndef BRIDGE_<%= blob.filename.toUpperCase() %>_H
#define BRIDGE_<%= blob.filename.toUpperCase() %>_H

#include <v8/v8.h>
//#include "bindings/v8/wrapper_type_info.h"
#include "bindings/v8/generated_code_helper.h"

<%= content %>

#endif // BRIDGE_<%= blob.filename.toUpperCase() %>_H
