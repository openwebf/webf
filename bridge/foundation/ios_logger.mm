/*
 * Copyright (C) 2024-present The OpenWebF Company. All rights reserved.
 * Licensed under GNU GPL with Enterprise exception.
 */
#if defined(IS_IOS)

#import <Foundation/Foundation.h>

extern "C" void ios_nslog(const char* cstr) {
  NSLog(@"WEBF_NATIVE_LOG: %s", cstr);
}

#endif